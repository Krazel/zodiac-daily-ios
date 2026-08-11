# Zodiac Daily - FreeAstroAPI Worker

Small Cloudflare Worker that keeps the FreeAstroAPI key out of the iOS app and
publishes one validated daily document containing all twelve signs. Production
is active at `https://zodiac-daily-content.krazel-zodiac-daily.workers.dev`.

## Behavior

- `GET /v1/daily/:date` reads KV and returns the exact snake-case array contract
  consumed by the app.
- `GET /v1/horoscopes/daily?date=YYYY-MM-DD` is a compatibility alias.
- `GET /health` reports configuration state without exposing identifiers or the
  secret.
- Public traffic never calls FreeAstroAPI. A cache miss returns `503`, causing
  the app to use its bundled date-specific content.
- Cron triggers do only a tiny enqueue operation. A free Cloudflare Queue
  consumer performs the heavier provider work outside the free cron's 10 ms
  CPU ceiling.
- The `09:45 UTC` cron queues tomorrow with a fifteen-minute buffer before
  UTC+14 reaches midnight. The `00:15 UTC` cron queues a check for today.
- KV keeps exact-date editions plus a last-known-good diagnostic copy. A prior
  date is never relabeled or served as today's new card.
- Requests are limited to today plus/minus one UTC day. This and the read-only
  public route prevent arbitrary traffic from exhausting provider quota.
- No CORS header is sent because native iOS does not need CORS. A future web
  client should add an explicit origin allowlist.

FreeAstroAPI currently documents one Daily Sign request at a time, not a
twelve-sign upstream bulk endpoint. The queue consumer calls all twelve signs
sequentially, at least one second apart, and exposes them as one bulk document.
After initial warm-up, this normally uses 12 of the free plan's published 80
daily requests. Initial activation can use up to 24 while current and next-day
editions are populated.

## Exact app contract

```json
{
  "schema_version": 2,
  "requested_date": "2026-08-09",
  "content_date": "2026-08-09",
  "generated_at": "2026-08-08T10:15:12.000Z",
  "stale": false,
  "provider": "freeastroapi",
  "horoscopes": [
    {
      "sign": "aries",
      "headline": "Initiative",
      "reading": "The complete English daily reading.",
      "details": {
        "source": "freeastroapi-v2",
        "focus": "Initiative",
        "keywords": ["Courage", "Momentum", "Clarity"],
        "love_score": 83,
        "career_score": 89,
        "money_score": 85,
        "health_score": 78,
        "lucky_color": "Silver",
        "lucky_number": 61,
        "moon_sign": "Capricorn",
        "moon_phase": "Last Quarter"
      },
      "content_version": 20260809
    }
  ]
}
```

Production responses contain all twelve unique lowercase signs.
`requested_date` and `content_date` must equal the requested date. Each headline
is nonblank and at most 52 characters; each reading is 40-500 characters.
Each item also preserves the validated V2 focus, keywords, four 0-100 scores,
lucky color/number, and Moon sign/phase returned by FreeAstroAPI. Any
incomplete, mismatched, stale, or invalid provider result is rejected as a
whole and is never stored under the daily key.

## Offline tests

Requires Node.js 20 or newer and no package installation:

```powershell
cd "C:\Users\dmkra\Documents\Codex Apps\ZodiacDailyNative\Backend\freeastro-worker"
npm test
```

Tests use fake provider responses and in-memory KV. They do not contact
FreeAstroAPI or Cloudflare.

Optional local Wrangler preview:

1. Copy `.dev.vars.example` to `.dev.vars`.
2. Put the real provider key only in `.dev.vars`.
3. Run `npx wrangler dev --local`.

`.dev.vars` is ignored here. Never put the key in source, `wrangler.jsonc`,
Xcode settings, URLs, or the iOS app.

## Production setup and maintenance

The owner authorized activation on 2026-08-11. The Cloudflare account now has
the `DAILY_CACHE` KV namespace, `zodiac-daily-warmup` Queue, two cron triggers,
and encrypted `FREEASTRO_API_KEY` secret. The public routes remain cache-only.
The following commands document how the deployed setup is maintained; do not
recreate resources that already exist.

1. Create a free FreeAstroAPI account and copy its API key.
2. Create or use a free Cloudflare account.
3. Authenticate from this directory:

   ```powershell
   npx wrangler login
   ```

4. Create the KV namespace:

   ```powershell
   npx wrangler kv namespace create DAILY_CACHE
   ```

5. Create the free warm-up queue:

   ```powershell
   npx wrangler queues create zodiac-daily-warmup
   ```

6. Keep the existing `DAILY_CACHE` namespace binding in `wrangler.jsonc`.
7. Store the API key as an encrypted Worker secret:

   ```powershell
   npx wrangler secret put FREEASTRO_API_KEY
   ```

8. Run `npm test`.
9. Deploy only after explicit owner authorization:

   ```powershell
   npx wrangler deploy
   ```

10. Warm-up is automatic: `09:45 UTC` prepares tomorrow and
   `00:15 UTC` to retry today if needed. Until the exact date exists in KV, the
   app deliberately uses bundled content.
11. Verify the production `/health` and `/v1/daily/YYYY-MM-DD` routes. The iOS
    app contains only the HTTPS Worker base URL, never the provider key.

Official references used for this adapter:

- Daily Sign endpoint: <https://www.freeastroapi.com/docs/western/daily-sign>
- Authentication and key security: <https://www.freeastroapi.com/docs/auth>
- Free-plan allowance and commercial use: <https://www.freeastroapi.com/pricing>
- Provider terms: <https://www.freeastroapi.com/terms>
- Workers Free limits: <https://developers.cloudflare.com/workers/platform/limits/>
- Queues Free limits: <https://developers.cloudflare.com/queues/platform/limits/>

## Content-rights decision

FreeAstroAPI currently advertises commercial use on its free plan. Its public
terms do not expressly state a retention period for generated horoscopes. On
2026-08-09 the product owner explicitly chose to proceed on the assumption that
the absence of a retention restriction permits a user's saved cards to remain.

That is the owner's product/legal assumption, not an additional license granted
by this code. Review current terms before App Store release. If the provider
later adds retention or attribution limits, stop importing new content and use
the bundled catalog until the product decision is revisited.

## Operations

- Never log request headers or `env.FREEASTRO_API_KEY`.
- A failed scheduled refresh gets a five-minute KV cooldown.
- Public routes are read-only with respect to FreeAstroAPI, so bots and cache
  misses cannot trigger upstream fan-out.
- The `last-valid` KV value is diagnostic only; it is never a cross-date API
  fallback.
- Saved cards remain immutable local snapshots in the app.
- The queue consumer is configured with one-message batches and concurrency
  one. Duplicate warm-up messages therefore serialize and recheck KV before
  spending provider quota.
- Queue delivery has one retry. Even two late twelve-sign failures for both
  daily jobs remain below the provider's published 80-request daily ceiling.
