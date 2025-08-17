import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class TaskHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;

  final VoidCallback onFilterPressed;
  final bool hasActiveFilters;

  const TaskHeader({
    super.key,
    required this.onMenuPressed,
   
    required this.onFilterPressed,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.screenPadding.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppConstants.borderRadiusLarge.r),
          bottomRight: Radius.circular(AppConstants.borderRadiusLarge.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          
          // Top Row - Menu, Search, More
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Menu Button
              IconButton(
                onPressed: onMenuPressed,
                icon:const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: AppConstants.iconSizeLarge,
                ),
              ),
              
             
              // Filter Button
              Stack(
                children: [
                  IconButton(
                    onPressed: onFilterPressed,
                    icon: const Icon(
                      Icons.filter_list_rounded,
                      color: Colors.white,
                      size: AppConstants.iconSizeLarge,
                    ),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // Date and Title
          Text(
            _getFormattedDate(),
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
          
          SizedBox(height: 4.h),
          
          Text(
            'My tasks',
            style: AppTheme.headingLarge.copyWith(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return 'Today, ${now.day} ${months[now.month - 1]}';
  }
}
