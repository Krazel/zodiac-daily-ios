# Visual comparison evidence

Generated: 2026-08-10

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
