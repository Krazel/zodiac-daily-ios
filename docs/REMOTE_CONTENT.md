# Remote daily content

Updated: 2026-08-11

The app can load a fresh daily edition from a Zodiac Daily-owned HTTPS endpoint
and falls back automatically to `BundledHoroscopeRepository` on connectivity,
HTTP, date, or payload errors. Saved cards remain immutable local snapshots;
the remote repository does not change the save/archive model.

The first successfully resolved card for each language, sign, and local date is pinned in
the separate `daily-editions.json` archive. This makes remote, fallback, and
relaunch behavior converge on one collectible card for the whole day. A user's
saved-card archive remains separate and, when present for the same sign/day,
its immutable snapshot is the one displayed.
Because daily editions are derivable, an unreadable pin archive is rebuilt on
the next successful resolution. This recovery policy never applies to the
user's saved-card archive, which is not silently discarded or overwritten.
If the derived cache cannot write, the valid resolved card still remains
available for that session.

## App configuration

The non-secret Xcode build setting `ZODIAC_DAILY_API_BASE_URL` is set to
`https://zodiac-daily-content.krazel-zodiac-daily.workers.dev`, without
credentials, query, or fragment. A FreeAstroAPI key exists only in the
server-side adapter and must never be copied into the app or its build settings.

The app requests:

```text
GET {baseURL}/v1/daily/YYYY-MM-DD?lang=en|es
Accept: application/json
```

## Normalized response contract

```json
{
  "schema_version": 3,
  "language": "es",
  "requested_date": "2026-08-09",
  "content_date": "2026-08-09",
  "generated_at": "2026-08-09T00:15:12.000Z",
  "stale": false,
  "provider": "freeastroapi",
  "horoscopes": [
    {
      "sign": "aries",
      "headline": "A concise editorial headline",
      "reading": "La lectura diaria completa en castellano.",
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

The example abbreviates `horoscopes`; schema-3 responses must contain exactly
all twelve unique lowercase `ZodiacSign` values. Headlines must be nonblank and
no longer than 52 English or 72 Spanish characters; readings must contain 40
to 500 English or 700 Spanish characters. Schema 3 requires an exact `en` or
`es` language match and complete FreeAstroAPI V2 details: four integer scores from 0
to 100, one to eight unique keywords, lucky number/color, and Moon sign/phase.
The app accepts legacy schema 1/2 documents without a language only as English;
schema 3 without `language` is rejected. Each
`content_version` must be a positive integer. `requested_date` must exactly
match the requested local Gregorian day, and `content_date` must always equal
`requested_date`. A last-valid payload from another date is deliberately
rejected so the app falls back to its date-correct bundled card. The server
caches one validated twelve-sign document per language/date. FreeAstroAPI is
called only for the English source document; Workers AI translates that cached
document once to Spanish. App traffic invokes neither service.

Cloudflare Cron Triggers only enqueue the target date. A Cloudflare Queue
consumer performs the twelve paced provider requests, validation, and KV write.
That separation avoids doing the heavier work inside the Workers Free cron
limit. The consumer uses one-message batches and concurrency one, so duplicate
messages serialize and recheck KV before they can spend provider quota.

The production endpoint is active in the app. The app-side implementation
neither contacts FreeAstroAPI directly nor contains its key.
It requests only the local date, `en`/`es`, and the full twelve-sign edition,
never the selected sign, birth data, account data, or saved cards.

The bilingual schema-3 code is currently a local candidate. The Workers AI
binding passed a remote-preview-only smoke test on 2026-08-11 with valid
Spanish and accented characters; the preview was stopped afterward. The
deployed endpoint remains on the prior English schema until rights review,
macOS tests, and explicit deployment authorization are complete.
