# App Review preflight — The Daily Zodiac 1.0 (1)

Prepared: 2026-08-31

This gate applies only to bundle `com.krazel.zodiacdaily`, marketing version
`1.0`, build `1`, and the English (U.S.) / Spanish localizations.

| Review surface | Exact 1.0 state | Evidence / result |
| --- | --- | --- |
| Accounts and permissions | No account, login, birth date, profile, protected-device permission, advertising identifier, or tracking prompt. | Source and privacy-manifest audit pass. |
| Network and storage | The app requests only date and `en`/`es` over HTTPS; sign, settings, cache, and saved cards remain local. | `docs/DATA_MINIMIZATION_AUDIT.md`. |
| SDKs and tracking | Apple frameworks plus local `ZodiacDailyCore`; no ads, analytics, attribution, crash-reporting, social, or third-party SDK. No ATT. | App Privacy accurately remains `No data collected`. |
| Purchases | No IAP or subscription exists in App Store Connect. The 1.0 binary hides all supporter purchase controls and does not start the StoreKit catalog. | `AppConfiguration.supporterPurchasesEnabled = false`; App Store Connect IAP and subscription pages are empty. |
| Metadata | Name, subtitle, keywords, description, screenshots, and review notes contain no price, discount, or unavailable-feature claim. | Final English/Spanish scan passed after store uploads. |
| Legal and support | App-specific privacy and support URLs are live; standard Apple EULA; optional marketing and privacy-choices URLs remain blank. | URLs recorded in `docs/LAUNCH_READINESS.md`. |
| EU distribution | DSA compliance is active. | App Store Connect account compliance, checked 2026-08-31. |
| Content rights | Third-party horoscope content rights are declared; readings are identified as entertainment and reflection, not professional advice. | App Store Connect metadata and in-app notice. |
| Encryption | Standard Apple HTTPS only; no proprietary or non-exempt encryption. | `ITSAppUsesNonExemptEncryption = NO`. |
| Release | Public App Store eligible archive, processed build, screenshots, privacy publication, selected build, and coherent review notes. | App Store Connect assembly is complete; review submission is explicitly excluded. |

## Final review notes

The app requires no account or login. Users choose one of 12 zodiac signs,
view a daily horoscope card, flip it for additional daily details, and save
cards locally on the device. The language can be changed between English and
Spanish in Settings.

The app requests only the calendar date and selected content language over
HTTPS to retrieve the daily edition. It does not transmit the selected sign,
saved cards, birth data, account information, advertising identifiers, or
precise location. It includes no advertising or analytics SDKs and requests no
device permissions. Version 1.0 contains no in-app purchase or subscription
offer. Horoscope content is for entertainment and personal reflection only.

## Remaining gate

- [x] 1.0 (1) signed App Store eligible archive validated and processed.
- [x] English and Spanish screenshots captured from the exact 1.0 source,
      hashed, and registered in `Design/APPROVALS.md`.
- [x] English and Spanish screenshots uploaded to App Store Connect.
- [x] Version field updated to 1.0 and build 1 selected.
- [x] Review notes replaced with the exact text above.
- [x] App Privacy `No data collected` published.
- [x] Final metadata scan completed after saving English and Spanish localizations.
- [x] App Review submission remains untouched until a later, separate owner instruction.

## Signed release evidence

- Build/upload workflow: run `33440183125`, commit
  `fa03ff09e4f383fe454c782e7eb0ec373511d4cb`.
- Artifact: `ZodiacDaily-v1.0-build-1-AppStore-run-16`, digest
  `sha256:da836a74ea9398ee4c86acc532f9aea128c316df4fbd737d35e6b5e5fb313fe0`.
- IPA: `ZodiacDaily-v1.0-build-1-fa03ff0-AppStore.ipa`, SHA-256
  `2316febd7191b1a75557c6ace5ae6d704bf6e0157794374a51d93ff6d02e5525`.
- Processed-build inspection: run `33441385942`; Apple reports `VALID`, iOS
  16.0 minimum, not expired, no non-exempt encryption, and
  `APP_STORE_ELIGIBLE`.
- Screenshot workflow: run `33440182881`, 12 captures at 1284 x 2778,
  artifact digest
  `sha256:2b1126361fd2d5492cf0f4aa3b9f343f9aa6c7584fac5d7476342467c73a8853`.
- Screenshot upload: run `33443511143`; App Store Connect reports all six
  `en-US` and all six `es-ES` assets as `COMPLETE` in ordered
  `APP_IPHONE_65` sets. The version page independently shows `6 of 10` for
  each localization.
- App Store Connect final state: version `1.0`, build `1` selected, English and
  Spanish metadata saved, Spanish subtitle saved, App Privacy published as
  `No data collected`, manual release retained, and `Add for Review` left
  untouched.
- The App Review page remains empty and states that submitted items would
  appear there, confirming that no review submission was created.
