import 'package:flutter/material.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/task_list_screen.dart';
import 'package:myapp/screens/health_screen.dart';
import 'package:myapp/screens/habits_screen.dart';
import 'package:myapp/screens/suggestions_screen.dart';

class AppNavigationDrawer extends StatelessWidget {
  final String currentPage; // Add the currentPage parameter

  const AppNavigationDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, // You can customize the header color
            ),
            child: Text(
              'Life Growth',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
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
