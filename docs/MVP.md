# MVP

Updated: 2026-08-09

## Product promise

> A beautifully written daily horoscope for your sign, presented like a
> collectible editorial card.

## Target user

An English- or Spanish-speaking iPhone user with a casual interest in astrology
who wants a brief, attractive daily ritual without creating an account or
sharing personal data. Interface and daily editorial content support English
and Spanish; English is the explicit availability fallback.

## Minimum flow and screens

1. **Welcome / Sign Selection**
   - Choose one of the 12 zodiac signs.
   - No birth date, account, or personal data.
2. **Today**
   - Selected sign, local date, headline, and daily reading.
   - Save or remove the card from saved items.
   - Change sign through a secondary control.
3. **Saved**
   - Local archive of saved cards.
   - Open a past card and remove it from saved items.
4. **Settings / About sheet**
   - Change sign.
   - Change interface and daily edition immediately between English and
     Español.
   - Optional Support the app, restore/manage subscription, review, help,
     privacy, terms, and entertainment notice.

## Required states

- First launch with no selected sign.
- Daily card available for the selected sign.
- Brief loading or refresh transition.
- Saved and unsaved card.
- Empty and populated Saved archive.
- Offline with already bundled or cached content.
- Content error with retry.
- New local day and new edition.
- Sign change.

No permissions are required in the MVP.

## Definition of done for the first candidate

- Runs on the agreed minimum iOS version on supported iPhones.
- The user can select a sign, read one stable card for the local day, save it,
  find it after relaunch, and change sign.
- All 12 signs and daily-key behavior have automated coverage.
- Core flows use no accounts or tracking. Fresh content uses the free daily
  service; English has a bundled emergency edition and resolved Spanish
  editions remain available from the local daily cache.
- Approved screens are reproduced faithfully and pass Dynamic Type, VoiceOver,
  contrast, and touch-target checks.
- English and Spanish interface copy is complete and reviewed; daily provider
  copy stays in the selected language and Spanish never falls back silently to
  English.

## Outside the MVP

- Android, a dedicated iPad layout, web, and languages beyond English/Spanish.
- Accounts, login, sync, profiles, birth dates, or personal data.
- Natal charts, compatibility, tarot, chat, or personalized AI.
- Notifications, widgets, analytics, or ads.
- Paid feature gates. Optional monthly supporter products are release-readiness
  work and may not restrict the free core experience.
- Publishing, TestFlight, or App Store submission.
- A general-purpose content-management backend. The narrow daily cache/proxy is
  allowed and contains no user accounts or personal data.
- Sharing is a stretch candidate, not a base requirement.
