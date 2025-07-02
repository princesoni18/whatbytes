import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whatbytes_assignment/shared/widgets/check_icon.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/social_login_button.dart';
import '../widgets/auth_header.dart';
import '../simple_auth_bloc.dart';
import '../auth_service.dart';
import 'signup_screen.dart';
import '../../tasks/ui/tasks_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill email field with default value
    _emailController.text = AppConstants.defaultEmail;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    return AuthService.validateEmail(value);
  }

  String? _validatePassword(String? value) {
    return AuthService.validatePassword(value);
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _handleSocialLogin(String provider) {
    // Handle social login logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider login not implemented yet')),
    );
  }

  void _showEmailDropdown() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(AppConstants.screenPadding.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Email',
                style: AppTheme.headingMedium,
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: const Icon(Icons.email, color: AppTheme.primaryColor),
                title: const Text(AppConstants.defaultEmail),
                onTap: () {
                  _emailController.text = AppConstants.defaultEmail;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: AppTheme.primaryColor),
                title: const Text('user@example.com'),
                onTap: () {
                  _emailController.text = 'user@example.com';
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const TasksScreen(),
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppConstants.screenPadding.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    SizedBox(height: 20.h,),
                  Center(
                    child: CheckmarkIcon(
                      size: 95.h,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  // Header
                  const AuthHeader(
                    title: "Welcome back!",
                   ),
                  
                  SizedBox(height: 40.h),

                  // Email Dropdown Field
                  GestureDetector(
                    onTap: _showEmailDropdown,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        label: 'Email',
                        controller: _emailController,
                        validator: _validateEmail,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppTheme.textSecondaryColor,
                        ),
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20.h),

                  // Password Field
                  CustomTextField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    obscureText: true,
                    validator: _validatePassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  
                  SizedBox(height: 10.h),

                  // Forgot Password Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Handle forgot password
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Forgot password not implemented yet')),
                          );
                        },
                        child: Text(
                          'Forgot password?',
                          style: AppTheme.linkText,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 32.h),

                  // Login Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Login',
                        onPressed: state is AuthLoading ? null : _handleLogin,
                        isLoading: state is AuthLoading,
                        width: double.infinity,
                      );
                    },
                  ),
                  
                  SizedBox(height: 24.h),

                 

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.borderColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'or',
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.borderColor,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                     SocialLoginButton(
                    provider: AppConstants.googleProvider,
                    onPressed: () => _handleSocialLogin('Google'),
                  ),
                  
                  SocialLoginButton(
                    provider: AppConstants.facebookProvider,
                    onPressed: () => _handleSocialLogin('Facebook'),
                  ),
                  
                  SocialLoginButton(
                    provider: AppConstants.appleProvider,
                    onPressed: () => _handleSocialLogin('Apple'),
                  ),

                  ],
                 ),
                   SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Get started!',
                          style: AppTheme.linkText,
                        ),
                      ),
                    ],
                  ),
                  // Social Login Buttons
                 
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
