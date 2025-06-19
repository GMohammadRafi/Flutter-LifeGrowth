import 'package:flutter/material.dart';
import 'package:lifegrowth/screens/dashboard_screen.dart';
import 'package:lifegrowth/screens/task_list_screen.dart';
import 'package:lifegrowth/screens/health_screen.dart';
import 'package:lifegrowth/screens/habits_screen.dart';
import 'package:lifegrowth/screens/suggestions_screen.dart';
import 'package:lifegrowth/screens/user_profile_screen.dart';
import 'package:lifegrowth/screens/auth/login_screen.dart';
import 'package:lifegrowth/services/auth_service.dart';

class AppNavigationDrawer extends StatefulWidget {
  final String currentPage; // Add the currentPage parameter

  const AppNavigationDrawer({super.key, required this.currentPage});

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  final AuthService _authService = AuthService();

  Future<void> _showLogoutDialog() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    try {
      // Sign out from Supabase (this clears both app and Supabase sessions)
      await _authService.signOut();

      // Force a small delay to ensure the auth state change is processed
      await Future.delayed(const Duration(milliseconds: 500));

      // Force navigation to login screen as a fallback
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }

      // Logout successful
    } catch (e) {
      // Handle logout error
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
            selected: widget.currentPage == 'Dashboard',
            onTap: () {
              if (widget.currentPage != 'Dashboard') {
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
            selected: widget.currentPage == 'Tasks',
            onTap: () {
              if (widget.currentPage != 'Tasks') {
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
            selected: widget.currentPage == 'Health',
            onTap: () {
              if (widget.currentPage != 'Health') {
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
            selected: widget.currentPage == 'Habits',
            onTap: () {
              if (widget.currentPage != 'Habits') {
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
            selected: widget.currentPage == 'Suggestions',
            onTap: () {
              if (widget.currentPage != 'Suggestions') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SuggestionsScreen()),
                );
              } else {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),

          // Divider before profile and logout options
          const Divider(
            thickness: 1,
            color: Color(0xFF73C7E3),
          ),

          // Profile option
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            selected: widget.currentPage == 'Profile',
            onTap: () {
              if (widget.currentPage != 'Profile') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserProfileScreen()),
                );
              } else {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),

          // Logout option
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }
}
