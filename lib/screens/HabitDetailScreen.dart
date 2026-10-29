import 'package:flutter/material.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitName;

  const HabitDetailScreen({
    super.key,
    required this.habitName,
  });

  @override
  State<HabitDetailScreen> createState() =>
      _HabitDetailScreenState();
}
class _HabitDetailScreenState extends State<HabitDetailScreen>{
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(widget.habitName), actions:[]),
      body:SingleChildScrollView(
        child: Padding(padding:EdgeInsetsGeometry.all(16),
        child: Column(children: [
          Icon(Icons.local_florist),
          Text("Weekly Progress"),
          Text("Category: placeholder"),
          Text("started: placeholder"),
          Text("Motivation: placeholder"),
          Text("Cycle Status"),
          FilledButton.icon(onPressed: () {}, label: Text('Check In')),
          Row(children: [
            FilledButton.icon(onPressed: () {}, label: Text('Start Week')),
            FilledButton.icon(onPressed: () {}, label: Text('Finish Week')),
          ]),
          FilledButton.icon(onPressed: () {}, label: Text('Reset')),
          TextButton(child:Text("View History"), onPressed: (){},),
          TextButton(child:Text("Delete habit"), onPressed: (){},),
        ]
        ,)
      ,)
      )
    );
  }
}