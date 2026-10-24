//This is where each of the 5 screens will live (Home, editor, details, settings, history)
import 'package:flutter/material.dart';

class HabitGardenScreen extends StatelessWidget {
  const HabitGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Mastery League'),
      ),
      body: const Center(
        child: Text('No habits yet'),
      ),
    );
  }
}