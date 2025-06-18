import 'package:flutter/material.dart';
import 'package:lifegrowth/widgets/navigation_drawer.dart';

class SuggestionsScreen extends StatelessWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions'),
      ),
      drawer: const AppNavigationDrawer(currentPage: 'Suggestions'),
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
                color: const Color(0xFF24B0BA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF24B0BA).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Color(0xFF24B0BA),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Daily Suggestions',
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
                    'Personalized tips for your growth journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Suggestions list
            Expanded(
              child: ListView(
                children: [
                  _buildSuggestionCard(
                    category: 'Health',
                    title: 'Take a 10-minute walk',
                    description:
                        'A short walk can boost your energy and improve your mood.',
                    icon: Icons.directions_walk,
                    isNew: true,
                  ),
                  const SizedBox(height: 12),
                  _buildSuggestionCard(
                    category: 'Productivity',
                    title: 'Try the Pomodoro Technique',
                    description:
                        'Work for 25 minutes, then take a 5-minute break to stay focused.',
                    icon: Icons.timer,
                    isNew: false,
                  ),
                  const SizedBox(height: 12),
                  _buildSuggestionCard(
                    category: 'Wellness',
                    title: 'Practice deep breathing',
                    description:
                        'Take 5 deep breaths to reduce stress and center yourself.',
                    icon: Icons.air,
                    isNew: true,
                  ),
                  const SizedBox(height: 12),
                  _buildSuggestionCard(
                    category: 'Learning',
                    title: 'Read for 15 minutes',
                    description:
                        'Expand your knowledge with just 15 minutes of reading today.',
                    icon: Icons.book,
                    isNew: false,
                  ),
                  const SizedBox(height: 12),
                  _buildSuggestionCard(
                    category: 'Social',
                    title: 'Call a friend or family member',
                    description:
                        'Strengthen your relationships with a quick check-in call.',
                    icon: Icons.phone,
                    isNew: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard({
    required String category,
    required String title,
    required String description,
    required IconData icon,
    required bool isNew,
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
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF73C7E3),
                          ),
                        ),
                        if (isNew) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF24B0BA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Dismiss suggestion
                },
                child: const Text(
                  'Dismiss',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Apply suggestion
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24B0BA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Try It'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
