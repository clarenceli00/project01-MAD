import 'package:flutter/material.dart';

import '../models.dart';
import 'screens.dart' show openCheckInForm;
import '../database_helper.dart';

//import '../garden_guide.dart';

class HistoryScreen extends StatefulWidget {
  final List<Habit> habits;
  final List<CheckIn> checkIns;
  final VoidCallback onChanged;
  final int? initialHabitId;

  const HistoryScreen({
    super.key,
    required this.habits,
    required this.checkIns,
    required this.onChanged,
    this.initialHabitId,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int? _selectedHabitId;
  DateTime _week = weekStart(DateTime.now());

  @override
  void initState() {
    super.initState();
    _selectedHabitId = widget.initialHabitId;
  }

  void _refresh() {
    widget.onChanged();
    if (mounted) setState(() {});
  }

  Future<void> _delete(CheckIn entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete check-in?'),
        content: const Text(
          'This removes the entry and updates weekly progress.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      await databaseHelper.deleteCheckIn(entry.id!);

      _refresh();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete check-in: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.habits.isEmpty) {
      return const Center(child: Text('Create a habit in Garden first.'));
    }
    final selectedId = _selectedHabitId ?? widget.habits.first.id;
    final habit = widget.habits.firstWhere(
      (item) => item.id == selectedId,
      orElse: () => widget.habits.first,
    );
    final end = DateTime(_week.year, _week.month, _week.day + 7);
    final entries =
        widget.checkIns
            .where(
              (entry) =>
                  entry.habitId == habit.id &&
                  !entry.date.isBefore(_week) &&
                  entry.date.isBefore(end),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final count = weeklyCount(widget.checkIns, habit.id!, _week);
    final dates = MaterialLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButton<int>(
            isExpanded: true,
            value: habit.id!,
            items: widget.habits
                .map(
                  (item) => DropdownMenuItem(
                    value: item.id!,
                    child: Text(item.title),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedHabitId = value),
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Previous week',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _week = DateTime(_week.year, _week.month, _week.day - 7);
                }),
              ),
              Expanded(
                child: Text(
                  '${dates.formatMediumDate(_week)} – ${dates.formatMediumDate(DateTime(_week.year, _week.month, _week.day + 6))}',
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                tooltip: 'Next week',
                icon: const Icon(Icons.chevron_right),
                onPressed: !_week.isBefore(weekStart(DateTime.now()))
                    ? null
                    : () => setState(() {
                        _week = DateTime(
                          _week.year,
                          _week.month,
                          _week.day + 7,
                        );
                      }),
              ),
            ],
          ),
          Text(
            '$count / ${habit.weeklyTarget} days · ${(count / habit.weeklyTarget * 100).round()}%',
            textAlign: TextAlign.center,
          ),
          const Text(
            'Progress uses the current weekly target.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('No check-ins for this week.'))
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dates.formatMediumDate(entry.date),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (entry.note.isNotEmpty) Text(entry.note),
                              Wrap(
                                children: [
                                  TextButton(
                                    onPressed: () => openCheckInForm(
                                      context,
                                      habit,
                                      widget.checkIns,
                                      _refresh,
                                      entry: entry,
                                    ),
                                    child: const Text('Edit'),
                                  ),
                                  TextButton(
                                    onPressed: () => _delete(entry),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          FilledButton.icon(
            onPressed: () =>
                openCheckInForm(context, habit, widget.checkIns, _refresh),
            icon: const Icon(Icons.add),
            label: const Text('Add Check-in'),
          ),
        ],
      ),
    );
  }
}
