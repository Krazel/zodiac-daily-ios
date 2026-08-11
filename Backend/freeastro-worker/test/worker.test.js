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

function validBundle(date) {
  return {
    schema_version: 2,
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

  assert.deepEqual(messages, [{ schema_version: 2, date: "2026-08-10" }]);
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

test("queue consumer warm-up writes one exact-date bulk document", async () => {
  const kv = new MemoryKV();
  let calls = 0;
  let acknowledged = false;
  const observedKeys = [];
  const env = { FREEASTRO_API_KEY: " secret-value\r\n", DAILY_CACHE: kv };

  await handleQueue({ messages: [{
    body: { schema_version: 2, date: "2026-08-09" },
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
  const cached = await getCachedDaily("2026-08-09", env);

  assert.equal(acknowledged, true);
  assert.equal(calls, 12);
  assert.ok(observedKeys.every((key) => key === "secret-value"));
  assert.equal(cached.horoscopes.length, 12);
  assert.equal(cached.requested_date, "2026-08-09");
  assert.equal(cached.content_date, "2026-08-09");
  assert.equal(kv.puts.filter(({ key }) => key.startsWith("daily:")).length, 1);
});

test("a second scheduled check uses KV and spends no provider quota", async () => {
  const cached = validBundle("2026-08-09");
  const kv = new MemoryKV({ "daily:v2:2026-08-09": JSON.stringify(cached) });
  let calls = 0;
  const result = await warmDate(
    "2026-08-09",
    { FREEASTRO_API_KEY: "secret", DAILY_CACHE: kv },
    { fetchImpl: async () => { calls += 1; return new Response(); } },
  );

  assert.equal(result.cache, "hit");
  assert.equal(calls, 0);
});

test("public cache miss never contacts provider or serves another date", async () => {
  const prior = validBundle("2026-08-08");
  const kv = new MemoryKV({ "last-valid:v2": JSON.stringify(prior) });
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
  assert.equal(await kv.get("last-valid:v2"), JSON.stringify(prior));
  assert.doesNotMatch(JSON.stringify(body), /never-expose-this/);
});

test("scheduled provider failure cools down and preserves only diagnostic last-valid", async () => {
  const prior = validBundle("2026-08-08");
  const kv = new MemoryKV({ "last-valid:v2": JSON.stringify(prior) });

  await assert.rejects(
    warmDate(
      "2026-08-09",
      { FREEASTRO_API_KEY: "secret", DAILY_CACHE: kv },
      {
        now: () => new Date("2026-08-09T00:15:00Z"),
        wait: async () => undefined,
        fetchImpl: async () => new Response("failure", { status: 500 }),
      },
    ),
    /provider_refresh_failed/,
  );

  assert.equal(await kv.get("failure:v2:2026-08-09"), "1");
  assert.equal(await kv.get("last-valid:v2"), JSON.stringify(prior));
  await assert.rejects(getCachedDaily("2026-08-09", { DAILY_CACHE: kv }), /daily_cache_miss/);
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
  const kv = new MemoryKV({ "daily:v2:2026-08-09": JSON.stringify(cached) });
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
  });
  assert.equal(response.status, 200);
  assert.doesNotMatch(await response.text(), /top-secret/);

  const unconfigured = await handleRequest(new Request("https://example.test/health"), {});
  assert.equal(unconfigured.status, 503);
});
