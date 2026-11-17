# Smart-ToDo

Smart-ToDo is an Anubisland Flutter task manager, built Android-first with iOS support in the generated project. It uses Material 3, a local SQLite database, English and Arabic UI, RTL layout, and light/dark/system themes.

## Current MVP

- Create, edit, complete, search, filter, and delete tasks. Deleted tasks can be restored from the undo action.
- Set a due date and optional time, duration, priority, category, project, notes, subtasks, and recurrence.
- Create the next daily or weekly occurrence when completing a recurring dated task.
- Use an offline English/Arabic quick parser for explicit dates, times, and durations.
- Browse a branded dashboard, task filters, monthly calendar, focus timer, task-status donut chart, and weekly completion chart.
- Create and check off persistent shopping, travel, and custom lists.
- Start grocery, travel, Umrah, Hajj, Ramadan, moving, and reading lists from editable checklist templates.
- Export tasks, focus history, lists, and list items as a JSON backup, then restore them after explicit confirmation.
- Choose Cairo, Amiri, Noto Sans Arabic, Noto Naskh Arabic, or Tajawal. Adjust text size and switch language and theme in Settings.
- Show the installed app version and Anubisland copyright notice in Settings.
- Use responsive bottom navigation on phones and a navigation rail on tablets.
- Persist tasks, lists, and focus sessions in SQLite; save language, font, text size, theme, and focus countdown preferences locally.
- Run Pomodoro countdowns that use a stored deadline, so elapsed time remains correct after backgrounding or reopening.

## Run

Flutter 3.44.9 / Dart 3.12.2 are used for the current build. Invoke Flutter with its full path if it is not on PATH.

```powershell
flutter pub get
flutter run
```

## Checks and Android build

```powershell
dart format .
flutter analyze
flutter test
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. Release builds use the existing Android debug key to preserve compatibility with the original evaluation APK; configure a dedicated production key after users have exported backups.

## Storage and privacy

Tasks, focus sessions, and saved lists are stored on the device. Backups are JSON files and are not encrypted; store them somewhere private. Smart input is local and does not call an AI service. There are no embedded service credentials. Firebase sync, AI planning, subscriptions, and local notifications are not configured or presented as available features.

## MVP boundaries

Project names and subtasks can be saved on tasks; there is no separate project overview or per-subtask completion tracking yet. Work, short-break, and long-break timers can be selected; automatic Pomodoro phase cycling is not implemented. Notifications are disabled because Android permission, exact-alarm, timezone, rescheduling, and device behavior have not been validated. Statistics show tasks completed by completion date and total recorded focus minutes.

The app icon supplied for this project is in `assets/branding/smart_todo_icon.png`; Android, iOS, and web launcher assets are generated from it. Bundled font files and their SIL Open Font License notices are in `assets/fonts/`.

## GitHub

The public repository is [`anubisland/Smart-ToDo`](https://github.com/anubisland/Smart-ToDo). Download the latest Android build from [GitHub Releases](https://github.com/anubisland/Smart-ToDo/releases/latest).
