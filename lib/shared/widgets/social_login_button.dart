import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class SocialLoginButton extends StatelessWidget {
  final String provider;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      
      radius: 36.sp,
      
      child:  _buildIcon(),
      
    );
  }

  Widget _buildIcon() {
    switch (provider.toLowerCase()) {
      case AppConstants.googleProvider:
        return FaIcon(
          FontAwesomeIcons.google,
          color: AppTheme.googleColor,
          size: AppConstants.iconSizeMedium,
        );
      case AppConstants.facebookProvider:
        return FaIcon(
          FontAwesomeIcons.facebookF,
          color: AppTheme.facebookColor,
          size: AppConstants.iconSizeMedium,
        );
      case AppConstants.appleProvider:
        return FaIcon(
          FontAwesomeIcons.apple,
          color: AppTheme.appleColor,
          size: AppConstants.iconSizeMedium,
        );
      default:
        return Icon(
          Icons.login,
          color: AppTheme.textSecondaryColor,
          size: AppConstants.iconSizeMedium,
        );
    }
  }

  String _getButtonText() {
    switch (provider.toLowerCase()) {
      case AppConstants.googleProvider:
        return 'Continue with Google';
      case AppConstants.facebookProvider:
        return 'Continue with Facebook';
      case AppConstants.appleProvider:
        return 'Continue with Apple';
      default:
        return 'Continue with $provider';
    }
  }
}
