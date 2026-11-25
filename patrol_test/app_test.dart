import 'package:basic_modern_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'full user journey – fast human speed',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      // Launch app
      await $.pumpWidgetAndSettle(const MyApp());
      await Future.delayed(const Duration(milliseconds: 600));

      // Verify header
      expect($('Welcome back'), findsOneWidget);
      expect($('Modern Flutter App'), findsOneWidget);
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify initial counter
      expect($('Counter'), findsOneWidget);
      expect($('0'), findsOneWidget);
      await Future.delayed(const Duration(milliseconds: 500));

      // Increment 3 times
      await $('Increment').tap();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 450));
      expect($('1'), findsOneWidget);

      await $('Increment').tap();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 450));
      expect($('2'), findsOneWidget);

      await $('Increment').tap();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 450));
      expect($('3'), findsOneWidget);

      // Reset
      await $('Reset').tap();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));
      expect($('0'), findsOneWidget);

      // Quick Actions cards
      await $('Explore').tap();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      await $('Favorites').tap();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      await $('Settings').tap();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      await $('About')
          .scrollTo()
          .tap(); // MODIFIED: was $('About').tap() - scroll into view first
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      // Bottom navigation
      await $('Search').tap();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      await $('Profile').tap();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      await $('Home').tap();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      // FAB
      await $(find.byType(FloatingActionButton)).tap();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));
      expect($('1'), findsOneWidget);

      // Final pause so the last state is clearly visible
      await Future.delayed(const Duration(milliseconds: 800));
    },
  );
}
