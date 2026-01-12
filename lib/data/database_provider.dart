import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static Database? _db;
  static final DatabaseProvider instance = DatabaseProvider._constructor();

  DatabaseProvider._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final path = join(databaseDirPath, 'leet_repeat.db');
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE problem (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT NOT NULL,
            difficulty INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE problem_list (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE problem_list_problem (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            problem_id INTEGER NOT NULL,
            problem_list_id INTEGER NOT NULL,
            FOREIGN KEY (problem_id) REFERENCES problem(id),
            FOREIGN KEY (problem_list_id) REFERENCES problem_list(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            perceived_difficulty INTEGER NOT NULL,
            last_solved_at TEXT NOT NULL,
            next_review_at TEXT NOT NULL,
            problem_id INTEGER NOT NULL,
            problem_list_id INTEGER NOT NULL,
            FOREIGN KEY (problem_id) REFERENCES problem(id),
            FOREIGN KEY (problem_list_id) REFERENCES problem_list(id)
          )
        ''');
      },
    );

    return database;
  }
}
