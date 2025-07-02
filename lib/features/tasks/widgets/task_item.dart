import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/entities/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: AppConstants.iconSizeLarge,
        ),
      ),
      onDismissed: (direction) {
        onDelete();
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                print('TaskItem: Toggle tapped for task ${task.id} (current: ${task.isCompleted})');
                onToggle();
              },
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppTheme.successColor
                        : AppTheme.borderColor,
                    width: 2,
                  ),
                  color: task.isCompleted
                      ? AppTheme.successColor
                      : Colors.transparent,
                ),
                child: task.isCompleted
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      )
                    : null,
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Task Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title
                  Text(
                    task.title,
                    style: AppTheme.bodyLarge.copyWith(
                      color: task.isCompleted
                          ? AppTheme.textSecondaryColor
                          : AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.w500,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Due Date
                  Text(
                    _getFormattedDueDate(),
                    style: AppTheme.bodySmall.copyWith(
                      color: task.isOverdue && !task.isCompleted
                          ? AppTheme.errorColor
                          : AppTheme.textSecondaryColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Category Tag
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: task.category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                    child: Text(
                      task.category.displayName,
                      style: AppTheme.bodyMedium.copyWith(
                        color: task.category.color,
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Priority Indicator
            if (task.priority == TaskPriority.high)
              Container(
                width: 4.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDueDate() {
    final now = DateTime.now();
    final dueDate = task.dueDate;
    
    if (task.isDueToday) {
      return 'Due today';
    } else if (task.isDueTomorrow) {
      return 'Due tomorrow';
    } else if (dueDate.isBefore(now)) {
      final difference = now.difference(dueDate).inDays;
      return 'Overdue by $difference day${difference > 1 ? 's' : ''}';
    } else {
      final difference = dueDate.difference(now).inDays;
      return 'Due in $difference day${difference > 1 ? 's' : ''}';
    }
  }
}
