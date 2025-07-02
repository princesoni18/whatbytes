import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class TaskHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onSearchPressed;
  final VoidCallback onMorePressed;

  const TaskHeader({
    super.key,
    required this.onMenuPressed,
    required this.onSearchPressed,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.screenPadding.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
            children: [
              // Menu Button
              IconButton(
                onPressed: onMenuPressed,
                icon: Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: AppConstants.iconSizeLarge,
                ),
              ),
              
              // Search Bar
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: AppConstants.iconSizeMedium,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Search tasks...',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // More Options Button
              IconButton(
                onPressed: onMorePressed,
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                  size: AppConstants.iconSizeLarge,
                ),
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
