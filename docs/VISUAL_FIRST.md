# Visual-first gate

Updated: 2026-08-09

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
| Welcome / no sign selected | `Design/Concepts/sign-selection-c2.png` | **Approved for final visual implementation** | 2026-08-09 | All 12 signs, no personal data, Pisces shown selected as an example. Native accessibility adaptations are allowed. |
| Saved / populated | `Design/Concepts/saved-populated-c2.png` | **Approved for final visual implementation** | 2026-08-09 | Personal archive of clearly separate card thumbnails. Native accessibility adaptations are allowed. |
| Saved / empty | `Design/Concepts/saved-empty-c2.png` | **Approved for final visual implementation** | 2026-08-09 | Empty collectible-card outline and route back to Today. Native accessibility adaptations are allowed. |
| Settings / About sheet | `Design/Concepts/settings-c2.png` | **Approved for final visual implementation** | 2026-08-09 | Native sheet for sign, local privacy, and entertainment notice. Native accessibility adaptations are allowed. |
| Saved / card detail | Not generated | Provisional implementation only | — | Reuses the approved card object, but its surrounding hierarchy is not approved. |

Approval of Today does not imply approval of the remaining screens. After a
direction is chosen, each required screen will receive its own complete image
and approval record before implementation.

Accessibility or native-platform adaptations must preserve the approved visual
hierarchy while allowing readable Dynamic Type, sufficient contrast, safe
areas, and standard touch targets.
