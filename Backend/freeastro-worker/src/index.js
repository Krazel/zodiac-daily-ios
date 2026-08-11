const SIGNS = Object.freeze([
  "aries",
  "taurus",
  "gemini",
  "cancer",
  "leo",
  "virgo",
  "libra",
  "scorpio",
  "sagittarius",
  "capricorn",
  "aquarius",
  "pisces",
]);

const UPSTREAM_URL = "https://api.freeastroapi.com/api/v2/horoscope/daily/sign";
const TRANSLATION_MODEL = "@cf/meta/m2m100-1.2b";
const CACHE_SCHEMA_VERSION = 3;
const LANGUAGES = Object.freeze(["en", "es"]);
const MAX_HEADLINE_CHARACTERS = 52;
const MIN_READING_CHARACTERS = 40;
// Live FreeAstroAPI editions currently sit around 324-382 characters. This
// guard remains bounded while accepting the provider's real daily copy.
const MAX_READING_CHARACTERS = 500;
const MAX_TRANSLATED_HEADLINE_CHARACTERS = 72;
const MAX_TRANSLATED_READING_CHARACTERS = 700;
const DAILY_TTL_SECONDS = 400 * 24 * 60 * 60;
const FAILURE_COOLDOWN_SECONDS = 5 * 60;
const PROVIDER_INTERVAL_MS = 1_050;
const inFlight = new Map();

export default {
  fetch(request, env, context) {
    return handleRequest(request, env, { context });
  },

  async scheduled(controller, env, context) {
    context.waitUntil(handleScheduled(controller, env));
  },

  async queue(batch, env) {
    await handleQueue(batch, env, {
      fetchImpl: fetch,
      now: () => new Date(),
      wait: sleep,
    });
  },
};

export async function handleScheduled(controller, env) {
  if (!env?.WARMUP_QUEUE) throw new Error("warmup_queue_not_configured");
  const date = scheduledTargetDate(controller.scheduledTime, controller.cron);
  await env.WARMUP_QUEUE.send({ schema_version: CACHE_SCHEMA_VERSION, date });
}

export async function handleQueue(batch, env, options = {}) {
  for (const message of batch.messages) {
    const body = message?.body;
    if (body?.schema_version !== CACHE_SCHEMA_VERSION || !isISODate(body?.date)) {
      message?.ack?.();
      continue;
    }

    await warmDate(body.date, env, options);
    message?.ack?.();
  }
}

export async function handleRequest(request, env, options = {}) {
  const url = new URL(request.url);

  if (request.method !== "GET") {
    return jsonResponse(
      { error: { code: "method_not_allowed", message: "Only GET is supported." } },
      405,
      { Allow: "GET" },
    );
  }

  if (url.pathname === "/health") {
    const configured = Boolean(
      secretValue(env?.FREEASTRO_API_KEY) && env?.DAILY_CACHE && env?.WARMUP_QUEUE && env?.AI,
    );
    return jsonResponse(
      {
        status: configured ? "ok" : "configuration_required",
        service: "zodiac-daily-content",
        schema_version: CACHE_SCHEMA_VERSION,
      },
      configured ? 200 : 503,
      { "Cache-Control": "no-store" },
    );
  }

  const legacyMatch = url.pathname.match(/^\/v1\/daily\/([^/]+)$/);
  const isAppRoute = url.pathname === "/v1/horoscopes/daily";
  if (!legacyMatch && !isAppRoute) {
    return jsonResponse(
      { error: { code: "not_found", message: "Route not found." } },
      404,
      { "Cache-Control": "no-store" },
    );
  }

  const date = isAppRoute
    ? url.searchParams.get("date") ?? ""
    : decodeURIComponent(legacyMatch[1]);
  const language = url.searchParams.get("lang") ?? "en";
  if (!isISODate(date)) {
    return jsonResponse(
      { error: { code: "invalid_date", message: "Use a real date in YYYY-MM-DD format." } },
      400,
      { "Cache-Control": "no-store" },
    );
  }

  if (!LANGUAGES.includes(language)) {
    return jsonResponse(
      { error: { code: "unsupported_language", message: "Use lang=en or lang=es." } },
      400,
      { "Cache-Control": "no-store" },
    );
  }

  const now = options.now?.() ?? new Date();
  if (!isNearToday(date, now)) {
    return jsonResponse(
      {
        error: {
          code: "date_out_of_range",
          message: "Only today and the adjacent UTC dates are available.",
        },
      },
      400,
      { "Cache-Control": "no-store" },
    );
  }

  if (!env?.DAILY_CACHE) {
    return jsonResponse(
      { error: { code: "service_not_configured", message: "Daily content is not configured." } },
      503,
      { "Cache-Control": "no-store" },
    );
  }

  try {
    const payload = await getCachedDaily(date, env, language);

    return jsonResponse(payload, 200, {
      "Cache-Control": "public, max-age=300, s-maxage=3600, stale-if-error=86400",
      "Content-Language": language,
      "X-Zodiac-Content-State": "fresh",
    });
  } catch {
    return jsonResponse(
      {
        error: {
          code: "daily_content_unavailable",
          message: "Daily content is temporarily unavailable. Use the app's bundled edition.",
        },
      },
      503,
      { "Cache-Control": "no-store", "Retry-After": "300" },
    );
  }
}

