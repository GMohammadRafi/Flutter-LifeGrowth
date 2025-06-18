import 'package:flutter/material.dart';
import 'package:myapp/widgets/navigation_drawer.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health'),
      ),
      drawer: const AppNavigationDrawer(currentPage: 'Health'),
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
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF24B0BA), // Teal
                    Color(0xFF73C7E3), // Light blue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Health Tracker',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Monitor your wellness journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Health metrics
            Expanded(
              child: ListView(
                children: [
                  _buildHealthMetric(
                    icon: Icons.directions_walk,
                    title: 'Steps Today',
                    value: '8,432',
                    target: '10,000',
                    progress: 0.84,
                    unit: 'steps',
                  ),
                  const SizedBox(height: 16),
                  _buildHealthMetric(
                    icon: Icons.local_drink,
                    title: 'Water Intake',
                    value: '6',
                    target: '8',
                    progress: 0.75,
                    unit: 'glasses',
                  ),
                  const SizedBox(height: 16),
                  _buildHealthMetric(
                    icon: Icons.bedtime,
                    title: 'Sleep',
                    value: '7.5',
                    target: '8',
                    progress: 0.94,
                    unit: 'hours',
                  ),
                  const SizedBox(height: 16),
                  _buildHealthMetric(
                    icon: Icons.fitness_center,
                    title: 'Exercise',
                    value: '45',
                    target: '60',
                    progress: 0.75,
                    unit: 'minutes',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric({
    required IconData icon,
    required String title,
    required String value,
    required String target,
    required double progress,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF73C7E3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF24B0BA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      '$value / $target $unit',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF24B0BA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF73C7E3).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF73C7E3),
                      Color(0xFF24B0BA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
