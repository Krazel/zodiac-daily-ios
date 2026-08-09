# Technical setup

Updated: 2026-08-09

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
- Manual `ZodiacDaily.xcodeproj` for an iPhone-only iOS 17 SwiftUI app with the
  local package linked and no third-party dependencies.
- Approved Today C2 implementation: native midnight background, masthead, sign
  selector, complete bordered card, procedural celestial art, daily local
  content, and separate save/remove action.
- Owner-approved native C2 implementations for Sign Selection, Saved empty and
  populated states, and Settings/About. Only Saved card detail remains
  explicitly **PROVISIONAL** pending its own approval.
- Privacy manifest declares no tracking or collected data and documents the
  app-only UserDefaults use.

The JSON catalog, plist, project references, and repository structure have been
checked on Windows. Swift compilation, XCTest execution, simulator checks, and
visual comparison remain pending because Swift/Xcode are not installed here.

## Recommended architecture

- Native SwiftUI and Swift.
- Proposed deployment target: iOS 17 or later.
- No third-party dependencies for the MVP.
- Pure Swift domain core with repository and store boundaries; no SwiftUI or
  SwiftData types in domain models.
- A selected-sign store that can later be backed by `@AppStorage` in app
  infrastructure.
- A `SavedCardStore` protocol with a JSON file-backed actor in app
  infrastructure; saved cards retain an immutable content snapshot.
- Bundled local content behind a replaceable `HoroscopeRepository`; no backend,
  account, analytics, or network dependency.
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

Core/data/persistence tests may be authored before visual approval. Final views,
layout, art, icons, store captures, and major visual motion remain gated.

## Environment and external setup

The current Windows environment has Git but not Swift or Xcode. Project
generation, compilation, simulator testing, signing, and archiving require a Mac
with the agreed Xcode version.

The intended GitHub repository is a private repository named
`zodiac-daily-ios`, with branch `main` and remote `origin`. Creating it and
pushing are deliberately pending explicit authorization because they change an
external service.

## Current project values and decisions still open

- Deployment minimum: iOS 17.
- Provisional bundle identifier: `com.zodiacdaily.app`.
- Confirm the production bundle identifier and signing team before device,
  archive, or distribution work.
- Define the authored content horizon and update model for bundled readings.
- Confirm rights-safe production fonts and illustrations after visual approval.
