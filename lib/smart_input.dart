import 'data/task.dart';

class SmartTaskDraft {
  const SmartTaskDraft(this.task, {this.needsReview = false});
  final TodoTask task;
  final bool needsReview;
}

/// Conservative offline parser: extracts only explicit date, clock time and duration.
class SmartInputParser {
  static SmartTaskDraft parse(String input, {DateTime? now}) {
    final current = now ?? DateTime.now();
    var title = input.trim();
    DateTime? due;
    var hasDueTime = false;
    int duration = 25;
    final durationMatch = RegExp(
      r'(?:for|لمدة)\s*(\d+|one|two|three|four|five|ساعة|ساعتين|ساعتان|دقيقة|دقيقتين)\s*(hours?|hrs?|h|minutes?|mins?|دقائق?|دقيقة|ساعات?|ساعة)?',
      caseSensitive: false,
    ).firstMatch(title);
    if (durationMatch != null) {
      final quantity = durationMatch.group(1)!.toLowerCase();
      final n =
          int.tryParse(quantity) ??
          const {
            'one': 1,
            'two': 2,
            'three': 3,
            'four': 4,
            'five': 5,
            'ساعة': 1,
            'ساعتين': 2,
            'ساعتان': 2,
            'دقيقة': 1,
            'دقيقتين': 2,
          }[quantity]!;
      final unit = (durationMatch.group(2) ?? quantity).toLowerCase();
      duration =
          unit.startsWith('h') ||
              unit.startsWith('ساعة') ||
              unit.startsWith('ساعات') ||
              quantity.startsWith('ساع')
          ? n * 60
          : n;
      title = title
          .replaceRange(durationMatch.start, durationMatch.end, '')
          .trim();
    }
    final timeMatch = RegExp(
      r'(?:at\s*)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)?|(?:الساعة\s*)?(\d{1,2})(?::(\d{2}))?\s*(مساءً|مساء|صباحاً|صباح)?',
      caseSensitive: false,
    ).firstMatch(title);
    if (timeMatch != null) {
      final ar = timeMatch.group(4) != null;
      var hour = int.parse(ar ? timeMatch.group(4)! : timeMatch.group(1)!);
      final minute =
          int.tryParse(
            ar ? (timeMatch.group(5) ?? '0') : (timeMatch.group(2) ?? '0'),
          ) ??
          0;
      final ampm = (ar ? timeMatch.group(6) : timeMatch.group(3))
          ?.toLowerCase();
      if (ampm != null &&
          (ampm == 'pm' || ampm.startsWith('مساء')) &&
          hour < 12) {
        hour += 12;
      }
      if (ampm != null &&
          (ampm == 'am' || ampm.startsWith('صباح')) &&
          hour == 12) {
        hour = 0;
      }
      if (hour < 24 && minute < 60) {
        due = DateTime(current.year, current.month, current.day, hour, minute);
        hasDueTime = true;
      }
      title = title.replaceRange(timeMatch.start, timeMatch.end, '').trim();
    }
    final lower = title.toLowerCase();
    if (lower.contains('tomorrow') ||
        title.contains('غداً') ||
        title.contains('غدا')) {
      final base = (due ?? current).add(const Duration(days: 1));
      due = DateTime(
        base.year,
        base.month,
        base.day,
        due?.hour ?? 0,
        due?.minute ?? 0,
      );
      title = title
          .replaceAll(RegExp(r'\btomorrow\b', caseSensitive: false), '')
          .replaceAll(RegExp(r'غداً|غدا'), '')
          .trim();
    } else if (lower.contains('today') || title.contains('اليوم')) {
      due ??= DateTime(current.year, current.month, current.day);
      title = title
          .replaceAll(RegExp(r'\btoday\b', caseSensitive: false), '')
          .replaceAll('اليوم', '')
          .trim();
    }
    final cleaned = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    return SmartTaskDraft(
      TodoTask(
        id: null,
        title: cleaned.isEmpty ? input.trim() : cleaned,
        dueAt: due,
        hasDueTime: hasDueTime,
        durationMinutes: duration,
      ),
      needsReview:
          due == null &&
          (input.contains('غداً') || input.toLowerCase().contains('tomorrow')),
    );
  }
}
