import 'package:flutter/material.dart';
import 'package:myapp/widgets/navigation_drawer.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
      ),
      drawer: AppNavigationDrawer(currentPage: 'Habits'),
      body: const Center(
        child: Text('Habits Screen'),
      ),
    );
  }
}
