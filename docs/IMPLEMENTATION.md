# iOS implementation

Updated: 2026-08-10

## Approved Today screen

The native Today view implements the approved
`Design/Concepts/today-c2-collectible-card.png` hierarchy:

- midnight editorial background and centered Zodiac Daily masthead;
- English local date and a 12-sign capsule menu;
- one complete, separately bounded collectible card with all corners visible;
- native procedural stars, twelve distinct constellation point sets, crescent,
  and waves;
- provider-authored headline and reading when configured, with bundled offline
  reading fallback;
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
date and selected app language. It sends neither a FreeAstroAPI key nor the
user's selected sign. The
response must contain twelve unique, validated readings for the exact requested
date; otherwise the bundled repository supplies the card automatically.
Schema 3 adds an explicit `language` and carries provider-authored focus,
keywords, four daily scores,
lucky values, and Moon data for the approved card reverse. The app never
manufactures replacements for those fields: bundled fallback is explicitly
shown as an offline edition with provider-only values absent.
`PinnedHoroscopeRepository` stores the first resolved card for each
language/sign/day in
`Application Support/ZodiacDaily/daily-editions.json`, so a network transition
cannot change the visible card later that day or after relaunch. This derived
cache rebuilds itself if its archive is corrupt; the separate user-owned saved
cards archive keeps the stricter fail-without-overwrite policy. If the derived
cache cannot write, the already resolved card is still shown for availability.

The Worker in `Backend/freeastro-worker` is read-only for public traffic. Only
its queue consumer can spend provider quota: normally twelve FreeAstroAPI
requests per new date, paced at one per second, cached in Cloudflare KV. The
same cached English document is translated once to Spanish through Workers AI;
app traffic never triggers translation or provider calls. Cron
triggers only enqueue work so they stay below the free plan's tighter CPU
ceiling. Production is active at
`https://zodiac-daily-content.krazel-zodiac-daily.workers.dev`; its provider key
exists only as an encrypted Worker secret.

## Persistence

`FileBackedSavedCardStore` stores versioned JSON in
`Application Support/ZodiacDaily/saved-cards.json`. It loads lazily inside an
actor, writes atomically, deduplicates by language/sign/day, and never replaces the first
saved snapshot with a later content version. The selected sign is stored in the
app's local `UserDefaults` container. Saved cards and the selected sign are not
transmitted. When remote content is enabled, the app sends the requested date
to the Zodiac Daily endpoint and normal HTTPS connection metadata is visible to
the hosting provider.

## Approved additional screens and icon

Sign Selection, Saved empty/populated, and Settings/About implement their
owner-approved C2 complete-screen references. They preserve the midnight
editorial language, collectible-card hierarchy, Dynamic Type reflow, VoiceOver
labels, safe-area-aware scrolling, and minimum 44-point interactions.

The owner's advance authorization also approves
`Design/Concepts/saved-detail-c2.png` and
`Design/Concepts/settings-support-c3.png` for final visual implementation.
Saved detail preserves the complete card object and places removal outside the
card. The Settings extension preserves the C2 sheet language while adding
optional support, review, privacy, and terms rows. Their implementation and
verification may proceed without another visual round, but that approval does
not authorize App Store Connect product creation or publication.

`Design/Concepts/app-icon-c1.png` is the approved icon reference. Its runtime
asset is stored under `ZodiacDaily/Assets.xcassets/AppIcon.appiconset`; App Store
submission and storefront artwork remain separate release actions.

## StoreKit support extension

StoreKit 2 support is implemented locally as an optional Settings feature. The
complete horoscope, Saved archive, and all core behavior remain free regardless
of supporter status. The seven equivalent monthly levels are:

- `com.krazel.zodiacdaily.support.monthly.099`;
- `com.krazel.zodiacdaily.support.monthly.299`;
- `com.krazel.zodiacdaily.support.monthly.499`;
- `com.krazel.zodiacdaily.support.monthly.999`;
- `com.krazel.zodiacdaily.support.monthly.1499`;
- `com.krazel.zodiacdaily.support.monthly.2999`; and
- `com.krazel.zodiacdaily.support.monthly.50`.

All seven display the same localized Monthly Supporter title and provide the
same benefit. The UI loads localized prices from StoreKit rather than embedding
reference prices. It includes explicit Restore
Purchases and Manage Subscription actions and remains useful when no products
are returned. Rate Zodiac Daily uses app ID `6800136195` for the App Store
`action=write-review` URL, so an explicit tap has a production destination. The
separate StoreKit system review prompt is eligible only after a successful save
produces at least three collected cards and only once per app version; Apple may
still suppress it.

## English and Spanish interface

`AppLanguage` persists `en` or `es` in local preferences. On first launch a
Spanish preferred device language selects Spanish; all other devices begin in
English. The root injects the selected locale so Settings can switch the live
interface without a relaunch. `Localizable.xcstrings` contains the English and
Spanish UI, navigation, zodiac names, dates, accessibility, error, and StoreKit
supporter copy.

The Today masthead has a visible 44-point Settings control while the sign
selector keeps its direct change-sign action. Settings contains Language,
Your Sign, Support the app, Restore/Manage Subscription, Rate, Help & Support,
Privacy, Terms, and About. FreeAstroAPI supplies the source English edition.
The production schema-3 Worker translates that cached document to Spanish once,
stores EN and ES separately, and never labels English as Spanish. If a Spanish
edition has not yet been pinned and the service is unavailable, the app reports
the failure instead of silently changing the reading to English. Saved
snapshots include their actual language, never overwrite the other language,
and never replace the live Today edition.

## Xcode handoff

- Open `ZodiacDaily.xcodeproj` on a Mac with Xcode.
- Target: `ZodiacDaily`, iPhone only, iOS 16.0+.
- Product name: Zodiac Daily.
- Registered production bundle identifier: `com.krazel.zodiacdaily`.
- App Store Connect record: **The Daily Zodiac**, app ID `6800136195`.
- Signing team: unset.
- Approved runtime icon: `ZodiacDaily/Assets.xcassets/AppIcon.appiconset`.
- Local dependency: root Swift package product `ZodiacDailyCore`.
- Public configuration: `ZODIAC_DAILY_API_BASE_URL` is set to the production
  Worker base URL. It must never contain the provider key.
- The shared app scheme builds and runs the app. Run the root package tests
  separately with `swift test` from the repository root; they are not embedded
  as an Xcode unit-test target in the app scheme.

Run the package's `ZodiacDailyCoreTests`, then build the app in an iPhone
simulator. Verify small and large iPhones, at least one accessibility Dynamic
Type size, VoiceOver order, save/relaunch/remove behavior, local midnight,
StoreKit empty/loading/purchase/restore states, and same-size comparisons
against all approved C2/C3 references. Archive, StoreKit testing, signing, and
runtime icon validation remain blocked until the project is opened on a Mac
with Xcode. Production support additionally requires the App Store Connect
products and group, App Store ID, public legal/support URLs, and signing setup.
