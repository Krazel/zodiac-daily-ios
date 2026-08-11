# Internal TestFlight status

Updated: 2026-08-11

## Available build

- App Store Connect app: **The Daily Zodiac** (`6800136195`).
- Bundle identifier: `com.krazel.zodiacdaily`.
- Marketing version: `0.1.1`.
- Build: `1`.
- Minimum OS: iOS 16.0.
- Audience: internal TestFlight only.
- Apple processing state: `VALID`.
- Export compliance: `usesNonExemptEncryption = false`.
- Internal group: `Testers`; access to all builds is enabled and the group has
  one tester. No tester identity or contact information is stored here.

No external testing, Beta App Review, App Review, TestFlight public link, App
Store publication, subscription product, or public release was created.

## Build evidence

- Source commit: `0d648d3c173ae5dded33a3a967b741736ef794c1`.
- Purpose: `TestFlight-Internal`.
- GitHub Actions run: `31488398661` (run number `6`), completed successfully.
- Workflow artifact:
  `ZodiacDaily-v0.1.1-build-1-TestFlight-run-6`.
- IPA filename:
  `ZodiacDaily-v0.1.1-build-1-0d648d3-TestFlight.ipa`.
- IPA SHA-256:
  `5f5ad46b6c8fc85733c33b59439fbf95d73b5b4f9bbe0124be9f5b9560b8f010`.
- Artifact archive SHA-256:
  `5e69970784108b039295bced0276f823a702eefd0217cc221ea3e1d0f62b68c3`.
Signing and App Store Connect credentials are encrypted outside Git. Temporary
signing files and the upload key are removed from the runner after every run.
Operational signing-resource identifiers remain only in the secure local
record and are intentionally excluded from this public repository.

## Internal test focus

- First-launch sign selection and changing signs from Today.
- Daily provider edition, offline fallback, and relaunch persistence.
- Complete front card at default text size on an iPhone 15 Pro-sized screen.
- Card flip and back details, including Reduce Motion.
- Save, remove, empty, populated, and saved-detail states.
- Settings privacy and terms links.
- Confirm supporter products remain unavailable because no App Store products
  are active in this build.

Any rebuild of unchanged version `0.1.1` must use build `2` or higher. A later
feature release must move to marketing version `0.2` according to the project
versioning rule.
