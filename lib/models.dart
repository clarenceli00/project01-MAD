class Habit {
  static int _nextId = 1;
  final int id;
  final String title;
  final String category;
  final int weeklyTarget;
  final DateTime startDate;
  final String motivation;

  Habit({
    int? id,
    required this.title,
    required this.category,
    required this.weeklyTarget,
    required this.startDate,
    required this.motivation,
  }) : id = id ?? _nextId++;
}

class CheckIn {
  final int habitId;
  final DateTime date;
  final String note;

  const CheckIn({
    required this.habitId,
    required this.date,
    required this.note,
  });
}

DateTime weekStart(DateTime date) {
  return DateTime(date.year, date.month, date.day - date.weekday + 1);
}

int weeklyCount(List<CheckIn> entries, int habitId, DateTime week) {
  final start = weekStart(week);
  final end = DateTime(start.year, start.month, start.day + 7);
  return entries
      .where(
        (entry) =>
            entry.habitId == habitId &&
            !entry.date.isBefore(start) &&
            entry.date.isBefore(end),
      )
      .map(
        (entry) => DateTime(entry.date.year, entry.date.month, entry.date.day),
      )
      .toSet()
      .length;
}
// ADD DATABASE MODELS FOR HABITS AND CHECKIN FORM
