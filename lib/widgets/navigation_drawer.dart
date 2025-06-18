import 'package:flutter/material.dart';
import 'package:lifegrowth/screens/dashboard_screen.dart';
import 'package:lifegrowth/screens/task_list_screen.dart';
import 'package:lifegrowth/screens/health_screen.dart';
import 'package:lifegrowth/screens/habits_screen.dart';
import 'package:lifegrowth/screens/suggestions_screen.dart';

class AppNavigationDrawer extends StatelessWidget {
  final String currentPage; // Add the currentPage parameter

  const AppNavigationDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF73C7E3), // Light blue
                  Color(0xFF24B0BA), // Teal
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 8),
                Text(
                  'Life Growth',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your Personal Journey',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: currentPage == 'Dashboard',
            onTap: () {
              if (currentPage != 'Dashboard') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              } else {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_box),
            title: const Text('Tasks'),
            selected: currentPage == 'Tasks',
            onTap: () {
              if (currentPage != 'Tasks') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TaskListScreen()),
                );
              } else {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Health'),
            selected: currentPage == 'Health',
            onTap: () {
              if (currentPage != 'Health') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HealthScreen()),
                );
              } else {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Habits'),
            selected: currentPage == 'Habits',
            onTap: () {
              if (currentPage != 'Habits') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HabitsScreen()),
                );
              } else {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb),
            title: const Text('Suggestions'),
            selected: currentPage == 'Suggestions',
            onTap: () {
              if (currentPage != 'Suggestions') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SuggestionsScreen()),
                );
              } else {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
        ],
      ),
    );
  }
}
