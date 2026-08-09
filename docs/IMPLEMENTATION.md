# iOS implementation

Updated: 2026-08-09

## Approved Today screen

The native Today view implements the approved
`Design/Concepts/today-c2-collectible-card.png` hierarchy:

- midnight editorial background and centered Zodiac Daily masthead;
- English local date and a 12-sign capsule menu;
- one complete, separately bounded collectible card with all corners visible;
- native procedural stars, twelve distinct constellation point sets, crescent,
  and waves;
- local deterministic headline and reading;
- Save Card action outside the card with saved/unsaved feedback; and
- Today/Saved native tab navigation.

The implementation uses semantic SwiftUI text, Dynamic Type, VoiceOver labels,
minimum 44-point interactions, safe-area-aware scrolling, and no third-party
fonts, images, or packages. Accessibility may legitimately reflow the card
vertically instead of preserving a fixed aspect ratio.

The app refreshes when the selected sign changes, when it becomes active, on
pull-to-refresh, and when the local Gregorian day crosses midnight. Stale async
results are discarded if the user changes signs while a card is loading.

## Fresh daily content

When `ZODIAC_DAILY_API_BASE_URL` contains the public HTTPS Worker address, the
app requests one normalized document containing all twelve signs for the local
date. It sends neither a FreeAstroAPI key nor the user's selected sign. The
response must contain twelve unique, validated readings for the exact requested
date; otherwise the bundled repository supplies the card automatically.
`PinnedHoroscopeRepository` stores the first resolved card for each sign/day in
`Application Support/ZodiacDaily/daily-editions.json`, so a network transition
cannot change the visible card later that day or after relaunch. This derived
cache rebuilds itself if its archive is corrupt; the separate user-owned saved
cards archive keeps the stricter fail-without-overwrite policy. If the derived
cache cannot write, the already resolved card is still shown for availability.

The Worker in `Backend/freeastro-worker` is read-only for public traffic. Only
its queue consumer can spend provider quota: normally twelve FreeAstroAPI
requests per day, paced at one per second, cached in Cloudflare KV. Cron
triggers only enqueue work so they stay below the free plan's tighter CPU
ceiling. No external account, secret, queue, KV namespace, or deployment has
been created yet.

## Persistence

`FileBackedSavedCardStore` stores versioned JSON in
`Application Support/ZodiacDaily/saved-cards.json`. It loads lazily inside an
actor, writes atomically, deduplicates by sign/day, and never replaces the first
saved snapshot with a later content version. The selected sign is stored in the
app's local `UserDefaults` container. Saved cards and the selected sign are not
transmitted. When remote content is enabled, the app sends the requested date
to the Zodiac Daily endpoint and normal HTTPS connection metadata is visible to
the hosting provider.

## Approved additional screens

Sign Selection, Saved empty/populated, and Settings/About implement their
owner-approved C2 complete-screen references. They preserve the midnight
editorial language, collectible-card hierarchy, Dynamic Type reflow, VoiceOver
labels, safe-area-aware scrolling, and minimum 44-point interactions.

Saved card detail remains **PROVISIONAL**. It reuses the approved card object,
but its surrounding navigation and remove-action hierarchy cannot become final
until `Design/Concepts/saved-detail-c2.png` receives explicit approval.

## Xcode handoff

- Open `ZodiacDaily.xcodeproj` on a Mac with Xcode.
- Target: `ZodiacDaily`, iPhone only, iOS 17.0+.
- Product name: Zodiac Daily.
- Provisional bundle identifier: `com.zodiacdaily.app`.
- Signing team: unset.
- Final app icon: intentionally absent.
- Local dependency: root Swift package product `ZodiacDailyCore`.
- Optional public configuration: `ZODIAC_DAILY_API_BASE_URL`; leave empty for
  fully local operation. It must never contain the provider key.
- The shared app scheme builds and runs the app. Run the root package tests
  separately with `swift test` from the repository root; they are not embedded
  as an Xcode unit-test target in the app scheme.

Run the package's `ZodiacDailyCoreTests`, then build the app in an iPhone
simulator. Verify small and large iPhones, at least one accessibility Dynamic
Type size, VoiceOver order, save/relaunch/remove behavior, local midnight, and a
same-size comparison against all approved C2 images. The unapproved Saved card
detail proposal must not be treated as a final screenshot target yet.
