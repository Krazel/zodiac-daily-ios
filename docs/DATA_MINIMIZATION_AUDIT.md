# Data and public-information minimization audit

Audited: 2026-08-31

Release candidate: iOS `1.0` / build `1`

This inventory describes the shipped code and current App Store Connect record,
not future features. It must be repeated before any later build that adds an
SDK, permission, account, upload, analytics, ads, or active StoreKit product.

The `app-language` preference stores only `en` or `es`
in `UserDefaults`. The same two-letter code is added to the daily content
request so the endpoint can return the requested edition; it is not associated
with an account, identifier, selected sign, analytics, or support record. This
does not change the current `No data collected` result, but the full audit must
still be rerun against the exact next build.

## Release data flow

| Area | Exact release behavior | Retention / control | Result |
| --- | --- | --- | --- |
| Accounts and user-entered fields | No account, login, birth date, name, email, phone, location, free-form text, or profile field exists in the app. | Not applicable. | Minimal. |
| Permissions and entitlements | No protected-device permission is requested. The target contains no usage-description keys and no entitlement file. | Not applicable. | Minimal. |
| Selected sign | Stored in `UserDefaults` on the device. | Changes when the user selects another sign; removed with app deletion. | Local only. |
| Saved cards and daily cache | `saved-cards.json` and `daily-editions.json` are stored in the app's Application Support directory. | Cards can be removed in the app; all files are removed with app deletion. | Local only. |
| Review prompt state | The app version already prompted for a review is stored in `UserDefaults`. | Replaced per version; removed with app deletion. | Local only. |
| Daily content request | One HTTPS `GET /v1/daily/YYYY-MM-DD?lang=en\|es` request. The app sends only the local date and two-letter content language, plus `Accept: application/json`; it sends no selected sign, saved card, birth data, account identifier, advertising identifier, or location. | Date and language are used only to return the edition. Krazel does not retain or associate connection data with a user. | Apple's real-time request exception supports `No data collected`. |
| Network infrastructure | The hosting layer necessarily handles transient connection metadata such as IP address to route and secure HTTPS. | Not retained or used by Krazel for identity, profiling, analytics, ads, or tracking. | Disclosed concisely in the privacy policy. |
| StoreKit | Apple StoreKit implementation remains compiled for a later release, but `supporterPurchasesEnabled` is false in version `1.0`: Settings exposes no purchase, price, restore, or manage-subscription control and the app does not start the product catalog. App Store Connect has no IAP or subscription product. | No purchase can be initiated and no payment details are received or stored by Krazel. Re-audit and obtain separate approval before activating a product. | No unavailable purchase is presented by the release candidate. |
| SDKs | SwiftUI, Foundation, Combine, and StoreKit are Apple frameworks. `ZodiacDailyCore` is a local Swift package. No AdMob, analytics, crash-reporting, attribution, social, advertising, or other third-party SDK is linked. | Not applicable. | No SDK disclosure omitted. |
| Support email | Support is external and voluntary through the public alias `coderappskrazel@gmail.com`. | Used only to answer support; deletion may be requested unless legal retention applies. | Public alias only; no personal owner details. |

The Privacy Manifest declares no tracking, no collected data types, no tracking
domains, and only the required-reason `UserDefaults` API (`CA92.1`). Export
compliance declares no non-exempt encryption because the app implements no
cryptography and uses Apple's standard HTTPS stack.

Apple defines collection as off-device transmission retained beyond the time
needed to service the request. It specifically permits omission of transient IP
or authentication data that is not retained after the real-time request:
<https://developer.apple.com/app-store/app-privacy-details/>.

## Public surfaces

- Privacy: <https://krazel.github.io/zodiac-daily/privacy/>. It states only the
  actual local storage, date request, transient hosting processing, third-party
  protection, support-message handling, retention/deletion, and support alias.
- Support: <https://krazel.github.io/zodiac-daily/support/>. It contains only a
  working support alias, minimum diagnostic request, sensitive-data warning,
  and privacy link.
- No full owner name, address, phone, personal account, source repository,
  infrastructure vendor, provider credential, or future purchase clause is
  published on either page.
