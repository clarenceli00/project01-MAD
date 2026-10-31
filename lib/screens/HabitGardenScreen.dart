import 'package:flutter/material.dart';

import '../models.dart';
import 'HabitDetailScreen.dart';
import 'HabitEditorScreen.dart';
import 'screens.dart' show HabitTile;
import '../database_helper.dart';

class HabitGardenScreen extends StatefulWidget {
  final List<Habit> habits;
  final List<CheckIn> checkIns;
  final VoidCallback onChanged;

  const HabitGardenScreen({
    super.key,
    required this.habits,
    required this.checkIns,
    required this.onChanged,
  });

  @override
  State<HabitGardenScreen> createState() => _HabitGardenScreenState();
}

class _HabitGardenScreenState extends State<HabitGardenScreen> {
  Future<void> _addHabit() async {
    final habit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(builder: (context) => const HabitEditorScreen()),
    );

    if (!mounted || habit == null) return;

    try {
      // Save to SQLite
      await databaseHelper.insertHabit(habit);

      // Reload saved habits
      widget.onChanged();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save habit: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Current Week'),
          Expanded(
            child: ListView.builder(
              itemCount: widget.habits.length,
              itemBuilder: (context, index) {
                final habit = widget.habits[index];
                return HabitTile(
                  title: habit.title,
                  category: habit.category,
                  completedDays: weeklyCount(
                    widget.checkIns,
                    habit.id,
                    DateTime.now(),
                  ),
                  weeklyTarget: habit.weeklyTarget,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HabitDetailScreen(
                          habitName: habit.title,
                          category: habit.category,
                          weeklyTarget: habit.weeklyTarget,
                          startDate: habit.startDate,
                          motivation: habit.motivation,
                          habitId: habit.id,
                          checkIns: widget.checkIns,
                          onCheckInsChanged: widget.onChanged,
                          onHabitChanged: (updatedHabit) {
                            if (!mounted) return;
                            widget.habits[index] = updatedHabit;
                            widget.onChanged();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          FilledButton.icon(
            onPressed: _addHabit,
            icon: const Icon(Icons.add),
            label: const Text('Add Habit'),
          ),
        ],
      ),
    );
  }
}