export async function getCachedDaily(date, env, language = "en") {
  if (!LANGUAGES.includes(language)) throw new Error("unsupported_language");
  const cacheKey = dailyCacheKey(date, language);
  const cached = await readPayload(env.DAILY_CACHE, cacheKey);
  if (cached && isValidBundle(cached, date, language)) return cached;
  throw new Error("daily_cache_miss");
}

export async function warmDate(date, env, options = {}) {
  if (!env?.DAILY_CACHE || !secretValue(env?.FREEASTRO_API_KEY) || !env?.AI) {
    throw new Error("service_not_configured");
  }

  try {
    const [english, spanish] = await Promise.all([
      getCachedDaily(date, env, "en"),
      getCachedDaily(date, env, "es"),
    ]);
    return { payload: english, translations: { es: spanish }, cache: "hit" };
  } catch {
    // Only scheduled warm-up is allowed to turn a cache miss into API calls.
  }

  const active = inFlight.get(date);
  if (active) return active;

  const operation = refreshDate(date, env, options).finally(() => {
    inFlight.delete(date);
  });
  inFlight.set(date, operation);
  return operation;
}

async function refreshDate(date, env, options) {
  let english;
  let englishCache = "hit";
  try {
    english = await getCachedDaily(date, env, "en");
  } catch {
    englishCache = "miss";
    english = await refreshEnglishDate(date, env, options);
  }

  let spanish;
  let spanishCache = "hit";
  try {
    spanish = await getCachedDaily(date, env, "es");
  } catch {
    spanishCache = "miss";
    spanish = await refreshSpanishDate(english, env, options);
  }

  return {
    payload: english,
    translations: { es: spanish },
    cache: englishCache === "hit" && spanishCache === "hit" ? "hit" : "miss",
  };
}

async function refreshEnglishDate(date, env, options) {
  if (await env.DAILY_CACHE.get(failureCacheKey(date, "en"))) {
    throw new Error("provider_cooldown");
  }

  try {
    const payload = await fetchProviderBundle(
      date,
      secretValue(env.FREEASTRO_API_KEY),
      options,
    );
    if (!isValidBundle(payload, date, "en")) throw new Error("invalid_normalized_bundle");
    await writePayload(env.DAILY_CACHE, payload);
    return payload;
  } catch (error) {
    await recordFailure(env.DAILY_CACHE, date, "en");
    console.error("provider refresh failed", {
      date,
      code: error instanceof Error ? error.message : "unknown",
    });
    throw new Error("provider_refresh_failed");
  }
}

