import 'package:flutter/material.dart';

import '../models.dart';

class HabitEditorScreen extends StatefulWidget {
  // Null creates a new habit, not null edits existing habit
  final Habit? habit;
  final DateTime? earliestCheckIn;

  const HabitEditorScreen({super.key, this.habit, this.earliestCheckIn});
  @override
  State<HabitEditorScreen> createState() => _HabitEditorScreenState();
}

class _HabitEditorScreenState extends State<HabitEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _motivationController = TextEditingController();
  String _category = 'Learning';
  double _weeklyTarget = 4;
  DateTime _startDate = DateUtils.dateOnly(DateTime.now());
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    if (habit != null) {
      _titleController.text = habit.title;
      _motivationController.text = habit.motivation;
      _category = habit.category;
      _weeklyTarget = habit.weeklyTarget.toDouble();
      _startDate = habit.startDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isAfter(today) ? today : _startDate,
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (!mounted || picked == null) return;
    setState(() => _startDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.earliestCheckIn != null &&
        _startDate.isAfter(widget.earliestCheckIn!)) {
      setState(
        () => _dateError = 'Correct or delete earlier check-ins before changing the start date.',
      );
      return;
    }

    final habit = Habit(
      id: widget.habit?.id,
      title: _titleController.text.trim(),
      category: _category,
      weeklyTarget: _weeklyTarget.round(),
      startDate: DateUtils.dateOnly(_startDate),
      motivation: _motivationController.text.trim(),
      cycleWeekStart: widget.habit?.cycleWeekStart,
      cycleStatus: widget.habit?.cycleStatus ?? 'Ready',
    );
    Navigator.pop(context, habit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Add Habit' : 'Edit Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Habit name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Learning', 'Creative', 'Personal', 'Other'].map((
                  category,
                ) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickStartDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  'Start date: ${MaterialLocalizations.of(context).formatMediumDate(_startDate)}',
                ),
              ),
              if (_dateError != null)
                Text(
                  _dateError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 16),
              Text(
                'Weekly target: ${_weeklyTarget.round()} ${_weeklyTarget == 1 ? 'day' : 'days'}',
              ),
              Slider(
                value: _weeklyTarget,
                min: 1,
                max: 7,
                divisions: 6,
                label: '${_weeklyTarget.round()} days',
                onChanged: (value) => setState(() => _weeklyTarget = value),
              ),
              TextFormField(
                controller: _motivationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Motivation (optional)',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
