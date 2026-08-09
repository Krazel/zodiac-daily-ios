# Asset inventory

Updated: 2026-08-09

## Approved Today implementation

- Visual reference: `Design/Concepts/today-c2-collectible-card.png`.
- Runtime bitmap assets: none. The reference image is documentation only and is
  not shipped inside the app.
- Typography: native iOS system serif and sans-serif designs; no external font
  files or licenses.
- Zodiac symbols: Unicode zodiac glyphs with English accessibility labels.
- Icons: SF Symbols for bookmark, settings, selection, and tab navigation.
- Background: native SwiftUI gradients.
- Card frame: native rounded rectangles, borders, and shadows.
- Celestial art: native SwiftUI `Canvas`; twelve distinct procedural
  constellation point sets, stars, crescent, and waves.
- Motion: no principal visual animation has been fixed or shipped.

## Newly approved screen references

- `Design/Concepts/sign-selection-c2.png`.
- `Design/Concepts/saved-populated-c2.png`.
- `Design/Concepts/saved-empty-c2.png`.
- `Design/Concepts/settings-c2.png`.

Their final implementation should continue to use native system fonts, SF
Symbols, Unicode zodiac glyphs, SwiftUI shapes, and procedural celestial art.

## Still gated

- Final art/layout for Saved card detail.
- Final app icon and any alternate icons.
- App Store screenshots, previews, and promotional artwork.
- Any non-system font or production illustration asset.

Approval is recorded per screen in `docs/VISUAL_FIRST.md`.
