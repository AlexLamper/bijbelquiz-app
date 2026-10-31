import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:bijbelquiz_mobile/core/theme/app_theme.dart';
import 'package:bijbelquiz_mobile/features/admin/data/admin_repository.dart';
import 'package:bijbelquiz_mobile/features/admin/present/admin_screen.dart';
import 'package:bijbelquiz_mobile/features/admin/present/admin_user_detail_screen.dart';
import 'package:bijbelquiz_mobile/features/admin/present/widgets/admin_ui.dart';
import 'package:bijbelquiz_mobile/features/profile/data/profile_model.dart';
import 'package:bijbelquiz_mobile/features/profile/present/profile_provider.dart';

import 'admin/admin_fakes.dart';
import 'screen_render_test.dart' show expectNoLayoutError, loadAppFonts;

/// Set with `--dart-define=ADMIN_SHOTS=/some/dir` to write a PNG per screen.
const String _shotsDir = String.fromEnvironment('ADMIN_SHOTS');

final _shotKey = GlobalKey();

ProfileModel _profile({required bool admin}) => ProfileModel(
  id: 'admin1',
  name: 'Beheerder',
  email: 'beheer@voorbeeld.nl',
  xp: 0,
  level: 1,
  levelTitle: 'Zoeker',
  levelProgress: 0,
  nextLevelXp: 100,
  isPremium: false,
  isAdmin: admin,
  streak: 0,
  bestStreak: 0,
  badges: const [],
  quizzesPlayed: 0,
  averageScore: 0,
  recentProgress: const [],
);

Widget _host(
  FakeAdminRepository repo, {
  String location = '/beheer',
  bool admin = true,
}) {
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(path: '/settings', builder: (_, _) => const Scaffold()),
      GoRoute(path: '/beheer', builder: (_, _) => const AdminScreen()),
      GoRoute(
        path: '/beheer/gebruikers/:id',
        builder: (_, state) =>
            AdminUserDetailScreen(userId: state.pathParameters['id']!),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      adminRepositoryProvider.overrideWithValue(repo),
      profileProvider.overrideWith((ref) async => _profile(admin: admin)),
    ],
    child: RepaintBoundary(
      key: _shotKey,
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    ),
  );
}

Future<void> _pumpPhone(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  await _settle(tester);
}

/// Pumps through the async loads without waiting on the skeleton pulse.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _scrollThrough(WidgetTester tester, {int steps = 14}) async {
  final scrollables = find.byType(Scrollable);
  // The page list is the last vertical scrollable on screen.
  Finder? list;
  for (final element in scrollables.evaluate().toList().reversed) {
    final s = element.widget as Scrollable;
    if (s.axisDirection == AxisDirection.down) {
      list = find.byWidget(s);
      break;
    }
  }
  if (list == null) return;
  for (var i = 0; i < steps; i++) {
    await tester.drag(list, const Offset(0, -500));
    await tester.pump();
    expectNoLayoutError(tester);
  }
}

