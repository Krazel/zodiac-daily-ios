# Visual-first gate

Updated: 2026-08-10

Explicit owner approval blocks only the final visual implementation. While a
screen is awaiting approval, work may continue on non-visual engine logic,
rules, data, local content, architecture, navigation plumbing, persistence,
tests, build/CI, privacy, store documentation, and clearly provisional internal
prototypes. Prototypes do not count as final screens and must not fix final
layout, art, iconography, store captures, major visual motion, or final visual
experience.

## Approval register

| Screen / state | Candidate images | Status | Approval date | Requested changes |
|---|---|---|---|---|
| Today / daily card available | `Design/Concepts/today-c2-collectible-card.png` | **Approved for final visual implementation** | 2026-08-09 | Preserve the complete saveable-card object with all four corners visible and keep Save Card outside it. Native accessibility adaptations are allowed. |
| Today / provider-data card reverse | `Design/Concepts/today-card-back-provider-c2.png` | **Approved for final visual implementation by owner's advance authorization and owner's instruction to proceed** | 2026-08-10 | Preserve the existing frame and Today composition. All daily values must come from FreeAstroAPI V2: focus, keywords, Love/Career/Money/Health scores, lucky number/color, and Moon data. Sign essence remains a clearly static sign profile. |
| Welcome / no sign selected | `Design/Concepts/sign-selection-c2.png` | **Approved for final visual implementation** | 2026-08-09 | All 12 signs, no personal data, Pisces shown selected as an example. Native accessibility adaptations are allowed. |
| Saved / populated | `Design/Concepts/saved-populated-c2.png` | **Approved for final visual implementation** | 2026-08-09 | Personal archive of clearly separate card thumbnails. Native accessibility adaptations are allowed. |
| Saved / empty | `Design/Concepts/saved-empty-c2.png` | **Approved for final visual implementation** | 2026-08-09 | Empty collectible-card outline and route back to Today. Native accessibility adaptations are allowed. |
| Settings / About sheet | `Design/Concepts/settings-c2.png` | **Approved for final visual implementation** | 2026-08-09 | Native sheet for sign, local privacy, and entertainment notice. Native accessibility adaptations are allowed. |
| Settings / Support and review extension | `Design/Concepts/settings-support-c3.png` | **Approved for final visual implementation by owner's advance authorization** | 2026-08-09 | Optional Support the app. The original three-row reference is extended to the canonical seven equivalent monthly levels confirmed on 2026-09-01; all use the same title/benefit and differ only by the live localized StoreKit price. Restore/manage, renewal disclosure, terms/privacy, and separate App Store review remain required. Must not obstruct free use. Native accessibility adaptations are allowed. |
| Saved / card detail | `Design/Concepts/saved-detail-c2.png` | **Approved for final visual implementation by owner's advance authorization** | 2026-08-09 | Complete saved-card object, native return path, and Remove from Saved outside the card. Native accessibility adaptations are allowed. |
| App icon | `Design/Concepts/app-icon-c1.png` | **Approved for final production integration by owner's advance authorization** | 2026-08-10 | Central twelve-point gold star and twelve orbiting points on midnight navy. No text, zodiac-specific glyph, transparency, or pre-rounded corners. |

Approval is recorded per screen and state. On 2026-08-09 the owner explicitly
authorized Codex to treat all remaining Zodiac Daily visual proposals as
approved without another confirmation round. That authorization is recorded on
the two rows above and does not authorize App Store upload or publication.

Accessibility or native-platform adaptations must preserve the approved visual
hierarchy while allowing readable Dynamic Type, sufficient contrast, safe
areas, and standard touch targets.
