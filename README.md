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

- Product: MVP defined for iPhone, English only.
- Visuals: the complete C2 references, Settings Support C3, and app icon C1 are
  approved under the owner's advance visual authorization.
- Code: the approved screens are implemented in the iOS 16 SwiftUI project,
  including final saved-card detail and optional monthly supporter controls.
- Persistence: saved-card snapshots use an actor-isolated, atomic JSON archive
  in Application Support; the selected sign uses local app preferences.
- Daily content: the FreeAstroAPI-to-Cloudflare Worker is deployed and the app
  is configured to load the complete twelve-sign daily
  edition through our endpoint, pins the first resolved sign/day card locally,
  and falls back locally on any failure.
- Support: StoreKit 2 loads three equivalent monthly levels using Apple's live
  localized prices. The app remains fully usable for free and includes verified
  entitlement status, restore, and subscription management.
- External services: the free provider account, encrypted Worker secret, KV
  cache, Queue, cron triggers, and public cache-only HTTPS endpoint are active.
- GitHub: public repository `Krazel/zodiac-daily-ios`; `main` is current.

Open `ZodiacDaily.xcodeproj` on a Mac with Xcode. The registered bundle
identifier is `com.krazel.zodiacdaily`; the App Store Connect app ID is
`6800136195`. No signing team or App Store Connect products are configured. The
unsigned Release device build compiles successfully in GitHub Actions. XCTest,
StoreKit sandbox verification, signed-device testing, and simulator comparison
remain pending.

See `docs/MVP.md`, `docs/VISUAL_FIRST.md`, `docs/ASSET_INVENTORY.md`, and
`docs/TECHNICAL_SETUP.md`.
