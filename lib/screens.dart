//This is where each of the 5 screens will live (Home, editor, details, settings, history)
import 'package:flutter/material.dart';

class HabitGardenTabs extends StatefulWidget {
  const HabitGardenTabs({super.key});
  @override
  State<HabitGardenTabs> createState() => _HabitGardenTabsState();
}
class _HabitGardenTabsState extends State<HabitGardenTabs>{
  var selected_tab = 0;
  final List<Widget> _screens = const [HabitGardenScreen(), HistoryScreen(), SettingsScreen(),];
  final List<String> _titles = const ['Habit Garden', 'History', 'Settings',];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Mastery League'),
      ),
      body: const Center(
        child: Text('No habits yet'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected_tab,
        onDestinationSelected: (int index) {
          setState(() {
            selected_tab = index;
          });
        },
        destinations: [NavigationDestination(icon: Icon(Icons.local_florist), label: "Garden"),
        NavigationDestination(icon: Icon(Icons.history), label: "History"),
        NavigationDestination(icon: Icon(Icons.settings), label: "Settings")],
      ),
    );
  }
}
class HabitGardenScreen extends StatefulWidget {
  const HabitGardenScreen({super.key});

  @override
  State<HabitGardenScreen> createState() => _HabitGardenScreenState();
}

class _HabitGardenScreenState extends State<HabitGardenScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No habits yet'),
    );
  }
}
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}
class _HistoryScreenState extends State<HistoryScreen>{
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No history yet'),);
  }
}
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen>{
  @override
  Widget build(BuildContext context){
    return const Center(child: Text('No Settings yet'),);
  }
}
class HabitEditorScreen extends StatefulWidget {
  const HabitEditorScreen({super.key});
  @override
  State<HabitEditorScreen> createState() => _HabitEditorScreenState();
}
class _HabitEditorScreenState extends State<HabitEditorScreen>{
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No editing yet'),);
  }
}
class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({super.key});
  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}
class _HabitDetailScreenState extends State<HabitDetailScreen>{
  @override
  Widget build(BuildContext context){
    return const Center(child: Text('no details yet'),);
  }
}