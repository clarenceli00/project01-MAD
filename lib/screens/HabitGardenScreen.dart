import 'package:flutter/material.dart';
import '../models.dart';
import 'HabitDetailScreen.dart';
import 'HabitEditorScreen.dart';
import 'screens.dart' show HabitTile;

class HabitGardenScreen extends StatefulWidget {
  const HabitGardenScreen({super.key});

  @override
  State<HabitGardenScreen> createState() => _HabitGardenScreenState();
}

class _HabitGardenScreenState extends State<HabitGardenScreen> {
  // These habits live in memory until SQLite is connected.
  final List<Habit> _habits = [
    Habit(
      title: 'Reading',
      category: 'Learning',
      weeklyTarget: 4,
      startDate: DateUtils.dateOnly(DateTime.now()),
      motivation: 'Read more regularly',
    ),
    Habit(
      title: 'Sketching',
      category: 'Creative',
      weeklyTarget: 3,
      startDate: DateUtils.dateOnly(DateTime.now()),
      motivation: '',
    ),
  ];

  Future<void> _addHabit() async {
    final habit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(builder: (context) => const HabitEditorScreen()),
    );
    if (!mounted || habit == null) return;
    setState(() => _habits.add(habit));
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
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return HabitTile(
                  title: habit.title,
                  category: habit.category,
                  completedDays: 0,
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
                          onHabitChanged: (updatedHabit) {
                            if (!mounted) return;
                            setState(() => _habits[index] = updatedHabit);
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