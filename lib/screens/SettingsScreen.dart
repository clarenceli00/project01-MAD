import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen>{
  var targetValue = 1.0;
  bool _reduceMotion = false;
  @override
  Widget build(BuildContext context){
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text('Default Weekly Target'),
        Text('${targetValue.round()} ${targetValue.round() == 1 ? 'day' : 'days'} per week',),
        Slider(value:targetValue,min:1,max:7,divisions:6, onChanged: (double value){ setState(() {
          targetValue = value;
        });}
        ),
        Text('Applies to newly created Targets'),
        SwitchListTile(
          title: const Text('Reduce motion'),
          subtitle: const Text(
            'Use still images instead of animations.',
          ),
          value: _reduceMotion,
          onChanged: (bool value) {
            setState(() {
              _reduceMotion = value;
            });
          },
        ),

        FilledButton(
          onPressed: () {
            // Save your settings here.
          },
          child: const Text('Save Settings'),
        ),
      ]
    );
  }
}