# Canonical visual approvals

Updated: 2026-08-31

This file is the source of truth for the complete approved images that govern
the shipped app. `Design/Approved/` contains only current masters.
`Design/Concepts/` contains proposals and retained approval history;
`Design/Comparisons/` contains real-build comparison evidence. A replacement
must be added as a new file and row before the previous master is marked
superseded. Approved history is never overwritten or deleted.

## Current masters

| Screen / state | Current master | Device / canvas | Orientation | Language | Approved | SHA-256 | Runtime evidence | Required fidelity / permitted adaptation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Today / loaded card front | `Design/Approved/today-readable-type-c7-front.png` | iPhone 15 Pro full-screen proposal, 853 x 1844 px | Portrait | Spanish | 2026-08-31 | `ba343b027cc7cf9c1fe3346cd7d2d03c670eaaf9a68688e117879deda1445c7a` | `Design/Comparisons/today-readable-type-c7-es-runtime.png`, run `33348593592`, commit `c48a449`, SHA-256 `4212f78d6e4b2e1286ed77a9a5437ca177aab6a51498203dfaf74a96f4ee8f36` | Preserve C6 composition. Use the sturdy native serif only for masthead and horoscope headline; reading copy, labels, cues, controls, and navigation use the native sans-serif at readable weights. |
| Today / loaded card back, provider data | `Design/Approved/today-readable-type-c7-back.png` | iPhone 15 Pro full-screen proposal, 853 x 1844 px | Portrait | Spanish | 2026-08-31 | `54af4da12d0596cfd5a5d87e567344ae3e27aae4b8f26c39e9e8fcfa0e621857` | `Design/Comparisons/today-readable-type-c7-back-es-runtime.png`, run `33348593592`, commit `c48a449`, SHA-256 `c57cf3d59ce6b02fc99f5fcb81b62afac837b833eefbec4105f8bdc7f63651e1` | Preserve every provider field and C6 geometry. Only masthead and Deeper Reading retain the editorial serif; changing values, labels, scores, lucky details, Moon, essence, cue, and controls use the native sans-serif. Scores and lucky numbers use semibold tabular digits. |
| First launch / sign selection | `Design/Approved/sign-selection-readable-type-c3.png` | iPhone 15 Pro full-screen proposal, 853 x 1844 px | Portrait | English | 2026-08-31 | `904e5fc419c6b4389c5afe65b1b567d276e0e94db2ce5858bdf85dad5ea372f3` | `Design/Comparisons/sign-selection-readable-type-c3-runtime.png`, run `33348593592`, commit `c48a449`, SHA-256 `8f0cc5164acbc0ae76b005fbbba3880d18de7dfdc4e71e38d964980cf486361d` | Preserve all 12 cards and selected-state glow. Titles retain the sturdy editorial serif; sign labels, explanation, and Continue use the native sans-serif with reduced tracking so long names remain readable. |
| Saved / empty | `Design/Approved/saved-empty-readable-type-c3.png` | iPhone 15 Pro full-screen proposal, 853 x 1844 px | Portrait | English | 2026-08-31 | `8bedefb6496355adbab9f29376c13d8838b4a56cbc492bfb12c9a3be601bbd2c` | `Design/Comparisons/saved-empty-readable-type-c3-runtime.png`, run `33348593592`, commit `c48a449`, SHA-256 `a49b85ca2db594d63c1e5a21114996880f5d285976357b6c89026e1e3b82bbe1` | Preserve the empty collectible-card composition. Editorial titles use the sturdy serif; explanatory copy, action, and tabs use the native sans-serif. |
| Saved / populated | `Design/Approved/saved-readable-type-c3.png` | iPhone 15 Pro full-screen proposal, 853 x 1844 px | Portrait | English | 2026-08-31 | `2455dc89a59e5df05994d33c3d1b96fcfd3c73957de0ec4061c293a16191a6d4` | `Design/Comparisons/saved-readable-type-c3-runtime.png`, run `33348593592`, commit `c48a449`, SHA-256 `482f12eadbd81eaa457d3fc0e9232e3ec231838dc5bd65d13a79d4fe789e8d0e` | Preserve the three-card archive and artwork. Card headlines retain the editorial serif; sign names, metadata, collection count, and tabs use the native sans-serif with long names kept inside their cards. |
| Saved / card detail | `Design/Approved/saved-detail-readable-type-c7.png` | iPhone 15 Pro full-screen proposal, 853 x 1844 px | Portrait | Spanish | 2026-08-31 | `10989616273d65ac90f1245c7c56235f6db09ba3720375feb3b8b3c2f7753191` | Front `Design/Comparisons/saved-detail-readable-type-c7-es-runtime.png`, SHA-256 `8deecc514bf19f9af5bfa32cad7048738ccb040cd980f0111b80affb6b43eefb`; back `Design/Comparisons/saved-detail-readable-type-c7-back-es-runtime.png`, SHA-256 `a893938a2fce009e93b40754cde31deaa61fb198beaffd953797b4a7e7744b13`; run `33348593592`, commit `c48a449` | Preserve the complete shared C7 card and stationary detail composition. Only the horoscope headline uses the sturdy serif; navigation, header, metadata, reading, cue, and destructive action use the native sans-serif. |
| Settings / free 1.0 release | `Design/Approved/settings-free-release-c5.png` | iPhone 14 Plus real-build capture, 1284 x 2778 px | Portrait | English | 2026-08-31 | `d259183792506f6010691d3847e89201210677f19421b74e669466b6fa9b1d20` | `AppStore/StoreReady/en-US/05-settings.png`, run `33440182881`, commit `fa03ff0`, same SHA-256 | Preserve the readable Settings hierarchy for sign, language, review, privacy, help, and version. The unconfigured supporter section is intentionally absent from the free 1.0 release. |
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
| Today / loaded card front | `Design/Approved/today-loaded-front-flip-c3.png` | Superseded, retained | 2026-08-11 | `Design/Approved/today-loaded-front-flip-c4-es-runtime.png` | C4 records the owner-directed direct selector, matching turn icons, unframed Settings gear, smaller card, and increased action/tab spacing in a real Spanish build. |
| Today / loaded card front | `Design/Approved/today-loaded-front-flip-c4-es-runtime.png` | Superseded, retained | 2026-08-18 | `Design/Approved/today-readable-frame-c5b.png` | The owner selected C5B for the card border and requested substantially larger reading type. C4 remains the real-build baseline for all unchanged Today elements. |
| Today / provider-data card back | `Design/Approved/today-loaded-back-provider-c2.png` | Superseded, retained | 2026-08-10 | `Design/Approved/today-loaded-back-provider-c3-es-runtime.png` | C3 records the same owner-directed composition changes and the complete Spanish provider-data state in a real build. |
| Today / C5B border and typography proposal | `Design/Approved/today-readable-frame-c5b.png` | Superseded as master, retained approval source | 2026-08-26 | `Design/Approved/today-loaded-front-c5b-es-runtime.png` | The real build now records the approved C5B border direction and larger reading together with the unchanged C4 screen composition. |
| Today / provider-data card back | `Design/Approved/today-loaded-back-provider-c3-es-runtime.png` | Superseded, retained | 2026-08-18 | `Design/Approved/today-loaded-back-provider-c5b-es-runtime.png` | The complete provider hierarchy is unchanged; the replacement records the shared C5B physical frame in the real build. |
| Today / loaded card front | `Design/Approved/today-loaded-front-c5b-es-runtime.png` | Superseded, retained | 2026-08-26 | `Design/Approved/today-large-card-front-c6-approved.png` | Owner removed the Today sign selector, enlarged the card, and required a composed reading zone after real TestFlight evidence showed cramped literal text. |
| Today / provider-data card back | `Design/Approved/today-loaded-back-provider-c5b-es-runtime.png` | Superseded, retained | 2026-08-26 | `Design/Approved/today-large-card-back-c6-approved.png` | Owner required substantially larger back typography and approved the C6 grouped hierarchy after seeing the small real-device text. |
| Saved / card detail | `Design/Approved/saved-detail-c2.png` | Superseded, retained | 2026-08-09 | `Design/Approved/saved-detail-c5b-en-runtime.png` | The real build records the same approved detail hierarchy with the shared C5B physical frame and stationary compact layout. |
| Settings / About | `Design/Concepts/settings-c2.png` | Superseded, retained | 2026-08-09 | `Design/Approved/settings-support-c3.png` | C3 keeps the approved Settings direction and adds the approved optional support/review section. |
| Today / loaded card front | `Design/Approved/today-large-card-front-c6-approved.png` | Superseded, retained | 2026-08-31 | `Design/Approved/today-readable-type-c7-front.png` | Owner requested an app-wide readable type system after real-device evidence showed the previous thin serif was difficult to read. |
| Today / provider-data card back | `Design/Approved/today-large-card-back-c6-approved.png` | Superseded, retained | 2026-08-31 | `Design/Approved/today-readable-type-c7-back.png` | C7 removes thin serif from changing data and uses clearer semibold sans-serif values and tabular numbers. |
| First launch / sign selection | `Design/Approved/sign-selection-c2.png` | Superseded, retained | 2026-08-09 | `Design/Approved/sign-selection-readable-type-c3.png` | C3 applies the global readable type system and protects long sign names. |
| Saved / empty | `Design/Approved/saved-empty-c2.png` | Superseded, retained | 2026-08-09 | `Design/Approved/saved-empty-readable-type-c3.png` | C3 applies the global readable type system without changing composition. |
| Saved / populated | `Design/Approved/saved-populated-c2.png` | Superseded, retained | 2026-08-09 | `Design/Approved/saved-readable-type-c3.png` | C3 applies the global readable type system to archive metadata and navigation. |
| Saved / card detail | `Design/Approved/saved-detail-c5b-en-runtime.png` | Superseded, retained | 2026-08-26 | `Design/Approved/saved-detail-readable-type-c7.png` | C7 applies shared-card typography and replaces the thin-serif interface header. |
| Settings / support and review | `Design/Approved/settings-support-c3.png` | Superseded, retained | 2026-08-09 | `Design/Approved/settings-readable-type-c4.png` | C4 removes thin serif from controls, prices, legal rows, and explanatory copy while preserving the approved Settings structure. |
| Settings / support and review | `Design/Approved/settings-readable-type-c4.png` | Superseded, retained | 2026-08-31 | `Design/Approved/settings-free-release-c5.png` | Version 1.0 deliberately ships without unconfigured purchases. C5 records the exact free-release Settings screen while retaining the readable typography and legal/support rows. |

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
- `today-readable-frame-c5a.png` — unapproved 853 x 1844 full-screen proposal
  with a restrained double-line frame, four-point corner stars, and larger
  reading typography; SHA-256
  `c7c1e28c4c273ccd5ba8dc3e836cd6957f53167fa5a9c57a1bffb55063dc7387`.
