# Remote daily content

Updated: 2026-08-09

The app can load a fresh daily edition from a Zodiac Daily-owned HTTPS endpoint
and falls back automatically to `BundledHoroscopeRepository` on connectivity,
HTTP, date, or payload errors. Saved cards remain immutable local snapshots;
the remote repository does not change the save/archive model.

The first successfully resolved card for each sign and local date is pinned in
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

Set the non-secret Xcode build setting `ZODIAC_DAILY_API_BASE_URL` to the public
HTTPS base URL, without credentials, query, or fragment. When it is empty, the
app remains fully local. A FreeAstroAPI key must exist only in the server-side
adapter and must never be copied into the app or its build settings.

The app requests:

```text
GET {baseURL}/v1/daily/YYYY-MM-DD
Accept: application/json
```

## Normalized response contract

```json
{
  "schema_version": 1,
  "requested_date": "2026-08-09",
  "content_date": "2026-08-09",
  "generated_at": "2026-08-09T00:15:12.000Z",
  "stale": false,
  "provider": "freeastroapi",
  "horoscopes": [
    {
      "sign": "aries",
      "headline": "A concise editorial headline",
      "reading": "The complete English daily reading with enough useful detail.",
      "content_version": 1
    }
  ]
}
```

The example abbreviates `horoscopes`; production responses must contain exactly
all twelve unique lowercase `ZodiacSign` values. Headlines must be nonblank and
no longer than 160 characters; readings must contain 40 to 2,000 characters.
Each `content_version` must be a positive integer. `requested_date` must exactly
match the requested local Gregorian day, and `content_date` must always equal
`requested_date`. A last-valid payload from another date is deliberately
rejected so the app falls back to its date-correct bundled card. The server
caches one validated twelve-sign document per date so FreeAstroAPI is called at
most once per daily refresh, regardless of app traffic.

Cloudflare Cron Triggers only enqueue the target date. A Cloudflare Queue
consumer performs the twelve paced provider requests, validation, and KV write.
That separation avoids doing the heavier work inside the Workers Free cron
limit. The consumer uses one-message batches and concurrency one, so duplicate
messages serialize and recheck KV before they can spend provider quota.

The production endpoint URL is intentionally unset in the app. This app-side
implementation neither contacts FreeAstroAPI directly nor contains its key.
It requests only the local date and the full twelve-sign edition, never the
selected sign, birth data, account data, or saved cards.
