//This is where each of the 5 screens will live (Home, editor, details, settings, history)
import 'package:flutter/material.dart';
import 'package:project01/screens/HabitGardenScreen.dart';
import 'package:project01/screens/HistoryScreen.dart';
import 'package:project01/screens/SettingsScreen.dart';
import 'package:project01/screens/HabitDetailScreen.dart';
import 'package:project01/screens/HabitEditorScreen.dart';

class HabitGardenTabs extends StatefulWidget {
  const HabitGardenTabs({super.key});
  @override
  State<HabitGardenTabs> createState() => _HabitGardenTabsState();
}
class _HabitGardenTabsState extends State<HabitGardenTabs>{
  var _selectedIndex = 0;
  final List<Widget> _screens = const [HabitGardenScreen(), HistoryScreen(), SettingsScreen(),];
  final List<String> _titles = const ['Habit Garden', 'History', 'Settings',];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Mastery League'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [NavigationDestination(icon: Icon(Icons.local_florist), label: "Garden"),
        NavigationDestination(icon: Icon(Icons.history), label: "History"),
        NavigationDestination(icon: Icon(Icons.settings), label: "Settings")],
      ),
    );
  }
}
class HabitTile extends StatelessWidget {
  const HabitTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Text('test'),
    );
  }
}

class CheckInForm extends StatefulWidget {
  const CheckInForm({super.key});

  @override
  State<CheckInForm> createState() => _CheckInFormState();
}
class _CheckInFormState extends State<CheckInForm>{
  @override
  Widget build(BuildContext context){
    return const Center(child: Text('test form'),);
  }
}