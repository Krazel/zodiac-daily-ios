# Visual fidelity audit

Updated: 2026-08-10

## Status

The existing SwiftUI screens are classified as **visual implementation in
progress** until the same-device comparison gate below passes. Functional
behavior, persistence, StoreKit boundaries, and iOS 16 support remain intact.

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
- [ ] Every affected SwiftUI screen uses the production assets and approved
      composition.
- [ ] Capture each state at the reference device aspect and size.
- [ ] Save side-by-side comparison sheets under `Design/Comparisons/`.
- [ ] Correct visible differences in background, hierarchy, proportion,
      typography, spacing, decoration, and materials.
- [ ] Record only unavoidable native/accessibility differences.
- [ ] Compile after the visual comparison gate passes.

