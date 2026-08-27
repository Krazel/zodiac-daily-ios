# iOS launch readiness

Updated: 2026-08-26

Internal TestFlight `0.3` (`1`) is processed as `VALID` and is available to the
automatic internal `Testers` group. It adds the approved C5B card frame and
larger measured reading, fixes compact stationary positioning, speeds Settings
localization, and makes sign changes immediate from Today and Settings. Its data
flow and monetization state are unchanged. Historical `0.2.3` (`1`) remains the
correction that replaced the disconnected 0.2.2 candidate.
This document does not authorize StoreKit products, external testing, App
Review, or publication.

## Recorded scope

- Historical internal TestFlight delivery 0.2.2/1: known disconnected build;
  do not use it for acceptance testing.
- Current internal TestFlight 0.3/1: iPhone / iOS 16+, English/Spanish interface and
  language-specific daily editions selected in Settings.
- This correction prevents legacy Saved cards
  from replacing the live Spanish edition, makes Spanish strict, repairs the
  direct sign selector, and applies the owner-directed Today spacing and icon
  refinements.
- The production schema-3 Worker caches English and Spanish separately. It
  translates each provider edition once; user traffic only reads the cache.
- Registered production bundle identifier: `com.krazel.zodiacdaily`.
- App Store Connect record: **The Daily Zodiac**, app ID `6800136195`, primary
  language English (U.S.), SKU `zodiac-daily-ios`.
- Subtitle: `Daily Horoscope & Zodiac`.
- Primary category: Lifestyle. Secondary category: Magazines & Newspapers.
- Price: free in all 175 App Store territories. Public distribution is enabled;
  Apple silicon Mac and Apple Vision Pro availability are disabled.
- App slug: `zodiac-daily`.
- Live privacy URL:
  `https://krazel.github.io/zodiac-daily/privacy/`.
- Live support URL:
  `https://krazel.github.io/zodiac-daily/support/`.
- No ads or AdMob planned.
- FreeAstroAPI content is fetched through the Zodiac Daily Worker; the app sends
  no provider key, account, birth data, saved cards, or selected sign. It sends
  the requested date and `en`/`es` content language, and the host sees ordinary
  HTTPS connection metadata.
- Content rights are declared for licensed third-party horoscope content.
- The age-rating questionnaire is complete: 9+ globally (12+ in Vietnam and
  Brazil), with health or wellness topics disclosed and every other listed
  content category marked absent.
- App Privacy is saved as `No data collected`. This is accurate under Apple's
  definition because the date request is used in real time and is not retained
  or associated with an identity. The live privacy URL is saved; the answer
  remains unpublished pending explicit publication authorization.
- Export compliance is declared in the build with
  `ITSAppUsesNonExemptEncryption = NO`; the app implements no proprietary or
  non-exempt encryption and relies only on standard HTTPS provided by Apple.
- Description, keywords, copyright, exact-build review notes, required support
  and privacy URLs, private review contact, and the no-login state are saved in
  App Store Connect. Optional promotional text, marketing URL, privacy-choices
  URL, and attachment are blank.
- The release data-flow audit is recorded in
  `docs/DATA_MINIMIZATION_AUDIT.md`: no permissions, accounts, ads, analytics,
  or third-party SDKs; date-and-language-only HTTPS request; local-only
  sign/cards/settings; StoreKit present but no active product.

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
- App Store review is separate. The persistent Rate Zodiac Daily row uses app
  ID `6800136195` for its App Store `action=write-review` URL. A StoreKit system
  prompt is eligible only after a successful third-card save and once per app
  version.

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

- Mac/Xcode or a device for StoreKitTest, simulator screenshot comparison,
  Dynamic Type, VoiceOver, and final icon checks. The signed archive and
  internal TestFlight upload already pass in GitHub Actions.
- EU DSA compliance is submitted and currently `In Review`; an unresolved or
  rejected result blocks EU distribution but does not justify changing trader
  status or exposing the private review contact publicly.

## Local QA IPA workflow

`.github/workflows/build-ios-local-qa.yml` is a manual, owner-only GitHub
Actions workflow for a compile-validated unsigned device IPA. It uses no Apple
or App Store Connect secrets and performs no release, TestFlight, or App Store
upload. The downloaded versioned `ZodiacDaily-...-Local-QA-unsigned.ipa` and its
manifest record app, version, build, commit, purpose, and GitHub run evidence.
The IPA is intended as input to a local signing/install tool such as Sideloadly;
it is not directly installable until that tool signs it for the test device.

