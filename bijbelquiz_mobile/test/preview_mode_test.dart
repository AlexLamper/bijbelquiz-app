import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bijbelquiz_mobile/core/config/preview_config.dart';
import 'package:bijbelquiz_mobile/core/preview/preview_data.dart';
import 'package:bijbelquiz_mobile/core/theme/app_theme.dart';
import 'package:bijbelquiz_mobile/features/dashboard/present/home_screen.dart';
import 'package:bijbelquiz_mobile/features/leaderboard/present/leaderboard_screen.dart';

void main() {
  test('preview mode is off unless the dart-define is passed', () {
    // The suite runs without --dart-define=PREVIEW=true, so this must be false.
    // Together with the kReleaseMode guard this keeps canned data out of
    // anything shipped to a store.
    expect(PreviewConfig.enabled, isFalse);
  });

  testWidgets('preview scope serves canned data to the dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      PreviewData.scope(
        MaterialApp(theme: AppTheme.lightTheme, home: const HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    // Name comes from the canned profile.
    expect(find.textContaining('Testspeler'), findsWidgets);

    // Quiz titles sit further down the page, so scroll before asserting.
    for (var i = 0; i < 8; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await tester.pump();
    }
    expect(tester.takeException(), isNull);
    expect(find.text('Genesis'), findsWidgets);
  });

  testWidgets('preview scope serves canned data to the leaderboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      PreviewData.scope(
        MaterialApp(theme: AppTheme.lightTheme, home: const LeaderboardScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.text('Top spelers'), findsOneWidget);
  });
}
