import 'package:flutter/material.dart';

import '../settings_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsHelper settings = SettingsHelper();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    int target = await settings.getDefaultTarget();
    bool reducedMotion = await settings.getReducedMotion();

    if (!mounted) return;

    setState(() {
      targetValue = target.toDouble();
      _reduceMotion = reducedMotion;
    });
  }

  Future<void> _saveSettings() async {
    try {
      await settings.saveDefaultTarget(targetValue.round());
      await settings.saveReducedMotion(_reduceMotion);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Settings saved!')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save settings: $error')),
      );
    }
  }

  var targetValue = 1.0;
  bool _reduceMotion = false;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text('Default Weekly Target'),
        Text(
          '${targetValue.round()} ${targetValue.round() == 1 ? 'day' : 'days'} per week',
        ),
        Slider(
          value: targetValue,
          min: 1,
          max: 7,
          divisions: 6,
          onChanged: (double value) {
            setState(() {
              targetValue = value;
            });
          },
        ),
        Text('Applies to newly created Targets'),
        SwitchListTile(
          title: const Text('Reduce motion'),
          subtitle: const Text('Use still images instead of animations.'),
          value: _reduceMotion,
          onChanged: (bool value) {
            setState(() {
              _reduceMotion = value;
            });
          },
        ),

        FilledButton(
          onPressed: _saveSettings,
          child: const Text('Save Settings'),
        ),
      ],
    );
  }
}
