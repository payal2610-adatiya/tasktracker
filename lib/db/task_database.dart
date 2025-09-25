import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabase {
  static final MyDatabase _instance = MyDatabase._internal();
  factory MyDatabase() => _instance;
  MyDatabase._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'task.db');

    return openDatabase(path, version: 2, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          email TEXT UNIQUE,
          password TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          due_date TEXT,
          status TEXT DEFAULT 'pending',
          priority TEXT DEFAULT 'low',
          user_id INTEGER
        )
      ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Add email column if upgrading from version 1
        await db.execute('ALTER TABLE users ADD COLUMN email TEXT UNIQUE');
      }
    });
  }

  // Users
  Future<int> insertUser(Map<String, dynamic> user) async {
    final database = await db;
    try {
      return await database.insert('users', user);
    } catch (e) {
      return -1; // duplicate or error
    }
  }

  Future<Map<String, dynamic>?> getUserByCredentials(String username, String password) async {
    final database = await db;
    final res = await database.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // Tasks
  Future<int> insertTask(Map<String, dynamic> t) async {
    final database = await db;
    return await database.insert('tasks', t);
  }

  Future<int> updateTask(Map<String, dynamic> t) async {
    final database = await db;
    return await database.update('tasks', t, where: 'id = ?', whereArgs: [t['id']]);
  }

  Future<int> deleteTask(int id) async {
    final database = await db;
    return await database.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getTasks({int? userId, String? status, String? query}) async {
    final database = await db;
    final where = <String>[];
    final args = <dynamic>[];
    if (userId != null) {
      where.add('user_id = ?');
      args.add(userId);
    }
    if (status != null && status != 'all') {
      where.add('status = ?');
      args.add(status);
    }
    if (query != null && query.trim().isNotEmpty) {
      where.add('(title LIKE ? OR description LIKE ?)');
      args.add('%$query%');
      args.add('%$query%');
    }
    final whereString = where.isEmpty ? null : where.join(' AND ');
    return await database.query('tasks', where: whereString, whereArgs: args, orderBy: 'due_date ASC');
  }
}
