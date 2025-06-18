import 'package:flutter/material.dart';
import 'package:myapp/widgets/navigation_drawer.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppNavigationDrawer(currentPage: 'Tasks'),
      appBar: AppBar(
        title: const Text('Manage Your Tasks'),
      ),
      body: Column(
        children: [
          // Placeholder for search bar, filters, and task list
          Center(
            child: const Text('Task list content will go here.'),
          ),
        ],
      ),
    );
  }
}
