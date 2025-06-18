class Task {
  final String id;
  String name;
  String category;
  String schedule;
  DateTime? dueDate;
  String? notes;
  bool isCompleted;
  int streak;
  int missedDays;

  Task({
    required this.id,
    required this.name,
    required this.category,
    required this.schedule,
    this.dueDate,
    this.notes,
    this.isCompleted = false,
    this.streak = 0,
    this.missedDays = 0,
  });
}