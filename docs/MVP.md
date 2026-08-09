# MVP

Updated: 2026-08-09

## Product promise

> A beautifully written daily horoscope for your sign, presented like a
> collectible editorial card.

## Target user

An English-speaking iPhone user with a casual interest in astrology who wants a
brief, attractive daily ritual without creating an account or sharing personal
data.

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
   - Short entertainment-content and local-privacy notices.

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
- Core flows work offline without accounts, tracking, or production services.
- Approved screens are reproduced faithfully and pass Dynamic Type, VoiceOver,
  contrast, and touch-target checks.
- English-only copy is complete and reviewed.

## Outside the MVP

- Android, a dedicated iPad layout, web, and additional languages.
- Accounts, login, sync, profiles, birth dates, or personal data.
- Natal charts, compatibility, tarot, chat, or personalized AI.
- Notifications, widgets, purchases, subscriptions, analytics, or ads.
- Publishing, TestFlight, or App Store submission.
- A content-management backend.
- Sharing is a stretch candidate, not a base requirement.
