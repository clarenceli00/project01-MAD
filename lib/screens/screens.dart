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
  final String title;
  final String category;
  final int completedDays;
  final int weeklyTarget;
  final VoidCallback onTap;

  const HabitTile({
    super.key,
    required this.title,
    required this.category,
    required this.completedDays,
    required this.weeklyTarget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (completedDays / weeklyTarget * 100).round();

    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_florist),
        title: Text(title),
        subtitle: Text(
          '$category\n'
          '$completedDays / $weeklyTarget days · $percentage%',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class CheckInForm extends StatefulWidget {
  final DateTime habitStartDate;

  const CheckInForm({
    super.key,
    required this.habitStartDate,
  });

  @override
  State<CheckInForm> createState() => _CheckInFormState();
}

class _CheckInFormState extends State<CheckInForm> {
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  final TextEditingController _noteController = TextEditingController();

  String get _dateText {
    final year = _selectedDate.year;
    final month = _selectedDate.month.toString().padLeft(2, '0');
    final day = _selectedDate.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateUtils.dateOnly(widget.habitStartDate),
      lastDate: DateUtils.dateOnly(DateTime.now()),
    );

    if (!mounted || pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Check-in'),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(_dateText),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, <String, String>{
                      'localDate': _dateText,
                      'note': _noteController.text.trim(),
                    });
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}