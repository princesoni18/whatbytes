import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whatbytes_assignment/features/tasks/widgets/simple_task_item.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../model/task.dart';


class TaskSection extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final Function(String, bool) onTaskToggle;
  final Function(String) onTaskDelete;

  const TaskSection({
    super.key,
    required this.title,
    required this.tasks,
    required this.onTaskToggle,
    required this.onTaskDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            Text(
              title,
              style: AppTheme.headingMedium.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
              child: Text(
                '${tasks.length}',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12.h),
        
        // Task List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskItem(
              key: ValueKey('${task.id}_${task.isCompleted}'),
              task: task,
              onToggle: () => onTaskToggle(task.id, task.isCompleted),
              onDelete: () => onTaskDelete(task.id),
            );
          },
        ),
      ],
    );
  }
}