async function refreshSpanishDate(english, env, options) {
  const date = english.content_date;
  if (await env.DAILY_CACHE.get(failureCacheKey(date, "es"))) {
    throw new Error("translation_cooldown");
  }

  try {
    const payload = await translateBundleToSpanish(english, env.AI, options);
    if (!isValidBundle(payload, date, "es")) throw new Error("invalid_translated_bundle");
    await writePayload(env.DAILY_CACHE, payload);
    return payload;
  } catch (error) {
    await recordFailure(env.DAILY_CACHE, date, "es");
    console.error("translation refresh failed", {
      date,
      code: error instanceof Error ? error.message : "unknown",
    });
    throw new Error("translation_refresh_failed");
  }
}

async function writePayload(kv, payload) {
  await Promise.all([
    kv.put(dailyCacheKey(payload.content_date, payload.language), JSON.stringify(payload), {
      expirationTtl: DAILY_TTL_SECONDS,
    }),
    kv.put(lastValidCacheKey(payload.language), JSON.stringify(payload)),
  ]);
}

async function recordFailure(kv, date, language) {
  try {
    await kv.put(failureCacheKey(date, language), "1", {
      expirationTtl: FAILURE_COOLDOWN_SECONDS,
    });
  } catch {
    // A failed cooldown write must not hide the original provider/AI failure.
  }
}

export async function fetchProviderBundle(date, apiKey, options = {}) {
  if (typeof apiKey !== "string" || apiKey.trim() === "") {
    throw new Error("missing_api_key");
  }

  const fetchImpl = options.fetchImpl ?? fetch;
  const wait = options.wait ?? sleep;
  const now = options.now?.() ?? new Date();
  const horoscopes = [];

  // FreeAstroAPI currently documents one sign per request, with a free-plan
  // ceiling of one request per second. This loop turns those calls into the
  // app's single daily bulk document without exceeding that published rate.
  for (let index = 0; index < SIGNS.length; index += 1) {
    const sign = SIGNS[index];
    const url = new URL(UPSTREAM_URL);
    url.searchParams.set("sign", sign);
    url.searchParams.set("date", date);
    url.searchParams.set("tz_str", "UTC");
    url.searchParams.set("lang", "en");

    const response = await fetchImpl(url, {
      method: "GET",
      headers: {
        Accept: "application/json",
        "x-api-key": apiKey,
      },
    });

    if (!response.ok) throw new Error(`provider_http_${response.status}`);

    let body;
    try {
      body = await response.json();
    } catch {
      throw new Error("provider_invalid_json");
    }

    horoscopes.push(normalizeProviderResponse(body, sign, date));
    if (index < SIGNS.length - 1) await wait(PROVIDER_INTERVAL_MS);
  }

  return {
    schema_version: CACHE_SCHEMA_VERSION,
    language: "en",
    requested_date: date,
    content_date: date,
    generated_at: now.toISOString(),
    stale: false,
    provider: "freeastroapi",
    horoscopes,
  };
}

export async function translateBundleToSpanish(english, ai, options = {}) {
  if (!isValidBundle(english, english?.content_date, "en")) {
    throw new Error("invalid_english_bundle");
  }
  if (!ai || typeof ai.run !== "function") throw new Error("ai_not_configured");

  const now = options.now?.() ?? new Date();
  const horoscopes = [];
  for (const horoscope of english.horoscopes) {
    const headline = await translateText(horoscope.headline, ai);
    const reading = await translateText(horoscope.reading, ai);
    const keywords = [];
    for (const keyword of horoscope.details.keywords) {
      keywords.push(await translateText(keyword, ai));
    }

    horoscopes.push({
      ...horoscope,
      headline,
      reading,
      details: {
        ...horoscope.details,
        focus: headline,
        keywords,
        lucky_color: await translateText(horoscope.details.lucky_color, ai),
        moon_sign: await translateText(horoscope.details.moon_sign, ai),
        moon_phase: await translateText(horoscope.details.moon_phase, ai),
      },
    });
  }

  return {
    ...english,
    language: "es",
    generated_at: now.toISOString(),
    horoscopes,
  };
}

