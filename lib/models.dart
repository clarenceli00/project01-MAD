class Habit {
  final String title;
  final String category;
  final int weeklyTarget;
  final DateTime startDate;
  final String motivation;

  const Habit({
    required this.title,
    required this.category,
    required this.weeklyTarget,
    required this.startDate,
    required this.motivation,
  });
}
// ADD DATABASE MODELS FOR HABITS AND CHECKIN FORM