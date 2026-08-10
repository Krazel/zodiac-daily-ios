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
const CACHE_SCHEMA_VERSION = 2;
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
      env?.FREEASTRO_API_KEY && env?.DAILY_CACHE && env?.WARMUP_QUEUE,
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
  if (!isISODate(date)) {
    return jsonResponse(
      { error: { code: "invalid_date", message: "Use a real date in YYYY-MM-DD format." } },
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
    const payload = await getCachedDaily(date, env);

    return jsonResponse(payload, 200, {
      "Cache-Control": "public, max-age=300, s-maxage=3600, stale-if-error=86400",
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

export async function getCachedDaily(date, env) {
  const cacheKey = dailyCacheKey(date);
  const cached = await readPayload(env.DAILY_CACHE, cacheKey);
  if (cached && isValidBundle(cached, date)) return cached;
  throw new Error("daily_cache_miss");
}

export async function warmDate(date, env, options = {}) {
  if (!env?.DAILY_CACHE || !env?.FREEASTRO_API_KEY) {
    throw new Error("service_not_configured");
  }

  try {
    return { payload: await getCachedDaily(date, env), cache: "hit" };
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
  const cooldown = await env.DAILY_CACHE.get(failureCacheKey(date));
  if (cooldown) throw new Error("provider_cooldown");

  try {
    const payload = await fetchProviderBundle(date, env.FREEASTRO_API_KEY, options);
    if (!isValidBundle(payload, date)) throw new Error("invalid_normalized_bundle");

    await Promise.all([
      env.DAILY_CACHE.put(dailyCacheKey(date), JSON.stringify(payload), {
        expirationTtl: DAILY_TTL_SECONDS,
      }),
      env.DAILY_CACHE.put(lastValidCacheKey(), JSON.stringify(payload)),
    ]);

    return { payload, cache: "miss" };
  } catch {
    try {
      await env.DAILY_CACHE.put(failureCacheKey(date), "1", {
        expirationTtl: FAILURE_COOLDOWN_SECONDS,
      });
    } catch {
      // A failed cooldown write must not hide the original provider failure.
    }
    // The last-valid record is retained for diagnosis only. Serving a previous
    // date as today's edition would violate the product promise, so the app
    // receives 503 and activates its bundled, date-specific fallback instead.
    throw new Error("provider_refresh_failed");
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
    requested_date: date,
    content_date: date,
    generated_at: now.toISOString(),
    stale: false,
    provider: "freeastroapi",
    horoscopes,
  };
}

export function normalizeProviderResponse(body, expectedSign, expectedDate) {
  const data = body?.data ?? body;
  const sign = cleanString(data?.sign)?.toLowerCase();
  const date = cleanString(data?.date);
  const reading = cleanString(data?.content?.text ?? data?.text ?? data?.horoscope);
  const theme = cleanString(data?.content?.theme ?? data?.theme);
  const keywords = cleanStringArray(data?.content?.keywords);
  const scores = data?.scores;
  const luckyColor = cleanString(data?.lucky?.color?.label);
  const luckyNumber = data?.lucky?.number;
  const moonSign = cleanString(data?.astro?.moon_sign?.label);
  const moonPhase = cleanString(data?.astro?.moon_phase?.label);

  if (sign !== expectedSign) throw new Error("provider_sign_mismatch");
  if (date !== expectedDate) throw new Error("provider_date_mismatch");
  if (!reading || reading.length < 40 || reading.length > 2_000) {
    throw new Error("provider_invalid_text");
  }
  if (!theme || theme.length > 100) throw new Error("provider_invalid_theme");
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

export function isValidBundle(value, expectedContentDate) {
  if (!value || value.schema_version !== CACHE_SCHEMA_VERSION) return false;
  if (value.requested_date !== expectedContentDate || value.content_date !== expectedContentDate) return false;
  if (value.stale !== false || value.provider !== "freeastroapi") return false;
  if (typeof value.generated_at !== "string" || Number.isNaN(Date.parse(value.generated_at))) return false;
  if (!Array.isArray(value.horoscopes) || value.horoscopes.length !== SIGNS.length) return false;

  const signs = new Set();
  for (const horoscope of value.horoscopes) {
    if (!SIGNS.includes(horoscope?.sign) || signs.has(horoscope.sign)) return false;
    if (!cleanString(horoscope.headline) || !cleanString(horoscope.reading)) return false;
    if (horoscope.headline.length > 160) return false;
    if (horoscope.reading.length < 40 || horoscope.reading.length > 2_000) return false;
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

function dailyCacheKey(date) {
  return `daily:v${CACHE_SCHEMA_VERSION}:${date}`;
}

function lastValidCacheKey() {
  return `last-valid:v${CACHE_SCHEMA_VERSION}`;
}

function failureCacheKey(date) {
  return `failure:v${CACHE_SCHEMA_VERSION}:${date}`;
}

function cleanString(value) {
  return typeof value === "string" ? value.trim() : null;
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

export { SIGNS };
