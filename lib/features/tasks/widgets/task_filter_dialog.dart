import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../model/task.dart';
import '../model/task_filter.dart';

class TaskFilterDialog extends StatefulWidget {
  final TaskFilterCriteria initialCriteria;
  final VoidCallback? onClearFilters;

  const TaskFilterDialog({
    super.key,
    required this.initialCriteria,
    this.onClearFilters,
  });

  @override
  State<TaskFilterDialog> createState() => _TaskFilterDialogState();
}

class _TaskFilterDialogState extends State<TaskFilterDialog> {
  late TaskFilter _statusFilter;
  late Set<TaskPriority> _priorityFilters;
  late Set<TaskCategory> _categoryFilters;

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.initialCriteria.statusFilter;
    _priorityFilters = Set.from(widget.initialCriteria.priorityFilters);
    _categoryFilters = Set.from(widget.initialCriteria.categoryFilters);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8; // 80% of screen height
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: 400.w, // Maximum width for larger screens
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Filter Tasks',
                  style: AppTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp, // Responsive font size
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, size: 20.sp),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.backgroundColor,
                    padding: EdgeInsets.all(8.w),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Filter
                    _buildSection(
                      title: 'Status',
                      child: Column(
                        children: TaskFilter.values.map((filter) {
                          return _buildRadioTile(
                            title: filter.displayName,
                            value: filter,
                            groupValue: _statusFilter,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _statusFilter = value;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Priority Filter
                    _buildSection(
                      title: 'Priority',
                      child: Column(
                        children: TaskPriority.values.map((priority) {
                          return _buildCheckboxTile(
                            title: priority.displayName,
                            value: _priorityFilters.contains(priority),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _priorityFilters.add(priority);
                                } else {
                                  _priorityFilters.remove(priority);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Category Filter
                    _buildSection(
                      title: 'Category',
                      child: Column(
                        children: TaskCategory.values.map((category) {
                          return _buildCheckboxTile(
                            title: category.displayName,
                            value: _categoryFilters.contains(category),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _categoryFilters.add(category);
                                } else {
                                  _categoryFilters.remove(category);
                                }
                              });
                            },
                            leading: Container(
                              width: 12.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _statusFilter = TaskFilter.all;
                        _priorityFilters.clear();
                        _categoryFilters.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium.r),
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final filterCriteria = TaskFilterCriteria(
                        statusFilter: _statusFilter,
                        priorityFilters: _priorityFilters,
                        categoryFilters: _categoryFilters,
                      );
                      Navigator.of(context).pop(filterCriteria);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium.r),
                      ),
                    ),
                    child: Text(
                      'Apply Filter',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        child: Row(
          children: [
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    Widget? leading,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
            SizedBox(width: 8.w),
            if (leading != null) ...[
              leading,
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
