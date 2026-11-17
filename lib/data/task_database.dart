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
        version: 3,
        onCreate: (db, version) async {
          await db.execute(
            '''CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT NOT NULL DEFAULT '', due_at TEXT, has_due_time INTEGER NOT NULL DEFAULT 0, duration INTEGER NOT NULL DEFAULT 25, priority TEXT NOT NULL DEFAULT 'medium', category TEXT NOT NULL DEFAULT 'Personal', project TEXT NOT NULL DEFAULT '', completed INTEGER NOT NULL DEFAULT 0, completed_at TEXT, recurrence TEXT NOT NULL DEFAULT 'none', subtasks TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL)''',
          );
          await db.execute(
            '''CREATE TABLE focus_sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, task_id INTEGER, started_at TEXT NOT NULL, duration INTEGER NOT NULL)''',
          );
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
}
