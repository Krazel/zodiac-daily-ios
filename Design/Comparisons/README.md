# Visual comparison evidence

Generated: 2026-08-10

Each PNG places the approved reference on the left and the corresponding raw
iPhone 15 Pro simulator capture on the right. Both panels use a 1179 x 2556
canvas. The reference panel includes its original decorative device frame;
the implementation panel is the screen-only image produced by `simctl`.

## Capture source

- Workflow run: `31386424927`
- Captured commit: `7968640`
- Simulator: iPhone 15 Pro
- Runtime: iOS 26.5
- Resolution: 1179 x 2556

The later commit `3386dff` changes only Today vertical spacing: 8 points above
the selector, 6 points above the loaded card, and 10 points between the card
and its save action. It still needs a replacement Today capture because macOS
runner allocation is currently blocked at the GitHub account billing layer.
