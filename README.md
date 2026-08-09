# Zodiac Daily Native

Independent iOS app for a brief, editorial daily horoscope ritual. The working
public name is **Zodiac Daily** and the internal project name is
`ZodiacDailyNative`.

The current milestone implements the owner-approved C2 Today screen as a native
SwiftUI app while preserving the per-screen visual gate for the remaining
flows. Engine, content, and persistence are fully local.

## Current status

- Product: MVP defined for iPhone, English only.
- Visuals: `today-c2-collectible-card.png` was approved on 2026-08-09 and is the
  final visual reference for Today.
- Code: iOS 17 SwiftUI project and Today are implemented. Sign Selection, Saved,
  and Settings are functional system-UI scaffolds explicitly marked provisional
  until their own complete-screen images are approved.
- Persistence: saved-card snapshots use an actor-isolated, atomic JSON archive
  in Application Support; the selected sign uses local app preferences.
- External services: none.
- GitHub: private repository pending explicit authorization.

Open `ZodiacDaily.xcodeproj` on a Mac with Xcode. The provisional bundle
identifier is `com.zodiacdaily.app`; no signing team or final app icon is set.
Swift compilation, tests, and simulator comparison are still pending because
the current environment is Windows.

See `docs/MVP.md`, `docs/VISUAL_FIRST.md`, `docs/ASSET_INVENTORY.md`, and
`docs/TECHNICAL_SETUP.md`.