async function translateText(text, ai) {
  const response = await ai.run(TRANSLATION_MODEL, {
    text,
    source_lang: "en",
    target_lang: "es",
  });
  const translated = normalizeCardCopy(response?.translated_text);
  if (!translated) throw new Error("translation_invalid_response");
  return translated;
}

export function normalizeProviderResponse(body, expectedSign, expectedDate) {
  const data = body?.data ?? body;
  const sign = cleanString(data?.sign)?.toLowerCase();
  const date = cleanString(data?.date);
  const reading = normalizeCardCopy(data?.content?.text ?? data?.text ?? data?.horoscope);
  const theme = normalizeCardCopy(data?.content?.theme ?? data?.theme);
  const keywords = cleanStringArray(data?.content?.keywords);
  const scores = data?.scores;
  const luckyColor = cleanString(data?.lucky?.color?.label);
  const luckyNumber = data?.lucky?.number;
  const moonSign = cleanString(data?.astro?.moon_sign?.label);
  const moonPhase = cleanString(data?.astro?.moon_phase?.label);

  if (sign !== expectedSign) throw new Error("provider_sign_mismatch");
  if (date !== expectedDate) throw new Error("provider_date_mismatch");
  if (
    !reading ||
    reading.length < MIN_READING_CHARACTERS ||
    reading.length > MAX_READING_CHARACTERS
  ) {
    throw new Error("provider_invalid_text");
  }
  if (!theme || theme.length > MAX_HEADLINE_CHARACTERS) {
    throw new Error("provider_invalid_theme");
  }
  if (!isValidKeywordList(keywords)) throw new Error("provider_invalid_keywords");
  if (![scores?.love, scores?.career, scores?.money, scores?.health].every(isScore)) {
    throw new Error("provider_invalid_scores");
  }
  if (!luckyColor || luckyColor.length > 32 || !isIntegerInRange(luckyNumber, 1, 99)) {
    throw new Error("provider_invalid_lucky_values");
  }
  if (!moonSign || moonSign.length > 40 || !moonPhase || moonPhase.length > 40) {
    throw new Error("provider_invalid_moon_data");
  }

  return {
    sign,
    headline: theme,
    reading,
    details: {
      source: "freeastroapi-v2",
      focus: theme,
      keywords,
      love_score: scores.love,
      career_score: scores.career,
      money_score: scores.money,
      health_score: scores.health,
      lucky_color: luckyColor,
      lucky_number: luckyNumber,
      moon_sign: moonSign,
      moon_phase: moonPhase,
    },
    content_version: Number(expectedDate.replaceAll("-", "")),
  };
}

export function isValidBundle(value, expectedContentDate, expectedLanguage = "en") {
  if (!value || value.schema_version !== CACHE_SCHEMA_VERSION) return false;
  if (value.language !== expectedLanguage || !LANGUAGES.includes(value.language)) return false;
  if (value.requested_date !== expectedContentDate || value.content_date !== expectedContentDate) return false;
  if (value.stale !== false || value.provider !== "freeastroapi") return false;
  if (typeof value.generated_at !== "string" || Number.isNaN(Date.parse(value.generated_at))) return false;
  if (!Array.isArray(value.horoscopes) || value.horoscopes.length !== SIGNS.length) return false;

  const signs = new Set();
  for (const horoscope of value.horoscopes) {
    if (!SIGNS.includes(horoscope?.sign) || signs.has(horoscope.sign)) return false;
    const headline = normalizeCardCopy(horoscope.headline);
    const reading = normalizeCardCopy(horoscope.reading);
    if (!headline || !reading) return false;
    if (headline !== horoscope.headline || reading !== horoscope.reading) return false;
    const headlineLimit = expectedLanguage === "es"
      ? MAX_TRANSLATED_HEADLINE_CHARACTERS
      : MAX_HEADLINE_CHARACTERS;
    const readingLimit = expectedLanguage === "es"
      ? MAX_TRANSLATED_READING_CHARACTERS
      : MAX_READING_CHARACTERS;
    if (headline.length > headlineLimit) return false;
    if (
      reading.length < MIN_READING_CHARACTERS ||
      reading.length > readingLimit
    ) return false;
    if (!isValidProviderDetails(horoscope.details)) return false;
    if (horoscope.content_version !== Number(expectedContentDate.replaceAll("-", ""))) return false;
    signs.add(horoscope.sign);
  }

  return signs.size === SIGNS.length;
}

