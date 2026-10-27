// Paywall screenshot for App Store Connect (the "Review Information" image
// every in-app purchase needs). Renders the real paywall with the store
// prices a buyer would see, at the iPhone 6.5" size (1242 x 2688), to
// `../docs/appstore/screenshots/paywall/`.
//
//   flutter test test/tools/paywall_screenshot.dart --dart-define=PREVIEW=true
//
// The prices are the ones set in the stores (EUR 39,99 / 5,99 / 74,99); the
// store itself is replaced by a fake, so nothing is bought and no network is
// used.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:bijbelquiz_mobile/core/config/app_config.dart';
import 'package:bijbelquiz_mobile/core/config/preview_config.dart';
import 'package:bijbelquiz_mobile/core/preview/preview_data.dart';
import 'package:bijbelquiz_mobile/core/router/app_router.dart';
import 'package:bijbelquiz_mobile/features/premium/data/premium_server.dart';
import 'package:bijbelquiz_mobile/features/premium/data/purchase_service.dart';
import 'package:bijbelquiz_mobile/main.dart';

class _Store implements PurchasesGateway {
  @override
  Future<List<PlanOffer>> loadOffers() async => [
    PlanOffer(
      plan: PremiumPlan.yearly,
      productId: PremiumPlan.yearly.productId,
      priceString: '€39,99',
      trial: const TrialOffer(periodUnit: PeriodUnit.day, periodCount: 7),
    ),
    PlanOffer(
      plan: PremiumPlan.monthly,
      productId: PremiumPlan.monthly.productId,
      priceString: '€5,99',
    ),
    PlanOffer(
      plan: PremiumPlan.lifetime,
      productId: PremiumPlan.lifetime.productId,
      priceString: '€74,99',
    ),
  ];

  @override
  Future<StoreCustomer> customer() async => StoreCustomer.none;

  @override
  Future<StoreCustomer> purchase(PlanOffer offer) async => StoreCustomer.none;

  @override
  Future<StoreCustomer> purchasePlan(PremiumPlan plan) async =>
      StoreCustomer.none;

  @override
  Future<StoreCustomer> restore() async => StoreCustomer.none;

  @override
  Future<StoreCustomer> logIn(String userId) async => StoreCustomer.none;

  @override
  Future<StoreCustomer> logOut() async => StoreCustomer.none;

  @override
  VoidCallback listen(void Function(StoreCustomer customer) onChange) =>
      () {};
}

class _Server implements PremiumServer {
  @override
  Future<ServerPremium?> sync() async =>
      const ServerPremium(isPremium: false);
}

final _captureKey = GlobalKey();

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
    _stubPlugins();
    AppConfig.setCustomApiBaseUrl('https://www.bijbelquiz.com/api/mobile');
    if (!PreviewConfig.enabled) {
      fail('Run with --dart-define=PREVIEW=true');
    }
  });

  for (final shot in const [
    ('paywall', '/premium'),
    ('paywall-gratis-limiet', '/premium?reden=gratis-limiet'),
  ]) {
    testWidgets(shot.$1, (tester) async {
      // A buyer on an iPhone sees App Store wording, not Google Play.
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      const pixelRatio = 3.0;
      tester.view.physicalSize = const Size(414 * pixelRatio, 896 * pixelRatio);
      tester.view.devicePixelRatio = pixelRatio;
      tester.view.padding = const FakeViewPadding(
        top: 44 * pixelRatio,
        bottom: 34 * pixelRatio,
      );
      tester.view.viewPadding = const FakeViewPadding(
        top: 44 * pixelRatio,
        bottom: 34 * pixelRatio,
      );
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          purchasesGatewayProvider.overrideWithValue(_Store()),
          premiumServerProvider.overrideWithValue(_Server()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        RepaintBoundary(
          key: _captureKey,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: UncontrolledProviderScope(
              container: container,
              child: PreviewData.scope(
                const ProviderScope(child: BijbelquizApp()),
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
      container.read(routerProvider).go(shot.$2);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }

      final boundary =
          _captureKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      late Uint8List bytes;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        bytes = data!.buffer.asUint8List();
        image.dispose();
      });
      final dir = Directory('../docs/appstore/screenshots/paywall')
        ..createSync(recursive: true);
      File('${dir.path}/${shot.$1}.png').writeAsBytesSync(bytes);
      // ignore: avoid_print
      print('wrote ${dir.path}/${shot.$1}.png (1242x2688)');

      // Let the app's own timers run out before the test ends.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(minutes: 2));
      debugDefaultTargetPlatformOverride = null;
    });
  }
}

Future<void> _loadFonts() async {
  const families = {
    'Fredoka': [
      'assets/fonts/Fredoka-400.ttf',
      'assets/fonts/Fredoka-500.ttf',
      'assets/fonts/Fredoka-600.ttf',
      'assets/fonts/Fredoka-700.ttf',
    ],
    'Nunito': [
      'assets/fonts/Nunito-400.ttf',
      'assets/fonts/Nunito-500.ttf',
      'assets/fonts/Nunito-600.ttf',
      'assets/fonts/Nunito-700.ttf',
      'assets/fonts/Nunito-800.ttf',
      'assets/fonts/Nunito-900.ttf',
    ],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      loader.addFont(
        Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
      );
    }
    await loader.load();
  }

  // The test engine ships no icon font; take it from the Flutter SDK cache.
  const relative =
      'bin/cache/artifacts/material_fonts/materialicons-regular.otf';
  var probe = Directory(Platform.resolvedExecutable).parent;
  var sdkFont = File('${probe.path}/$relative');
  for (var i = 0; i < 8 && !sdkFont.existsSync(); i++) {
    probe = probe.parent;
    sdkFont = File('${probe.path}/$relative');
  }
  if (sdkFont.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(sdkFont.readAsBytesSync())));
    await loader.load();
  }
}

/// Answers the plugin channels the app touches at startup.
void _stubPlugins() {
  const channels = [
    'plugins.it_nomads.com/flutter_secure_storage',
    'plugins.flutter.io/shared_preferences',
    'plugins.flutter.io/url_launcher',
  ];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final name in channels) {
    messenger.setMockMethodCallHandler(MethodChannel(name), (call) async {
      if (call.method == 'getAll' || call.method == 'readAll') {
        return <String, Object?>{};
      }
      return null;
    });
  }
}
