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