- `today-readable-frame-c5b.png` — approved 2026-08-26 for the card border and
  larger reading direction; the proposal copy is retained here and its
  canonical copy is `Design/Approved/today-readable-frame-c5b.png`; SHA-256
  `2086a188263371138f8801c4b27312fc640bb2d32401629dd8f07e2dbd0159b4`.

The schema-3 candidate adds only functional language variants to the existing
hierarchy: an actual-language `EN`/`ES` marker on saved snapshots and an
English-fallback label when Spanish is unavailable. These variants remain
implementation candidates until real EN/ES captures are compared at the same
device size; they do not replace any current master in this manifest.

## Owner-directed Today correction completed

On 2026-08-18 the owner approved four precise changes to the current Today
direction: the sign capsule opens selection directly, both card faces use the
same turn icon, the Settings gear has no visible circular surround, and the
card is slightly smaller to create more space around Save and the tab bar.
The 0.2.2 real-build English/Spanish captures passed on iPhone 15 Pro and the
stationary compact-height check passed on iPhone SE. The resulting Spanish
front C4 and provider back C3 are now the complete current masters above; the
previous English mockups remain retained as superseded approval history.

## Store-ready release captures — 1.0 (1)

The following screenshots were captured from the actual release-candidate UI,
not redrawn. They were produced by workflow run `33440182881` from commit
`fa03ff09e4f383fe454c782e7eb0ec373511d4cb` on an iPhone 14 Plus simulator at
1284 x 2778 px, portrait, on 2026-08-31. The artifact digest is
`sha256:2b1126361fd2d5492cf0f4aa3b9f343f9aa6c7584fac5d7476342467c73a8853`.

