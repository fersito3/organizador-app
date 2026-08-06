import 'package:flutter/material.dart';
import '../../../calendar/presentation/screens/calendar_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CalendarScreen(initialTab: 1);
  }
}
