import 'package:flutter/material.dart';
import 'app.dart';
import 'data/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await ReminderService.instance.initialize();
  } catch (_) {
    // Notification setup is optional; task management must still start.
  }
  runApp(const SmartTodoApp());
}
