# Smart-ToDo 1.0.2

- Optional local Android reminders for tasks with a due time. Date-only tasks are scheduled for 9:00 AM local time.
- Android asks for notification permission when reminders are first enabled in Settings.
- Scheduled reminders are restored after device reboot, app update, or system time-zone change.
- The APK uses the same signing certificate as earlier releases, so it can update 1.0.0 or 1.0.1 without uninstalling.

Reminders use Android's inexact scheduling to avoid requesting exact-alarm access. Android power-saving behavior and some manufacturers can delay delivery. Enable reminders in **Settings → Reminders**.
