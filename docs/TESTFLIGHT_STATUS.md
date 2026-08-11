# Internal TestFlight status

Updated: 2026-08-11

## Available build

- App Store Connect app: **The Daily Zodiac** (`6800136195`).
- Bundle identifier: `com.krazel.zodiacdaily`.
- Marketing version: `0.2`.
- Build: `1`.
- Minimum OS: iOS 16.0.
- Audience: internal TestFlight only.
- Apple state: `En pruebas` (`Testing`), expiring in 90 days.
- Export compliance: `usesNonExemptEncryption = false`.
- Internal group: `Testers`; the build is assigned to the group.

No external testing, Beta App Review, App Review, public TestFlight link, App
Store publication, subscription product, or public release was created.

## Build evidence

- Source commit: `4e3518e19a35b00c01101822dd88037fb9eda1c6`.
- Purpose: `TestFlight-Internal`.
- GitHub Actions run: `31522839488` (run number `8`), completed successfully.
- Workflow artifact:
  `ZodiacDaily-v0.2-build-1-TestFlight-run-8`.
- IPA filename:
  `ZodiacDaily-v0.2-build-1-4e3518e-TestFlight.ipa`.
- IPA SHA-256:
  `f5e97d9019b568674a29325d14d9a3270407dc7280baeada048125e1ae64de52`.
- Artifact archive SHA-256:
  `ae247e93b07a830a71bed7ab82309d01e296298fa3bf88e2c0a992c502a3a073`.
- Apple delivery UUID:
  `93b70d57-c420-4b84-a34e-264760a432ca`.
- Cloudflare Worker version:
  `5a2cbd27-fa30-4789-a664-ed72b0a28403` (schema 3, English/Spanish).

Signing and App Store Connect credentials are encrypted outside Git. Temporary
signing files and the upload key are removed from the runner after every run.
No secret value is stored in this repository.

## Internal test focus

- Change Settings between English and Spanish and confirm the interface updates
  immediately.
- Confirm daily content follows the selected language.
- Confirm Spanish failures fall back to a real English edition without
  labelling it as Spanish.
- Save English and Spanish cards for the same sign/day and confirm they remain
  separate, stable snapshots.
- First-launch sign selection and changing signs from Today.
- Complete front card, card flip, back details, and Reduce Motion.
- Saved empty, populated, remove, and detail states.
- Confirm supporter products remain unavailable because no App Store products
  are active in this build.

Any rebuild of unchanged version `0.2` must use build `2` or higher. The next
feature release must move to a new visible version according to the project
versioning rule.
