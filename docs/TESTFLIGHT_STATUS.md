# Internal TestFlight status

Updated: 2026-08-18

## Available build

- App Store Connect app: **The Daily Zodiac** (`6800136195`).
- Bundle identifier: `com.krazel.zodiacdaily`.
- Marketing version: `0.2.1`.
- Build: `1`.
- Minimum OS: iOS 16.0.
- Audience: internal TestFlight only.
- Apple state: `En pruebas` (`Testing`), expiring in 90 days.
- Export compliance: `usesNonExemptEncryption = false`.
- Internal group: `Testers`; the build is assigned to the group.

No external testing, Beta App Review, App Review, public TestFlight link, App
Store publication, subscription product, or public release was created.

## Build evidence

- Source commit: `090929f6f4dccf8e750ebc34b059aff2e0a9f9a6`.
- Purpose: `TestFlight-Internal`.
- GitHub Actions run: `32172428478`, completed successfully.
- Workflow artifact:
  `ZodiacDaily-v0.2.1-build-1-TestFlight-run-9`.
- IPA filename:
  `ZodiacDaily-v0.2.1-build-1-090929f-TestFlight.ipa`.
- Apple delivery UUID:
  `c2449421-e503-4a93-8501-5b697ae66fdd`.
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

The owner-directed correction candidate is `0.2.2` build `1`. It must pass its
own visual, Core, archive, and exact-binary checks before any new upload.
