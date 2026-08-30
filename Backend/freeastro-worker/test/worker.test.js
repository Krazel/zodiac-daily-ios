import assert from "node:assert/strict";
import test from "node:test";

import {
  SIGNS,
  fetchProviderBundle,
  getCachedDaily,
  handleQueue,
  handleRequest,
  handleScheduled,
  isValidBundle,
  normalizeProviderResponse,
  scheduledTargetDate,
  translateBundleToSpanish,
  warmDate,
} from "../src/index.js";

class MemoryKV {
  constructor(initial = {}) {
    this.values = new Map(Object.entries(initial));
    this.puts = [];
  }

  async get(key) {
    return this.values.get(key) ?? null;
  }

  async put(key, value, options) {
    this.values.set(key, value);
    this.puts.push({ key, value, options });
  }
}

function providerBody(sign, date, text = null) {
  return {
    data: {
      sign,
      date,
      scores: { overall: 86, love: 83, career: 89, money: 85, health: 78 },
      lucky: {
        color: { name: "silver", label: "Silver" },
        number: 61,
        time_window: "08:00-10:00",
      },
      content: {
        theme: `${sign} theme`,
        keywords: ["Empathy", "Flow", "Imagination"],
        text:
          text ??
          `A considered ${sign} reading for ${date} with enough useful detail to form a complete daily card.`,
      },
      astro: {
        moon_sign: { name: "capricorn", label: "Capricorn" },
        moon_phase: { name: "last_quarter", label: "Last Quarter" },
      },
    },
  };
}

function validBundle(date, language = "en") {
  return {
    schema_version: 3,
    language,
    requested_date: date,
    content_date: date,
    generated_at: `${date}T00:15:00.000Z`,
    stale: false,
    provider: "freeastroapi",
    horoscopes: SIGNS.map((sign) => ({
      sign,
      headline: `${sign} theme`,
      reading: `A complete reading for ${sign} with enough useful detail to remain a valid daily card.`,
      details: {
        source: "freeastroapi-v2",
        focus: `${sign} theme`,
        keywords: ["Empathy", "Flow", "Imagination"],
        love_score: 83,
        career_score: 89,
        money_score: 85,
        health_score: 78,
        lucky_color: "Silver",
        lucky_number: 61,
        moon_sign: "Capricorn",
        moon_phase: "Last Quarter",
      },
      content_version: Number(date.replaceAll("-", "")),
    })),
  };
}

function fakeAI(calls = []) {
  return {
    async run(model, input) {
      calls.push({ model, input });
      if (isReviewRequest(input)) return { response: approvedReview() };
      return { response: editorialResponse(input) };
    },
  };
}

function isReviewRequest(input) {
  return Boolean(input?.response_format?.json_schema?.properties?.faithful);
}

function approvedReview(overrides = {}) {
  return {
    faithful: true,
    is_spanish: true,
    preserves_astrology: true,
    no_new_facts: true,
    ...overrides,
  };
}

function editorialResponse(input, overrides = {}) {
  const source = JSON.parse(input.messages[1].content);
  return {
    headline: `Un nuevo enfoque para ${source.sign}`,
    reading: `Esta lectura está escrita con naturalidad en castellano y conserva fielmente el sentido completo de la fuente: ${source.reading}`,
    keywords: source.keywords.map((keyword) => ({
      Empathy: "Empatía",
      Flow: "Fluidez",
      Imagination: "Imaginación",
    })[keyword] ?? `Idea ${keyword}`),
    lucky_color: source.lucky_color === "Silver" ? "Plateado" : `Color ${source.lucky_color}`,
    moon_sign: source.moon_sign === "Capricorn" ? "Capricornio" : `Signo ${source.moon_sign}`,
    moon_phase: source.moon_phase === "Last Quarter" ? "Cuarto menguante" : `Fase ${source.moon_phase}`,
    ...overrides,
  };
}

async function drainQueuedMessages(messages, env, options = {}) {
  let acknowledgements = 0;
  while (messages.length > 0) {
    const body = messages.shift();
    await handleQueue({ messages: [{
      body,
      ack: () => { acknowledgements += 1; },
    }] }, env, options);
  }
  return acknowledgements;
}

