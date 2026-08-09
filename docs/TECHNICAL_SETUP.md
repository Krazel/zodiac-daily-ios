# Technical setup

Updated: 2026-08-09

## Recommended architecture

- Native SwiftUI and Swift.
- Proposed deployment target: iOS 17 or later.
- No third-party dependencies for the MVP.
- Lightweight feature-first structure with repository boundaries.
- `@AppStorage` for the selected sign.
- SwiftData for saved cards.
- Bundled local content behind a replaceable `HoroscopeRepository`; no backend,
  account, analytics, or network dependency.
- `ShareLink` remains isolated as a later stretch option.

## Planned structure after visual approval

```text
ZodiacDaily.xcodeproj
ZodiacDaily/
  App/
  Core/Models/
  Core/Content/
  Core/Date/
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
- Content coverage for all 12 signs and every shipped edition.
- Save, unsave, duplicate prevention, persistence, and relaunch behavior.
- First launch, sign change, offline behavior, and corrupt-content error path.
- Dynamic Type, VoiceOver, contrast, and touch targets.
- Same-size visual comparison against each approved screen reference.

## Environment and external setup

The current Windows environment has Git but not Swift or Xcode. Project
generation, compilation, simulator testing, signing, and archiving require a Mac
with the agreed Xcode version.

The intended GitHub repository is a private repository named
`zodiac-daily-ios`, with branch `main` and remote `origin`. Creating it and
pushing are deliberately pending explicit authorization because they change an
external service.

## Decisions still open

- Confirm iOS 17 as the deployment minimum.
- Confirm bundle identifier and signing team before project generation.
- Define the authored content horizon and update model for bundled readings.
- Confirm rights-safe production fonts and illustrations after visual approval.
