# iOS launch readiness

Updated: 2026-08-10

Planning only. This document does not authorize account creation, secrets,
StoreKit products, uploads, TestFlight, App Review, or publication.

## Recorded scope

- iPhone / iOS 17+, English only.
- Intended production bundle identifier: `com.krazel.zodiacdaily`.
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

- Approved reference: `Design/Concepts/settings-support-c3.png`, covered by the
  owner's advance visual authorization.
- Placement: an extension inside Settings titled `Support the app`.
- The complete free horoscope, saved cards, and settings remain available
  without payment.
- StoreKit 2 implementation is complete locally; no App Store Connect products
  or subscription group have been created.
- Equivalent monthly auto-renewing supporter levels:
  - `com.krazel.zodiacdaily.support.monthly`;
  - `com.krazel.zodiacdaily.support.kind`;
  - `com.krazel.zodiacdaily.support.generous`.
- All three must belong to one subscription group and provide the same core
  supporter status; none unlocks horoscope or Saved functionality.
- Minimum benefit: active supporter status in Settings, a thank-you message,
  and a short explanation that support funds maintenance and updates.
- Required purchase information: live localized StoreKit price, monthly duration,
  auto-renewal, cancellation, Restore Purchases, Manage Subscription, privacy,
  and terms/EULA.
- Optional reminder: low frequency only after meaningful use, never on first
  launch or during a critical action, with `Not now` and `Don't ask again`.
- App Store review is separate. The persistent Rate Zodiac Daily row will open
  the App Store `action=write-review` URL after the production App Store ID is
  assigned; it must not contain a placeholder ID. A StoreKit system prompt is
  eligible only after a successful third-card save and once per app version.

[App Review guideline 3.1.2](https://developer.apple.com/app-store/review/guidelines/#subscriptions)
requires auto-renewable subscriptions to provide ongoing value. Before creating
the products, confirm with App Store Connect or Apple Developer Support that the
persistent cross-device supporter status and maintenance/update proposition are
sufficient. If they are not, keep the same optional Settings presentation but
change the external product model to one-time support purchases before
submission; do not submit a knowingly weak subscription proposition.

Saved detail (`Design/Concepts/saved-detail-c2.png`) and the app icon
(`Design/Concepts/app-icon-c1.png`) are also approved through advance visual
authorization. The runtime icon is present in
`ZodiacDaily/Assets.xcassets/AppIcon.appiconset`. These approvals authorize
local implementation only, not uploads or external activation.

## External release blockers

- Mac with Xcode for build, StoreKitTest, simulator, archive, and icon checks.
- App Store Connect app record, one subscription group, and all three products.
- Production App Store ID for the write-review URL.
- Published Privacy Policy, Terms of Use/EULA, and support URLs.
- Production signing team, certificates, and provisioning.

## Local QA IPA workflow

`.github/workflows/build-ios-local-qa.yml` is a manual, owner-only GitHub
Actions workflow for a compile-validated unsigned device IPA. It uses no Apple
or App Store Connect secrets and performs no release, TestFlight, or App Store
upload. The downloaded `ZodiacDaily-Local-QA-unsigned.ipa` is intended as input
to a local signing/install tool such as Sideloadly; it is not directly
installable until that tool signs it for the test device.

The workflow validates bundle ID `com.krazel.zodiacdaily`, marketing version
`0.1.0`, build number, iOS 17 minimum, executable, privacy manifest, compiled
assets, and bundled horoscope content before packaging. It has not run yet:
this repository currently has no GitHub remote and the local GitHub CLI session
must be reauthenticated before a workflow can be pushed or dispatched.

## Remaining release checklist

- [x] Approve Saved card detail visual.
- [x] Approve Settings support/review extension visual.
- [x] Approve app icon C1 and prepare its runtime asset catalog.
- [ ] Create shared privacy and support pages.
- [ ] Publish or select a Terms of Use/EULA URL.
- [ ] Confirm `com.krazel.zodiacdaily` and the signing team.
- [ ] Record App Store Connect app ID, version, and build.
- [ ] Complete age rating, content-rights, export-compliance, and App Privacy
      answers.
- [x] Define supporter product IDs locally.
- [ ] Create the App Store Connect subscription group/products after explicit
      external authorization.
- [ ] Resolve the guideline 3.1.2 ongoing-value review risk before product
      creation; use one-time support products if Apple requires it.
- [x] Implement supporter status, dynamic prices, restore purchases, management
      sheet, privacy, and terms locally.
- [ ] Validate all StoreKit states with a local configuration and sandbox on Mac.
- [ ] Validate archive, XCTest, simulator, Dynamic Type, and VoiceOver on Mac.
- [x] Prepare a manual, no-secret Local QA IPA artifact workflow.
- [ ] Reauthenticate GitHub, create/select the private remote, push the workflow,
      and run it to obtain the unsigned IPA artifact.
- [ ] Validate the approved runtime icon and prepare App Store screenshots.
- [ ] Prepare a protected manual upload workflow; do not add secrets yet.
- [ ] Obtain explicit authorization before any account/product creation,
      secret use, upload, IAP review, App Review, or publication.
