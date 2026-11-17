import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'task.dart';

class TaskDatabase {
  TaskDatabase._({DatabaseFactory? factory, String? path})
    : _factory = factory,
      _path = path;
  TaskDatabase.testing({required DatabaseFactory factory, required String path})
    : this._(factory: factory, path: path);
  static final TaskDatabase instance = TaskDatabase._();
  final DatabaseFactory? _factory;
  final String? _path;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = _path ?? p.join(await getDatabasesPath(), 'smart_todo.db');
    _db = await (_factory ?? databaseFactory).openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) async {
          await db.execute(
            '''CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT NOT NULL DEFAULT '', due_at TEXT, has_due_time INTEGER NOT NULL DEFAULT 0, duration INTEGER NOT NULL DEFAULT 25, priority TEXT NOT NULL DEFAULT 'medium', category TEXT NOT NULL DEFAULT 'Personal', project TEXT NOT NULL DEFAULT '', completed INTEGER NOT NULL DEFAULT 0, completed_at TEXT, recurrence TEXT NOT NULL DEFAULT 'none', subtasks TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL)''',
          );
          await db.execute(
            '''CREATE TABLE focus_sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, task_id INTEGER, started_at TEXT NOT NULL, duration INTEGER NOT NULL)''',
          );
          await _createLists(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              'ALTER TABLE tasks ADD COLUMN has_due_time INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 3) {
            await db.execute('ALTER TABLE tasks ADD COLUMN completed_at TEXT');
          }
          if (oldVersion < 4) await _createLists(db);
        },
      ),
    );
    return _db!;
  }

  Future<List<TodoTask>> allTasks() async {
    final rows = await (await database).query(
      'tasks',
      orderBy: 'completed ASC, due_at IS NULL, due_at ASC, id DESC',
    );
    return rows.map(TodoTask.fromMap).toList();
  }

  Future<int> save(TodoTask task) async => (await database).insert(
    'tasks',
    task.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  Future<void> delete(int id) async {
    await (await database).delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveFocus(int? taskId, DateTime started, int duration) async =>
      (await database).insert('focus_sessions', {
        'task_id': taskId,
        'started_at': started.toIso8601String(),
        'duration': duration,
      });
  Future<int> focusMinutes() async {
    final rows = await (await database).rawQuery(
      'SELECT COALESCE(SUM(duration), 0) AS total FROM focus_sessions',
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  static Future<void> _createLists(DatabaseExecutor db) async {
    await db.execute(
      'CREATE TABLE task_lists (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, kind TEXT NOT NULL, created_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE list_items (id INTEGER PRIMARY KEY AUTOINCREMENT, list_id INTEGER NOT NULL, title TEXT NOT NULL, checked INTEGER NOT NULL DEFAULT 0, FOREIGN KEY(list_id) REFERENCES task_lists(id))',
    );
  }

  Future<List<Map<String, Object?>>> allLists() async =>
      (await database).query('task_lists', orderBy: 'created_at DESC');

  Future<List<Map<String, Object?>>> listItems(int listId) async =>
      (await database).query(
        'list_items',
        where: 'list_id = ?',
        whereArgs: [listId],
        orderBy: 'checked ASC, id ASC',
      );

  Future<int> createList(String name, String kind) async =>
      (await database).insert('task_lists', {
        'name': name,
        'kind': kind,
        'created_at': DateTime.now().toIso8601String(),
      });

  Future<int> createListItem(int listId, String title) async => (await database)
      .insert('list_items', {'list_id': listId, 'title': title});

  Future<void> checkListItem(int id, bool checked) async {
    await (await database).update(
      'list_items',
      {'checked': checked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteListItem(int id) async {
    await (await database).delete(
      'list_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteList(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('list_items', where: 'list_id = ?', whereArgs: [id]);
      await txn.delete('task_lists', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<Map<String, Object?>> exportBackup() async {
    final db = await database;
    return {
      'format': 'anubisland-smart-todo-backup',
      'version': 1,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'data': {
        'tasks': await db.query('tasks', orderBy: 'id ASC'),
        'focus_sessions': await db.query('focus_sessions', orderBy: 'id ASC'),
        'task_lists': await db.query('task_lists', orderBy: 'id ASC'),
        'list_items': await db.query('list_items', orderBy: 'id ASC'),
      },
    };
  }

  Future<void> restoreBackup(Map<String, dynamic> backup) async {
    if (backup['format'] != 'anubisland-smart-todo-backup' ||
        backup['version'] != 1 ||
        backup['data'] is! Map) {
      throw const FormatException('Unsupported Smart-ToDo backup.');
    }
    final data = Map<String, dynamic>.from(backup['data'] as Map);
    List<Map<String, Object?>> rows(String key) {
      final value = data[key];
      if (value is! List || value.any((row) => row is! Map)) {
        throw FormatException('Invalid $key in backup.');
      }
      return value.map((row) => Map<String, Object?>.from(row as Map)).toList();
    }

    final tasks = rows('tasks');
    final sessions = rows('focus_sessions');
    final lists = rows('task_lists');
    final items = rows('list_items');
    bool hasId(Map<String, Object?> row) => row['id'] is int;
    if (tasks.any((row) => !hasId(row) || row['title'] is! String) ||
        sessions.any((row) => !hasId(row) || row['started_at'] is! String) ||
        lists.any(
          (row) =>
              !hasId(row) || row['name'] is! String || row['kind'] is! String,
        ) ||
        items.any(
          (row) =>
              !hasId(row) ||
              row['list_id'] is! int ||
              row['title'] is! String ||
              row['checked'] is! int,
        )) {
      throw const FormatException('Backup data is incomplete or invalid.');
    }
    final listIds = lists.map((row) => row['id'] as int).toSet();
    if (items.any((row) => !listIds.contains(row['list_id']))) {
      throw const FormatException('Backup contains an item without a list.');
    }

    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('list_items');
      await txn.delete('task_lists');
      await txn.delete('focus_sessions');
      await txn.delete('tasks');
      for (final row in tasks) {
        await txn.insert('tasks', row);
      }
      for (final row in sessions) {
        await txn.insert('focus_sessions', row);
      }
      for (final row in lists) {
        await txn.insert('task_lists', row);
      }
      for (final row in items) {
        await txn.insert('list_items', row);
      }
    });
  }
}
