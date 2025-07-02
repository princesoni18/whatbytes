import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whatbytes_assignment/core/theme/app_theme.dart';
import 'package:whatbytes_assignment/features/tasks/ui/tasks_screen.dart';

void main() {
  group('TasksScreen Tests', () {
    Widget createTasksScreen() {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            home: const TasksScreen(),
          );
        },
      );
    }

    testWidgets('TasksScreen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTasksScreen());
      
      // Verify that the screen title is displayed
      expect(find.text('My tasks'), findsOneWidget);
      
      // Verify that the date is displayed
      expect(find.textContaining('Today,'), findsOneWidget);
    });

    testWidgets('TasksScreen displays task sections', (WidgetTester tester) async {
      await tester.pumpWidget(createTasksScreen());
      
      // Wait for the widget to settle
      await tester.pumpAndSettle();
      
      // Verify that task sections are displayed
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('TasksScreen displays FAB', (WidgetTester tester) async {
      await tester.pumpWidget(createTasksScreen());
      
      // Verify that the FAB is displayed
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('TasksScreen displays bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTasksScreen());
      
      // Verify that bottom navigation is displayed
      expect(find.byIcon(Icons.menu_rounded), findsWidgets);
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
    });
  });
}