The deliverable workflow currently validates bundle ID
`com.krazel.zodiacdaily`, marketing version `0.3`, build `1`, iOS 16 minimum,
the packaged endpoint and App Store ID, executable endpoint fallback, privacy
manifest, compiled assets, and bundled horoscope content before packaging.
Historical run `31347517648` (workflow run 5) completed
successfully for the prior unsigned iOS 16 Local QA IPA. The public remote is
`Krazel/zodiac-daily-ios`; the GitHub
connector's repo-specific access remains optional because the existing Git
credential can push and dispatch this workflow.

Correction run `32912659741` completed successfully from commit `fb65eb9` for
0.2.3/1: 65 Core tests passed, the unsigned Release app built, the packaged
endpoint and App Store ID matched, the executable endpoint fallback was found,
and the versioned Local QA IPA artifact was stored. This is validation only and
did not sign with distribution credentials or contact App Store Connect.

## Internal TestFlight

The protected manual workflow
`.github/workflows/build-ios-testflight.yml` compiled, tested, analyzed,
archived, signed, inspected, exported, and uploaded version `0.3` build `1`.
Run `33029296526` completed successfully from commit `77c381c`; App Store
Connect inspection run `33029584933` reports the build `VALID`, iOS 16.0
minimum, no non-exempt encryption, internal-only, and available to the
automatic internal `Testers` group. Full non-secret evidence is in
`docs/TESTFLIGHT_STATUS.md`.

No external group, public TestFlight link, Beta App Review, App Review, or App
Store release was created.

Version `0.2.2` build `1` passed the no-upload signed candidate run
`32175886395` and visual run `32175884780`. The latter captures the current
English/Spanish Today front, complete provider-data reverse, long Spanish copy,
and iPhone SE stationary layout. The owner-authorized upload run `32906780701`
then passed Apple's verification and upload with delivery UUID
`0543a959-d7a8-456d-8fce-b5b1132b960c`. TestFlight availability follows
Apple's processing of that accepted delivery.

Post-delivery inspection found that the 0.2.2 IPA omitted both custom plist
values, so it could not contact the Worker. Version 0.2.3 build 1 is the
corrective build. Upload run `32915420982` passed 65 tests, Release analysis,
signed archive configuration checks, export, Apple verification, and Apple
upload. Delivery UUID: `a8f5f3b7-d5df-4a4d-9427-5a421f7aebe3`.
Read-only App Store Connect run `32915848511` confirmed `VALID`, iOS 16.0,
`INTERNAL_ONLY`, not expired, and automatic access for the internal `Testers`
group.

## Remaining release checklist

- [x] Approve Saved card detail visual.
- [x] Approve Settings support/review extension visual.
- [x] Approve app icon C1 and prepare its runtime asset catalog.
- [x] Publish shared privacy and support pages.
- [x] Enter the live privacy and support URLs in App Store Connect; leave the
      optional privacy-choices and marketing URLs blank.
- [x] Use Apple's standard EULA; no custom EULA is required for the current
      free core.
- [x] Confirm the production signing team for `com.krazel.zodiacdaily`.
- [x] Record App Store Connect app ID `6800136195`, version `0.1.1`, and build
      `1`. Release is configured for manual publication.
- [x] Complete age rating, content rights, and export compliance.
- [ ] Publish the saved `No data collected` App Privacy answer only after
      explicit authorization.
- [x] Keep the required App Review contact complete in Apple's private review
      section; do not copy its values to public pages or repository docs.
- [ ] Confirm that Apple's EU DSA compliance review has completed successfully.
- [x] Define supporter product IDs locally.
- [ ] Create the App Store Connect subscription group/products after explicit
      external authorization.
- [ ] Resolve the guideline 3.1.2 ongoing-value review risk before product
      creation; use one-time support products if Apple requires it.
- [x] Implement supporter status, dynamic prices, restore purchases, management
      sheet, privacy, and terms locally.
- [ ] Validate all StoreKit states with a local configuration and sandbox on Mac.
- [x] Validate archive and XCTest on GitHub-hosted macOS/Xcode.
- [ ] Validate simulator screenshots, Dynamic Type, and VoiceOver on Mac.
- [x] Prepare a manual, no-secret Local QA IPA artifact workflow.
- [x] Create the private GitHub remote, push `main`, run the workflow, and
      obtain the unsigned IPA artifact.
- [ ] Validate the approved runtime icon and prepare App Store screenshots.
- [x] Prepare a protected manual upload workflow and complete the explicitly
      authorized internal TestFlight upload.
- [x] Obtain explicit authorization for signing-secret use and the internal
      TestFlight upload.
- [ ] Obtain separate explicit authorization before external testing, IAP
      review, App Review, or publication.
