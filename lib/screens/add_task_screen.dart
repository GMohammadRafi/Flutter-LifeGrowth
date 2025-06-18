import 'package:flutter/material.dart';
import '../models/enhanced_task_model.dart';
import '../models/category_model.dart';
import '../models/schedule_type_model.dart';
import '../services/enhanced_task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _enhancedTaskService = EnhancedTaskService();

  List<CategoryModel> _categories = [];
  List<ScheduleTypeModel> _scheduleTypes = [];
  CategoryModel? _selectedCategory;
  ScheduleTypeModel? _selectedScheduleType;
  DateTime? _selectedDueDate;

  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoadingData = true;
        _errorMessage = null;
      });

      final categories = await _enhancedTaskService.getCategories();
      final scheduleTypes = await _enhancedTaskService.getScheduleTypes();

      setState(() {
        _categories = categories;
        _scheduleTypes = scheduleTypes;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoadingData = false;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF24B0BA),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final task = EnhancedTaskModel(
        name: _taskNameController.text.trim(),
        categoryId: _selectedCategory?.id,
        scheduleTypeId: _selectedScheduleType?.id,
        dueDate: _selectedDueDate,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      await _enhancedTaskService.createTask(task);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create task: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        title: const Text('Add New Task'),
        backgroundColor: const Color(0xFF73C7E3),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF24B0BA),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),

                    // Task Name Field
                    _buildSectionTitle('Task Name *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _taskNameController,
                      decoration: _buildInputDecoration(
                        'Enter task name',
                        Icons.task_alt,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a task name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Category Field
                    _buildSectionTitle('Category'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<CategoryModel>(
                      value: _selectedCategory,
                      decoration: _buildInputDecoration(
                        'Select category',
                        Icons.category,
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (CategoryModel? value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Schedule Type Field
                    _buildSectionTitle('Schedule Type'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ScheduleTypeModel>(
                      value: _selectedScheduleType,
                      decoration: _buildInputDecoration(
                        'Select schedule type',
                        Icons.schedule,
                      ),
                      items: _scheduleTypes.map((scheduleType) {
                        return DropdownMenuItem(
                          value: scheduleType,
                          child: Text(scheduleType.name),
                        );
                      }).toList(),
                      onChanged: (ScheduleTypeModel? value) {
                        setState(() {
                          _selectedScheduleType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Due Date Field
                    _buildSectionTitle('Due Date (Optional)'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDueDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF24B0BA),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDueDate != null
                                  ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                                  : 'Select due date',
                              style: TextStyle(
                                color: _selectedDueDate != null
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            if (_selectedDueDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _selectedDueDate = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notes Field
                    _buildSectionTitle('Notes (Optional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: _buildInputDecoration(
                        'Add any relevant notes or details...',
                        Icons.notes,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF24B0BA)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF24B0BA),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF24B0BA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Create Task',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF24B0BA),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF24B0BA),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF24B0BA),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
