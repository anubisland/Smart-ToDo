# Changelog

## 1.0.1 — 2026-11-17

- Added JSON backup and restore for tasks, focus sessions, and saved lists. Restore validates the file and asks before replacing current data.
- Added editable grocery, travel, Umrah, Hajj, Ramadan, moving, and reading list templates.
- Kept the existing Android signing certificate so this APK can update the 1.0.0 evaluation build without uninstalling it.
- Added file picker support and excluded Android build output from version control.

The backup file is not encrypted. Store it in a private location. Settings and the in-progress focus countdown are not part of the backup.
