# Changelog

## 1.0.8 — 2026-11-17

- Added weekday and monthly task recurrence options in English and Arabic.
- Preserved the time of day when creating a recurring occurrence and clamped monthly dates to the last valid day of shorter months.
- Kept the existing Android signing certificate for direct upgrades.

## 1.0.7 — 2026-11-17

- Added optional password-protected encrypted backups using Argon2id key derivation and authenticated AES-256-GCM encryption.
- Kept the standard JSON backup and restore flow, including support for existing backups.
- Added encrypted `.stbackup` restore and password confirmation.
- Preserved the existing Android signing certificate for direct upgrades.

## 1.0.6 — 2026-11-17

- Added 7-day and 30-day completion trend views with comparison to the previous period.
- Added completed-task progress by category.
- Kept the existing Android signing certificate for direct upgrades.

## 1.0.5 — 2026-11-17

- Added guided Pomodoro phase cycling: focus sessions prepare a short break, every fourth prepares a long break, and breaks prepare the next focus session.
- Kept transitions manual so the next phase does not start without the user.
- Saved completed focus sessions and cycle progress across app restarts.
- Preserved the existing Android signing certificate for direct upgrades.

## 1.0.4 — 2026-11-17

- Added a dashboard project overview with per-project completion progress.
- Added project filtering to the task list and included project names in search.
- Preserved the existing Android signing certificate for direct upgrades.

## 1.0.3 — 2026-11-17

- Added individually checkable subtasks with progress indicators on task cards.
- Added a database migration that preserves existing tasks and resets subtask progress for each recurring occurrence.
- Kept the existing Android signing certificate for a direct update from 1.0.2.

## 1.0.2 — 2026-11-17

- Added opt-in Android task reminders. Tasks with a time notify at the scheduled time; date-only tasks notify at 9:00 AM local time.
- Added Android notification permission handling and rescheduling after reboot, time changes, and app updates.
- Reminders use inexact alarms so they do not require exact-alarm access. Battery-saving policies and some device manufacturers may delay delivery.
- Preserved the existing Android signing certificate for a direct update from 1.0.1.

## 1.0.1 — 2026-11-17

- Added JSON backup and restore for tasks, focus sessions, and saved lists. Restore validates the file and asks before replacing current data.
- Added editable grocery, travel, Umrah, Hajj, Ramadan, moving, and reading list templates.
- Kept the existing Android signing certificate so this APK can update the 1.0.0 evaluation build without uninstalling it.
- Added file picker support and excluded Android build output from version control.

The backup file is not encrypted. Store it in a private location. Settings and the in-progress focus countdown are not part of the backup.
