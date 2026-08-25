# Internal TestFlight status

Updated: 2026-08-26

## Latest delivery

- App Store Connect app: **The Daily Zodiac** (`6800136195`).
- Bundle identifier: `com.krazel.zodiacdaily`.
- Marketing version: `0.2.2`.
- Build: `1`.
- Minimum OS: iOS 16.0.
- Audience: internal TestFlight only.
- Apple transport state: verified and accepted for processing on 2026-08-26.
- Export compliance: `usesNonExemptEncryption = false`.
- Internal group: `Testers`; availability of this delivery depends on Apple
  finishing TestFlight processing.

No external testing, Beta App Review, App Review, public TestFlight link, App
Store publication, subscription product, or public release was created.

## Build evidence

- Source commit: `40286ad3dbb9cd71b729d83130f7cd0168938043`.
- Purpose: `TestFlight-Internal`.
- GitHub Actions run: `32906780701`, completed successfully.
- Workflow artifact:
  `ZodiacDaily-v0.2.2-build-1-TestFlight-run-11`.
- IPA filename:
  `ZodiacDaily-v0.2.2-build-1-40286ad-TestFlight.ipa`.
- Apple delivery UUID:
  `0543a959-d7a8-456d-8fce-b5b1132b960c`.
- Apple transport verification: `VERIFY SUCCEEDED with no errors`.
- Apple transport upload: `UPLOAD SUCCEEDED with no errors`.
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
- First-launch sign selection and changing signs from Today.
- Complete front card, card flip, back details, and Reduce Motion.
- Saved empty, populated, remove, and detail states.
- Confirm supporter products remain unavailable because no App Store products
  are active in this build.

## Delivered 0.2.2 correction

- App-code commit: `6623459`.
- Canonical visual-evidence commit: `0611028` (no target source changes).
- Signed validation workflow: `32175886395`, success.
- Signed artifact: `ZodiacDaily-v0.2.2-build-1-TestFlight-run-10`.
- The workflow passed Core tests, Release analysis, signed archive inspection,
  and IPA export. `upload_to_testflight=false`; no Apple upload occurred.
- Visual workflow: `32175884780`, success on iPhone 15 Pro and iPhone SE.
- English/Spanish front, complete provider-data back, long Spanish copy, and
  stationary compact-height states passed. Current full-screen masters and
  evidence are recorded in `Design/APPROVALS.md`.
- The owner explicitly authorized the internal upload. Upload-enabled workflow
  `32906780701` delivered the exact version/build to Apple successfully.

## Known defect in delivered 0.2.2

Inspection of the exact signed IPA showed that Xcode omitted the custom
`ZodiacDailyAPIBaseURL` and `ZodiacDailyAppStoreID` values from the generated
`Info.plist`. Consequently, 0.2.2 never contacted the production Worker: it
displayed bundled English emergency copy and the incomplete reverse. The Worker
and its English/Spanish schema-3 editions remained healthy. Build 0.2.2 must not
be used for product acceptance.

Correction candidate `0.2.3` build `1` uses an explicit plist plus a compiled
public endpoint fallback, requires exact-language provider content, refuses to
present bundled emergency copy as live Today content, and adds signed-archive
checks that fail if either value is absent. It has not been uploaded to
TestFlight.
