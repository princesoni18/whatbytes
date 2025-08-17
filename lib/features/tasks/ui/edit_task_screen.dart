import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../model/task.dart';
import '../bloc/simple_task_bloc.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  
  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  
  late DateTime _selectedDate;
  late TaskPriority _selectedPriority;
  late TaskCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with current task data
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    
    // Initialize selections with current task data
    _selectedDate = widget.task.dueDate;
    _selectedPriority = widget.task.priority;
    _selectedCategory = widget.task.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateTask() {
    if (_formKey.currentState!.validate()) {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        dueDate: _selectedDate,
        priority: _selectedPriority,
        category: _selectedCategory,
      );

      context.read<TaskBloc>().add(UpdateTask(updatedTask));
      Navigator.of(context).pop();
    }
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close edit screen
                context.read<TaskBloc>().add(DeleteTask(widget.task.id));
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: AppTheme.textPrimaryColor,
            size: 24.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Task',
          style: AppTheme.headingMedium.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppTheme.errorColor,
              size: 24.sp,
            ),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: widget.task.isCompleted 
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium.r),
                  border: Border.all(
                    color: widget.task.isCompleted 
                        ? AppTheme.successColor
                        : AppTheme.primaryColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.task.isCompleted ? Icons.check_circle : Icons.schedule,
                      size: 16.sp,
                      color: widget.task.isCompleted 
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      widget.task.isCompleted ? 'Completed' : 'Pending',
                      style: AppTheme.bodySmall.copyWith(
                        color: widget.task.isCompleted 
                            ? AppTheme.successColor
                            : AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Title Field
              Text(
                'Task Title',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: _titleController,
                hintText: 'Enter task title',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20.h),
              
              // Description Field
              Text(
                'Description',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Enter task description (optional)',
                maxLines: 3,
              ),
              
              SizedBox(height: 20.h),
              
              // Due Date
              Text(
                'Due Date',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: _selectDate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.mediumPadding,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppTheme.textSecondaryColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Priority Selection
              Text(
                'Priority',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: priority != TaskPriority.values.last ? 8.w : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPriority = priority),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _getPriorityColor(priority).withOpacity(0.1)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? _getPriorityColor(priority)
                                  : AppTheme.borderColor,
                            ),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(priority),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                _getPriorityText(priority),
                                style: AppTheme.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? _getPriorityColor(priority)
                                      : AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              SizedBox(height: 20.h),
              
              // Category Selection
              Text(
                'Category',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: TaskCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        _getCategoryText(category),
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              SizedBox(height: 40.h),
              
              // Update Button
              CustomButton(
                text: 'Update Task',
                onPressed: _updateTask,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  String _getCategoryText(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.app:
        return 'App';
      case TaskCategory.cf:
        return 'CF';
      case TaskCategory.study:
        return 'Study';
    }
  }
}
