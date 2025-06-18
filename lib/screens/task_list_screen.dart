import 'package:flutter/material.dart';
import 'package:lifegrowth/widgets/navigation_drawer.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppNavigationDrawer(currentPage: 'Tasks'),
      appBar: AppBar(
        title: const Text('Manage Your Tasks'),
      ),
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
                    Color(0xFF73C7E3), // Light blue
                    Color(0xFF24B0BA), // Teal
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
                        Icons.check_box,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Task Manager',
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
                    'Stay organized and productive',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF24B0BA),
                  ),
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Task categories
            Row(
              children: [
                _buildCategoryChip('All', true),
                const SizedBox(width: 8),
                _buildCategoryChip('Today', false),
                const SizedBox(width: 8),
                _buildCategoryChip('Pending', false),
                const SizedBox(width: 8),
                _buildCategoryChip('Completed', false),
              ],
            ),
            const SizedBox(height: 20),

            // Tasks list
            Expanded(
              child: ListView(
                children: [
                  _buildTaskCard(
                    title: 'Complete project proposal',
                    description:
                        'Finish the quarterly project proposal document',
                    isCompleted: false,
                    priority: 'High',
                    dueDate: 'Today',
                  ),
                  const SizedBox(height: 12),
                  _buildTaskCard(
                    title: 'Team meeting preparation',
                    description:
                        'Prepare agenda and materials for tomorrow\'s meeting',
                    isCompleted: false,
                    priority: 'Medium',
                    dueDate: 'Tomorrow',
                  ),
                  const SizedBox(height: 12),
                  _buildTaskCard(
                    title: 'Review code changes',
                    description: 'Review and approve pending pull requests',
                    isCompleted: true,
                    priority: 'Low',
                    dueDate: 'Yesterday',
                  ),
                  const SizedBox(height: 12),
                  _buildTaskCard(
                    title: 'Update documentation',
                    description: 'Update API documentation with recent changes',
                    isCompleted: false,
                    priority: 'Medium',
                    dueDate: 'This week',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new task functionality
        },
        backgroundColor: const Color(0xFF24B0BA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF24B0BA) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF24B0BA) : const Color(0xFF73C7E3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF24B0BA),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String description,
    required bool isCompleted,
    required String priority,
    required String dueDate,
  }) {
    Color priorityColor;
    switch (priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      case 'Low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

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
              // Completion checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF24B0BA)
                      : Colors.transparent,
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
              const SizedBox(width: 12),

              // Task title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),

              // Priority indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Task description
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),

          // Due date
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                dueDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
