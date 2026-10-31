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

  // Open database
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, _databaseName);

    _db = await openDatabase(
      path,
      version: _databaseVersion,

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        await createTables(db);
      },
    );
  }

  // Create the tables when database is first opened
  Future<void> createTables(Database db) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL CHECK(length(trim(title)) > 0),
        category TEXT NOT NULL CHECK(length(trim(category)) > 0),
        weekly_target INTEGER NOT NULL
          CHECK(weekly_target BETWEEN 1 AND 7),
        started_local_date TEXT NOT NULL,
        motivation TEXT NOT NULL DEFAULT '',
        cycle_week_start TEXT,
        cycle_status TEXT NOT NULL DEFAULT 'Ready'
          CHECK(cycle_status IN ('Ready', 'Active', 'Finished'))
      )
    ''');

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

    await db.execute('''
      CREATE INDEX idx_checkins_habit
      ON check_ins(habit_id, local_date)
    ''');
  }

  // Check if habit information is valid
  void validateHabit(Habit habit) {
    if (habit.title.trim().isEmpty) {
      throw ArgumentError('Habit name cannot be blank.');
    }

    if (habit.category.trim().isEmpty) {
      throw ArgumentError('Category cannot be blank.');
    }

    if (habit.weeklyTarget < 1 || habit.weeklyTarget > 7) {
      throw ArgumentError('Target must be between 1 and 7.');
    }

    if (dateToString(habit.startDate).compareTo(dateToString(DateTime.now())) >
        0) {
      throw ArgumentError('Future start dates are not allowed.');
    }
  }

  // CREATE habit
  Future<int> insertHabit(Habit habit) async {
    validateHabit(habit);

    Map<String, dynamic> row = habit.toMap();
    row.remove('id');
    row['cycle_week_start'] = null;
    row['cycle_status'] = 'Ready';

    return await _db.insert(habitTable, row);
  }

  // READ all habits
  Future<List<Habit>> getHabits() async {
    final rows = await _db.query(
      habitTable,
      orderBy: 'title COLLATE NOCASE ASC',
    );

    List<Habit> habits = [];

    for (final row in rows) {
      habits.add(Habit.fromMap(row));
    }

    return habits;
  }

  // READ one habit
  Future<Habit?> getHabit(int id) async {
    final rows = await _db.query(
      habitTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Habit.fromMap(rows.first);
  }

  // UPDATE habit
  Future<int> updateHabit(Habit habit) async {
    if (habit.id == null) {
      throw ArgumentError('Habit ID is required.');
    }

    validateHabit(habit);

    return await _db.transaction((txn) async {
      // Find earliest check-in date
      final rows = await txn.query(
        checkInTable,
        columns: ['local_date'],
        where: 'habit_id = ?',
        whereArgs: [habit.id],
        orderBy: 'local_date ASC',
        limit: 1,
      );

      if (rows.isNotEmpty) {
        String earliestDate = rows.first['local_date'] as String;

        if (dateToString(habit.startDate).compareTo(earliestDate) > 0) {
          throw ArgumentError('Correct or delete earlier check-ins first.');
        }
      }

      Map<String, dynamic> row = habit.toMap();
      row.remove('id');
      row.remove('cycle_week_start');
      row.remove('cycle_status');

      return await txn.update(
        habitTable,
        row,
        where: 'id = ?',
        whereArgs: [habit.id],
      );
    });
  }

  // DELETE habit
  Future<int> deleteHabit(int id) async {
    return await _db.delete(habitTable, where: 'id = ?', whereArgs: [id]);
  }

  // Count check-ins before deleting a habit
  Future<int> countCheckIns(int habitId) async {
    final rows = await _db.rawQuery(
      'SELECT COUNT(*) FROM check_ins WHERE habit_id = ?',
      [habitId],
    );

    return Sqflite.firstIntValue(rows) ?? 0;
  }
}
