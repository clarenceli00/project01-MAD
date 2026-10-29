import 'package:flutter/material.dart';

class HabitEditorScreen extends StatefulWidget {
  const HabitEditorScreen({super.key});
  @override
  State<HabitEditorScreen> createState() => _HabitEditorScreenState();
}
class _HabitEditorScreenState extends State<HabitEditorScreen>{
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No editing yet'),);
  }
}