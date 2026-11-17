# Smart-ToDo

Smart-ToDo is an Anubisland Flutter task manager, built Android-first with iOS support in the generated project. It uses Material 3, a local SQLite database, English and Arabic UI, RTL layout, and light/dark/system themes.

## Current MVP

- Create, edit, complete, search, filter, and delete tasks. Deleted tasks can be restored from the undo action.
- Set a due date and optional time, duration, priority, category, project, notes, subtasks, and recurrence.
- Create the next daily or weekly occurrence when completing a recurring dated task.
- Use an offline English/Arabic quick parser for explicit dates, times, and durations.
- Browse a branded dashboard, task filters, monthly calendar, focus timer, task-status donut chart, and weekly completion chart.
- Create and check off persistent shopping, travel, and custom lists.
- Choose Cairo, Amiri, Noto Sans Arabic, Noto Naskh Arabic, or Tajawal. Adjust text size and switch language and theme in Settings.
- Use responsive bottom navigation on phones and a navigation rail on tablets.
- Persist tasks, lists, and focus sessions in SQLite; save language, font, text size, theme, and focus countdown preferences locally.
- Run Pomodoro countdowns that use a stored deadline, so elapsed time remains correct after backgrounding or reopening.

## Run

Flutter 3.41.9 / Dart 3.11.5 were used to initialize and build this project. Add `C:\src\flutter\bin` to PATH, or invoke Flutter with its full path.

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

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. The release build succeeds; Flutter Doctor still reports Android SDK licenses that have not been accepted on this workstation.

## Storage and privacy

Tasks and focus-session totals are stored on the device. Smart input is local and does not call an AI service. There are no embedded service credentials. Firebase sync, AI planning, subscriptions, and local notifications are not configured or presented as available features.

## MVP boundaries

Project names and subtasks can be saved on tasks; there is no separate project overview or per-subtask completion tracking yet. Work, short-break, and long-break timers can be selected; automatic Pomodoro phase cycling is not implemented. Notifications are disabled because Android permission, exact-alarm, timezone, rescheduling, and device behavior have not been validated. Statistics show tasks completed by completion date and total recorded focus minutes.

The app icon supplied for this project is in `assets/branding/smart_todo_icon.png`; Android, iOS, and web launcher assets are generated from it. Bundled font files and their SIL Open Font License notices are in `assets/fonts/`.

## GitHub

The local repository is initialized on `main`. GitHub CLI is authenticated as `melwazeer` and can see the `anubisland` organization. No remote repository has been created, and nothing has been pushed. The intended remote name is `Smart-ToDo`; create/push only after confirming the organization's repository permissions and visibility.
