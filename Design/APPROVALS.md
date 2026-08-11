# Canonical visual approvals

Updated: 2026-08-11

This file is the source of truth for the complete approved images that govern
the shipped app. `Design/Approved/` contains only current masters.
`Design/Concepts/` contains proposals and retained approval history;
`Design/Comparisons/` contains real-build comparison evidence. A replacement
must be added as a new file and row before the previous master is marked
superseded. Approved history is never overwritten or deleted.

## Current masters

| Screen / state | Current master | Device / canvas | Orientation | Language | Approved | SHA-256 | Runtime evidence | Required fidelity / permitted adaptation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Today / loaded card front | `Design/Approved/today-loaded-front-c2.png` | iPhone full-screen mockup, 862 x 1824 px including device frame | Portrait | English | 2026-08-09 | `c7d794bc89a8d62b83d1e265fdac53e0fc4b25c0593e91ed0c2d6ab34d8029ab` | `Design/Comparisons/today-comparison.png` | Preserve the complete collectible card and keep Save Card outside it. Dynamic Type, VoiceOver, safe-area, and native status-bar adaptations are permitted without changing the hierarchy. |
| Today / loaded card back, provider data | `Design/Approved/today-loaded-back-provider-c2.png` | iPhone full-screen mockup, 862 x 1825 px including device frame | Portrait | English | 2026-08-10 | `3933f81e13821b46d07642f6100171ff0a490cd46f2f7aac8476e1183e934ecd` | `Design/Comparisons/today-back-provider-comparison.png` | Preserve the front frame and Today composition. Changing daily fields must be provider-authored; sign essence may be static. Reduce Motion may replace the 3D turn with a short fade. |
| First launch / sign selection | `Design/Approved/sign-selection-c2.png` | iPhone full-screen mockup, 862 x 1824 px including device frame | Portrait | English | 2026-08-09 | `0f10cdc2ceab984f32e14bc74d1a2f13325785d5c9a0846537caa87892190180` | `Design/Comparisons/sign-selection-comparison.png` | Show all 12 signs and no personal-data request. Pisces is the selected example. Native accessibility reflow is permitted. |
| Saved / empty | `Design/Approved/saved-empty-c2.png` | iPhone full-screen mockup, 862 x 1825 px including device frame | Portrait | English | 2026-08-09 | `0475bcb8f9c7d5f044a9b248e0ebb4c1abb22f12caf3a630d500d6977d8c28d3` | `Design/Comparisons/saved-empty-comparison.png` | Preserve the empty collectible-card outline and route to Today. Native accessibility reflow is permitted. |
| Saved / populated | `Design/Approved/saved-populated-c2.png` | iPhone full-screen mockup, 862 x 1825 px including device frame | Portrait | English | 2026-08-09 | `8bca65dbf9e07f8efd7e8264f7332ab51a6d430c34248f69b20412d5121f896b` | `Design/Comparisons/saved-populated-comparison.png` | Preserve the separate card-thumbnail archive and approved hierarchy. Native accessibility reflow is permitted. |
| Saved / card detail | `Design/Approved/saved-detail-c2.png` | iPhone full-screen mockup, 862 x 1825 px including device frame | Portrait | English | 2026-08-09 | `566e1ca9ac10ba8abe2ab397a93ad4df58c89c39f6739d7450c482fb4bcddea8` | `Design/Comparisons/saved-detail-comparison.png` | Preserve the complete saved card, native return path, and Remove from Saved outside the card. Native accessibility reflow is permitted. |
| Settings / support and review | `Design/Approved/settings-support-c3.png` | iPhone full-screen mockup, 863 x 1822 px including device frame | Portrait | English | 2026-08-09 | `7aea1d31d7920360d85ac11196f492e761728711daedf164802e32c369945060` | `Design/Comparisons/settings-comparison.png` | Preserve optional support inside Settings, free core access, restore/manage controls, privacy/terms, and separate review entry. StoreKit prices must be live localized values. Native accessibility reflow is permitted. |
| App icon | `Design/Approved/app-icon-c1.png` | Square master, 1254 x 1254 px | N/A | No text | 2026-08-10 | `353b30862440057996c28eaaee116337f460107b961be22cf12b529af4e5e00c` | Runtime asset: `ZodiacDaily/Assets.xcassets/AppIcon.appiconset/` | Preserve the central twelve-point gold star, twelve orbiting points, midnight navy, no text, no zodiac-specific glyph, no transparency, and no pre-rounded corners. |

The comparison sheets above contain captures from the real SwiftUI build on an
iPhone 15 Pro simulator at 1179 x 2556. Their provenance and workflow runs are
recorded in `Design/Comparisons/README.md`. The final 18-point Today spacing
change still requires one refreshed runtime comparison before the visual gate
can be called final.

## Superseded approved references

| Screen / state | Retained reference | Status | Approved | Replaced by | Reason |
| --- | --- | --- | --- | --- | --- |
| Today / card back | `Design/Concepts/today-card-back-c1.png` | Superseded, retained | 2026-08-10 | `Design/Approved/today-loaded-back-provider-c2.png` | The owner required all changing daily values to come from the real provider rather than local invention. |
| Settings / About | `Design/Concepts/settings-c2.png` | Superseded, retained | 2026-08-09 | `Design/Approved/settings-support-c3.png` | C3 keeps the approved Settings direction and adds the approved optional support/review section. |

## Proposal history (not current masters)

These files remain in `Design/Concepts/` and must not be used as final visual
specifications:

- `today-a-celestial-broadsheet.png`
- `today-b-modern-magazine.png`
- `today-c-mystic-night.png`

## Store screenshot rule

App Store screenshots may use the current masters as art direction only. The
base screenshot must be captured from the real release-candidate build at the
declared device size, then linked here with version, build, commit, locale,
device, resolution, capture date, and SHA-256 before submission. No store
screenshots are approved or registered yet.