| Locale | Order / state | File | SHA-256 |
| --- | --- | --- | --- |
| en-US | 01 Today | `AppStore/StoreReady/en-US/01-today.png` | `058d41edf83bd83f36872041ee2150d9f3d4780bb9d264505a1778fc684d2dbc` |
| en-US | 02 Daily details | `AppStore/StoreReady/en-US/02-daily-details.png` | `505b10be1c260b5c44c729c33c3b25d3a8b815caadcc15da8d02e97d18cddf14` |
| en-US | 03 Saved cards | `AppStore/StoreReady/en-US/03-saved-cards.png` | `fd9c724959ef4ddf2f35ee8324e233b5cfc6266ef4a162947735e4620ead7115` |
| en-US | 04 Saved detail | `AppStore/StoreReady/en-US/04-saved-detail.png` | `beb8005d1eae2f16eb6b60687cff578f789cf7988f102a1779923b764019ed0d` |
| en-US | 05 Settings | `AppStore/StoreReady/en-US/05-settings.png` | `d259183792506f6010691d3847e89201210677f19421b74e669466b6fa9b1d20` |
| en-US | 06 Choose sign | `AppStore/StoreReady/en-US/06-choose-sign.png` | `97d11be698d77dc4e7e337b12b5848e440789af2632ff6f2027f5624340f4d85` |
| es-ES | 01 Hoy | `AppStore/StoreReady/es-ES/01-today.png` | `0173d1e1beb7cd4f349fd7662f8b33893f666e17ccafb9a7cb50cfff892f7cd6` |
| es-ES | 02 Lectura profunda | `AppStore/StoreReady/es-ES/02-daily-details.png` | `22dd3f10ae941734f86ba727ef59f55f4de74ef66b8774cb30d55590607c0384` |
| es-ES | 03 Cartas guardadas | `AppStore/StoreReady/es-ES/03-saved-cards.png` | `771824fe626a794d4ab775b42327d3a4f632a5101a95e7504416f8b9d96826a8` |
| es-ES | 04 Detalle guardado | `AppStore/StoreReady/es-ES/04-saved-detail.png` | `2fd4a7bcfcd8e3d69fd80899127d4309e3d4f89c8b377f61bc9aacd5e8a69f0c` |
| es-ES | 05 Ajustes | `AppStore/StoreReady/es-ES/05-settings.png` | `3b625bfa22cb129e315eba4e5610e2797dae741e33146af67bb5084af1a143cb` |
| es-ES | 06 Elegir signo | `AppStore/StoreReady/es-ES/06-choose-sign.png` | `9a59ca7b31ec9c921b4756ccc7311fb335ec0119118bf974caf3f4ad7384d5dd` |

## Store screenshot rule

App Store screenshots may use the current masters as art direction only. The
base screenshot must be captured from the real release-candidate build at the
declared device size, then linked here with version, build, commit, locale,
device, resolution, capture date, and SHA-256 before submission. The registered
1.0 (1) set above satisfies this rule; any later build requires a new set.
