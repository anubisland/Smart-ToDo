import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo/data/task.dart';
import 'package:smart_todo/data/task_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SQLite task data persists across database reopen', () async {
    sqfliteFfiInit();
    final directory = await Directory.systemTemp.createTemp('smart-todo-');
    final path = '${directory.path}${Platform.pathSeparator}tasks.sqlite';
    final database = TaskDatabase.testing(
      factory: databaseFactoryFfi,
      path: path,
    );
    final task = TodoTask(
      id: null,
      title: 'Persist locally',
      dueAt: DateTime(2026, 11, 20, 16),
      hasDueTime: true,
      priority: TaskPriority.high,
    );
    await database.save(task);
    final listId = await database.createList('Travel', 'travel');
    final itemId = await database.createListItem(listId, 'Passport');
    await database.checkListItem(itemId, true);
    await (await database.database).close();

    final reopened = TaskDatabase.testing(
      factory: databaseFactoryFfi,
      path: path,
    );
    final stored = await reopened.allTasks();
    expect(stored, hasLength(1));
    expect(stored.single.title, task.title);
    expect(stored.single.priority, TaskPriority.high);
    expect(stored.single.dueAt, task.dueAt);
    expect(stored.single.hasDueTime, isTrue);
    final savedLists = await reopened.allLists();
    expect(savedLists.single['name'], 'Travel');
    final savedItems = await reopened.listItems(listId);
    expect(savedItems.single['title'], 'Passport');
    expect(savedItems.single['checked'], 1);

    await (await reopened.database).close();
    await directory.delete(recursive: true);
  });
}
