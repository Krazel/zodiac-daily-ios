# Canonical visual approvals

Updated: 2026-08-18

This file is the source of truth for the complete approved images that govern
the shipped app. `Design/Approved/` contains only current masters.
`Design/Concepts/` contains proposals and retained approval history;
`Design/Comparisons/` contains real-build comparison evidence. A replacement
must be added as a new file and row before the previous master is marked
superseded. Approved history is never overwritten or deleted.

## Current masters

| Screen / state | Current master | Device / canvas | Orientation | Language | Approved | SHA-256 | Runtime evidence | Required fidelity / permitted adaptation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Today / loaded card front | `Design/Approved/today-loaded-front-flip-c3.png` | iPhone full-screen mockup, 862 x 1825 px including device frame | Portrait | English | 2026-08-11 | `8ba5227954cb5ff0c029d59066758385644b24670ef2e1f4c4587ed8d88c00c3` | `Design/Comparisons/today-front-flip-c3-comparison.png`; long-copy evidence: `Design/Comparisons/today-long-provider-runtime.png` | Preserve the complete collectible card, keep Save Card outside it, and preserve the visible gold turn ornament with `TAP FOR MORE` inside the card. At regular text sizes Today must not contain a scroll gesture: shorter screens scale the approved composition to fit. Accessibility Dynamic Type may scroll so content remains reachable. |
| Today / loaded card back, provider data | `Design/Approved/today-loaded-back-provider-c2.png` | iPhone full-screen mockup, 862 x 1825 px including device frame | Portrait | English | 2026-08-10 | `3933f81e13821b46d07642f6100171ff0a490cd46f2f7aac8476e1183e934ecd` | `Design/Comparisons/today-back-provider-comparison.png` | Preserve the front frame and Today composition. Changing daily fields must be provider-authored; sign essence may be static. Reduce Motion may replace the 3D turn with a short fade. |
| First launch / sign selection | `Design/Approved/sign-selection-c2.png` | iPhone full-screen mockup, 862 x 1824 px including device frame | Portrait | English | 2026-08-09 | `0f10cdc2ceab984f32e14bc74d1a2f13325785d5c9a0846537caa87892190180` | `Design/Comparisons/sign-selection-comparison.png` | Show all 12 signs and no personal-data request. Pisces is the selected example. Native accessibility reflow is permitted. |
| Saved / empty | `Design/Approved/saved-empty-c2.png` | iPhone full-screen mockup, 862 x 1825 px including device frame | Portrait | English | 2026-08-09 | `0475bcb8f9c7d5f044a9b248e0ebb4c1abb22f12caf3a630d500d6977d8c28d3` | `Design/Comparisons/saved-empty-comparison.png` | Preserve the empty collectible-card outline and route to Today. Native accessibility reflow is permitted. |
| Saved / populated | `Design/Approved/saved-populated-c2.png` | iPhone full-screen mockup, 862 x 1825 px including device frame | Portrait | English | 2026-08-09 | `8bca65dbf9e07f8efd7e8264f7332ab51a6d430c34248f69b20412d5121f896b` | `Design/Comparisons/saved-populated-comparison.png` | Preserve the separate card-thumbnail archive and approved hierarchy. Native accessibility reflow is permitted. |
| Saved / card detail | `Design/Approved/saved-detail-c2.png` | iPhone full-screen mockup, 862 x 1825 px including device frame | Portrait | English | 2026-08-09 | `566e1ca9ac10ba8abe2ab397a93ad4df58c89c39f6739d7450c482fb4bcddea8` | `Design/Comparisons/saved-detail-comparison.png` | Preserve the complete saved card, native return path, and Remove from Saved outside the card. Native accessibility reflow is permitted. |
| Settings / support and review | `Design/Approved/settings-support-c3.png` | iPhone full-screen mockup, 863 x 1822 px including device frame | Portrait | English | 2026-08-09 | `7aea1d31d7920360d85ac11196f492e761728711daedf164802e32c369945060` | `Design/Comparisons/settings-comparison.png` | Preserve optional support inside Settings, free core access, restore/manage controls, privacy/terms, and separate review entry. StoreKit prices must be live localized values. Native accessibility reflow is permitted. |
| App icon | `Design/Approved/app-icon-c1.png` | Square master, 1254 x 1254 px | N/A | No text | 2026-08-10 | `353b30862440057996c28eaaee116337f460107b961be22cf12b529af4e5e00c` | Runtime asset: `ZodiacDaily/Assets.xcassets/AppIcon.appiconset/` | Preserve the central twelve-point gold star, twelve orbiting points, midnight navy, no text, no zodiac-specific glyph, no transparency, and no pre-rounded corners. |

