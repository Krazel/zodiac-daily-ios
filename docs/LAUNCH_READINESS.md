# iOS launch readiness

Updated: 2026-08-09

Planning only. This document does not authorize account creation, secrets,
StoreKit products, uploads, TestFlight, App Review, or publication.

## Recorded scope

- iPhone / iOS 17+, English only.
- Working bundle identifier: `com.zodiacdaily.app` (provisional).
- App category: Lifestyle (provisional).
- App slug: `zodiac-daily`.
- Planned privacy URL:
  `https://krazel.github.io/zodiac-daily/privacy/`.
- Planned support URL:
  `https://krazel.github.io/zodiac-daily/support/`.
- No ads or AdMob planned.
- FreeAstroAPI content is fetched through the Zodiac Daily Worker; the app sends
  no provider key, account, birth data, saved cards, or selected sign. It sends
  the requested date, and the host sees ordinary HTTPS connection metadata.
- Before App Privacy answers are finalized, confirm Worker/Cloudflare logging
  and retention are minimized and match the public privacy page.

## Voluntary supporter plan

- Placement: a visually approved extension inside Settings titled
  `Support the app`.
- The complete free horoscope, saved cards, and settings remain available
  without payment.
- Preferred products: equivalent monthly auto-renewing supporter levels.
- Minimum benefit: active supporter status in Settings, a thank-you message,
  and a short explanation that support funds maintenance and updates.
- Required purchase information: localized price, monthly duration,
  auto-renewal, cancellation, Restore Purchases, Manage Subscription, privacy,
  and terms/EULA.
- Optional reminder: low frequency only after meaningful use, never on first
  launch or during a critical action, with `Not now` and `Don't ask again`.
- App Store review is separate: a persistent Settings entry and conservative
  StoreKit review request timing.

The Settings extension has no approved visual reference yet. No StoreKit UI or
product identifiers may be finalized until that visual gate and the separate
product-creation authorization are satisfied.

## Remaining release checklist

- [ ] Approve Saved card detail visual.
- [ ] Generate and approve Settings support/review extension visual.
- [ ] Create shared privacy and support pages.
- [ ] Confirm production bundle identifier and signing team.
- [ ] Record App Store Connect app ID, version, and build.
- [ ] Complete age rating, content-rights, export-compliance, and App Privacy
      answers.
- [ ] Define supporter product IDs and subscription group after authorization.
- [ ] Implement and test supporter status, restore purchases, management link,
      privacy, and terms after visual approval.
- [ ] Validate archive, XCTest, simulator, Dynamic Type, and VoiceOver on Mac.
- [ ] Prepare icon and App Store screenshots through visual-first approval.
- [ ] Prepare a protected manual upload workflow; do not add secrets yet.
- [ ] Obtain explicit authorization before any account/product creation,
      secret use, upload, IAP review, App Review, or publication.