test("provider responses normalize to the exact app item contract", () => {
  const item = normalizeProviderResponse(providerBody("aries", "2026-08-09"), "aries", "2026-08-09");
  assert.deepEqual(Object.keys(item), ["sign", "headline", "reading", "details", "content_version"]);
  assert.equal(item.sign, "aries");
  assert.equal(item.headline, "aries theme");
  assert.deepEqual(item.details, {
    source: "freeastroapi-v2",
    focus: "aries theme",
    keywords: ["Empathy", "Flow", "Imagination"],
    love_score: 83,
    career_score: 89,
    money_score: 85,
    health_score: 78,
    lucky_color: "Silver",
    lucky_number: 61,
    moon_sign: "Capricorn",
    moon_phase: "Last Quarter",
  });
  assert.equal(item.content_version, 20260809);
});

test("provider card copy collapses transport whitespace", () => {
  const body = providerBody("aries", "2026-08-09");
  body.data.content.theme = "  A   measured\nstep  ";
  body.data.content.text =
    "  A\tclear  daily\nreading keeps every useful thought while removing transport spacing.  ";

  const item = normalizeProviderResponse(body, "aries", "2026-08-09");

  assert.equal(item.headline, "A measured step");
  assert.equal(
    item.reading,
    "A clear daily reading keeps every useful thought while removing transport spacing.",
  );
});

test("provider card copy accepts the exact fixed-card character limits", () => {
  const body = providerBody("aries", "2026-08-09", "R".repeat(500));
  body.data.content.theme = "H".repeat(52);

  const item = normalizeProviderResponse(body, "aries", "2026-08-09");

  assert.equal(item.headline.length, 52);
  assert.equal(item.reading.length, 500);
});

test("provider card copy rejects overflow instead of truncating", () => {
  const longHeadline = providerBody("aries", "2026-08-09");
  longHeadline.data.content.theme = "H".repeat(53);
  assert.throws(
    () => normalizeProviderResponse(longHeadline, "aries", "2026-08-09"),
    /provider_invalid_theme/,
  );

  const longReading = providerBody("aries", "2026-08-09", "R".repeat(501));
  assert.throws(
    () => normalizeProviderResponse(longReading, "aries", "2026-08-09"),
    /provider_invalid_text/,
  );
});

test("cached bundles require normalized card copy within the same limits", () => {
  const normalized = validBundle("2026-08-09");
  normalized.horoscopes[0].headline = "H".repeat(52);
  normalized.horoscopes[0].reading = "R".repeat(500);
  assert.equal(isValidBundle(normalized, "2026-08-09"), true);

  const whitespace = structuredClone(normalized);
  whitespace.horoscopes[0].headline = "  unnormalized   headline  ";
  assert.equal(isValidBundle(whitespace, "2026-08-09"), false);

  const headlineOverflow = structuredClone(normalized);
  headlineOverflow.horoscopes[0].headline = "H".repeat(53);
  assert.equal(isValidBundle(headlineOverflow, "2026-08-09"), false);

  const readingOverflow = structuredClone(normalized);
  readingOverflow.horoscopes[0].reading = "R".repeat(501);
  assert.equal(isValidBundle(readingOverflow, "2026-08-09"), false);
});

test("cron targets today at 00:15 and tomorrow before UTC+14 midnight", () => {
  const time = Date.parse("2026-08-09T09:45:00Z");
  assert.equal(scheduledTargetDate(time, "15 0 * * *"), "2026-08-09");
  assert.equal(scheduledTargetDate(time, "45 9 * * *"), "2026-08-10");
});

test("cron only enqueues warm-up work and never calls the provider", async () => {
  const messages = [];
  await handleScheduled(
    { scheduledTime: Date.parse("2026-08-09T09:45:00Z"), cron: "45 9 * * *" },
    { WARMUP_QUEUE: { send: async (message) => messages.push(message) } },
  );

  assert.deepEqual(messages, [{
    schema_version: 3,
    task: "warm_date",
    date: "2026-08-10",
  }]);
});

