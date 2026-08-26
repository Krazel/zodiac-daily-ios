# Visual comparison evidence

Generated: 2026-08-11

Each PNG contains four panels: approved reference, implementation, 50% overlay,
and an amplified difference view. The approved device frame was cropped to its
display area and normalized to the same 1179 x 2556 iPhone 15 Pro canvas as the
raw `simctl` capture. The generated mockups do not all share a physical iPhone
aspect ratio, so horizontal and vertical normalization are measured separately.

## Capture source

- Workflow run: `31403855782`
- Captured commit: `b4db977`
- Simulator: iPhone 15 Pro
- Runtime: iOS 26.5
- Resolution: 1179 x 2556

## Normalized comparison results

Mean absolute RGB error (lower is closer; it also includes system status-bar
rendering and illustration differences):

- Today: 17.018
- Sign Selection: 17.938
- Saved Empty: 11.923
- Saved Populated: 16.631
- Saved Detail: 16.755
- Settings: 14.647

The six captures compiled and rendered successfully in the same workflow run.

## Interactive card reverse validation

- Approved reference: `Design/Concepts/today-card-back-c1.png`
- Comparison sheet: `Design/Comparisons/today-back-comparison.png`
- Workflow run: `31418716587`
- Captured commit: `7132a57`
- Simulator: iPhone 15 Pro
- Resolution: 1179 x 2556
- Mean absolute RGB error: 15.184

The final capture shows the complete front or reverse card, Save Card action,
and custom tab bar in the first viewport at default text size. The reverse uses
the approved hierarchy from top to bottom: sign, deeper reading, today's focus,
Love, Work, Well-being, lucky details, sign essence, and turn affordance.

## Provider-authored reverse validation

- Approved reference: `Design/Concepts/today-card-back-provider-c2.png`
- Comparison sheet: `Design/Comparisons/today-back-provider-comparison.png`
- Workflow run: `31426176026`
- Captured commit: `1f5e8c0`
- Simulator: iPhone 15 Pro
- Resolution: 1179 x 2556
- Mean absolute RGB error: 6.189%

The validated reverse preserves the approved frame, cosmic material, score
grid, lucky and Moon sections, static sign essence, Save Card action, and tab
bar in one viewport. All changing values in this state are sourced from the
FreeAstroAPI V2 contract; the app does not synthesize missing daily scores.

## Fixed Today and turn affordance validation

- Approved reference: `Design/Approved/today-loaded-front-flip-c3.png`
- Comparison sheet: `Design/Comparisons/today-front-flip-c3-comparison.png`
- Long-copy runtime evidence: `Design/Comparisons/today-long-provider-runtime.png`
- Workflow run: `31496180232`
- Captured commit: `f203c22`
- Simulator: iPhone 15 Pro
- Runtime: iOS 26.5
- Resolution: 1179 x 2556
- Mean absolute RGB error: 6.567%
- Comparison SHA-256: `aecd66167e63c0b3d484250e6dee45e57857370920e4ec551cb93370a883f59f`
- Long-copy SHA-256: `e3eeb60587e2dc7b2599586998d47a84221617e6dd32da9ae56a46a5de12b4c4`

The final regular-size capture keeps the masthead, sign selector, complete
front or back, Save Card action, and custom tab bar in one stationary viewport.
The stress fixture contains 396 characters, which covers the observed live
provider range of 324-382 characters. It renders the complete reading and the
visible `TAP FOR MORE` affordance without page movement or clipping at the
default text size. Compact-height and enlarged-text layouts retain measured
overflow scrolling so information is not hidden.

## Owner-directed Today correction 0.2.2

- Workflow run: `32175884780`
- Captured commit: `6623459`
- Simulator: iPhone 15 Pro and iPhone SE (3rd generation)
- iPhone 15 Pro resolution: 1179 x 2556
- iPhone SE resolution: 750 x 1334
- Languages: English and Spanish
- Current Spanish front master:
  `Design/Approved/today-loaded-front-flip-c4-es-runtime.png`
- Current Spanish provider-back master:
  `Design/Approved/today-loaded-back-provider-c3-es-runtime.png`
- English evidence: `today-front-en-v0.2.2.png`,
  `today-back-en-v0.2.2.png`
- Spanish stress/compact evidence: `today-long-es-v0.2.2.png`,
  `today-front-es-iphone-se-v0.2.2.png`

The real build keeps the complete card, Save action, and tab bar visible without
regular-size scrolling. Spanish long copy remains inside the frame. The front
and back use the same turn icon, the Settings gear has no surrounding circle,
and the direct sign capsule is implemented as a single button rather than a
dual-action menu.

## Settings performance and one-tap sign-change validation

- Workflow run: `32917443740`
- Captured commit: `9bd4d33`
- Simulator: iPhone 15 Pro and iPhone SE (3rd generation)
- Artifact: `ZodiacDaily-Visual-QA-31`
- Artifact SHA-256 digest:
  `323058cbbb2c3e7d057b7137faae9a654a5879b9f48b6db076d6e64f9b211b48`

The run passed 65 Core tests, compiled the full visual-QA app, captured every
approved state in English plus the Spanish Today states, and verified the
stationary Today, long-copy Today, and saved-detail layouts on iPhone SE. The
code caches immutable localization bundles, builds Settings sections lazily,
and applies sign changes immediately when the selector is opened from Today or
Settings. First launch retains the approved explicit Continue action. The C5
card-frame proposals remain unapproved and were not implemented by this run.
