import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whatbytes_assignment/shared/widgets/check_icon.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

import '../widgets/auth_header.dart';
import '../simple_auth_bloc.dart';
import '../auth_service.dart';
import 'login_screen.dart';
import '../../tasks/ui/tasks_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    return AuthService.validateName(value);
  }

  String? _validateEmail(String? value) {
    return AuthService.validateEmail(value);
  }

  String? _validatePassword(String? value) {
    return AuthService.validatePassword(value);
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              displayName: _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
                  : null,
            ),
          );
    }
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  SizedBox(
                    height: 20.h,
                  ),
                  Center(
                    child: CheckmarkIcon(
                      size: 95.h,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  const AuthHeader(
                    title: "Let's get started!",
                  ),

                  SizedBox(height: 40.h),

                  // Name Field
                  CustomTextField(
                    label: 'Full Name',
                    hintText: 'Enter your full name',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    validator: _validateName,
                    prefixIcon: const Icon(
                      Icons.person_outlined,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Email Field
                  CustomTextField(
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppTheme.textSecondaryColor,
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

                  SizedBox(height: 32.h),

                  // Sign Up Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Sign up',
                        onPressed: state is AuthLoading ? null : _handleSignUp,
                        isLoading: state is AuthLoading,
                        width: double.infinity,
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Log in',
                          style: AppTheme.linkText,
                        ),
                      ),
                    ],
                  ),

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
