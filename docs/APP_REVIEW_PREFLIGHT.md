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
| Metadata | Name, subtitle, keywords, description, screenshots, and review notes contain no price, discount, or unavailable-feature claim. | Final scan required after store uploads. |
| Legal and support | App-specific privacy and support URLs are live; standard Apple EULA; optional marketing and privacy-choices URLs remain blank. | URLs recorded in `docs/LAUNCH_READINESS.md`. |
| EU distribution | DSA compliance is active. | App Store Connect account compliance, checked 2026-08-31. |
| Content rights | Third-party horoscope content rights are declared; readings are identified as entertainment and reflection, not professional advice. | App Store Connect metadata and in-app notice. |
| Encryption | Standard Apple HTTPS only; no proprietary or non-exempt encryption. | `ITSAppUsesNonExemptEncryption = NO`. |
| Release | Public App Store eligible archive, processed build, screenshots, privacy publication, selected build, and coherent review notes. | Pending the authorized release workflow and final App Store Connect assembly. |

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

- [ ] 1.0 (1) signed App Store eligible archive validated and processed.
- [ ] English and Spanish screenshots captured from the exact 1.0 source,
      hashed, registered in `Design/APPROVALS.md`, and uploaded.
- [ ] Version field updated to 1.0 and build 1 selected.
- [ ] Review notes replaced with the exact text above.
- [ ] App Privacy `No data collected` published.
- [ ] Automatic release after approval selected.
- [ ] App added and submitted to App Review.
