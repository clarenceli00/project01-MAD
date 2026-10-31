import 'package:flutter/material.dart';

import '../models.dart';
import 'HabitEditorScreen.dart';
import 'HistoryScreen.dart';
import 'screens.dart' show openCheckInForm;
import '../database_helper.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitName;
  final String category;
  final int weeklyTarget;
  final DateTime startDate;
  final String motivation;
  final int completedDays;
  final ValueChanged<Habit>? onHabitChanged;
  final int? habitId;
  final List<CheckIn>? checkIns;
  final VoidCallback? onCheckInsChanged;

  const HabitDetailScreen({
    super.key,
    required this.habitName,
    required this.category,
    required this.weeklyTarget,
    required this.startDate,
    required this.motivation,
    this.completedDays = 0,
    this.onHabitChanged,
    this.habitId,
    this.checkIns,
    this.onCheckInsChanged,
  }) : assert(weeklyTarget >= 1 && weeklyTarget <= 7),
       assert(completedDays >= 0 && completedDays <= 7);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  String cycleStatus = 'Ready';
  late Habit _habit;

  @override
  void initState() {
    super.initState();
    _habit = Habit(
      id: widget.habitId,
      title: widget.habitName,
      category: widget.category,
      weeklyTarget: widget.weeklyTarget,
      startDate: widget.startDate,
      motivation: widget.motivation,
    );
  }

  Future<void> _editHabit() async {
    final dates =
        (widget.checkIns ?? <CheckIn>[])
            .where((entry) => entry.habitId == _habit.id)
            .map((entry) => entry.date)
            .toList()
          ..sort();
    final updatedHabit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
        builder: (context) => HabitEditorScreen(
          habit: _habit,
          earliestCheckIn: dates.isEmpty ? null : dates.first,
        ),
      ),
    );
    if (!mounted || updatedHabit == null) return;

    setState(() => _habit = updatedHabit);
    // Update the matching card in Garden as well.
    widget.onHabitChanged?.call(updatedHabit);
  }

  void _refreshCheckIns() {
    widget.onCheckInsChanged?.call();
    if (mounted) setState(() {});
  }

  Future<void> _viewHistory() async {
    if (widget.checkIns == null) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('${_habit.title} history')),
          body: HistoryScreen(
            habits: [_habit],
            checkIns: widget.checkIns!,
            initialHabitId: _habit.id,
            onChanged: _refreshCheckIns,
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final completedDays = widget.checkIns == null
        ? widget.completedDays
        : weeklyCount(widget.checkIns!, _habit.id, DateTime.now());
    final progress = completedDays / _habit.weeklyTarget;
    final percentage = (progress * 100).round();
    final startDate = MaterialLocalizations.of(context)
        .formatMediumDate(_habit.startDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(_habit.title),
        actions: [TextButton(onPressed: _editHabit, child: const Text('Edit'))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: FlowerProgress(progress: progress)),
              const SizedBox(height: 16),

              Text(
                '$completedDays of ${_habit.weeklyTarget} days this week',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '$percentage%',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: widget.checkIns != null && cycleStatus == 'Active'
                    ? () => openCheckInForm(
                        context,
                        _habit,
                        widget.checkIns!,
                        _refreshCheckIns,
                      )
                    : null,
                icon: const Icon(Icons.check),
                label: const Text('Check In'),
              ),
              const SizedBox(height: 16),

              Text('Cycle status: $cycleStatus'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: cycleStatus == 'Ready'
                        ? () {
                            setState(() {
                              cycleStatus = 'Active';
                            });
                          }
                        : null,
                    child: const Text('Start Week'),
                  ),
                  OutlinedButton(
                    onPressed: cycleStatus == 'Active'
                        ? () {
                            setState(() {
                              cycleStatus = 'Finished';
                            });
                          }
                        : null,
                    child: const Text('Finish Week'),
                  ),
                  TextButton(
                    onPressed: cycleStatus != 'Ready'
                        ? () {
                            setState(() {
                              cycleStatus = 'Ready';
                            });
                          }
                        : null,
                    child: const Text('Reset Flow'),
                  ),
                ],
              ),
              const Text('Reset changes the cycle status only, not check-ins.'),
              const SizedBox(height: 24),

              Text(
                'About this habit',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Category: ${_habit.category}'),
              Text('Started: $startDate'),
              if (_habit.motivation.trim().isNotEmpty) Text(_habit.motivation),
              const SizedBox(height: 16),

              TextButton(
                onPressed: widget.checkIns != null ? _viewHistory : null,
                child: const Text('View Check-in History'),
              ),
              const SizedBox(height: 24),
              TextButton(
                // TODO: connect with the database; confirm deletion
                onPressed: null,
                child: const Text('Delete Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlowerProgress extends StatelessWidget {
  final double progress;

  const FlowerProgress({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final fill = progress.clamp(0.0, 1.0);

    return Semantics(
      label: 'Weekly progress flower',
      value: '${(progress * 100).round()} percent',
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.green,
            Colors.green,
            Colors.grey.shade300,
            Colors.grey.shade300,
          ],
          stops: [0, fill, fill, 1],
        ).createShader(bounds),
        child: Image.asset(
          'assets/images/flower-rose-plant-icon.png',
          width: 180,
          height: 180,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
