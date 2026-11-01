class Habit {
  final int? id;
  final String title;
  final String category;
  final int weeklyTarget;
  final DateTime startDate;
  final String motivation;

  // Weekly workflow data
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

  // Convert a Habit into data for SQLite
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

  // Convert SQLite data into a Habit
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

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habit_id': habitId,
      'local_date': dateToString(date),
      'note': note,
    };
  }

  factory CheckIn.fromMap(Map<String, dynamic> map) {
    return CheckIn(
      id: map['id'] as int,
      habitId: map['habit_id'] as int,
      date: DateTime.parse(map['local_date'] as String),
      note: map['note'] as String,
    );
  }
}

// Save dates in YYYY-MM-DD format
String dateToString(DateTime date) {
  String year = date.year.toString().padLeft(4, '0');
  String month = date.month.toString().padLeft(2, '0');
  String day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}

// Find Monday of the selected week
DateTime weekStart(DateTime date) {
  DateTime day = DateTime(date.year, date.month, date.day);

  return DateTime(day.year, day.month, day.day - day.weekday + 1);
}

// Count distinct check-in dates in a week
int weeklyCount(List<CheckIn> entries, int habitId, DateTime week) {
  DateTime start = weekStart(week);

  DateTime end = DateTime(start.year, start.month, start.day + 7);

  Set<String> dates = {};

  for (CheckIn entry in entries) {
    DateTime day = DateTime(entry.date.year, entry.date.month, entry.date.day);

    if (entry.habitId == habitId && !day.isBefore(start) && day.isBefore(end)) {
      dates.add(dateToString(day));
    }
  }

  return dates.length;
}
