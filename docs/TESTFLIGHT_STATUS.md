# Internal TestFlight status

Updated: 2026-08-27

## Latest delivery

- App Store Connect app: **The Daily Zodiac** (`6800136195`).
- Bundle identifier: `com.krazel.zodiacdaily`.
- Marketing version: `0.3`.
- Build: `1`.
- Minimum OS: iOS 16.0.
- Audience: internal TestFlight only.
- Apple processing state: `VALID`.
- Export compliance: `usesNonExemptEncryption = false`.
- Internal group: `Testers`; `hasAccessToAllBuilds = true`, two internal
  testers, audience `INTERNAL_ONLY`.

No external testing, Beta App Review, App Review, public TestFlight link, App
Store publication, subscription product, or public release was created.

## Build evidence

- Source commit: `77c381c257f325ad76e47a5f31767a6588035d2d`.
- Purpose: `TestFlight-Internal`.
- GitHub Actions run: `33029296526`, completed successfully.
- Workflow artifact:
  `ZodiacDaily-v0.3-build-1-TestFlight-run-13`.
- IPA filename:
  `ZodiacDaily-v0.3-build-1-77c381c-TestFlight.ipa`.
- Apple delivery UUID:
  `b1bc0813-cc22-4794-b3d6-948e38403673`.
- Apple transport verification: `VERIFY SUCCEEDED with no errors`.
- Apple transport upload: `UPLOAD SUCCEEDED with no errors`.
- Artifact digest:
  `sha256:e5ac54038aabedac44ec0b259bfceba0d2fd65f91d4f929a01b1d4f6ad6cebaa`.
- Workflow-artifact digest:
  `sha256:81c4492e53098f209fb3835ddcfc938b0788ef7b22e3b4b560925d21cca7d02d`.
- App Store Connect inspection run: `33029584933`, success; version/build
  `0.3 (1)`, `VALID`, iOS 16.0 minimum, not expired, no non-exempt
  encryption, internal only, automatic access for `Testers`.
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
- Confirm the C5B thin-gold frame is identical on front, provider back, and
  Saved detail; verify regular and long readings remain complete.
- Confirm Today and Saved detail stay stationary at regular text sizes on a
  short iPhone, while accessibility Dynamic Type remains reachable.
- Confirm Settings opens smoothly and a sign selected from Today or Settings
  applies and closes in one tap.
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

The delivered correction `0.2.3` build `1` uses an explicit plist plus a compiled
public endpoint fallback, requires exact-language provider content, refuses to
present bundled emergency copy as live Today content, and adds signed-archive
checks that fail if either value is absent. Local QA workflow `32912659741`
passed 65 Core tests, the unsigned Release build, packaged-value inspection,
and IPA packaging from commit `fb65eb9`. Artifact
`ZodiacDaily-v0.2.3-build-1-fb65eb9474a3060d689c0134fde39582b0e0f575-Local-QA-run-11`
has digest `sha256:c102ab8f0172c24c086ae4b1dae07660ce2e7fa2afb01d7f04d0fd97c6b6fd3d`.
The correction was subsequently signed, inspected, uploaded, processed, and
made available to the automatic internal group by runs `32915420982` and
`32915848511`.
