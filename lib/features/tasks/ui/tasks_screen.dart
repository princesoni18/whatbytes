import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../bloc/task_bloc.dart';
import '../../auth/simple_auth_bloc.dart';
import '../model/task_filter.dart';
import '../widgets/task_header.dart';
import '../widgets/simple_task_item.dart';
import '../widgets/custom_fab.dart';
import '../widgets/task_filter_dialog.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {


  @override
  void initState() {
    super.initState();
    // Load tasks when the screen loads
    print('TasksScreen: Loading tasks');
    context.read<TaskBloc>().add(LoadTasks());
  }

  void _toggleTaskCompletion(String taskId, bool currentStatus) {
    print('TasksScreen: Toggling task $taskId (current status: $currentStatus)');
    print('TasksScreen: Dispatching ToggleTask event');
    context.read<TaskBloc>().add(ToggleTask(taskId));
  }

  void _deleteTask(String taskId) {
    context.read<TaskBloc>().add(DeleteTask(taskId));
  }

  

  void _onFabPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: const AddTaskScreen(),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthSignOutRequested());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog(TaskFilterCriteria currentFilter) {
    showDialog<TaskFilterCriteria>(
      context: context,
      builder: (BuildContext context) {
        return TaskFilterDialog(
          initialCriteria: currentFilter,
        );
      },
    ).then((filterCriteria) {
      if (filterCriteria != null) {
        context.read<TaskBloc>().add(FilterTasks(filterCriteria));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                final hasActiveFilters = state is TasksLoaded && state.filterCriteria.hasActiveFilters;
                final currentFilter = state is TasksLoaded ? state.filterCriteria : const TaskFilterCriteria();
                
                return TaskHeader(
                  onMenuPressed: () {
                    // Handle menu press
                    _showLogoutDialog();
                  },
                
                  onFilterPressed: () => _showFilterDialog(currentFilter),
                  hasActiveFilters: hasActiveFilters,
                );
              },
            ),
            
            // Task Content
            Expanded(
              child: BlocConsumer<TaskBloc, TaskState>(
                listener: (context, state) {
                  print('TasksScreen: BLoC state changed to ${state.runtimeType}');
                  if (state is TaskError) {
                    print('TasksScreen: Error - ${state.message}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  } else if (state is TasksLoaded) {
                    print('TasksScreen: Tasks loaded - ${state.tasks.length} tasks');
                  }
                },
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is TasksLoaded) {
                    print("state changed");
                    return _buildTasksList(state);
                  } else if (state is TaskError) {
                    return _buildErrorView(state);
                  }
                  return const Center(
                    child: Text('No tasks available'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
     
      // Floating Action Button
      floatingActionButton: CustomFAB(
        onPressed: _onFabPressed,
      ),
      
    );
  }

  Widget _buildTasksList(TasksLoaded state) {
    // Check if there are any tasks at all
    if (state.tasks.isEmpty) {
      final hasFilters = state.filterCriteria.hasActiveFilters;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.filter_list_off : Icons.task_alt,
              size: 64.sp,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              hasFilters ? 'No Tasks Match Filters' : 'No Tasks Yet',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              hasFilters 
                  ? 'Try adjusting your filters to see more tasks'
                  : 'Tap the + button to create your first task',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  context.read<TaskBloc>().add(ClearFilters());
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.screenPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          
          // Filter Status (if any filters are active)
          if (state.filterCriteria.hasActiveFilters)
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium.r),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16.sp,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _getFilterDescription(state.filterCriteria),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<TaskBloc>().add(ClearFilters());
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Clear',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Tasks List Header
          if (state.tasks.isNotEmpty) ...[
            Text(
              'All Tasks (${state.tasks.length})',
              style: AppTheme.headingMedium.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 16.h),
          ],
          
          // All Tasks List
          ...state.tasks.map((task) => TaskItem(
            key: ValueKey(task.id), // Use only task.id for stable keys
            task: task,
            onToggle: () => _toggleTaskCompletion(task.id, task.isCompleted),
            onDelete: () => _deleteTask(task.id),
          )).toList(),
          
          SizedBox(height: 100.h), // Space for FAB
        ],
      ),
    );
  }

  String _getFilterDescription(TaskFilterCriteria criteria) {
    final List<String> parts = [];
    
    if (criteria.statusFilter != TaskFilter.all) {
      parts.add(criteria.statusFilter.displayName);
    }
    
    if (criteria.priorityFilters.isNotEmpty) {
      final priorities = criteria.priorityFilters
          .map((p) => p.displayName)
          .join(', ');
      parts.add('Priority: $priorities');
    }
    
    if (criteria.categoryFilters.isNotEmpty) {
      final categories = criteria.categoryFilters
          .map((c) => c.displayName)
          .join(', ');
      parts.add('Category: $categories');
    }
    
    return parts.join(' • ');
  }

  Widget _buildErrorView(TaskError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppTheme.errorColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: AppTheme.headingMedium,
          ),
          SizedBox(height: 8.h),
          Text(
            state.message,
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<TaskBloc>().add(LoadTasks());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
