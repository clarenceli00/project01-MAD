import 'package:flutter/material.dart';
import 'package:project01/screens/HabitDetailScreen.dart';
import 'package:project01/screens/screens.dart';

class HabitGardenScreen extends StatefulWidget {
  const HabitGardenScreen({super.key});

  @override
  State<HabitGardenScreen> createState() => _HabitGardenScreenState();
}

class _HabitGardenScreenState extends State<HabitGardenScreen> {
  final List<String> _habitNames = ['Reading', 'Sketching',];


  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsetsGeometry.all(16),
      child:Column(
        children: [
        Text("Current Week"),
        Expanded(
          child: ListView.builder(
            itemCount: _habitNames.length,
            itemBuilder: (context, index) {
              final name = _habitNames[index];

              return HabitTile(
                title: name,
                category: 'Learning',
                completedDays: 0,
                weeklyTarget: 4,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitDetailScreen(
                        habitName: name,
                        category: 'Learning',
                        weeklyTarget: 4,
                        startDate: DateTime(2026, 10, 29),
                        motivation: 'Read more regularly',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        FilledButton.icon(label: Text('Add Habit'), onPressed: (){},),
        ]
      ),
    );
  }
}