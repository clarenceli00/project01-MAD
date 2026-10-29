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
    return Scaffold(body:Center(child:Text(widget.habitName)));
  }
}