async function readPayload(kv, key) {
  try {
    const raw = await kv.get(key);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function dailyCacheKey(date, language) {
  return `daily:v${CACHE_SCHEMA_VERSION}:${language}:${date}`;
}

function lastValidCacheKey(language) {
  return `last-valid:v${CACHE_SCHEMA_VERSION}:${language}`;
}

function failureCacheKey(date, language) {
  return `failure:v${CACHE_SCHEMA_VERSION}:${language}:${date}`;
}

function cleanString(value) {
  return typeof value === "string" ? value.trim() : null;
}

function normalizeCardCopy(value) {
  return typeof value === "string" ? value.trim().replace(/\s+/gu, " ") : null;
}

function cleanStringArray(value) {
  return Array.isArray(value) ? value.map(cleanString).filter(Boolean) : null;
}

function isIntegerInRange(value, minimum, maximum) {
  return Number.isInteger(value) && value >= minimum && value <= maximum;
}

function isScore(value) {
  return isIntegerInRange(value, 0, 100);
}

function isValidKeywordList(value) {
  if (!Array.isArray(value) || value.length < 1 || value.length > 8) return false;
  if (value.some((keyword) => !keyword || keyword.length > 40)) return false;
  return new Set(value.map((keyword) => keyword.toLowerCase())).size === value.length;
}

function isValidProviderDetails(details) {
  if (!details || details.source !== "freeastroapi-v2") return false;
  if (!cleanString(details.focus) || details.focus.length > 100) return false;
  if (!isValidKeywordList(details.keywords)) return false;
  if (![details.love_score, details.career_score, details.money_score, details.health_score].every(isScore)) {
    return false;
  }
  if (!cleanString(details.lucky_color) || details.lucky_color.length > 32) return false;
  if (!isIntegerInRange(details.lucky_number, 1, 99)) return false;
  if (!cleanString(details.moon_sign) || details.moon_sign.length > 40) return false;
  return Boolean(cleanString(details.moon_phase) && details.moon_phase.length <= 40);
}

function isISODate(value) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const [year, month, day] = value.split("-").map(Number);
  const candidate = new Date(Date.UTC(year, month - 1, day));
  return (
    candidate.getUTCFullYear() === year &&
    candidate.getUTCMonth() === month - 1 &&
    candidate.getUTCDate() === day
  );
}

function isNearToday(date, now) {
  const requested = Date.parse(`${date}T00:00:00Z`);
  const today = Date.parse(`${toUTCDate(now)}T00:00:00Z`);
  return Math.abs(requested - today) <= 24 * 60 * 60 * 1_000;
}

function secretValue(value) {
  return typeof value === "string" ? value.trim() : "";
}

function toUTCDate(date) {
  return date.toISOString().slice(0, 10);
}

export function scheduledTargetDate(scheduledTime, cron) {
  const scheduledAt = new Date(scheduledTime);
  // At 09:45 UTC prepare tomorrow before UTC+14 reaches midnight. The
  // 00:15 UTC run normally finds today's edition already cached.
  if (cron === "45 9 * * *") {
    return toUTCDate(new Date(scheduledAt.getTime() + 24 * 60 * 60 * 1_000));
  }
  return toUTCDate(scheduledAt);
}

function sleep(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

function jsonResponse(body, status, extraHeaders = {}) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "X-Content-Type-Options": "nosniff",
      ...extraHeaders,
    },
  });
}

export { LANGUAGES, SIGNS, TRANSLATION_MODEL };
