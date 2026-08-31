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

## Approved C5B frame and larger-reading validation

- Approval source: `Design/Approved/today-readable-frame-c5b.png`
- Current front master: `Design/Approved/today-loaded-front-c5b-es-runtime.png`
- Current provider-back master:
  `Design/Approved/today-loaded-back-provider-c5b-es-runtime.png`
- Current saved-detail master: `Design/Approved/saved-detail-c5b-en-runtime.png`
- Same-canvas sheet: `Design/Comparisons/today-c5b-runtime-comparison.png`
  (approved proposal, real build, 50% overlay), SHA-256
  `e3f74b2c9da166738d06bc70775830040b5b93615ff167c81900308ce7854b4d`
- Final workflow run: `32963500029`
- Captured commit: `95d28aa`
- Artifact: `ZodiacDaily-Visual-QA-34`
- Artifact digest:
  `sha256:89a86259d57fec8531bc37913573c86561b49a07dcb9f962755ee17a5e696670`
- Simulators: iPhone 15 Pro and iPhone SE (3rd generation)
- Resolutions: 1179 x 2556 and 750 x 1334

The real front and back use one shared C5B component: a thin warm-gold outer
line, inset hairline, squarer geometry, and four mirrored engraved
crescent/star corner motifs. The old thick gray rim, brackets, and burst
corners are absent. The regular Spanish reading renders complete at the
approved larger target while retaining the C4 masthead, selector, Settings,
Save action, and tab composition. The provider back preserves focus, keywords,
four scores, lucky number/color, Moon data, sign essence, and the matching turn
cue.

The long Spanish fixture is recorded at
`Design/Comparisons/today-long-c5b-es-runtime.png` (SHA-256
`13793f9ce0e5704d84a72c59afb9abcf75b369fd8d0ba489c73c8e4b37d03f81`).
The first C5B run, `32961689190`, exposed a compact-height anchoring defect in
that stress state. Commit `95d28aa` pinned the transformed page to a stable top
origin; the repeated run then showed the masthead, selector, complete long
reading, Save action, and tabs together without a regular-size scroll view.
Compact evidence is retained in
`today-c5b-es-iphone-se-runtime.png`,
`today-long-c5b-es-iphone-se-runtime.png`, and
`saved-detail-c5b-es-iphone-se-runtime.png` with respective SHA-256 values
`7b1fd6db2e2a3e6497f3ec8e65be32b59f54ad368e920f8c773931b922163104`,
`d0c0978fd50eaeb4fb8827ec85aa8c70d7b9aa52d2b4d6cc51bcb6051474fe61`,
and `52a3f19371026c07052d73327fc5c4be24b1e8aa4dab97aa1c5e61d579a5f964`.
Accessibility Dynamic Type retains the documented scrolling escape hatch so
content remains reachable.

## Approved C6 large-card runtime validation

- Approved front: `Design/Approved/today-large-card-front-c6-approved.png`
- Approved provider back: `Design/Approved/today-large-card-back-c6-approved.png`
- Final workflow run: `33343386120`
- Captured commit: `b41e6dc`
- Artifact: `ZodiacDaily-Visual-QA-36`
- Artifact digest:
  `sha256:58c72548b45faa585ddc0c9f7693af4eac903fa3b76e79635e20a0b8548deed8`
- Simulators: iPhone 15 Pro and iPhone SE (3rd generation)
- Resolutions: 1179 x 2556 and 750 x 1334

The final run removed the Today sign selector, enlarged the shared card,
preserved the complete front and provider back in the stationary regular
viewport, and kept sign changes in Settings. The first candidate run
`33342484665` was rejected because long Spanish copy touched the turn cue.
Commit `b41e6dc` introduced a measured finite reading region and the repeated
run demonstrates clear separation in both regular and compact heights.

Canonical runtime files and SHA-256 values:

- `today-large-card-front-c6-es-runtime.png`:
  `fba535c925685838ec9d1edecb56e441174cb8cb6090584eb030712710eb06dc`
- `today-large-card-back-c6-es-runtime.png`:
  `3744198c51f29116ccf1445bc4a7589435f964f863e3cb07c7705017db3c9843`
- `today-large-card-long-c6-es-runtime.png`:
  `4f24ee2013c6c35607449e6efaeb8823c48ff6a51133d1bf08a76747c64d7a9b`
- `saved-detail-c6-es-runtime.png`:
  `be53ff7f6516034dab00f532b79510d781a47829b4400d7d0ed53da574a5d4a4`
- `today-large-card-long-c6-es-iphone-se-runtime.png`:
  `b5e847ad98b2080fb92f49c1b1a9ba11ce3500f05faec564d93463447d6f89ce`
- `today-large-card-back-c6-es-iphone-se-runtime.png`:
  `7755702a4552a44e4f5c96096419d2e4d19f487748c11149617b35586587906a`

## Approved C7 readable-typography runtime validation

- Current complete masters: `Design/Approved/*readable-type*.png`
- Final workflow run: `33348593592`
- Captured commit: `c48a449`
- Artifact: `ZodiacDaily-Visual-QA-37`
- Simulators: iPhone 15 Pro and iPhone SE (3rd generation)
- Resolutions: 1179 x 2556 and 750 x 1334

The runtime preserves the approved C6 card geometry, backgrounds, artwork,
controls, and stationary layout. Thin Didot interface type is absent. A sturdy
native serif remains only for large editorial titles; changing provider data,
scores, lucky details, Settings rows and prices, sign labels, Saved metadata,
navigation, buttons, and reading copy use the native sans-serif. Score digits
are semibold and tabular. Long sign names remain inside their cards.

The run passed Core tests, iOS compilation, every English/Spanish visual state,
and stationary-layout checks on the short iPhone. Canonical runtime files and
SHA-256 values are recorded directly in `Design/APPROVALS.md`; compact front
and back evidence is retained as
`today-readable-type-c7-es-iphone-se-runtime.png` and
`today-readable-type-c7-back-es-iphone-se-runtime.png`.
