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
// Translate the complete editorial unit in one pass. The previous M2M model
// translated each field independently, which was faithful at word level but
// produced stiff, context-free Spanish. This multilingual instruct model can
// preserve the reading as a whole and return a validated structured result.
const TRANSLATION_MODEL = "@cf/openai/gpt-oss-20b";
const TRANSLATION_REVIEW_MODEL = "@cf/meta/llama-3.1-8b-instruct-fast";
const SPANISH_COPY_REVISION = 6;
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
// Two short in-call retries absorb occasional structured-output/reviewer
// misses without returning to FreeAstroAPI. Queue retries remain the outer
// recovery layer and each message still stays far below subrequest limits.
const TRANSLATION_RETRY_DELAYS_MS = Object.freeze([500, 1_500]);
const QUEUE_TASK_WARM_DATE = "warm_date";
const QUEUE_TASK_TRANSLATE_SIGN = "translate_sign";
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
  await env.WARMUP_QUEUE.send({
    schema_version: CACHE_SCHEMA_VERSION,
    task: QUEUE_TASK_WARM_DATE,
    date,
  });
}

export async function handleQueue(batch, env, options = {}) {
  for (const message of batch.messages) {
    const body = message?.body;
    if (body?.schema_version !== CACHE_SCHEMA_VERSION || !isISODate(body?.date)) {
      message?.ack?.();
      continue;
    }

    if (body.task === QUEUE_TASK_TRANSLATE_SIGN) {
      if (!SIGNS.includes(body.sign)) {
        message?.ack?.();
        continue;
      }
      await translateSignForDate(body.date, body.sign, env, options);
    } else if (body.task === undefined || body.task === QUEUE_TASK_WARM_DATE) {
      // Messages created by schema-v3 deployments before task names existed
      // remain valid warm-date messages.
      await warmDate(body.date, env, options);
    } else {
      message?.ack?.();
      continue;
    }
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
    // Confirm the lightweight Queue handoff before returning the fallback.
    // This never calls the provider or AI from a public request, but prevents
    // the repair message from being lost when a request context ends early.
    await requestMissingEditionRepair(date, language, env);
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

async function requestMissingEditionRepair(date, language, env) {
  if (!env?.DAILY_CACHE || !env?.WARMUP_QUEUE) return;
  const key = repairCacheKey(date, language);

  try {
    if (await env.DAILY_CACHE.get(key)) return;
    await env.DAILY_CACHE.put(key, "1", { expirationTtl: FAILURE_COOLDOWN_SECONDS });
    await env.WARMUP_QUEUE.send({
      schema_version: CACHE_SCHEMA_VERSION,
      task: QUEUE_TASK_WARM_DATE,
      date,
    });
  } catch (error) {
    console.error("missing edition repair failed", {
      date,
      language,
      code: error instanceof Error ? error.message : "unknown",
    });
    // Repair scheduling must never change the public fallback response.
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
  if (!env?.DAILY_CACHE || !secretValue(env?.FREEASTRO_API_KEY) || !env?.WARMUP_QUEUE) {
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
  try {
    spanish = await getCachedDaily(date, env, "es");
  } catch {
    await enqueueSpanishTranslations(english, env);
    return {
      payload: english,
      translations: { es: null },
      cache: "miss",
    };
  }

  return {
    payload: english,
    translations: { es: spanish },
    cache: englishCache === "hit" ? "hit" : "miss",
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

async function enqueueSpanishTranslations(english, env) {
  if (!env?.WARMUP_QUEUE) throw new Error("warmup_queue_not_configured");
  for (const sign of SIGNS) {
    await env.WARMUP_QUEUE.send({
      schema_version: CACHE_SCHEMA_VERSION,
      task: QUEUE_TASK_TRANSLATE_SIGN,
      date: english.content_date,
      sign,
    });
  }
}

export async function translateSignForDate(date, sign, env, options = {}) {
  if (!env?.DAILY_CACHE || !env?.AI) throw new Error("service_not_configured");
  if (!SIGNS.includes(sign)) throw new Error("unsupported_sign");

  try {
    return await getCachedDaily(date, env, "es");
  } catch {
    // Continue until all twelve sign fragments can be assembled atomically.
  }

  const failureKey = failureCacheKey(date, "es", sign);
  if (await env.DAILY_CACHE.get(failureKey)) throw new Error("translation_cooldown");

  try {
    const english = await getCachedDaily(date, env, "en");
    const source = english.horoscopes.find((horoscope) => horoscope.sign === sign);
    if (!source) throw new Error("missing_english_sign");

    const partialKey = translationPartCacheKey(date, sign);
    let translated = await readPayload(env.DAILY_CACHE, partialKey);
    if (!isValidHoroscope(translated, date, "es")) {
      translated = await translateHoroscopeToSpanish(source, env.AI, options);
      if (!isValidHoroscope(translated, date, "es")) {
        throw new Error("invalid_translated_sign");
      }
      await env.DAILY_CACHE.put(partialKey, JSON.stringify(translated), {
        expirationTtl: DAILY_TTL_SECONDS,
      });
    }

    return await assembleSpanishEdition(english, env.DAILY_CACHE, options);
  } catch (error) {
    await recordFailure(env.DAILY_CACHE, date, "es", sign);
    console.error("translation sign failed", {
      date,
      sign,
      code: error instanceof Error ? error.message : "unknown",
    });
    throw new Error("translation_sign_failed");
  }
}

async function assembleSpanishEdition(english, kv, options = {}) {
  const horoscopes = await Promise.all(
    SIGNS.map((sign) => readPayload(kv, translationPartCacheKey(english.content_date, sign))),
  );
  if (!horoscopes.every((horoscope) =>
    isValidHoroscope(horoscope, english.content_date, "es")
  )) {
    return null;
  }

  const payload = {
    ...english,
    language: "es",
    generated_at: (options.now?.() ?? new Date()).toISOString(),
    horoscopes,
  };
  if (!isValidBundle(payload, english.content_date, "es")) {
    throw new Error("invalid_translated_bundle");
  }
  await writePayload(kv, payload);
  return payload;
}

async function writePayload(kv, payload) {
  await Promise.all([
    kv.put(dailyCacheKey(payload.content_date, payload.language), JSON.stringify(payload), {
      expirationTtl: DAILY_TTL_SECONDS,
    }),
    kv.put(lastValidCacheKey(payload.language), JSON.stringify(payload)),
  ]);
}

async function recordFailure(kv, date, language, sign = null) {
  try {
    await kv.put(failureCacheKey(date, language, sign), "1", {
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
    horoscopes.push(await translateHoroscopeToSpanish(horoscope, ai, options));
  }

  return {
    ...english,
    language: "es",
    generated_at: now.toISOString(),
    horoscopes,
  };
}

async function translateHoroscopeToSpanish(horoscope, ai, options = {}) {
  const translated = await translateEditorialUnit(horoscope, ai, options);

  return {
    ...horoscope,
    headline: translated.headline,
    reading: translated.reading,
    details: {
      ...horoscope.details,
      focus: translated.headline,
      keywords: translated.keywords,
      lucky_color: translated.lucky_color,
      moon_sign: translated.moon_sign,
      moon_phase: translated.moon_phase,
    },
  };
}

async function translateEditorialUnit(horoscope, ai, options = {}) {
  const wait = options.wait ?? sleep;
  let lastError = new Error("translation_invalid_response");
  const input = editorialTranslationRequest(horoscope);

  for (let attempt = 0; attempt <= TRANSLATION_RETRY_DELAYS_MS.length; attempt += 1) {
    try {
      const response = await ai.run(TRANSLATION_MODEL, input);
      const translated = normalizeEditorialTranslation(extractAIResult(response), horoscope);
      if (translated && await reviewEditorialTranslation(horoscope, translated, ai)) {
        return translated;
      }
      lastError = new Error("translation_invalid_response");
    } catch (error) {
      lastError = error instanceof Error ? error : new Error("translation_request_failed");
    }

    const delay = TRANSLATION_RETRY_DELAYS_MS[attempt];
    if (delay !== undefined) await wait(delay);
  }

  throw lastError;
}

async function reviewEditorialTranslation(source, translated, ai) {
  if (!passesLocalSpanishQualityGate(translated)) {
    console.warn("Spanish local quality gate rejected translation", { sign: source.sign });
    return false;
  }

  const response = await ai.run(TRANSLATION_REVIEW_MODEL, {
    messages: [
      {
        role: "system",
        content: [
          "Actúa como revisor bilingüe estricto, no como redactor.",
          "Compara la fuente inglesa con la adaptación al castellano de España.",
          "Marca faithful=false si se omite, añade, suaviza o intensifica cualquier consejo, predicción, planeta, casa, signo, relación causal o dato.",
          "Marca is_spanish=false si queda una frase o metadato en inglés o si el castellano es literal, mecánico o impropio.",
          "Marca grammar_correct=false ante cualquier error de género, número, concordancia, preposición o régimen verbal.",
          "Marca natural_spanish=false si aparecen calcos como 'un lente', 'domicilio' por casa astrológica, 'juicio de seguridad' o fórmulas repetitivas poco naturales.",
          "Marca all_metadata_translated=false si el titular, las palabras clave, el color, el signo lunar o la fase lunar conservan vocabulario inglés.",
          "Marca preserves_astrology=false si cambia el significado de terminología astrológica.",
          "Marca no_new_facts=false si aparece cualquier afirmación que no esté en la fuente.",
          "Devuelve solamente el objeto solicitado.",
        ].join(" "),
      },
      {
        role: "user",
        content: JSON.stringify({ source, translated }),
      },
    ],
    response_format: {
      type: "json_schema",
      json_schema: {
        type: "object",
        properties: {
          faithful: { type: "boolean" },
          is_spanish: { type: "boolean" },
          grammar_correct: { type: "boolean" },
          natural_spanish: { type: "boolean" },
          all_metadata_translated: { type: "boolean" },
          preserves_astrology: { type: "boolean" },
          no_new_facts: { type: "boolean" },
        },
        required: [
          "faithful",
          "is_spanish",
          "grammar_correct",
          "natural_spanish",
          "all_metadata_translated",
          "preserves_astrology",
          "no_new_facts",
        ],
        additionalProperties: false,
      },
    },
    temperature: 0,
    max_tokens: 320,
  });

  let verdict = extractAIResult(response);
  if (typeof verdict === "string") {
    try {
      verdict = JSON.parse(verdict);
    } catch {
      return false;
    }
  }
  const accepted = Boolean(
    verdict?.faithful === true
      && verdict?.is_spanish === true
      && verdict?.grammar_correct === true
      && verdict?.natural_spanish === true
      && verdict?.all_metadata_translated === true
      && verdict?.preserves_astrology === true
      && verdict?.no_new_facts === true,
  );
  if (!accepted) {
    console.warn("Spanish editorial review rejected translation", {
      sign: source.sign,
      faithful: verdict?.faithful === true,
      is_spanish: verdict?.is_spanish === true,
      grammar_correct: verdict?.grammar_correct === true,
      natural_spanish: verdict?.natural_spanish === true,
      all_metadata_translated: verdict?.all_metadata_translated === true,
      preserves_astrology: verdict?.preserves_astrology === true,
      no_new_facts: verdict?.no_new_facts === true,
    });
  }
  return accepted;
}

function passesLocalSpanishQualityGate(translated) {
  const completeCopy = [
    translated.headline,
    translated.reading,
    ...translated.keywords,
    translated.lucky_color,
    translated.moon_sign,
    translated.moon_phase,
  ].join(" ");

  const forbiddenPatterns = [
    // In Spanish, ordinal adjectives agree with the feminine noun "casa".
    /\b(?:primer|segundo|tercer|cuarto|quinto|sexto|séptimo|octavo|noveno|décimo|undécimo|duodécimo)\s+casa\b/iu,
    /\bun\s+lente\b/iu,
    /\b(?:domicilio|juicio de seguridad)\b/iu,
    // Common FreeAstro metadata that must never leak through untranslated.
    /\b(?:detail|analysis|service|momentum|freedom|innovation|humanity|growth|silver|full moon|new moon|first quarter|last quarter)\b/iu,
  ];

  return forbiddenPatterns.every((pattern) => !pattern.test(completeCopy));
}

function extractAIResult(response) {
  return response?.response ?? response?.choices?.[0]?.message?.content ?? null;
}

function editorialTranslationRequest(horoscope) {
  const schema = {
    type: "object",
    properties: {
      headline: { type: "string", maxLength: MAX_TRANSLATED_HEADLINE_CHARACTERS },
      reading: { type: "string", minLength: MIN_READING_CHARACTERS, maxLength: MAX_TRANSLATED_READING_CHARACTERS },
      keywords: {
        type: "array",
        minItems: horoscope.details.keywords.length,
        maxItems: horoscope.details.keywords.length,
        items: { type: "string", minLength: 1, maxLength: 40 },
      },
      lucky_color: { type: "string", minLength: 1, maxLength: 32 },
      moon_sign: { type: "string", minLength: 1, maxLength: 40 },
      moon_phase: { type: "string", minLength: 1, maxLength: 40 },
    },
    required: ["headline", "reading", "keywords", "lucky_color", "moon_sign", "moon_phase"],
    additionalProperties: false,
  };

  return {
    messages: [
      {
        role: "system",
        content: [
          "Eres editor de una revista de astrología escrita originalmente en castellano de España.",
          "Adapta el texto inglés con naturalidad, calidez y precisión; no hagas una traducción palabra por palabra.",
          "Conserva exactamente el sentido, el grado de certeza y todos los consejos del original.",
          "No añadas predicciones, fechas, cifras, afirmaciones ni información que no aparezca en la fuente.",
          "Usa un tono elegante y cercano, en segunda persona del singular (tú), sin anglicismos ni frases mecánicas.",
          "Dirígete a la persona lectora; nunca escribas construcciones como 'el Escorpio', 'la Aries' o equivalentes.",
          "Si el signo actúa como sujeto, usa su nombre propio traducido y sin artículo: por ejemplo, 'Escorpio afronta el día'.",
          "Prefiere giros idiomáticos de España y evita calcos como 'enfrentar el día' o 'impulsos fuertes'.",
          "La palabra 'casa' es femenina: escribe 'primera casa', 'segunda casa', 'séptima casa', etc.; nunca 'primer casa' ni 'séptimo casa'.",
          "En castellano de España, 'lente' es femenino ('una lente') y una house astrológica siempre es una 'casa', nunca un 'domicilio'.",
          "Evita expresiones forzadas como 'juicio de seguridad', 'visión aérea' o 'filtro acuoso'; expresa la misma idea con prosa natural.",
          "No repitas mecánicamente fórmulas; mantén cada consejo fiel, pero intégralo con una redacción española fluida.",
          "El titular debe ser breve y evocador, pero no puede introducir ideas ausentes en el titular inglés.",
          "La lectura debe fluir como un único texto editorial.",
          "Traduce correctamente los términos astrológicos, el color y cada palabra clave.",
          "Devuelve solamente el objeto solicitado.",
        ].join(" "),
      },
      {
        role: "user",
        content: JSON.stringify({
          sign: horoscope.sign,
          headline: horoscope.headline,
          reading: horoscope.reading,
          keywords: horoscope.details.keywords,
          lucky_color: horoscope.details.lucky_color,
          moon_sign: horoscope.details.moon_sign,
          moon_phase: horoscope.details.moon_phase,
        }),
      },
    ],
    response_format: {
      type: "json_schema",
      json_schema: schema,
    },
    reasoning: { effort: "low" },
    temperature: 0.25,
    max_tokens: 1_400,
  };
}

function normalizeEditorialTranslation(value, source) {
  let candidate = value;
  if (typeof candidate === "string") {
    try {
      candidate = JSON.parse(candidate);
    } catch {
      return null;
    }
  }
  if (!candidate || typeof candidate !== "object" || Array.isArray(candidate)) return null;

  const headline = knownSpanishTerm(source.headline) ?? normalizeCardCopy(candidate.headline);
  const reading = normalizeSpanishReading(candidate.reading);
  const candidateKeywords = cleanStringArray(candidate.keywords)?.map(normalizeCardCopy);
  const keywords = source.details.keywords.map((term, index) => (
    knownSpanishTerm(term) ?? candidateKeywords?.[index]
  ));
  const luckyColor = knownSpanishTerm(source.details.lucky_color)
    ?? normalizeCardCopy(candidate.lucky_color);
  const moonSign = knownSpanishTerm(source.details.moon_sign)
    ?? normalizeCardCopy(candidate.moon_sign);
  const moonPhase = knownSpanishTerm(source.details.moon_phase)
    ?? normalizeCardCopy(candidate.moon_phase);
  if (!headline || headline.length > MAX_TRANSLATED_HEADLINE_CHARACTERS) return null;
  if (!reading || reading.length < MIN_READING_CHARACTERS || reading.length > MAX_TRANSLATED_READING_CHARACTERS) return null;
  if (headline.toLocaleLowerCase("es") === source.headline.toLocaleLowerCase("en")) return null;
  if (reading.toLocaleLowerCase("es") === source.reading.toLocaleLowerCase("en")) return null;
  if (!isValidKeywordList(keywords) || keywords.length !== source.details.keywords.length) return null;
  if (!luckyColor || luckyColor.length > 32) return null;
  if (!moonSign || moonSign.length > 40 || !moonPhase || moonPhase.length > 40) return null;

  return {
    headline,
    reading,
    keywords,
    lucky_color: luckyColor,
    moon_sign: moonSign,
    moon_phase: moonPhase,
  };
}

const KNOWN_SPANISH_TERMS = Object.freeze({
  adaptability: "Adaptabilidad", adventure: "Aventura", ambition: "Ambición",
  analysis: "Análisis", aries: "Aries", aquarius: "Acuario", balance: "Equilibrio",
  black: "Negro", blue: "Azul", boldness: "Audacia", brown: "Marrón",
  cancer: "Cáncer", capricorn: "Capricornio", care: "Cuidado", clarity: "Claridad",
  communication: "Comunicación", compassion: "Compasión", confidence: "Confianza",
  creativity: "Creatividad", curiosity: "Curiosidad", detail: "Precisión",
  discipline: "Disciplina", emotion: "Emoción", empathy: "Empatía", energy: "Energía",
  flow: "Fluidez", focus: "Enfoque", freedom: "Libertad", full_moon: "Luna llena",
  "full moon": "Luna llena", gemini: "Géminis", gold: "Dorado", green: "Verde",
  growth: "Crecimiento", harmony: "Armonía", humanity: "Humanidad",
  imagination: "Imaginación", initiative: "Iniciativa", innovation: "Innovación",
  intensity: "Intensidad", intuition: "Intuición", leadership: "Liderazgo",
  leo: "Leo", libra: "Libra", "last quarter": "Cuarto menguante",
  last_quarter: "Cuarto menguante", mystery: "Misterio", momentum: "Impulso",
  "new moon": "Luna nueva", new_moon: "Luna nueva", orange: "Naranja",
  optimism: "Optimismo", perspective: "Perspectiva", philosophy: "Filosofía",
  pisces: "Piscis", practicality: "Practicidad", purple: "Púrpura", red: "Rojo",
  relationship: "Relación", reset: "Reajuste", responsibility: "Responsabilidad",
  sagittarius: "Sagitario", scorpio: "Escorpio", sensuality: "Sensualidad",
  service: "Servicio", silver: "Plateado", spirituality: "Espiritualidad",
  stability: "Estabilidad", taurus: "Tauro", transformation: "Transformación",
  virgo: "Virgo", white: "Blanco", yellow: "Amarillo",
  "first quarter": "Cuarto creciente", first_quarter: "Cuarto creciente",
});

function knownSpanishTerm(value) {
  const normalized = cleanString(value)?.toLocaleLowerCase("en");
  return normalized ? KNOWN_SPANISH_TERMS[normalized] ?? null : null;
}

function normalizeSpanishReading(value) {
  let reading = normalizeCardCopy(value);
  if (!reading) return null;

  const feminineOrdinals = Object.freeze({
    primer: "primera", primero: "primera", segundo: "segunda", tercer: "tercera",
    tercero: "tercera", cuarto: "cuarta", quinto: "quinta", sexto: "sexta",
    "séptimo": "séptima", octavo: "octava", noveno: "novena", "décimo": "décima",
    "undécimo": "undécima", "duodécimo": "duodécima",
  });
  const ordinalPattern = new RegExp(`\\b(${Object.keys(feminineOrdinals).join("|")})\\s+casa\\b`, "giu");
  reading = reading.replace(ordinalPattern, (match, ordinal) => {
    const replacement = feminineOrdinals[ordinal.toLocaleLowerCase("es")];
    return /^[A-ZÁÉÍÓÚÑ]/u.test(match) ? `${replacement[0].toLocaleUpperCase("es")}${replacement.slice(1)} casa` : `${replacement} casa`;
  });

  return reading
    .replace(/\bun lente\b/giu, "una lente")
    .replace(/\b(octava|octavo) domicilio\b/giu, "octava casa")
    .replace(/\bjuicio de seguridad\b/giu, "criterio centrado en la seguridad")
    .replace(/\bvisión aérea\b/giu, "perspectiva racional")
    .replace(/\bfiltro acuoso\b/giu, "mirada intuitiva")
    .replace(/\bprisma acuático\b/giu, "mirada intuitiva")
    .replace(/\blente terrestre\b/giu, "mirada práctica")
    .replace(/\benfoque ardiente\b/giu, "mirada enérgica");
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
    if (!isValidHoroscope(horoscope, expectedContentDate, expectedLanguage)) return false;
    signs.add(horoscope.sign);
  }

  return signs.size === SIGNS.length;
}

function isValidHoroscope(horoscope, expectedContentDate, expectedLanguage) {
  if (!SIGNS.includes(horoscope?.sign)) return false;
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
  if (reading.length < MIN_READING_CHARACTERS || reading.length > readingLimit) return false;
  if (!isValidProviderDetails(horoscope.details)) return false;
  return horoscope.content_version === Number(expectedContentDate.replaceAll("-", ""));
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
  return `daily:v${CACHE_SCHEMA_VERSION}:${languageCacheSegment(language)}:${date}`;
}

function lastValidCacheKey(language) {
  return `last-valid:v${CACHE_SCHEMA_VERSION}:${languageCacheSegment(language)}`;
}

function failureCacheKey(date, language, sign = null) {
  const suffix = sign ? `:${sign}` : "";
  return `failure:v${CACHE_SCHEMA_VERSION}:${languageCacheSegment(language)}:${date}${suffix}`;
}

function repairCacheKey(date, language) {
  return `repair:v${CACHE_SCHEMA_VERSION}:${languageCacheSegment(language)}:${date}`;
}

function translationPartCacheKey(date, sign) {
  return `translation-part:v${CACHE_SCHEMA_VERSION}:es-r${SPANISH_COPY_REVISION}:${date}:${sign}`;
}

function languageCacheSegment(language) {
  return language === "es" ? `es-r${SPANISH_COPY_REVISION}` : language;
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

export {
  LANGUAGES,
  SIGNS,
  SPANISH_COPY_REVISION,
  TRANSLATION_MODEL,
  TRANSLATION_REVIEW_MODEL,
};
