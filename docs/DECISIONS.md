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
