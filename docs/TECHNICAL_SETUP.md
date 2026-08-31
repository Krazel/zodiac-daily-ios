# Technical setup

Updated: 2026-08-10

## Implemented core and app shell

- Swift Package `ZodiacDailyCore`; no UI or third-party dependencies.
- Twelve stable zodiac-sign identifiers and Gregorian `LocalDayKey`.
- Versioned, bundled English catalog with deterministic FNV-1a selection.
- Separate edition identity and sign/day archive key.
- Immutable saved-card snapshots behind `SavedCardStore`.
- In-memory actor store for focused tests.
- Actor-isolated JSON file store with lazy loading, atomic writes, immutable
  snapshot semantics, relaunch persistence, and corrupt-archive errors.
- XCTest coverage for catalog validity, all 12 signs, deterministic editions,
  local midnight/time zones/DST, content-version snapshots, save/remove,
  ordering, deduplication, JSON relaunch persistence, and corrupt archives.
- Manual `ZodiacDaily.xcodeproj` for an iPhone-only iOS 16 SwiftUI app with the
  local package linked and no third-party dependencies.
- Approved Today C2 implementation: native midnight background, masthead, sign
  selector, complete bordered card, procedural celestial art, daily local
  content, and separate save/remove action.
- Owner-approved native C2 implementations for Sign Selection, Saved empty and
  populated states, and Settings/About.
- Advance authorization approves the final references
  `Design/Concepts/saved-detail-c2.png` and
  `Design/Concepts/settings-support-c3.png`; their local implementation and
  verification may proceed without another visual round.
- Approved icon C1 is represented at runtime by
  `ZodiacDaily/Assets.xcassets/AppIcon.appiconset`.
- Privacy manifest declares no tracking or collected data and documents the
  app-only UserDefaults use.
- Remote daily repository with strict HTTPS/date/twelve-sign validation and an
  automatic bundled fallback.
- Durable first-edition pinning by sign/day so remote and fallback changes do
  not alter a card during the day or after relaunch.
- Deployed Cloudflare Worker adapter with queue-based FreeAstroAPI ingestion,
  exact-date KV cache, secret isolation, and public cache-only routes. Cron
  triggers only enqueue work; the free queue consumer handles the heavier
  twelve-sign normalization outside the cron's 10 ms CPU ceiling.

The JSON catalog, plist, project references, and repository structure have been
checked on Windows. The unsigned Release device app compiles in GitHub Actions
with an iOS 16.0 minimum. XCTest execution, simulator checks, and visual
comparison remain pending because Swift/Xcode are not installed locally.

## StoreKit 2 support

- The core app remains free; supporter status cannot gate Today, Saved, content,
  settings, or offline behavior.
- Seven equivalent monthly product IDs are fixed locally:
  `com.krazel.zodiacdaily.support.monthly.099`,
  `com.krazel.zodiacdaily.support.monthly.299`,
  `com.krazel.zodiacdaily.support.monthly.499`,
  `com.krazel.zodiacdaily.support.monthly.999`,
  `com.krazel.zodiacdaily.support.monthly.1499`,
  `com.krazel.zodiacdaily.support.monthly.2999`, and
  `com.krazel.zodiacdaily.support.monthly.50`.
- Every product uses the same localized Monthly Supporter title and the same
  supporter-status benefit. StoreKit's live localized price is the only
  user-facing distinction between levels.
- Products must be loaded from StoreKit and rendered with their localized
  names/prices. Empty, partial, restricted-payment, loading, and retry states
  must not display reference-image prices as real offers.
- Verified StoreKit 2 entitlements drive supporter status. Restore Purchases is
  explicit, and Manage Subscription uses the system subscription UI.
- Rate Zodiac Daily uses app ID `6800136195` for the App Store
  `action=write-review` URL. The separate system review prompt is triggered
  conservatively after a successful third-card save, at most once per app
  version.
- Local implementation is complete. Product/group creation, Xcode StoreKitTest,
  sandbox validation, and production activation remain external release work.

## Recommended architecture

- Native SwiftUI and Swift.
- Deployment target: iOS 16 or later.
- No third-party dependencies for the MVP.
- Pure Swift domain core with repository and store boundaries; no SwiftUI or
  SwiftData types in domain models.
- A selected-sign store that can later be backed by `@AppStorage` in app
  infrastructure.
- A `SavedCardStore` protocol with a JSON file-backed actor in app
  infrastructure; saved cards retain an immutable content snapshot.
- Bundled local content behind a replaceable `HoroscopeRepository`; the remote
  repository is optional and never prevents offline reading. There are no user
  accounts, analytics, or personal-data requests.
- `ShareLink` remains isolated as a later stretch option.

## Structure that may advance before visual approval

```text
ZodiacDaily.xcodeproj
ZodiacDaily/
  App/
  Core/Models/
  Core/Content/
  Core/Date/
  Infrastructure/Preferences/
  Infrastructure/Persistence/
  Features/SignSelection/
  Features/Daily/
  Features/Saved/
  Features/Settings/
  Store/
  DesignSystem/
  Resources/
  Assets.xcassets/
ZodiacDailyTests/
ZodiacDailyUITests/
```

## Verification plan

- Stable Gregorian local-day key and correct transition at midnight.
- Explicit injected clock, calendar, and time-zone policy; no process-random
  `Hasher` for persistent identifiers.
- Content coverage for all 12 signs and every shipped edition.
- Save, unsave, duplicate prevention, persistence, and relaunch behavior.
- First launch, sign change, offline behavior, and corrupt-content error path.
- Dynamic Type, VoiceOver, contrast, and touch targets.
- Same-size visual comparison against each approved screen reference.
- StoreKit product loading, verification, pending/cancelled purchases,
  entitlement updates, restore, manage-subscription presentation, and absence
  of products.
- Runtime validation of the C1 icon catalog on device/simulator and archive.

Core/data/persistence tests may be authored before visual approval. Final views,
layout, art, icons, store captures, and major visual motion remain gated.

## Environment and external setup

The current Windows environment has Git but not Swift or Xcode. Project
generation, compilation, simulator testing, signing, and archiving require a Mac
with the agreed Xcode version.

The App Store Connect record and production App Store ID now exist. StoreKit
production activation still requires one subscription group containing all
seven equivalent monthly products, published legal/support URLs, and a signing
team. Those remaining external resources are not created by the local
implementation.

The free content adapter is active. FreeAstroAPI is stored only as the encrypted
Worker secret `FREEASTRO_API_KEY`; Cloudflare KV, Queue, cron triggers, and the
public cache-only endpoint are deployed. The Xcode build setting points to
`https://zodiac-daily-content.krazel-zodiac-daily.workers.dev`. Maintenance and
verification steps live in `Backend/freeastro-worker/README.md`.

The GitHub repository is the public `Krazel/zodiac-daily-ios`, with branch
`main` and remote `origin`. Its manual Local QA workflow uses no signing or
App Store secrets and performs no external upload.

## Current project values and decisions still open

- Deployment minimum: iOS 16.0.
- Registered production bundle identifier: `com.krazel.zodiacdaily`.
- App Store Connect: **The Daily Zodiac**, app ID `6800136195`.
- Confirm the signing team before device, archive, or distribution work.
- Record the final Privacy Policy, Terms/EULA, and support URLs.
- Create and validate the StoreKit subscription group/products only after
  explicit external authorization.
- Define the authored content horizon and update model for bundled readings.
- Confirm rights-safe production fonts and illustrations after visual approval.
