import 'package:flutter/material.dart';
import 'package:project01/screens/screens.dart';

class HabitGardenScreen extends StatefulWidget {
  const HabitGardenScreen({super.key});

  @override
  State<HabitGardenScreen> createState() => _HabitGardenScreenState();
}

class _HabitGardenScreenState extends State<HabitGardenScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsetsGeometry.all(16),
      child:Column(
        children: [
        Text("Current Week"),
        Expanded(
          child: ListView(
            children: [
              HabitTile(
                title: 'gooning',
                category: 'gooning',
                completedDays: 2,
                weeklyTarget: 4,
                onTap: (){}
                ,)
            ],
          )
        ),
        FilledButton.icon(label: Text('Add Habit'), onPressed: (){},),
        ]
      ),
    );
  }
}