test("a provider sign mismatch is rejected", () => {
  assert.throws(
    () => normalizeProviderResponse(providerBody("taurus", "2026-08-09"), "aries", "2026-08-09"),
    /provider_sign_mismatch/,
  );
});

test("provider metadata must be complete and within documented ranges", () => {
  const missingMoon = providerBody("aries", "2026-08-09");
  delete missingMoon.data.astro.moon_phase;
  assert.throws(
    () => normalizeProviderResponse(missingMoon, "aries", "2026-08-09"),
    /provider_invalid_moon_data/,
  );

  const invalidScore = providerBody("aries", "2026-08-09");
  invalidScore.data.scores.love = 101;
  assert.throws(
    () => normalizeProviderResponse(invalidScore, "aries", "2026-08-09"),
    /provider_invalid_scores/,
  );
});

test("provider fan-out covers 12 signs and respects the published free rate", async () => {
  const calls = [];
  const waits = [];
  const payload = await fetchProviderBundle("2026-08-09", "private-test-key", {
    now: () => new Date("2026-08-08T10:15:00Z"),
    wait: async (milliseconds) => waits.push(milliseconds),
    fetchImpl: async (url, init) => {
      const sign = url.searchParams.get("sign");
      calls.push({ sign, key: init.headers["x-api-key"] });
      return Response.json(providerBody(sign, "2026-08-09"));
    },
  });

  assert.equal(calls.length, 12);
  assert.deepEqual(calls.map(({ sign }) => sign), SIGNS);
  assert.ok(calls.every(({ key }) => key === "private-test-key"));
  assert.equal(waits.length, 11);
  assert.ok(waits.every((milliseconds) => milliseconds >= 1_000));
  assert.ok(isValidBundle(payload, "2026-08-09"));
  assert.doesNotMatch(JSON.stringify(payload), /private-test-key/);
});

test("Workers AI translates every user-facing field into a valid Spanish edition", async () => {
  const english = validBundle("2026-08-09");
  const calls = [];
  const spanish = await translateBundleToSpanish(english, fakeAI(calls), {
    now: () => new Date("2026-08-08T10:30:00Z"),
  });

  assert.equal(spanish.language, "es");
  assert.equal(spanish.generated_at, "2026-08-08T10:30:00.000Z");
  assert.equal(spanish.horoscopes[0].headline, "Un nuevo enfoque para aries");
  assert.match(spanish.horoscopes[0].reading, /^Esta lectura está escrita con naturalidad/);
  assert.deepEqual(spanish.horoscopes[0].details.keywords, [
    "Empatía",
    "Fluidez",
    "Imaginación",
  ]);
  assert.equal(spanish.horoscopes[0].details.focus, spanish.horoscopes[0].headline);
  assert.equal(spanish.horoscopes[0].details.lucky_color, "Plateado");
  assert.equal(spanish.horoscopes[0].details.moon_sign, "Capricornio");
  assert.equal(spanish.horoscopes[0].details.moon_phase, "Cuarto menguante");
  assert.equal(spanish.horoscopes[0].details.love_score, 83);
  assert.equal(spanish.horoscopes[0].content_version, 20260809);
  assert.equal(calls.length, 24);
  assert.ok(calls.every(({ input }) => input.response_format.type === "json_schema"));
  const editorialCalls = calls.filter(({ input }) => !isReviewRequest(input));
  const reviewCalls = calls.filter(({ input }) => isReviewRequest(input));
  assert.equal(editorialCalls.length, 12);
  assert.equal(reviewCalls.length, 12);
  assert.ok(editorialCalls.every(({ model }) => model === "@cf/openai/gpt-oss-20b"));
  assert.ok(reviewCalls.every(({ model }) => model === "@cf/meta/llama-3.1-8b-instruct-fast"));
  assert.ok(editorialCalls.every(({ input }) => input.messages[0].content.includes("castellano de España")));
  assert.ok(isValidBundle(spanish, "2026-08-09", "es"));
  assert.ok(isValidBundle(english, "2026-08-09", "en"));
  assert.equal(isValidBundle(english, "2026-08-09", "es"), false);
});

