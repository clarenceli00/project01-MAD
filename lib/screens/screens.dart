//This is where each of the 5 screens will live (Home, editor, details, settings, history)
import 'package:flutter/material.dart';
import 'package:project01/screens/habit_garden_screen.dart';
import 'package:project01/screens/history_screen.dart';
import 'package:project01/screens/settings_screen.dart';

import '../models.dart';
import '../database_helper.dart';

class HabitGardenTabs extends StatefulWidget {
  const HabitGardenTabs({super.key});
  @override
  State<HabitGardenTabs> createState() => _HabitGardenTabsState();
}

class _HabitGardenTabsState extends State<HabitGardenTabs> {
  var _selectedIndex = 0;
  // Shared in-memory records for Garden, Details, and History.
  final List<Habit> _habits = [];
  final List<CheckIn> _checkIns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final habits = await databaseHelper.getHabits();
      final checkIns = await databaseHelper.getAllCheckIns();

      if (!mounted) return;

      setState(() {
        // Keep the original List objects so screens that
        // received them will see the latest records.
        _habits.clear();
        _habits.addAll(habits);

        _checkIns.clear();
        _checkIns.addAll(checkIns);

        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not load data: $error')));
    }
  }

  void _refresh() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Mastery League')),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HabitGardenScreen(
            habits: _habits,
            checkIns: _checkIns,
            onChanged: _refresh,
          ),
          HistoryScreen(
            habits: _habits,
            checkIns: _checkIns,
            onChanged: _refresh,
          ),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.local_florist),
            label: "Garden",
          ),
          NavigationDestination(icon: Icon(Icons.history), label: "History"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
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
          '$completedDays / $weeklyTarget Days Completed | Progress: $percentage%',
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
  final CheckIn? entry;
  final List<DateTime> usedDates;

  const CheckInForm({
    super.key,
    required this.habitStartDate,
    this.entry,
    this.usedDates = const [],
  });

  @override
  State<CheckInForm> createState() => _CheckInFormState();
}

class _CheckInFormState extends State<CheckInForm> {
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  final TextEditingController _noteController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _selectedDate = widget.entry!.date;
      _noteController.text = widget.entry!.note;
    }
  }

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
            Text(widget.entry == null ? 'Add Check-in' : 'Edit Check-in'),

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

            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
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
                    final today = DateUtils.dateOnly(DateTime.now());
                    if (_selectedDate.isAfter(today) ||
                        _selectedDate.isBefore(
                          DateUtils.dateOnly(widget.habitStartDate),
                        )) {
                      setState(
                        () => _error =
                            'Choose a date between the habit start and today.',
                      );
                      return;
                    }
                    if (widget.usedDates.any(
                      (date) => DateUtils.isSameDay(date, _selectedDate),
                    )) {
                      setState(
                        () =>
                            _error = 'A check-in already exists for this date.',
                      );
                      return;
                    }
                    Navigator.pop(context, <String, String>{
                      'localDate': _dateText,
                      'note': _noteController.text.trim(),
                    });
                  },
                  child: const Text('Save Check-in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Both Details and History use the same form and save to the shared list.
Future<void> openCheckInForm(
  BuildContext context,
  Habit habit,
  List<CheckIn> checkIns,
  VoidCallback onChanged, {
  CheckIn? entry,
}) async {
  if (habit.id == null) return;

  // Get dates already used by this habit
  List<DateTime> usedDates = [];

  for (CheckIn item in checkIns) {
    if (item.habitId == habit.id && item.id != entry?.id) {
      usedDates.add(item.date);
    }
  }

  final result = await showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => CheckInForm(
      habitStartDate: habit.startDate,
      entry: entry,
      usedDates: usedDates,
    ),
  );

  if (result == null || !context.mounted) return;

  // Create the CheckIn object
  CheckIn updated = CheckIn(
    id: entry?.id,
    habitId: habit.id!,
    date: DateTime.parse(result['localDate']!),
    note: result['note']!,
  );

  try {
    if (entry == null) {
      // Create new check-in
      await databaseHelper.insertCheckIn(updated);
    } else {
      // Update existing check-in
      await databaseHelper.updateCheckIn(updated);
    }

    // Reload data
    onChanged();
  } catch (error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not save check-in: $error')));
  }
}
