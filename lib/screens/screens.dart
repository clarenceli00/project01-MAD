//This is where each of the 5 screens will live (Home, editor, details, settings, history)
import 'package:flutter/material.dart';
import 'package:project01/screens/HabitGardenScreen.dart';
import 'package:project01/screens/HistoryScreen.dart';
import 'package:project01/screens/SettingsScreen.dart';

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
  final List<CheckIn> _checkIns = [];

  void _refresh() => setState(() {});
  @override
  Widget build(BuildContext context) {
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
  if (habit.startDate.isAfter(DateUtils.dateOnly(DateTime.now()))) return;
  final result = await showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => CheckInForm(
      habitStartDate: habit.startDate,
      entry: entry,
      usedDates: checkIns
          .where((item) => item.habitId == habit.id && item != entry)
          .map((item) => item.date)
          .toList(),
    ),
  );
  if (result == null || !context.mounted) return;
  final updated = CheckIn(
    habitId: habit.id,
    date: DateTime.parse(result['localDate']!),
    note: result['note']!,
  );
  if (entry == null) {
    checkIns.add(updated);
  } else {
    checkIns[checkIns.indexOf(entry)] = updated;
  }
  onChanged();
}
