# Zodiac Daily Native

Independent iOS app for a brief, editorial daily horoscope ritual. The public
App Store name is **The Daily Zodiac**, the in-app brand is **Zodiac Daily**,
and the internal project name is `ZodiacDailyNative`.

The current milestone implements the owner-approved C2 Today, Sign Selection,
Saved empty/populated/detail, Settings, and optional Support experience as a
native SwiftUI app. Engine, preferences, saved cards, and a date-correct
fallback remain local; fresh daily content can come from the optional Zodiac
Daily endpoint.

## Current status

- Product: MVP defined for iPhone with an English/Spanish interface and daily
  editions in the selected language. The production service translates the
  provider's English source edition once, caches separate English and Spanish
  documents, and never changes a Spanish request silently to English.
- Visuals: the complete C2 references, Settings Support C3, and app icon C1 are
  approved under the owner's advance visual authorization.
- Code: the approved screens are implemented in the iOS 16 SwiftUI project,
  including final saved-card detail and optional monthly supporter controls.
- Persistence: saved-card snapshots use an actor-isolated, atomic JSON archive
  in Application Support; the selected sign uses local app preferences.
- Daily content: the production schema-3 service prepares separate English and
  Spanish twelve-sign documents, and the app requests `lang=en|es`. Today uses
  that live/pinned edition; old Saved snapshots cannot replace it.
- Support: StoreKit 2 loads three equivalent monthly levels using Apple's live
  localized prices. The app remains fully usable for free and includes verified
  entitlement status, restore, and subscription management.
- Settings: a visible gear opens sign, language, optional support, review,
  help, privacy, terms, and About controls. Language follows Spanish devices on
  first launch and can be changed instantly between English and Español.
- External services: the free provider account, encrypted Worker secret, KV
  cache, Queue, cron triggers, and public cache-only HTTPS endpoint are active.
- GitHub: public repository `Krazel/zodiac-daily-ios`; the local `0.2`
  candidate is awaiting its release commit and push.

Open `ZodiacDaily.xcodeproj` on a Mac with Xcode. The registered bundle
identifier is `com.krazel.zodiacdaily`; the App Store Connect app ID is
`6800136195`. Release signing is configured through the protected GitHub
environment; no App Store Connect products are configured. The previous signed
TestFlight build passed archive/export. XCTest, analysis, signing, and export
for this `0.2` candidate remain gated by its macOS workflow.

See `docs/MVP.md`, `docs/VISUAL_FIRST.md`, `docs/ASSET_INVENTORY.md`, and
`docs/TECHNICAL_SETUP.md`.
