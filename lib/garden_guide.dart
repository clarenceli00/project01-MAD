import 'models.dart';

class GardenGuideResult {
  final int? suggestedTarget;
  final String message;
  final List<int> weeklyCounts;
  final List<DateTime> weeks;

  GardenGuideResult({
    required this.suggestedTarget,
    required this.message,
    required this.weeklyCounts,
    required this.weeks,
  });
}

class GardenGuide {
  // Calculate suggestion using existing check-ins
  static GardenGuideResult suggest(
    Habit habit,
    List<CheckIn> checkIns, {
    DateTime? today,
  }) {
    DateTime currentDate = today ?? DateTime.now();

    // Validate saved habit information
    if (habit.id == null ||
        habit.weeklyTarget < 1 ||
        habit.weeklyTarget > 7 ||
        dateToString(habit.startDate).compareTo(dateToString(currentDate)) >
            0) {
      return GardenGuideResult(
        suggestedTarget: null,
        message: 'Invalid habit information.',
        weeklyCounts: [],
        weeks: [],
      );
    }

    // Validate check-in history
    for (CheckIn entry in checkIns) {
      if (entry.habitId != habit.id ||
          dateToString(entry.date).compareTo(dateToString(habit.startDate)) <
              0 ||
          dateToString(entry.date).compareTo(dateToString(currentDate)) > 0) {
        return GardenGuideResult(
          suggestedTarget: null,
          message: 'Invalid check-in history.',
          weeklyCounts: [],
          weeks: [],
        );
      }
    }

    DateTime currentMonday = weekStart(currentDate);

    List<int> counts = [];
    List<DateTime> weeks = [];

    // Examine the three previous completed weeks
    for (int i = 1; i <= 3; i++) {
      DateTime monday = DateTime(
        currentMonday.year,
        currentMonday.month,
        currentMonday.day - (7 * i),
      );

      // Exclude a partial starting week
      if (dateToString(monday).compareTo(dateToString(habit.startDate)) < 0) {
        continue;
      }

      int count = weeklyCount(checkIns, habit.id!, monday);

      weeks.add(monday);
      counts.add(count);
    }

    // Not enough eligible completed weeks
    if (counts.length < 3) {
      return GardenGuideResult(
        suggestedTarget: null,
        message: 'Not enough history.',
        weeklyCounts: counts,
        weeks: weeks,
      );
    }

    int suggestion = suggestFromCounts(counts);

    return GardenGuideResult(
      suggestedTarget: suggestion,
      message: 'Based on your last 3 completed weeks.',
      weeklyCounts: counts,
      weeks: weeks,
    );
  }

  // Suggest target using three weekly counts
  static int suggestFromCounts(List<int> counts) {
    if (counts.length != 3) {
      throw ArgumentError('Exactly 3 weeks are required.');
    }

    int total = 0;

    for (int count in counts) {
      if (count < 0 || count > 7) {
        throw ArgumentError('Invalid weekly count.');
      }

      total = total + count;
    }

    int result = (total / 3).round();

    if (result < 1) {
      result = 1;
    }

    if (result > 7) {
      result = 7;
    }

    return result;
  }

  // Calculate absolute error
  static int absoluteError(int predicted, int actual) {
    return (predicted - actual).abs();
  }

  // Calculate mean absolute error
  static double meanAbsoluteError(List<int> errors) {
    if (errors.isEmpty) {
      throw ArgumentError('At least one result is required.');
    }

    int total = 0;

    for (int error in errors) {
      total = total + error;
    }

    return total / errors.length;
  }
}

// Numeric progress can exceed 100 percent
double progressPercent(int completedDays, int target) {
  if (target < 1 || target > 7) {
    throw ArgumentError('Invalid target.');
  }

  return completedDays / target * 100;
}

// Visual plant progress cannot exceed 100 percent
double plantProgress(int completedDays, int target) {
  if (target < 1 || target > 7) {
    throw ArgumentError('Invalid target.');
  }

  double result = completedDays / target;

  if (result > 1) {
    return 1.0;
  }

  return result;
}
