import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../simple_task_bloc.dart';
import '../../auth/simple_auth_bloc.dart';
import '../widgets/task_header.dart';
import '../widgets/task_section.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_fab.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _selectedBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load tasks when the screen loads
    print('TasksScreen: Loading tasks');
    context.read<TaskBloc>().add(LoadTasks());
  }

  void _toggleTaskCompletion(String taskId, bool currentStatus) {
    print('TasksScreen: Toggling task $taskId (current status: $currentStatus)');
    context.read<TaskBloc>().add(ToggleTask(taskId));
  }

  void _deleteTask(String taskId) {
    context.read<TaskBloc>().add(DeleteTask(taskId));
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            TaskHeader(
              onMenuPressed: () {
                // Handle menu press
              },
              onSearchPressed: () {
                // Handle search press
              },
              onMorePressed: _showLogoutDialog,
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
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
      
      // Floating Action Button
      floatingActionButton: CustomFAB(
        onPressed: _onFabPressed,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTasksList(TasksLoaded state) {
    // Check if there are any tasks at all
    if (state.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64.sp,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Tasks Yet',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap the + button to create your first task',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
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
          
          // Today Tasks
          if (state.todayTasks.isNotEmpty)
            TaskSection(
              key: ValueKey('today_${state.todayTasks.length}_${state.todayTasks.map((t) => '${t.id}_${t.isCompleted}').join('_')}'),
              title: 'Today',
              tasks: state.todayTasks,
              onTaskToggle: _toggleTaskCompletion,
              onTaskDelete: _deleteTask,
            ),
          
          SizedBox(height: 24.h),
          
          // Tomorrow Tasks
          if (state.tomorrowTasks.isNotEmpty)
            TaskSection(
              key: ValueKey('tomorrow_${state.tomorrowTasks.length}_${state.tomorrowTasks.map((t) => '${t.id}_${t.isCompleted}').join('_')}'),
              title: 'Tomorrow',
              tasks: state.tomorrowTasks,
              onTaskToggle: _toggleTaskCompletion,
              onTaskDelete: _deleteTask,
            ),
          
          SizedBox(height: 24.h),
          
          // This Week Tasks
          if (state.thisWeekTasks.isNotEmpty)
            TaskSection(
              key: ValueKey('week_${state.thisWeekTasks.length}_${state.thisWeekTasks.map((t) => '${t.id}_${t.isCompleted}').join('_')}'),
              title: 'This week',
              tasks: state.thisWeekTasks,
              onTaskToggle: _toggleTaskCompletion,
              onTaskDelete: _deleteTask,
            ),
          
          SizedBox(height: 100.h), // Space for FAB
        ],
      ),
    );
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
