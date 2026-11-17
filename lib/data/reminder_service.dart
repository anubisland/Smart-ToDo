import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'task.dart';

class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    final localZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localZone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final requested = await android?.requestNotificationsPermission();
    final enabled = await android?.areNotificationsEnabled();
    return enabled ?? requested ?? true;
  }

  Future<bool> areNotificationsEnabled() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.areNotificationsEnabled() ?? true;
  }

  Future<void> scheduleTask(TodoTask task, String lang) async {
    if (task.id == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('reminders_enabled') ?? false)) return;
    if (task.completed || task.dueAt == null) {
      await cancelTask(task.id!);
      return;
    }
    await initialize();
    await _schedule(task, lang);
  }

  Future<void> scheduleAll(List<TodoTask> tasks, String lang) async {
    await initialize();
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('reminders_enabled') ?? false)) return;
    final now = tz.TZDateTime.now(tz.local);
    final eligible = tasks.where((task) {
      if (task.id == null || task.completed || task.dueAt == null) return false;
      return _scheduledTime(task).isAfter(now);
    }).toList()..sort((a, b) => _scheduledTime(a).compareTo(_scheduledTime(b)));
    for (final task in eligible.take(450)) {
      await _schedule(task, lang);
    }
  }

  Future<void> cancelTask(int id) async {
    await initialize();
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  Future<void> _schedule(TodoTask task, String lang) async {
    final id = task.id;
    if (id == null || task.dueAt == null || task.completed) return;
    final scheduledDate = _scheduledTime(task);
    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _plugin.cancel(id: id);
      return;
    }
    final dueText = lang == 'ar' ? 'حان موعد المهمة' : 'Task is due now';
    await _plugin.zonedSchedule(
      id: id,
      title: task.title,
      body: task.description.isEmpty ? dueText : task.description,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          lang == 'ar' ? 'تذكيرات المهام' : 'Task reminders',
          channelDescription: lang == 'ar'
              ? 'تنبيهات المهام المجدولة'
              : 'Notifications for scheduled tasks',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: id.toString(),
    );
  }

  tz.TZDateTime _scheduledTime(TodoTask task) {
    final due = task.dueAt!;
    final dateTime = task.hasDueTime
        ? due
        : DateTime(due.year, due.month, due.day, 9);
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
