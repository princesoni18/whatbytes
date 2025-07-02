import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/injection/injection_container.dart' as di;
import 'features/tasks/bloc/task_bloc.dart';
import 'features/auth/simple_auth_bloc.dart';
import 'features/tasks/ui/tasks_screen.dart';
import 'features/intro/ui/intro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
    
    // Initialize dependencies
    await di.init();
    print('Dependencies initialized successfully');
    
    runApp(const MyApp());
  } catch (e) {
    print('Error during initialization: $e');
    
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), 
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => di.sl<AuthBloc>()..add(AuthCheckRequested())),
            BlocProvider(create: (context) => di.sl<TaskBloc>()),
          ],
          child: MaterialApp(
            title: 'Task Planner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const AuthWrapper(),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // User is logged in, load tasks
          context.read<TaskBloc>().add(LoadTasks());
          return const TasksScreen();
        } else if (state is AuthUnauthenticated) {
          // User is not logged in, show intro screen
          return const IntroScreen();
        } else {
          // Loading state
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

