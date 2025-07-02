import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whatbytes_assignment/core/theme/app_theme.dart';
import 'package:whatbytes_assignment/features/intro/ui/intro_screen.dart';

void main() {
  group('IntroScreen Tests', () {
    Widget createIntroScreen() {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            home: const IntroScreen(),
          );
        },
      );
    }

    testWidgets('IntroScreen displays title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(createIntroScreen());
      
      // Verify that the title is displayed
      expect(find.text('Get things done.'), findsOneWidget);
      
      // Verify that the subtitle is displayed
      expect(find.text('Just a click away from planning your tasks.'), findsOneWidget);
    });

    testWidgets('IntroScreen displays next button', (WidgetTester tester) async {
      await tester.pumpWidget(createIntroScreen());
      
      // Verify that the arrow icon (next button) is displayed
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('IntroScreen navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(createIntroScreen());
      
      // Find and tap the next button
      final nextButton = find.byIcon(Icons.arrow_forward_rounded);
      expect(nextButton, findsOneWidget);
      
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
      
      // Verify navigation to SignUpScreen
      expect(find.text("Let's get started!"), findsOneWidget);
    });
  });
}
