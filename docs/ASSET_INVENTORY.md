# Asset inventory

Updated: 2026-08-31

## Approved Today C6 implementation

- Current front reference:
  `Design/Approved/today-large-card-front-c6-approved.png`.
- Current provider-back reference:
  `Design/Approved/today-large-card-back-c6-approved.png`.
- Screen background bitmap:
  `ZodiacDaily/Assets.xcassets/CelestialBackground.imageset/celestial-background.png`.
- Card scene bitmaps: `CardLake`, `CardOcean`, and `CardRoad` asset sets. The
  sign family selects one scene; a native `Canvas` draws each distinct
  constellation over it.
- Typography: built-in iOS Didot plus native system sans serif; no external font
  file or license.
- Zodiac identity: Unicode glyph plus localized sign name inside the card.
  Today has no sign-selection control; Settings owns that action.
- Icons: SF Symbols for bookmark, Settings, turn cue, and tab navigation.
- Card frame: one shared native `Canvas` implementation with warm-gold outer
  stroke, inset hairline, engraved crescent/star corners, and native shadow.
- Front material: the full scene bitmap plus a progressive native navy/indigo
  gradient that creates the C6 reading zone without a hard rectangular panel.
- Back material: native navy/indigo gradient, subtle sign watermark, hairline
  dividers, and a typographic two-column score grid. No progress-bar asset is
  used in C6.
- Motion: native SwiftUI 3D Y-axis rotation; Reduce Motion uses a short opacity
  transition.

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

## Shared Saved detail card

- Saved detail uses the same `FlippableDailyCard`, scene assets, C6 frame,
  typography hierarchy, and motion as Today.
- Date/navigation and Remove from Saved remain native controls outside the
  physical card. Saved-list thumbnails are unchanged by C6.

## Still gated

- App Store screenshots, previews, and promotional artwork.
- Any non-system font or production illustration asset.

Approval is recorded per screen in `docs/VISUAL_FIRST.md`.