test("Spanish translation retries transient AI failures without losing the edition", async () => {
  const english = validBundle("2026-08-09");
  let attempts = 0;
  const waits = [];
  const ai = {
    async run(_model, input) {
      attempts += 1;
      if (attempts === 1) throw new Error("transient_ai_failure");
      if (isReviewRequest(input)) return { response: approvedReview() };
      return { response: editorialResponse(input) };
    },
  };

  const spanish = await translateBundleToSpanish(english, ai, {
    wait: async (milliseconds) => waits.push(milliseconds),
  });

  assert.ok(isValidBundle(spanish, "2026-08-09", "es"));
  assert.equal(attempts, 25);
  assert.deepEqual(waits, [500]);
});

test("Spanish editorial quality gate retries duplicate translated keywords", async () => {
  const english = validBundle("2026-08-09");
  let attempts = 0;
  const ai = {
    async run(_model, input) {
      attempts += 1;
      if (isReviewRequest(input)) return { response: approvedReview() };
      const response = attempts === 1
        ? editorialResponse(input, { keywords: ["Conexión", "Conexión", "Imaginación"] })
        : editorialResponse(input);
      return { response };
    },
  };

  const waits = [];
  const spanish = await translateBundleToSpanish(english, ai, {
    wait: async (milliseconds) => waits.push(milliseconds),
  });

  assert.deepEqual(spanish.horoscopes[0].details.keywords, [
    "Empatía",
    "Fluidez",
    "Imaginación",
  ]);
  assert.equal(attempts, 25);
  assert.deepEqual(waits, [500]);
  assert.ok(isValidBundle(spanish, "2026-08-09", "es"));
});

test("Spanish editorial reviewer rejects untranslated or unfaithful copy", async () => {
  const english = validBundle("2026-08-09");
  let editorialCalls = 0;
  let reviewCalls = 0;
  const waits = [];
  const ai = {
    async run(_model, input) {
      if (isReviewRequest(input)) {
        reviewCalls += 1;
        return {
          response: reviewCalls === 1
            ? approvedReview({ is_spanish: false })
            : approvedReview(),
        };
      }
      editorialCalls += 1;
      return { response: editorialResponse(input) };
    },
  };

  const spanish = await translateBundleToSpanish(english, ai, {
    wait: async (milliseconds) => waits.push(milliseconds),
  });

  assert.equal(editorialCalls, 13);
  assert.equal(reviewCalls, 13);
  assert.deepEqual(waits, [500]);
  assert.ok(isValidBundle(spanish, "2026-08-09", "es"));
});

test("queue consumer writes one English and one Spanish exact-date edition", async () => {
  const kv = new MemoryKV();
  let calls = 0;
  let acknowledged = false;
  const observedKeys = [];
  const aiCalls = [];
  const messages = [];
  const env = {
    FREEASTRO_API_KEY: " secret-value\r\n",
    DAILY_CACHE: kv,
    AI: fakeAI(aiCalls),
    WARMUP_QUEUE: { send: async (message) => messages.push(message) },
  };

  await handleQueue({ messages: [{
    body: { schema_version: 3, date: "2026-08-09" },
    ack: () => { acknowledged = true; },
  }] }, env, {
    now: () => new Date("2026-08-08T10:15:00Z"),
    wait: async () => undefined,
    fetchImpl: async (url, init) => {
      calls += 1;
      observedKeys.push(init.headers["x-api-key"]);
      const sign = url.searchParams.get("sign");
      return Response.json(providerBody(sign, "2026-08-09"));
    },
  });
  assert.equal(messages.length, 12);
  assert.ok(messages.every(({ task }) => task === "translate_sign"));
  let translationAcknowledgements = 0;
  while (messages.length > 0) {
    const body = messages.shift();
    const callsBeforeMessage = aiCalls.length;
    await handleQueue({ messages: [{
      body,
      ack: () => { translationAcknowledgements += 1; },
    }] }, env, { now: () => new Date("2026-08-08T10:30:00Z") });
    assert.equal(aiCalls.length - callsBeforeMessage, 2);
  }
  const cached = await getCachedDaily("2026-08-09", env, "en");
  const translated = await getCachedDaily("2026-08-09", env, "es");

  assert.equal(acknowledged, true);
  assert.equal(calls, 12);
  assert.ok(observedKeys.every((key) => key === "secret-value"));
  assert.equal(cached.horoscopes.length, 12);
  assert.equal(cached.requested_date, "2026-08-09");
  assert.equal(cached.content_date, "2026-08-09");
  assert.equal(cached.language, "en");
  assert.equal(translated.language, "es");
  assert.match(translated.horoscopes[0].reading, /^Esta lectura está escrita con naturalidad/);
  assert.equal(aiCalls.length, 24);
  assert.equal(translationAcknowledgements, 12);
  assert.equal(kv.puts.filter(({ key }) => key.startsWith("daily:")).length, 2);
});

