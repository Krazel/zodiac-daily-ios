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
| Today / daily card available | `Design/Concepts/today-a-celestial-broadsheet.png`; `today-b-modern-magazine.png`; `today-c-mystic-night.png`; `today-c2-collectible-card.png` | C2 revision awaiting approval | — | Owner asked for the reading to feel like a saveable physical card; C2 makes the whole card visible and moves Save Card outside it. |
| Welcome / no sign selected | Not generated | Blocked by Today direction | — | — |
| Saved / empty and populated | Not generated | Blocked by Today direction | — | — |
| Settings / About sheet | Not generated | Blocked by Today direction | — | — |

Approval of Today does not imply approval of the remaining screens. After a
direction is chosen, each required screen will receive its own complete image
and approval record before implementation.

Accessibility or native-platform adaptations must preserve the approved visual
hierarchy while allowing readable Dynamic Type, sufficient contrast, safe
areas, and standard touch targets.
