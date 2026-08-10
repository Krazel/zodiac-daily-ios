# Visual fidelity audit

Updated: 2026-08-10

## Status

The six approved states have been implemented and inspected from a real
iPhone 15 Pro simulator capture. The final visual gate remains **blocked on one
recapture**, because GitHub stopped assigning macOS runners after the last
spacing correction. Functional behavior, persistence, StoreKit boundaries,
and iOS 16 support remain intact.

## Approved specifications

| Screen/state | Approved reference |
| --- | --- |
| Today / loaded card | `Design/Concepts/today-c2-collectible-card.png` |
| First launch / sign selection | `Design/Concepts/sign-selection-c2.png` |
| Saved / empty | `Design/Concepts/saved-empty-c2.png` |
| Saved / populated | `Design/Concepts/saved-populated-c2.png` |
| Saved / detail | `Design/Concepts/saved-detail-c2.png` |
| Settings / support | `Design/Concepts/settings-support-c3.png` |

## Asset inventory

### Raster production assets

- `CelestialBackground.imageset`: edge-to-edge midnight nebula and star field.
- `CardOcean.imageset`: moonlit Pisces ocean scene.
- `CardLake.imageset`: Scorpio alpine lake scene.
- `CardRoad.imageset`: Sagittarius winding-road scene.
- `AppIcon.appiconset`: approved C1 runtime icon.

The four new production images were generated with the built-in image tool
using the approved C2/C3 screens as edit references. Prompts required removal
of all phone chrome, text, symbols, controls, frames, and UI while preserving
the approved palette, atmosphere, material detail, and composition of the
underlying background or illustration.

### Native production elements

- Didot display typography with dynamic native body text.
- Double gold card borders, steel outer rim, corner brackets, starbursts, and
  shadows.
- Native constellation overlays keyed to all twelve signs.
- Gold/lavender capsule controls and selected-card glow.
- Custom Today/Saved bottom navigation matching the approved hierarchy.
- Loading, error, empty, populated, saved, destructive, StoreKit unavailable,
  and Dynamic Type reflow states.

## Original visible gaps

- The asset catalog contained only the app icon.
- Screens used a flat gradient instead of the approved nebula background.
- Card art used generic procedural waves for every sign.
- Card ornaments, materials, spacing, typography, shadows, and tab bar were
  simplified.
- Settings did not reproduce the approved grouped composition.
- No same-device implementation captures existed.

## Acceptance gate

- [x] Approved reference recorded for every affected state.
- [x] Missing raster assets inventoried and created.
- [x] Every affected SwiftUI screen uses the production assets and approved
      composition.
- [x] Capture each state at 1179 x 2556 on an iPhone 15 Pro simulator.
- [x] Save side-by-side comparison sheets under `Design/Comparisons/`.
- [x] Correct visible differences in background, hierarchy, proportion,
      typography, spacing, decoration, and materials.
- [x] Record unavoidable reference/runtime differences below.
- [x] Compile the integrated visual implementation on macOS/Xcode.
- [ ] Recapture the final 18-point Today spacing adjustment.

## Runtime evidence

- Successful workflow: GitHub Actions run `31386424927`.
- Captured commit: `7968640`.
- Device: iPhone 15 Pro simulator.
- Runtime: iOS 26.5.
- Output size: 1179 x 2556 for all six states.
- Final code commit: `3386dff`; this moves the Today selector/card/action group
  upward and reduces the card-to-action gap by 18 points in total.

The approved images include a decorative phone frame and have a slightly
different internal screen proportion from a real iPhone 15 Pro screenshot.
Comparison sheets therefore place the full approved reference and the raw
simulator screenshot on equal 1179 x 2556 canvases. Status-bar battery artwork,
the Dynamic Island, and anti-aliasing remain native to the captured iOS
runtime.

## Current external blocker

GitHub Actions refuses to start another macOS job before running any workflow
step. Its annotation states that recent account payments failed or the account
spending limit must be increased. Repository Actions permissions remain
enabled. Resolving billing or restoring available macOS minutes is the only
required external action; no IPA, TestFlight upload, product creation, or
publication is involved.