test("an English cache hit translates Spanish without spending provider quota", async () => {
  const english = validBundle("2026-08-09");
  const kv = new MemoryKV({
    "daily:v3:en:2026-08-09": JSON.stringify(english),
  });
  let providerCalls = 0;
  const aiCalls = [];
  const messages = [];
  const env = {
    FREEASTRO_API_KEY: "secret",
    DAILY_CACHE: kv,
    AI: fakeAI(aiCalls),
    WARMUP_QUEUE: { send: async (message) => messages.push(message) },
  };

  const result = await warmDate(
    "2026-08-09",
    env,
    { fetchImpl: async () => { providerCalls += 1; return new Response(); } },
  );

  assert.equal(result.cache, "miss");
  assert.equal(providerCalls, 0);
  assert.equal(aiCalls.length, 0);
  assert.equal(messages.length, 12);
  await drainQueuedMessages(messages, env);
  assert.equal(aiCalls.length, 24);
  assert.equal((await getCachedDaily("2026-08-09", { DAILY_CACHE: kv }, "es")).language, "es");
});

test("a second scheduled check uses KV and spends no provider quota", async () => {
  const english = validBundle("2026-08-09");
  const spanish = await translateBundleToSpanish(english, fakeAI(), {
    now: () => new Date("2026-08-09T00:15:00Z"),
  });
  const kv = new MemoryKV({
    "daily:v3:en:2026-08-09": JSON.stringify(english),
    "daily:v3:es-r3:2026-08-09": JSON.stringify(spanish),
  });
  let calls = 0;
  const result = await warmDate(
    "2026-08-09",
    {
      FREEASTRO_API_KEY: "secret",
      DAILY_CACHE: kv,
      AI: fakeAI(),
      WARMUP_QUEUE: { send: async () => undefined },
    },
    { fetchImpl: async () => { calls += 1; return new Response(); } },
  );

  assert.equal(result.cache, "hit");
  assert.equal(calls, 0);
});

test("public cache miss never contacts provider or serves another date", async () => {
  const prior = validBundle("2026-08-08");
  const kv = new MemoryKV({ "last-valid:v3:en": JSON.stringify(prior) });
  let calls = 0;
  const response = await handleRequest(
    new Request("https://example.test/v1/daily/2026-08-09"),
    { FREEASTRO_API_KEY: "never-expose-this", DAILY_CACHE: kv },
    {
      now: () => new Date("2026-08-09T12:00:00Z"),
      fetchImpl: async () => { calls += 1; return new Response(); },
    },
  );
  const body = await response.json();

  assert.equal(response.status, 503);
  assert.equal(body.error.code, "daily_content_unavailable");
  assert.equal(calls, 0);
  assert.equal(await kv.get("last-valid:v3:en"), JSON.stringify(prior));
  assert.doesNotMatch(JSON.stringify(body), /never-expose-this/);
});

