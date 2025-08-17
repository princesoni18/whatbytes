import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whatbytes_assignment/features/intro/ui/bottom_circle.dart';
import 'package:whatbytes_assignment/shared/widgets/check_icon.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';


class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child:  Stack(
            alignment: Alignment.center,
            children: [

             Padding(
          padding: EdgeInsets.all(AppConstants.screenPadding.w),
          child: Column(
                children: [
                  // Main content area
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Illustration placeholder (you can add an image here)
                        Container(
                          height: 300.h,
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 60.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                          ),
                          alignment: Alignment.center,
                          child: const CheckmarkIcon()
                        ),
              
                        // Title
                        Text(
                          'Get things done.',
                          style: AppTheme.headingLarge.copyWith(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Subtitle
                        Text(
                          'Just a click away from planning your tasks.',
                          style: AppTheme.bodyLarge.copyWith(
                            fontSize: 18.sp,
                            color: AppTheme.textSecondaryColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              
                  // Get Started Button
                 
                ],
              ),),
         
        
             const  Positioned(
                bottom: 0,
                right: 0,
                child: BottomRightQuarterCircle())

             
            ],
          ),
        
      ),
    );
  }
}
