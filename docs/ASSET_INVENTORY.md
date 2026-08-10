# Asset inventory

Updated: 2026-08-10

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

## Newly approved final references

- Saved card detail: `Design/Concepts/saved-detail-c2.png`.
- Settings support/review extension: `Design/Concepts/settings-support-c3.png`.
- Both continue to use native system fonts, SF Symbols, Unicode zodiac glyphs,
  SwiftUI shapes, and procedural celestial art; no new runtime bitmap is needed.
- Final app icon reference: `Design/Concepts/app-icon-c1.png`.
- Shipped icon artwork: `ZodiacDaily/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`,
  opaque RGB, 1024×1024, with no pre-rounded corners.

## Today card reverse

- Visual reference: `Design/Concepts/today-card-back-c1.png`.
- Runtime bitmap assets: no additional bitmap. The approved screen image is a
  specification and is not shipped in the app.
- Background and card material: reuse the approved cosmic background, card
  navy gradient, gold double frame, corner ornaments, shadow, and Didot/system
  typography already present in Today.
- Sign watermark: native Unicode zodiac glyph with low opacity.
- Dividers, category labels, and turn indicator: native SwiftUI shapes and an
  SF Symbol where appropriate.
- Motion: native SwiftUI 3D Y-axis rotation; a short opacity transition replaces
  it when Reduce Motion is enabled.

## Still gated

- App Store screenshots, previews, and promotional artwork.
- Any non-system font or production illustration asset.

Approval is recorded per screen in `docs/VISUAL_FIRST.md`.
