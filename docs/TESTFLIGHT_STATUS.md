# Internal TestFlight status

Updated: 2026-08-31

## Latest delivery

- App Store Connect app: **The Daily Zodiac** (`6800136195`).
- Bundle identifier: `com.krazel.zodiacdaily`.
- Marketing version: `0.4`.
- Build: `1`.
- Minimum OS: iOS 16.0.
- Audience: internal TestFlight only.
- Apple processing state: `VALID`.
- Export compliance: `usesNonExemptEncryption = false`.
- Internal group access is enabled; audience `INTERNAL_ONLY`.

No external testing, Beta App Review, App Review, public TestFlight link, App
Store publication, subscription product, or public release was created.

## Build evidence

- The protected workflow passed Core tests, Release analysis, signing,
  archive inspection, IPA export, Apple verification, and upload.
- App Store Connect independently confirmed version/build `0.4 (1)` as
  `VALID`, iOS 16.0 minimum, not expired, no non-exempt encryption, and
  internal only.
- Cloudflare Worker: production schema 3, English/Spanish.

Signing and App Store Connect credentials are encrypted outside Git. Temporary
signing files and the upload key are removed from the runner after every run.
No secret value is stored in this repository.

## Internal test focus

- Change Settings between English and Spanish and confirm the interface updates
  immediately.
- Confirm daily content follows the selected language.
- Confirm Spanish never changes silently to English and a missing uncached
  Spanish edition reports unavailable.
- Save English and Spanish cards for the same sign/day and confirm they remain
  separate, stable snapshots.
- First-launch sign selection and changing signs from Settings.
- Complete front card, card flip, back details, and Reduce Motion.
- Confirm the C6 large C5B-derived frame is identical on front, provider back,
  and Saved detail; verify regular and long readings remain complete.
- Confirm Today and Saved detail stay stationary at regular text sizes on a
  short iPhone, while accessibility Dynamic Type remains reachable.
- Confirm Settings opens smoothly and a sign selected there applies and closes
  in one tap.
- Saved empty, populated, remove, and detail states.
- Confirm supporter products remain unavailable because no App Store products
  are active in this build.

## Delivered 0.2.2 correction

- The workflow passed Core tests, Release analysis, signed archive inspection,
  and IPA export. `upload_to_testflight=false`; no Apple upload occurred.
- English/Spanish front, complete provider-data back, long Spanish copy, and
  stationary compact-height states passed. Current full-screen masters and
  evidence are recorded in `Design/APPROVALS.md`.
- The owner explicitly authorized the internal upload, which delivered the
  exact version/build to Apple successfully.

## Known defect in delivered 0.2.2

Inspection of the exact signed IPA showed that Xcode omitted the custom
`ZodiacDailyAPIBaseURL` and `ZodiacDailyAppStoreID` values from the generated
`Info.plist`. Consequently, 0.2.2 never contacted the production Worker: it
displayed bundled English emergency copy and the incomplete reverse. The Worker
and its English/Spanish schema-3 editions remained healthy. Build 0.2.2 must not
be used for product acceptance.

The delivered correction `0.2.3` build `1` uses an explicit plist plus a compiled
public endpoint fallback, requires exact-language provider content, refuses to
present bundled emergency copy as live Today content, and adds signed-archive
checks that fail if either value is absent. Local QA passed 65 Core tests, the
unsigned Release build, packaged-value inspection, and IPA packaging. The
correction was subsequently signed, inspected, uploaded, processed, and made
available to the automatic internal group.
