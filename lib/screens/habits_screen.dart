import 'package:flutter/material.dart';
import 'package:lifegrowth/widgets/navigation_drawer.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
      ),
      drawer: const AppNavigationDrawer(currentPage: 'Habits'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF73C7E3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF73C7E3).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        color: Color(0xFF24B0BA),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Daily Habits',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF24B0BA),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Build positive habits for a better life',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Habits list
            Expanded(
              child: ListView(
                children: [
                  _buildHabitCard(
                    title: 'Morning Exercise',
                    description: '30 minutes of physical activity',
                    isCompleted: true,
                    streak: 7,
                  ),
                  const SizedBox(height: 12),
                  _buildHabitCard(
                    title: 'Read for 20 minutes',
                    description: 'Daily reading habit',
                    isCompleted: false,
                    streak: 3,
                  ),
                  const SizedBox(height: 12),
                  _buildHabitCard(
                    title: 'Drink 8 glasses of water',
                    description: 'Stay hydrated throughout the day',
                    isCompleted: true,
                    streak: 12,
                  ),
                  const SizedBox(height: 12),
                  _buildHabitCard(
                    title: 'Meditation',
                    description: '10 minutes of mindfulness',
                    isCompleted: false,
                    streak: 5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new habit functionality
        },
        backgroundColor: const Color(0xFF24B0BA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHabitCard({
    required String title,
    required String description,
    required bool isCompleted,
    required int streak,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF73C7E3).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Completion checkbox
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? const Color(0xFF24B0BA) : Colors.transparent,
              border: Border.all(
                color: isCompleted ? const Color(0xFF24B0BA) : Colors.grey,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Habit details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Streak indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF73C7E3).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${streak}d',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF24B0BA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