The comparison sheets contain captures from the real SwiftUI build on an
iPhone 15 Pro simulator at 1179 x 2556. Their provenance and workflow runs are
recorded in `Design/Comparisons/README.md`. The C3 turn affordance, fixed
viewport, provider-length stress state, and accessibility fallback have current
runtime evidence.

## Superseded approved references

| Screen / state | Retained reference | Status | Approved | Replaced by | Reason |
| --- | --- | --- | --- | --- | --- |
| Today / loaded card front | `Design/Concepts/today-loaded-front-c2-approved-history.png` | Superseded, retained | 2026-08-09 | `Design/Approved/today-loaded-front-flip-c3.png` | C3 preserves the composition and adds the owner-requested visible turn affordance without adding another screen row. |
| Today / card back | `Design/Concepts/today-card-back-c1.png` | Superseded, retained | 2026-08-10 | `Design/Approved/today-loaded-back-provider-c2.png` | The owner required all changing daily values to come from the real provider rather than local invention. |
| Settings / About | `Design/Concepts/settings-c2.png` | Superseded, retained | 2026-08-09 | `Design/Approved/settings-support-c3.png` | C3 keeps the approved Settings direction and adds the approved optional support/review section. |

## Proposal history (not current masters)

These files remain in `Design/Concepts/` and must not be used as final visual
specifications:

- `today-a-celestial-broadsheet.png`
- `today-b-modern-magazine.png`
- `today-c-mystic-night.png`
- `settings-language-support-c4.png` — complete Settings extension with the
  English/Español selector, the historical English-only provider note, and
  Help & Support. It predates the schema-3 Spanish translation candidate and
  must not govern that new note;
  SHA-256 `89e4ef5d2025b49593746604ccc5e1d8360442ecb28573b716f31e2e9516692f`.
- `today-settings-entry-c4.png` — complete Today proposal showing the visible
  Settings entry while retaining the sign selector's direct action; SHA-256
  `45afee32eac0ab2fd92345b7b58babcd74aa0494aaa9f32be4c0e470d876fa9f`.

The schema-3 candidate adds only functional language variants to the existing
hierarchy: an actual-language `EN`/`ES` marker on saved snapshots and an
English-fallback label when Spanish is unavailable. These variants remain
implementation candidates until real EN/ES captures are compared at the same
device size; they do not replace any current master in this manifest.

## Owner-directed Today correction awaiting runtime evidence

On 2026-08-18 the owner approved four precise changes to the current Today
direction: the sign capsule opens selection directly, both card faces use the
same turn icon, the Settings gear has no visible circular surround, and the
card is slightly smaller to create more space around Save and the tab bar.
These changes are an implementation candidate until the 0.2.2 real-build
English/Spanish captures are compared at the declared device sizes. The C3
front and C2 provider back remain the governing art direction in the meantime.

## Store screenshot rule

App Store screenshots may use the current masters as art direction only. The
base screenshot must be captured from the real release-candidate build at the
declared device size, then linked here with version, build, commit, locale,
device, resolution, capture date, and SHA-256 before submission. No store
screenshots are approved or registered yet.
