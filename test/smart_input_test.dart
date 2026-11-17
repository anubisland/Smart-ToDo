import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo/data/task.dart';
import 'package:smart_todo/smart_input.dart';

void main() {
  group('SmartInputParser', () {
    final now = DateTime(2026, 11, 16, 10);

    test('extracts English tomorrow, time and duration explicitly', () {
      final draft = SmartInputParser.parse(
        'Complete the project report tomorrow at 5 PM for two hours',
        now: now,
      );
      expect(draft.task.title, 'Complete the project report');
      expect(draft.task.dueAt, DateTime(2026, 11, 17, 17));
      expect(draft.task.durationMinutes, 120);
    });

    test('extracts Arabic tomorrow and evening time', () {
      final draft = SmartInputParser.parse(
        'مذاكرة الرياضيات غداً الساعة 5 مساءً لمدة ساعتين',
        now: now,
      );
      expect(draft.task.dueAt, DateTime(2026, 11, 17, 17));
      expect(draft.task.durationMinutes, 120);
    });

    test('does not add a date to a task without a date phrase', () {
      final draft = SmartInputParser.parse('Read a chapter', now: now);
      expect(draft.task.dueAt, isNull);
      expect(draft.task.title, 'Read a chapter');
    });
  });

  test('task data survives serialization with priority and date', () {
    final original = TodoTask(
      id: 3,
      title: 'Review',
      dueAt: DateTime(2026, 11, 18, 14),
      priority: TaskPriority.high,
      completed: true,
      subtasks: const ['Read', 'Revise'],
    );
    final restored = TodoTask.fromMap(original.toMap());
    expect(restored.title, original.title);
    expect(restored.dueAt, original.dueAt);
    expect(restored.priority, TaskPriority.high);
    expect(restored.completed, isTrue);
    expect(restored.subtasks, original.subtasks);
  });

  test('date-only tasks become overdue after their due day ends', () {
    final task = TodoTask(
      id: 1,
      title: 'Due today',
      dueAt: DateTime(2026, 11, 16),
    );
    expect(isOverdue(task, DateTime(2026, 11, 16, 23, 59)), isFalse);
    expect(isOverdue(task, DateTime(2026, 11, 17)), isTrue);
  });

  test('weekly recurrence creates the next scheduled task on completion', () {
    final task = TodoTask(
      id: 8,
      title: 'Weekly review',
      dueAt: DateTime(2026, 11, 16, 17),
      hasDueTime: true,
      recurrence: 'weekly',
    );
    final next = nextOccurrence(task)!;
    expect(next.id, isNull);
    expect(next.completed, isFalse);
    expect(next.dueAt, DateTime(2026, 11, 23, 17));
    expect(nextOccurrence(task.copyWith(completed: true)), isNull);
  });
}