- Workers AI receives only provider-authored horoscope text for one daily
  editorial adaptation and a separate fidelity/language review. It receives no
  user text, selected sign, account, device identifier, or saved-card contents.
- The App Store marketing URL and privacy-choices URL are intentionally blank.
  The optional promotional-text field is also blank.
- The required support and privacy URLs are saved in App Store Connect. The
  `No data collected` answer was published on 2026-08-31 after the exact 1.0
  binary audit.
- App Review contact details are filled only in Apple's private required review
  section. Their values are intentionally not copied into this repository or
  any public page.
- Review notes for the public candidate describe the exact `1.0` build: no login,
  no permissions, no ads/analytics, date-and-language-only content request,
  local saves, an explicit unavailable/retry state instead of fake offline
  content, and no visible or active purchase flow. They contain
  no infrastructure name or future promise.
- Apple's standard EULA is used. No unnecessary custom terms page exists.

## Material territorial requirement

The app is configured for EU availability. The account-level EU Digital
Services Act compliance status is **Active** in App Store Connect as of
2026-08-31. Do not change the trader classification to reduce disclosure.
Apple may be legally required to display
verified trader contact information in the EU; that required disclosure must
remain confined to Apple's compliance surface and must not be duplicated on the
app's public privacy/support pages.

## Evidence

- App configuration: `ZodiacDaily/App/AppConfiguration.swift`
- Local storage and repository wiring: `ZodiacDaily/App/AppModel.swift`
- Exact request construction: `Sources/ZodiacDailyCore/Content/RemoteHoroscopeRepository.swift`
- StoreKit boundary: `ZodiacDaily/Store/SupportStore.swift`
- Privacy Manifest: `ZodiacDaily/Resources/PrivacyInfo.xcprivacy`
- Xcode target settings: `ZodiacDaily.xcodeproj/project.pbxproj`
- Historical 0.3/1 TestFlight validation passed 65 Core tests, Release
  analysis, signed archive checks, packaged configuration inspection, IPA
  export, Apple verification, and upload. App Store Connect confirmed it as
  valid and internal only.
- Historical 0.4/1 TestFlight validation passed visual QA, Core tests, Release
  analysis, signed archive checks, packaged configuration inspection, IPA
  export, Apple verification, and upload.
- App Store Connect confirmed `0.4 (1)`, `VALID`, iOS 16.0,
  `INTERNAL_ONLY`, not expired, and automatic access for `Testers`.
- Exact `0.4.1 (1)` passed the unchanged data-flow audit, C7 visual QA, Core
  tests, Release analysis, signed archive inspection, IPA export, Apple
  validation, upload, and processed-build inspection. App Store Connect
  confirmed `VALID`, iOS 16.0, `INTERNAL_ONLY`, not expired, no non-exempt
  encryption, and automatic internal-group access.
- Production content validation: 29/29 offline tests and the real 2026-08-31
  Spanish edition passed 12/12 signs with
  complete daily data and no detected English residual or known agreement
  defect.
- Public privacy and support pages passed the minimization review.
- Exact public candidate `1.0 (1)` passed 65 Core tests, Release analysis,
  signing, archive inspection, IPA export, Apple validation, and upload in run
  `33440183125`. Inspection run `33441385942` confirms the processed binary is
  `VALID`, iOS 16.0+, not expired, declares no non-exempt encryption, and is
  `APP_STORE_ELIGIBLE`. No SDK, permission, data category, purchase surface, or
  transmission beyond the audited date-and-language request was added.
- App Privacy was published on 2026-08-31 as `No data collected`; the public
  preview and declared data-type list both state that no data is collected. The
  result remains exact for the processed 1.0 (1) binary.

## Gate

The code inventory passes for the exact processed public `1.0` / build `1`.
Changes since the delivered `0.4.1` binary hide the unconfigured voluntary
support UI and stop its StoreKit catalog task; they add no SDK,
permission, storage category, transmission, account field, analytics, ad, or
tracking behavior. Signed archive and App Store inspection evidence are now
recorded; future binary or SDK changes require a fresh audit.
