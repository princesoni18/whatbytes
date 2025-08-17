import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../model/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge.r),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted 
                      ? task.category.color 
                      : AppTheme.borderColor,
                  width: 2,
                ),
                color: task.isCompleted 
                    ? task.category.color 
                    : Colors.transparent,
              ),
              child: task.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 14.sp,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // Task Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Priority
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: AppTheme.bodyLarge.copyWith(
                          color: task.isCompleted 
                              ? AppTheme.textSecondaryColor 
                              : AppTheme.textPrimaryColor,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    // Priority Indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        task.priority.displayName,
                        style: AppTheme.bodySmall.copyWith(
                          color: _getPriorityColor(),
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (task.description != null && task.description!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    task.description!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
                      decoration: task.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                SizedBox(height: 8.h),
                
                // Due Date and Category
                Row(
                  children: [
                    // Category
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: task.category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: task.category.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            task.category.displayName,
                            style: AppTheme.bodySmall.copyWith(
                              color: task.category.color,
                              fontWeight: FontWeight.w500,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(width: 8.w),
                    
                    // Due Date
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getDueDateColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12.sp,
                            color: _getDueDateColor(),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formatDueDate(),
                            style: AppTheme.bodySmall.copyWith(
                              color: _getDueDateColor(),
                              fontWeight: FontWeight.w500,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Edit Button
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 18.sp,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 8.w),
                    
                    // Delete Button
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18.sp,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.high:
        return AppTheme.errorColor;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return AppTheme.successColor;
    }
  }

  Color _getDueDateColor() {
    if (task.isCompleted) return AppTheme.textSecondaryColor;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    
    if (taskDate.isBefore(today)) {
      return AppTheme.errorColor; // Overdue
    } else if (taskDate.isAtSameMomentAs(today)) {
      return Colors.orange; // Due today
    } else {
      return AppTheme.textSecondaryColor; // Future
    }
  }

  String _formatDueDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    
    if (taskDate.isBefore(today)) {
      final daysDiff = today.difference(taskDate).inDays;
      return daysDiff == 1 ? 'Yesterday' : '$daysDiff days ago';
    } else if (taskDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      final daysDiff = taskDate.difference(today).inDays;
      if (daysDiff <= 7) {
        return 'In $daysDiff days';
      } else {
        // Format as MM/dd for distant dates
        return '${task.dueDate.month.toString().padLeft(2, '0')}/${task.dueDate.day.toString().padLeft(2, '0')}';
      }
    }
  }
}