test("a public miss schedules one bounded queue repair without calling the provider", async () => {
  const kv = new MemoryKV();
  const messages = [];
  const env = {
    DAILY_CACHE: kv,
    WARMUP_QUEUE: { send: async (message) => messages.push(message) },
  };
  const request = new Request(
    "https://example.test/v1/daily/2026-08-09?lang=es",
  );
  const options = { now: () => new Date("2026-08-09T12:00:00Z") };

  const first = await handleRequest(request, env, options);
  const second = await handleRequest(request, env, options);

  assert.equal(first.status, 503);
  assert.equal(second.status, 503);
  assert.deepEqual(messages, [{
    schema_version: 3,
    task: "warm_date",
    date: "2026-08-09",
  }]);
  assert.equal(await kv.get("repair:v3:es-r3:2026-08-09"), "1");
});

test("public language selection never substitutes the wrong-language cache", async () => {
  const english = validBundle("2026-08-09", "en");
  const kv = new MemoryKV({
    "daily:v3:en:2026-08-09": JSON.stringify(english),
  });
  const options = { now: () => new Date("2026-08-09T12:00:00Z") };

  const englishResponse = await handleRequest(
    new Request("https://example.test/v1/horoscopes/daily?date=2026-08-09&lang=en"),
    { DAILY_CACHE: kv },
    options,
  );
  assert.equal(englishResponse.status, 200);
  assert.equal(englishResponse.headers.get("Content-Language"), "en");
  assert.equal((await englishResponse.json()).language, "en");

  const spanishResponse = await handleRequest(
    new Request("https://example.test/v1/horoscopes/daily?date=2026-08-09&lang=es"),
    { DAILY_CACHE: kv },
    options,
  );
  assert.equal(spanishResponse.status, 503);
  assert.equal((await spanishResponse.json()).error.code, "daily_content_unavailable");
});

test("Spanish route returns only the cached Spanish edition and language header", async () => {
  const english = validBundle("2026-08-09", "en");
  const spanish = await translateBundleToSpanish(english, fakeAI(), {
    now: () => new Date("2026-08-09T00:15:00Z"),
  });
  const kv = new MemoryKV({
    "daily:v3:es-r3:2026-08-09": JSON.stringify(spanish),
  });

  const response = await handleRequest(
    new Request("https://example.test/v1/horoscopes/daily?date=2026-08-09&lang=es"),
    { DAILY_CACHE: kv },
    { now: () => new Date("2026-08-09T12:00:00Z") },
  );
  const body = await response.json();
  assert.equal(response.status, 200);
  assert.equal(response.headers.get("Content-Language"), "es");
  assert.equal(body.language, "es");
  assert.match(body.horoscopes[0].reading, /^Esta lectura está escrita con naturalidad/);
});

test("unsupported public languages are rejected before any cache access", async () => {
  let reads = 0;
  const response = await handleRequest(
    new Request("https://example.test/v1/horoscopes/daily?date=2026-08-09&lang=fr"),
    { DAILY_CACHE: { get: async () => { reads += 1; return null; } } },
    { now: () => new Date("2026-08-09T12:00:00Z") },
  );
  assert.equal(response.status, 400);
  assert.equal((await response.json()).error.code, "unsupported_language");
  assert.equal(reads, 0);
});

test("scheduled provider failure cools down and preserves only diagnostic last-valid", async () => {
  const prior = validBundle("2026-08-08");
  const kv = new MemoryKV({ "last-valid:v3:en": JSON.stringify(prior) });

  await assert.rejects(
    warmDate(
      "2026-08-09",
      {
        FREEASTRO_API_KEY: "secret",
        DAILY_CACHE: kv,
        AI: fakeAI(),
        WARMUP_QUEUE: { send: async () => undefined },
      },
      {
        now: () => new Date("2026-08-09T00:15:00Z"),
        wait: async () => undefined,
        fetchImpl: async () => new Response("failure", { status: 500 }),
      },
    ),
    /provider_refresh_failed/,
  );

  assert.equal(await kv.get("failure:v3:en:2026-08-09"), "1");
  assert.equal(await kv.get("last-valid:v3:en"), JSON.stringify(prior));
  await assert.rejects(getCachedDaily("2026-08-09", { DAILY_CACHE: kv }), /daily_cache_miss/);
});

