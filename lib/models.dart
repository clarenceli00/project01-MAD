class Habit {
  final int? id;
  final String title;
  final String category;
  final int weeklyTarget;
  final DateTime startDate;
  final String motivation;

  // Saved weekly workflow information
  final DateTime? cycleWeekStart;
  final String cycleStatus;

  Habit({
    this.id,
    required this.title,
    required this.category,
    required this.weeklyTarget,
    required this.startDate,
    required this.motivation,
    this.cycleWeekStart,
    this.cycleStatus = 'Ready',
  });

  // Convert a Habit object to a SQLite Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'category': category,
      'weekly_target': weeklyTarget,
      'started_local_date': dateToString(startDate),
      'motivation': motivation,
      'cycle_week_start': cycleWeekStart == null
          ? null
          : dateToString(cycleWeekStart!),
      'cycle_status': cycleStatus,
    };
  }

  // Convert a SQLite Map to a Habit object
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int,
      title: map['title'] as String,
      category: map['category'] as String,
      weeklyTarget: map['weekly_target'] as int,
      startDate: DateTime.parse(map['started_local_date'] as String),
      motivation: map['motivation'] as String,
      cycleWeekStart: map['cycle_week_start'] == null
          ? null
          : DateTime.parse(map['cycle_week_start'] as String),
      cycleStatus: map['cycle_status'] as String,
    );
  }
}

class CheckIn {
  final int? id;
  final int habitId;
  final DateTime date;
  final String note;

  CheckIn({
    this.id,
    required this.habitId,
    required this.date,
    required this.note,
  });

  // Convert a CheckIn object to a SQLite Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habit_id': habitId,
      'local_date': dateToString(date),
      'note': note,
    };
  }

  // Convert a SQLite Map to a CheckIn object
  factory CheckIn.fromMap(Map<String, dynamic> map) {
    return CheckIn(
      id: map['id'] as int,
      habitId: map['habit_id'] as int,
      date: DateTime.parse(map['local_date'] as String),
      note: map['note'] as String,
    );
  }
}

// Convert DateTime to YYYY-MM-DD string
String dateToString(DateTime date) {
  String year = date.year.toString().padLeft(4, '0');
  String month = date.month.toString().padLeft(2, '0');
  String day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}

// Get Monday of the selected week
DateTime weekStart(DateTime date) {
  DateTime day = DateTime(date.year, date.month, date.day);

  return day.subtract(Duration(days: day.weekday - 1));
}

// Count unique check-in dates for a selected week
int weeklyCount(List<CheckIn> entries, int habitId, DateTime week) {
  DateTime monday = weekStart(week);
  DateTime nextMonday = DateTime(monday.year, monday.month, monday.day + 7);

  Set<String> dates = {};

  for (CheckIn entry in entries) {
    if (entry.habitId != habitId) {
      continue;
    }

    DateTime day = DateTime(entry.date.year, entry.date.month, entry.date.day);

    if (!day.isBefore(monday) && day.isBefore(nextMonday)) {
      dates.add(dateToString(day));
    }
  }

  return dates.length;
}
