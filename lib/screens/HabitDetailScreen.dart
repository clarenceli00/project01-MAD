import 'package:flutter/material.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitName;
  final String category;
  final int weeklyTarget;
  final DateTime startDate;
  final String motivation;
  final int completedDays;

  const HabitDetailScreen({
    super.key,
    required this.habitName,
    required this.category,
    required this.weeklyTarget,
    required this.startDate,
    required this.motivation,
    this.completedDays = 0,
  }) : assert(weeklyTarget >= 1 && weeklyTarget <= 7),
       assert(completedDays >= 0 && completedDays <= 7);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  String cycleStatus = 'Ready';

  @override
  Widget build(BuildContext context) {
    // Example: 2 completed days / target of 4 = 0.5 (50%).
    final progress = widget.completedDays / widget.weeklyTarget;
    final percentage = (progress * 100).round();
    final startDate = MaterialLocalizations.of(context)
        .formatMediumDate(widget.startDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitName),
        actions: [
          TextButton(
            // TODO: open editor
            onPressed: null,
            child: const Text('Edit'),
          ),
        ],
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
                '${widget.completedDays} of ${widget.weeklyTarget} days this week',
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
                // TODO: open the checkin form and save to database
                onPressed: null,
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
                    onPressed: cycleStatus == 'Ready' ? () {
                      setState(() {
                        cycleStatus = 'Active';
                      });
                    } : null,
                    child: const Text('Start Week'),
                  ),
                  OutlinedButton(
                    onPressed: cycleStatus == 'Active' ? () {
                      setState(() {
                        cycleStatus = 'Finished';
                      });
                    } : null,
                    child: const Text('Finish Week'),
                  ),
                  TextButton(
                    onPressed: cycleStatus != 'Ready' ? () {
                      setState(() {
                        cycleStatus = 'Ready';
                      });
                    } : null,
                    child: const Text('Reset Flow'),
                  ),
                ],
              ),
              const Text('Reset changes the cycle status only, not check-ins.'),
              const SizedBox(height: 24),

              Text('About this habit',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Category: ${widget.category}'),
              Text('Started: $startDate'),
              if (widget.motivation.trim().isNotEmpty)
                Text(widget.motivation),
              const SizedBox(height: 16),

              TextButton(
                // TODO: get history from database
                onPressed: null,
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
