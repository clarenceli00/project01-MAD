import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'screens/screens.dart';

Future<void> main() async {
  // Initialize Flutter plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Open the SQLite database
  await databaseHelper.init();

  // Start the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Mastery League',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      home: const HabitGardenTabs(),
    );
  }
}
