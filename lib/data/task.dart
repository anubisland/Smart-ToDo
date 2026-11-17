enum TaskPriority { low, medium, high }

class TodoTask {
  const TodoTask({
    required this.id,
    required this.title,
    this.description = '',
    this.dueAt,
    this.hasDueTime = false,
    this.durationMinutes = 25,
    this.priority = TaskPriority.medium,
    this.category = 'Personal',
    this.project = '',
    this.completed = false,
    this.completedAt,
    this.recurrence = 'none',
    this.subtasks = const [],
    this.subtasksDone = const [],
    this.createdAt,
  });

  final int? id;
  final String title;
  final String description;
  final DateTime? dueAt;
  final bool hasDueTime;
  final int durationMinutes;
  final TaskPriority priority;
  final String category;
  final String project;
  final bool completed;
  final DateTime? completedAt;
  final String recurrence;
  final List<String> subtasks;
  final List<bool> subtasksDone;
  final DateTime? createdAt;

  TodoTask copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueAt,
    bool? hasDueTime,
    bool clearDueAt = false,
    int? durationMinutes,
    TaskPriority? priority,
    String? category,
    String? project,
    bool? completed,
    DateTime? completedAt,
    String? recurrence,
    List<String>? subtasks,
    List<bool>? subtasksDone,
  }) => TodoTask(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
    hasDueTime: clearDueAt ? false : (hasDueTime ?? this.hasDueTime),
    durationMinutes: durationMinutes ?? this.durationMinutes,
    priority: priority ?? this.priority,
    category: category ?? this.category,
    project: project ?? this.project,
    completed: completed ?? this.completed,
    completedAt: completed == false ? null : (completedAt ?? this.completedAt),
    recurrence: recurrence ?? this.recurrence,
    subtasks: subtasks ?? this.subtasks,
    subtasksDone: subtasksDone ?? this.subtasksDone,
    createdAt: createdAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'due_at': dueAt?.toIso8601String(),
    'has_due_time': hasDueTime ? 1 : 0,
    'duration': durationMinutes,
    'priority': priority.name,
    'category': category,
    'project': project,
    'completed': completed ? 1 : 0,
    'completed_at': completedAt?.toIso8601String(),
    'recurrence': recurrence,
    'subtasks': subtasks.join('\n'),
    'subtasks_done': subtasksDone.map((done) => done ? '1' : '0').join('\n'),
    'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
  };

  factory TodoTask.fromMap(Map<String, Object?> map) {
    final subtasks = (map['subtasks'] as String? ?? '')
        .split('\n')
        .where((s) => s.isNotEmpty)
        .toList();
    final done = (map['subtasks_done'] as String? ?? '').split('\n');
    return TodoTask(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      dueAt: map['due_at'] == null
          ? null
          : DateTime.parse(map['due_at'] as String),
      hasDueTime: map['has_due_time'] == 1,
      durationMinutes: map['duration'] as int? ?? 25,
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: map['category'] as String? ?? 'Personal',
      project: map['project'] as String? ?? '',
      completed: map['completed'] == 1,
      completedAt: DateTime.tryParse(map['completed_at'] as String? ?? ''),
      recurrence: map['recurrence'] as String? ?? 'none',
      subtasks: subtasks,
      subtasksDone: List<bool>.generate(
        subtasks.length,
        (index) => index < done.length && done[index] == '1',
      ),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? ''),
    );
  }
}

bool isOverdue(TodoTask task, [DateTime? now]) =>
    !task.completed &&
    task.dueAt != null &&
    (task.hasDueTime
        ? task.dueAt!.isBefore(now ?? DateTime.now())
        : DateTime(
            task.dueAt!.year,
            task.dueAt!.month,
            task.dueAt!.day,
          ).isBefore(
            DateTime(
              (now ?? DateTime.now()).year,
              (now ?? DateTime.now()).month,
              (now ?? DateTime.now()).day,
            ),
          ));
TodoTask? nextOccurrence(TodoTask task) {
  if (task.completed || task.dueAt == null || task.recurrence == 'none') {
    return null;
  }
  final due = task.dueAt!;
  DateTime shiftDays(int days) =>
      DateTime(due.year, due.month, due.day + days, due.hour, due.minute);
  final nextDue = switch (task.recurrence) {
    'daily' => shiftDays(1),
    'weekdays' => _nextWeekday(shiftDays(1)),
    'weekly' => shiftDays(7),
    'monthly' => _nextMonth(due),
    _ => null,
  };
  if (nextDue == null) return null;
  return TodoTask(
    id: null,
    title: task.title,
    description: task.description,
    dueAt: nextDue,
    hasDueTime: task.hasDueTime,
    durationMinutes: task.durationMinutes,
    priority: task.priority,
    category: task.category,
    project: task.project,
    recurrence: task.recurrence,
    subtasks: task.subtasks,
    subtasksDone: List<bool>.filled(task.subtasks.length, false),
  );
}

DateTime _nextWeekday(DateTime date) {
  var next = date;
  while (next.weekday == DateTime.saturday || next.weekday == DateTime.sunday) {
    next = DateTime(
      next.year,
      next.month,
      next.day + 1,
      next.hour,
      next.minute,
    );
  }
  return next;
}

DateTime _nextMonth(DateTime date) {
  final firstOfNextMonth = DateTime(date.year, date.month + 1);
  final lastDay = DateTime(
    firstOfNextMonth.year,
    firstOfNextMonth.month + 1,
    0,
  ).day;
  final day = date.day > lastDay ? lastDay : date.day;
  return DateTime(
    firstOfNextMonth.year,
    firstOfNextMonth.month,
    day,
    date.hour,
    date.minute,
  );
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