test("translation failure keeps English cached and retries never refetch FreeAstro", async () => {
  const kv = new MemoryKV();
  let providerCalls = 0;
  let aiCalls = 0;
  const messages = [];
  const env = {
    FREEASTRO_API_KEY: "secret",
    DAILY_CACHE: kv,
    AI: {
      async run() {
        aiCalls += 1;
        throw new Error("offline_ai_failure");
      },
    },
    WARMUP_QUEUE: { send: async (message) => messages.push(message) },
  };
  const options = {
    now: () => new Date("2026-08-09T00:15:00Z"),
    wait: async () => undefined,
    fetchImpl: async (url) => {
      providerCalls += 1;
      return Response.json(providerBody(url.searchParams.get("sign"), "2026-08-09"));
    },
  };

  const result = await warmDate("2026-08-09", env, options);
  assert.equal(result.cache, "miss");
  assert.equal(messages.length, 12);
  const ariesMessage = messages[0];
  await assert.rejects(
    handleQueue({ messages: [{ body: ariesMessage }] }, env, options),
    /translation_sign_failed/,
  );
  assert.equal(providerCalls, 12);
  assert.equal(aiCalls, 2);
  assert.equal((await getCachedDaily("2026-08-09", env, "en")).language, "en");
  await assert.rejects(getCachedDaily("2026-08-09", env, "es"), /daily_cache_miss/);
  assert.equal(await kv.get("failure:v3:es-r3:2026-08-09:aries"), "1");

  await assert.rejects(
    handleQueue({ messages: [{ body: ariesMessage }] }, env, options),
    /translation_cooldown/,
  );
  assert.equal(providerCalls, 12);
  assert.equal(aiCalls, 2);
});

test("invalid, impossible, and distant dates cannot consume provider quota", async () => {
  let calls = 0;
  const options = {
    now: () => new Date("2026-08-09T12:00:00Z"),
    fetchImpl: async () => { calls += 1; return new Response(); },
  };
  const env = { FREEASTRO_API_KEY: "secret", DAILY_CACHE: new MemoryKV() };

  for (const date of ["2026-02-30", "09-08-2026", "2027-01-01"]) {
    const response = await handleRequest(new Request(`https://example.test/v1/daily/${date}`), env, options);
    assert.equal(response.status, 400);
  }
  assert.equal(calls, 0);
});

test("canonical and compatibility routes return the exact array contract", async () => {
  const cached = validBundle("2026-08-09");
  const kv = new MemoryKV({ "daily:v3:en:2026-08-09": JSON.stringify(cached) });
  const env = { FREEASTRO_API_KEY: "secret", DAILY_CACHE: kv };
  const options = { now: () => new Date("2026-08-09T12:00:00Z") };

  for (const url of [
    "https://example.test/v1/daily/2026-08-09",
    "https://example.test/v1/horoscopes/daily?date=2026-08-09",
  ]) {
    const response = await handleRequest(new Request(url), env, options);
    const body = await response.json();
    assert.equal(response.status, 200);
    assert.deepEqual(Object.keys(body), [
      "schema_version",
      "language",
      "requested_date",
      "content_date",
      "generated_at",
      "stale",
      "provider",
      "horoscopes",
    ]);
    assert.deepEqual(body, cached);
  }
});

test("health never returns the provider key", async () => {
  const response = await handleRequest(new Request("https://example.test/health"), {
    FREEASTRO_API_KEY: "top-secret",
    DAILY_CACHE: new MemoryKV(),
    WARMUP_QUEUE: { send: async () => undefined },
    AI: fakeAI(),
  });
  assert.equal(response.status, 200);
  assert.doesNotMatch(await response.text(), /top-secret/);

  const missingAI = await handleRequest(new Request("https://example.test/health"), {
    FREEASTRO_API_KEY: "top-secret",
    DAILY_CACHE: new MemoryKV(),
    WARMUP_QUEUE: { send: async () => undefined },
  });
  assert.equal(missingAI.status, 503);

  const unconfigured = await handleRequest(new Request("https://example.test/health"), {});
  assert.equal(unconfigured.status, 503);
});
