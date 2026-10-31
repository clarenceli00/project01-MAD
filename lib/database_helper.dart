//SQL database and CRUD functionality

//data base getter, then open or create database
//should be able to insert, retrieve, update and delete habits and checkins individually
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

class DatabaseHelper {
  static const _databaseName = 'HabitMasteryLeague.db';
  static const _databaseVersion = 1;

  static const habitTable = 'habits';
  static const checkInTable = 'check_ins';

  late Database _db;

  // Open or create database
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, _databaseName);

    _db = await openDatabase(
      path,
      version: _databaseVersion,

      onConfigure: (db) async {
        // Enable foreign key relationships
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        await createTables(db);
      },
    );
  }

  // Create the database tables
  Future<void> createTables(Database db) async {
    // Habits table
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
          CHECK(length(trim(title)) > 0),
        category TEXT NOT NULL
          CHECK(length(trim(category)) > 0),
        weekly_target INTEGER NOT NULL
          CHECK(weekly_target BETWEEN 1 AND 7),
        started_local_date TEXT NOT NULL,
        motivation TEXT NOT NULL DEFAULT '',
        cycle_week_start TEXT,
        cycle_status TEXT NOT NULL DEFAULT 'Ready'
          CHECK(cycle_status IN ('Ready', 'Active', 'Finished'))
      )
    ''');

    // Check-ins table
    await db.execute('''
      CREATE TABLE check_ins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        local_date TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',

        FOREIGN KEY (habit_id)
          REFERENCES habits(id)
          ON DELETE CASCADE,

        UNIQUE(habit_id, local_date)
      )
    ''');

    // Index helps find check-ins by habit and date
    await db.execute('''
      CREATE INDEX idx_checkins_habit_date
      ON check_ins(habit_id, local_date)
    ''');
  }
}
