import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crypto_app/core/theme/app_theme.dart';
import 'package:crypto_app/widgets/glass_floating_nav_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget({
    required int currentIndex,
    required ValueChanged<int> onTap,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return MaterialApp(
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Scaffold(
        bottomNavigationBar: GlassFloatingNavBar(
          currentIndex: currentIndex,
          onTap: onTap,
        ),
      ),
    );
  }

  group('GlassFloatingNavBar Tests', () {
    testWidgets('1. Renders all 3 destinations: Markets, Statistics, Watchlist',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          currentIndex: 0,
          onTap: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Markets'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Watchlist'), findsOneWidget);
    });

    testWidgets('2. Tapping Statistics triggers onTap with index 1',
        (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        buildTestWidget(
          currentIndex: 0,
          onTap: (index) => tappedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Statistics'));
      await tester.pumpAndSettle();

      expect(tappedIndex, equals(1));
    });

    testWidgets('3. Tapping Watchlist triggers onTap with index 2',
        (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        buildTestWidget(
          currentIndex: 0,
          onTap: (index) => tappedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Watchlist'));
      await tester.pumpAndSettle();

      expect(tappedIndex, equals(2));
    });

    testWidgets('4. Light and Dark themes render without error',
        (tester) async {
      // Light theme
      await tester.pumpWidget(
        buildTestWidget(
          currentIndex: 0,
          onTap: (_) {},
          themeMode: ThemeMode.light,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassFloatingNavBar), findsOneWidget);

      // Dark theme
      await tester.pumpWidget(
        buildTestWidget(
          currentIndex: 1,
          onTap: (_) {},
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassFloatingNavBar), findsOneWidget);
    });
  });
}
