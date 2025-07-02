import 'package:flutter/material.dart';
import '../../features/intro/ui/intro_screen.dart';
import '../../features/auth/ui/signup_screen.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/tasks/ui/tasks_screen.dart';

class AppNavigator {
  static const String intro = '/';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String tasks = '/tasks';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case intro:
        return MaterialPageRoute(
          builder: (_) => const IntroScreen(),
          settings: settings,
        );
      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case tasks:
        return MaterialPageRoute(
          builder: (_) => const TasksScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
          settings: settings,
        );
    }
  }

  // Helper methods for navigation
  static void pushToSignup(BuildContext context) {
    Navigator.pushNamed(context, signup);
  }

  static void pushToLogin(BuildContext context) {
    Navigator.pushNamed(context, login);
  }

  static void pushToTasks(BuildContext context) {
    Navigator.pushReplacementNamed(context, tasks);
  }

  static void pushToIntro(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, intro, (route) => false);
  }
}
