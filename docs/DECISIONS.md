# Decisions

## 2026-08-09 — Initial product boundary

- Zodiac Daily is a separate app and repository from Tarot.
- Internal name: `ZodiacDailyNative`.
- Working public name: **Zodiac Daily**.
- Public-name shortlist: **The Daily Zodiac**, **Zodiac Post**,
  **Your Sign Today**, **Twelve Signs**, **Sign & Sky**,
  **Astral Edition**, and **Starprint Daily**.
- Platform: iPhone / iOS only for version 1.
- Language: English only.
- Privacy: no account or personal data in the MVP.
- Base action: save a daily card locally. Sharing is a stretch candidate.
- Visual approval is required per screen before UI implementation.

## 2026-08-09 — Practical visual gate

- Visual approval blocks final UI appearance, not non-visual product work.
- Core logic, local content, persistence, tests, build setup, privacy, and
  documentation may advance before visual approval.
- Any internal UI prototype created beforehand must be marked provisional and
  cannot establish the final layout or art direction.

## Recommended initial visual direction

Candidate A, **Celestial Broadsheet**, is the product recommendation because it
expresses the promised newspaper ritual most directly while remaining calm and
distinct from Tarot. Candidates B and C intentionally test a brighter modern
magazine and a darker nocturnal edition.

## 2026-08-09 — Collectible-card feedback

The owner asked for the reading to feel more like a card that can be saved as an
owned object. `today-c2-collectible-card.png` applies that feedback by showing
the complete card with all four corners visible and keeping the Save Card action
outside the card. C2 is now the recommended candidate pending explicit approval.

## 2026-08-09 — Today C2 approved

The owner explicitly approved `today-c2-collectible-card.png` and authorized
implementation. It is the final visual reference for Today. Sign Selection,
Saved, and Settings still require their own image approval; any implementation
of those screens before approval remains provisional.

## 2026-08-09 — Remaining primary screens approved

The owner explicitly approved `sign-selection-c2.png`,
`saved-populated-c2.png`, `saved-empty-c2.png`, and `settings-c2.png` and asked
the project to continue. These images now authorize final visual implementation
of Sign Selection, both Saved states, and Settings. Saved card detail remains
provisional until it receives its own complete image approval.

## 2026-08-09 — Free daily-content service

- The owner selected FreeAstroAPI's free plan instead of a paid provider or a
  large hand-authored annual bundle.
- A Cloudflare Worker on the free plan will protect the provider key, request
  the twelve individual sign readings, assemble one validated edition, and
  cache it by date.
- Cron triggers will only enqueue dates. A free Cloudflare Queue consumer will
  perform the paced provider fan-out, avoiding the cron-specific 10 ms CPU
  ceiling; one-message batches and concurrency one serialize duplicate work.
- The iOS app will request the complete edition from our Worker, never embed the
  FreeAstroAPI key, and never transmit the user's selected sign.
- Bundled content remains the offline and service-failure fallback. Saved cards
  remain immutable local snapshots.
- The first resolved edition for each sign/day is pinned locally so the same
  card cannot change when connectivity changes or the app relaunches.
- The owner accepts proceeding under FreeAstroAPI's published commercial-use
  terms despite their silence about indefinite saved-card retention.
- Implementation and local tests are authorized. Creating accounts, adding
  secrets, or deploying the Worker remains a separate explicit activation step.

## 2026-08-09 — Voluntary support standard

- Zodiac Daily remains fully usable for free. Support is optional and belongs
  inside Settings, never in the primary flow.
- User-facing wording will use **Support the app**, **Support development**, or
  **Monthly Supporter**, not donation language.
- Equivalent monthly auto-renewing tiers may provide supporter status, thanks,
  and minor visual acknowledgement only; no core feature is withheld.
- Pricing, duration, renewal, cancellation, restore purchases, privacy, and
  terms must be visible before purchase. App Store reviews remain a separate
  StoreKit action.
- This Settings extension requires its own complete visual proposal and owner
  approval. StoreKit product creation, builds, and IAP review are not authorized
  by this decision and do not block the current content work.

## 2026-08-09 — Advance visual authorization

- The owner instructed Codex to complete Zodiac Daily autonomously and treat
  any remaining visual proposals as approved without requesting another review.
- Existing `saved-detail-c2.png` and newly generated
  `settings-support-c3.png` are therefore approved final implementation
  references.
- This authorization covers local product and visual decisions. It does not
  supply external credentials or remove the separate no-upload/no-publication
  boundary.
