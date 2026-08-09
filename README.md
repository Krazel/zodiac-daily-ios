# Zodiac Daily Native

Independent iOS app for a brief, editorial daily horoscope ritual. The working
public name is **Zodiac Daily** and the internal project name is
`ZodiacDailyNative`.

The current milestone implements the owner-approved C2 Today, Sign Selection,
Saved empty/populated, and Settings screens as a native SwiftUI app. The visual
gate remains active for Saved card detail and later production artwork. Engine,
content, and persistence are fully local.

## Current status

- Product: MVP defined for iPhone, English only.
- Visuals: the five complete C2 references for Today, Sign Selection, Saved
  empty/populated, and Settings were approved on 2026-08-09.
- Code: those approved screens are implemented in the iOS 17 SwiftUI project.
  Saved card detail remains explicitly provisional while
  `Design/Concepts/saved-detail-c2.png` awaits approval.
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