Future<void> _shot(WidgetTester tester, String name) async {
  if (_shotsDir.isEmpty) return;
  final boundary =
      _shotKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory(_shotsDir).createSync(recursive: true);
    File('$_shotsDir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> _openSection(WidgetTester tester, String label) async {
  final chip = find.descendant(
    of: find.byType(AdminSegmentedControl),
    matching: find.text(label),
  );
  await tester.ensureVisible(chip);
  await tester.pump();
  await tester.tap(chip);
  await _settle(tester);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  testWidgets('overview renders every section', (tester) async {
    await _pumpPhone(tester, _host(FakeAdminRepository()));
    expectNoLayoutError(tester);

    expect(find.text('Beheer'), findsOneWidget);
    expect(find.text('Aangemeld via'), findsOneWidget);
    expect(find.text('Website (computer)'), findsWidgets);
    await _shot(tester, '01_overzicht');

    await _scrollThrough(tester, steps: 6);
    await _shot(tester, '02_overzicht_midden');
    await _scrollThrough(tester, steps: 6);
    await _shot(tester, '03_overzicht_premium');
    await _scrollThrough(tester, steps: 20);
    expect(find.text('Laatste betalingen'), findsOneWidget);
    // Proefperiodes sits above the user and payment lists.
    final pageList = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(
      find.text('Lennon Wederfoort'),
      -200,
      scrollable: pageList.last,
    );
    // A little further, so the section title above the first row shows too.
    await tester.drag(pageList.last, const Offset(0, 160));
    await tester.pump();
    expect(find.text('Proefperiodes'), findsOneWidget);
    expect(find.text('Opgezegd'), findsOneWidget);
    await _shot(tester, '03b_overzicht_proefperiodes');
  });

  testWidgets('users list with filters renders', (tester) async {
    await _pumpPhone(tester, _host(FakeAdminRepository()));
    await _openSection(tester, 'Gebruikers');
    expectNoLayoutError(tester);

    expect(find.text('Zoek op naam of e-mail'), findsOneWidget);
    expect(find.text('Platform: alle'), findsOneWidget);
    expect(find.text('13 gebruikers'), findsOneWidget);
    expect(find.text('Noor'), findsWidgets);
    await _shot(tester, '04_gebruikers');

    // The platform filter opens its choice sheet.
    await tester.tap(find.text('Platform: alle'));
    await _settle(tester);
    expect(find.text('Android-app'), findsOneWidget);
    await _shot(tester, '05_filter');
    await tester.tap(find.text('Android-app'));
    await _settle(tester);
    expect(find.text('Android-app'), findsOneWidget);
    expectNoLayoutError(tester);
  });

  testWidgets('quizzes, payments and funnel sections render', (tester) async {
    final repo = FakeAdminRepository();
    await _pumpPhone(tester, _host(repo));

    await _openSection(tester, 'Quizzen');
    expectNoLayoutError(tester);
    expect(find.text('Goedkeuren'), findsOneWidget);
    await _shot(tester, '06_quizzen');
    await tester.tap(find.text('Goedkeuren'));
    await _settle(tester);
    expect(repo.quizActions.single.$2, AdminQuizAction.approve);

    await tester.tap(find.text('Alle'));
    await _settle(tester);
    expectNoLayoutError(tester);
    await _scrollThrough(tester, steps: 8);

    await _openSection(tester, 'Betalingen');
    expectNoLayoutError(tester);
    expect(find.text('Er is iets kapot'), findsOneWidget);
    await _scrollThrough(tester, steps: 10);
    expect(find.text('Anna de Vries'), findsOneWidget);
    expect(find.text('Meer laden'), findsOneWidget);
    await _shot(tester, '07_betalingen');

    await _openSection(tester, 'Funnel');
    expectNoLayoutError(tester);
    expect(find.text('Paywall getoond'), findsOneWidget);
    await _shot(tester, '08_funnel');
    await _scrollThrough(tester, steps: 10);
  });

  testWidgets('user detail renders every block', (tester) async {
    await _pumpPhone(
      tester,
      _host(FakeAdminRepository(), location: '/beheer/gebruikers/u1'),
    );
    expectNoLayoutError(tester);
    expect(find.text('Sanne'), findsWidgets);
    expect(find.text('Premium actief'), findsOneWidget);
    await _shot(tester, '09_gebruiker');
    await _scrollThrough(tester, steps: 6);
    await _shot(tester, '10_gebruiker_account');
    await _scrollThrough(tester, steps: 14);
    expect(find.text('Geschiedenis Premium-giften'), findsOneWidget);
    expect(find.text('Ingetrokken'), findsOneWidget);
    await _shot(tester, '11_gebruiker_log');
  });

  testWidgets('grant flow: choose 3 maanden, confirm, success', (tester) async {
    final repo = FakeAdminRepository();
    await _pumpPhone(tester, _host(repo, location: '/beheer/gebruikers/u1'));

    final button = find.text('Premium geven');
    await tester.scrollUntilVisible(
      button,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(button);
    await _settle(tester);
    expectNoLayoutError(tester);
    expect(find.text('Hoe lang'), findsOneWidget);
    for (final d in [
      '7 dagen',
      '1 maand',
      '3 maanden',
      '1 jaar',
      'Levenslang',
    ]) {
      expect(find.text(d), findsOneWidget);
    }
    await _shot(tester, '12_geven_kiezen');

    await tester.tap(find.text('3 maanden'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, 'Prijs zomerquiz');
    await tester.tap(find.text('Verder'));
    await _settle(tester);
    expect(find.text('Klopt dit?'), findsOneWidget);
    expect(
      find.textContaining('(3 maanden)', findRichText: true),
      findsOneWidget,
    );
    await _shot(tester, '13_geven_bevestigen');

    await tester.tap(find.text('Bevestigen'));
    await _settle(tester);
    expectNoLayoutError(tester);

    expect(repo.grants, hasLength(1));
    expect(repo.grants.single.duration, AdminGrantDuration.months3);
    expect(repo.grants.single.note, 'Prijs zomerquiz');
    expect(find.text('Klopt dit?'), findsNothing);
    expect(find.text('Premium gegeven'), findsOneWidget);
    expect(find.textContaining('tot en met'), findsOneWidget);
    await _shot(tester, '14_geven_gelukt');
  });

  testWidgets('grant error stays in the sheet', (tester) async {
    final repo = FakeAdminRepository(
      grantError: const AdminApiException(
        400,
        'De einddatum moet in de toekomst liggen.',
        field: 'until',
      ),
    );
    await _pumpPhone(tester, _host(repo, location: '/beheer/gebruikers/u1'));
    final button = find.text('Premium geven');
    await tester.scrollUntilVisible(
      button,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(button);
    await _settle(tester);
    await tester.tap(find.text('7 dagen'));
    await tester.tap(find.text('Verder'));
    await _settle(tester);
    await tester.tap(find.text('Bevestigen'));
    await _settle(tester);
    expect(find.text('Klopt dit?'), findsOneWidget);
    expect(
      find.text('De einddatum moet in de toekomst liggen.'),
      findsOneWidget,
    );
  });

  testWidgets('revoke a manual grant', (tester) async {
    final repo = FakeAdminRepository();
    await _pumpPhone(
      tester,
      _host(repo, location: '/beheer/gebruikers/manual'),
    );
    final button = find.text('Premium intrekken');
    await tester.scrollUntilVisible(
      button,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Einddatum wijzigen'), findsOneWidget);
    await tester.tap(button);
    await _settle(tester);
    expect(find.text('Premium intrekken?'), findsOneWidget);
    await tester.tap(find.text('Intrekken'));
    await _settle(tester);
    expect(repo.revokes, hasLength(1));
    expect(find.text('Premium ingetrokken'), findsOneWidget);
    expectNoLayoutError(tester);
  });

  testWidgets('older server: overview falls back, lists ask for an update', (
    tester,
  ) async {
    final repo = FakeAdminRepository(
      missing: {'overview', 'users', 'quizzes', 'payments', 'health', 'funnel'},
    );
    await _pumpPhone(tester, _host(repo));
    expectNoLayoutError(tester);
    expect(find.text('Werk de server bij'), findsOneWidget);
    await _shot(tester, '15_oude_server');
    await tester.scrollUntilVisible(
      find.text('Premium per bron'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expectNoLayoutError(tester);

    await _openSection(tester, 'Gebruikers');
    expect(find.text('Werk de server bij'), findsWidgets);
    expect(find.text('Opnieuw proberen'), findsOneWidget);
    expectNoLayoutError(tester);

    await _openSection(tester, 'Betalingen');
    expect(find.text('Opnieuw proberen'), findsWidgets);
    expectNoLayoutError(tester);
  });

  testWidgets('non-admins see no data', (tester) async {
    final repo = FakeAdminRepository();
    await _pumpPhone(tester, _host(repo, admin: false));
    expect(find.text('Geen toegang'), findsOneWidget);
    expect(find.byType(AdminSegmentedControl), findsNothing);
  });

  testWidgets('back from a section returns to Overzicht first', (tester) async {
    await _pumpPhone(tester, _host(FakeAdminRepository()));
    await _openSection(tester, 'Funnel');
    expect(find.text('Paywall getoond'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Terug'));
    await _settle(tester);
    expect(find.text('Aangemeld via'), findsOneWidget);
  });
}
