// App Store / Play Store screenshot generator.
//
// Renders the real app (router, shell, bottom tab bar) with the canned
// preview data at exact store pixel sizes and writes PNGs to
// `docs/appstore/screenshots/<device>/`.
//
// Run from `bijbelquiz_mobile/`:
//
//   flutter test test/tools/appstore_screenshots.dart --dart-define=PREVIEW=true
//
// The PREVIEW define is what makes the router boot straight to /home with no
// login. Quiz artwork is read from `../public/images/quizzes` and seeded into
// the image cache under the URL the app would fetch, so no network is used.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bijbelquiz_mobile/core/config/app_config.dart';
import 'package:bijbelquiz_mobile/core/config/preview_config.dart';
import 'package:bijbelquiz_mobile/core/preview/preview_data.dart';
import 'package:bijbelquiz_mobile/features/profile/data/profile_model.dart';
import 'package:bijbelquiz_mobile/features/profile/present/profile_provider.dart';
import 'package:bijbelquiz_mobile/core/router/app_router.dart';
import 'package:bijbelquiz_mobile/core/theme/app_theme.dart';
import 'package:bijbelquiz_mobile/main.dart';

/// A store screenshot target: logical canvas size plus the pixel ratio that
/// turns it into the exact pixel size App Store Connect expects.
class Device {
  const Device({
    required this.folder,
    required this.logical,
    required this.pixelRatio,
    required this.topInset,
    required this.bottomInset,
    required this.statusBarHeight,
  });

  final String folder;
  final Size logical;
  final double pixelRatio;
  final double topInset;
  final double bottomInset;
  final double statusBarHeight;

  Size get pixels => Size(
    logical.width * pixelRatio,
    logical.height * pixelRatio,
  );
}

/// iPhone 11 Pro Max / 6.5" - 1242 x 2688. This is the size App Store Connect
/// accepts for this app record's iPhone slot (it also takes 1284 x 2778).
const iphone65 = Device(
  folder: 'iphone-6.5',
  logical: Size(414, 896),
  pixelRatio: 3.0,
  topInset: 44,
  bottomInset: 34,
  statusBarHeight: 44,
);

/// iPhone 12/13 Pro Max - 1284 x 2778, the other size the same slot accepts.
const iphone65Alt = Device(
  folder: 'iphone-6.5-alt-1284x2778',
  logical: Size(428, 926),
  pixelRatio: 3.0,
  topInset: 47,
  bottomInset: 34,
  statusBarHeight: 47,
);

/// iPhone 16 Pro Max / 6.9" - 1290 x 2796. Only usable on app records that
/// expose the newer 6.9" slot.
const iphone69 = Device(
  folder: 'iphone-6.9',
  logical: Size(430, 932),
  pixelRatio: 3.0,
  topInset: 59,
  bottomInset: 34,
  statusBarHeight: 59,
);

/// iPad Pro 13" - 2064 x 2752. Required because the target device family is
/// "1,2" (iPhone + iPad).
const ipad13 = Device(
  folder: 'ipad-13',
  logical: Size(1032, 1376),
  pixelRatio: 2.0,
  topInset: 24,
  bottomInset: 20,
  statusBarHeight: 24,
);

final outputRoot = Directory('../docs/appstore/screenshots');

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadAppFonts();
    _stubPlugins();
    // Same host the app uses in preview mode, so the seeded cache keys match
    // the URLs ServerImage builds.
    AppConfig.setCustomApiBaseUrl('https://www.bijbelquiz.com/api/mobile');

    if (!PreviewConfig.enabled) {
      fail(
        'Run with --dart-define=PREVIEW=true, otherwise the app boots into '
        'the splash/login flow instead of the dashboard.',
      );
    }
  });

  for (final device in [iphone65, iphone65Alt, iphone69, ipad13]) {
    group(device.folder, () {
      testWidgets('01 home', (tester) async {
        final app = await _boot(tester, device);
        await _shoot(tester, device, '01-home');
        app.dispose();
      });

      testWidgets('02 library', (tester) async {
        final app = await _boot(tester, device);
        await app.go(tester, '/quizzes');
        await _shoot(tester, device, '02-quizzen');
        app.dispose();
      });

      testWidgets('03 quiz detail', (tester) async {
        final app = await _boot(tester, device);
        await app.go(tester, '/quiz/genesis');
        await _shoot(tester, device, '03-quiz-detail');
        app.dispose();
      });

      testWidgets('04 quiz player', (tester) async {
        final app = await _boot(tester, device);
        await app.go(tester, '/quiz/genesis/play');
        await _shoot(tester, device, '04-quiz-vraag');
        app.dispose();
      });

      testWidgets('05 quiz player answered', (tester) async {
        // Premium profile, otherwise the explanation card is blurred behind an
        // upgrade prompt - a poor shot for the store listing.
        final app = await _boot(tester, device, premium: true);
        await app.go(tester, '/quiz/genesis/play');

        final answer = find.text('Mozes');
        if (answer.evaluate().isNotEmpty) {
          await tester.tap(answer.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
        }
        await _settle(tester);
        await _shoot(tester, device, '05-quiz-uitleg');
        app.dispose();
      });

      testWidgets('06 leaderboard', (tester) async {
        final app = await _boot(tester, device);
        await app.go(tester, '/leaderboard');
        await _shoot(tester, device, '06-ranglijst');
        app.dispose();
      });

      testWidgets('07 profile', (tester) async {
        final app = await _boot(tester, device);
        await app.go(tester, '/profile');
        await _shoot(tester, device, '07-profiel');
        app.dispose();
      });

      testWidgets('08 achievements', (tester) async {
        final app = await _boot(tester, device);
        await app.go(tester, '/profile/achievements');
        await _shoot(tester, device, '08-badges');
        app.dispose();
      });
    });
  }
}

/// Handle to a booted app: keeps the container so the test can drive the
/// router the same way a tap on the tab bar would.
class _BootedApp {
  _BootedApp(this.container);

  final ProviderContainer container;

  Future<void> go(WidgetTester tester, String location) async {
    container.read(routerProvider).go(location);
    await _settle(tester);
  }

  void dispose() {}
}

final _captureKey = GlobalKey();

/// The canned preview profile with premium switched on.
final _premiumProfile = ProfileModel(
  id: PreviewData.profile.id,
  name: PreviewData.profile.name,
  email: PreviewData.profile.email,
  xp: PreviewData.profile.xp,
  level: PreviewData.profile.level,
  levelTitle: PreviewData.profile.levelTitle,
  levelProgress: PreviewData.profile.levelProgress,
  nextLevelXp: PreviewData.profile.nextLevelXp,
  isPremium: true,
  streak: PreviewData.profile.streak,
  bestStreak: PreviewData.profile.bestStreak,
  badges: PreviewData.profile.badges,
  quizzesPlayed: PreviewData.profile.quizzesPlayed,
  averageScore: PreviewData.profile.averageScore,
  recentProgress: PreviewData.profile.recentProgress,
);

Future<_BootedApp> _boot(
  WidgetTester tester,
  Device device, {
  bool premium = false,
}) async {
  tester.view.physicalSize = device.pixels;
  tester.view.devicePixelRatio = device.pixelRatio;
  tester.view.padding = FakeViewPadding(
    top: device.topInset * device.pixelRatio,
    bottom: device.bottomInset * device.pixelRatio,
  );
  tester.view.viewPadding = FakeViewPadding(
    top: device.topInset * device.pixelRatio,
    bottom: device.bottomInset * device.pixelRatio,
  );
  addTearDown(tester.view.reset);

  await _seedQuizImages(tester);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Positioned.fill(
              child: UncontrolledProviderScope(
                container: container,
                child: PreviewData.scope(
                  ProviderScope(
                    overrides: premium
                        ? [
                            profileProvider.overrideWith(
                              (ref) async => _premiumProfile,
                            ),
                          ]
                        : const [],
                    child: const BijbelquizApp(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(child: _StatusBar(device: device)),
            ),
          ],
        ),
      ),
    ),
  );
  await _settle(tester);
  return _BootedApp(container);
}

/// Pumps through animations without hanging on the repeating ones (shimmers,
/// progress rings) that would make `pumpAndSettle` time out.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _shoot(WidgetTester tester, Device device, String name) async {
  final error = tester.takeException();
  if (error != null) {
    // ignore: avoid_print
    print('WARN [$name]: $error');
  }

  final boundary =
      _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

  late Uint8List bytes;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: device.pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    bytes = data!.buffer.asUint8List();
    image.dispose();
  });

  final dir = Directory('${outputRoot.path}/${device.folder}');
  dir.createSync(recursive: true);
  final file = File('${dir.path}/$name.png');
  file.writeAsBytesSync(bytes);

  // ignore: avoid_print
  print(
    'wrote ${file.path} '
    '(${device.pixels.width.toInt()}x${device.pixels.height.toInt()})',
  );
}

/// Loads the real fonts. Without this the test engine substitutes a
/// placeholder face and every string renders as boxes of the wrong width.
Future<void> _loadAppFonts() async {
  const families = {
    'Inter': [
      'assets/fonts/Inter-Regular.ttf',
      'assets/fonts/Inter-Medium.ttf',
      'assets/fonts/Inter-SemiBold.ttf',
      'assets/fonts/Inter-Bold.ttf',
    ],
    'Newsreader': [
      'assets/fonts/Newsreader-Regular.ttf',
      'assets/fonts/Newsreader-Medium.ttf',
      'assets/fonts/Newsreader-SemiBold.ttf',
    ],
  };

  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      final bytes = await File(path).readAsBytes();
      loader.addFont(
        Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)),
      );
    }
    await loader.load();
  }

  // The test engine ships no icon font, so every Icon would render as an empty
  // box. Pull the real one out of the Flutter SDK cache next to the dart
  // executable that is running this test.
  const relative =
      'bin/cache/artifacts/material_fonts/materialicons-regular.otf';
  var probe = Directory(Platform.resolvedExecutable).parent;
  File sdkFont = File('${probe.path}/$relative');
  for (var i = 0; i < 8 && !sdkFont.existsSync(); i++) {
    probe = probe.parent;
    sdkFont = File('${probe.path}/$relative');
  }
  if (sdkFont.existsSync()) {
    final loader = FontLoader('MaterialIcons');
    loader.addFont(
      Future.value(ByteData.view(sdkFont.readAsBytesSync().buffer)),
    );
    await loader.load();
  } else {
    // ignore: avoid_print
    print('WARN: MaterialIcons font not found at ${sdkFont.path}');
  }
}

/// Answers the plugin channels the app touches at startup, so the screens do
/// not blow up on MissingPluginException inside the test engine.
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
      if (call.method == 'getAll' || call.method == 'readAll') return <String, Object?>{};
      return null;
    });
  }
}

/// Puts the local `public/images/quizzes/*.png` files into the image cache
/// under the network URL the app resolves them to, so `Image.network` hits the
/// cache instead of the test binding's 1x1 transparent stub.
Future<void> _seedQuizImages(WidgetTester tester) async {
  final source = Directory('../public/images/quizzes');
  if (!source.existsSync()) {
    // ignore: avoid_print
    print('WARN: ${source.path} not found - quiz art will be blank.');
    return;
  }

  await tester.runAsync(() async {
    for (final file in source.listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      if (!name.toLowerCase().endsWith('.png')) continue;

      final url = '${AppConfig.baseUrl}/images/quizzes/$name';
      final bytes = await file.readAsBytes();
      final provider = MemoryImage(bytes);
      final completer = provider.loadImage(
        provider,
        PaintingBinding.instance.instantiateImageCodecWithSize,
      );

      PaintingBinding.instance.imageCache.putIfAbsent(
        NetworkImage(url),
        () => completer,
      );

      final done = Completer<void>();
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (_, _) {
          if (!done.isCompleted) done.complete();
        },
        onError: (_, _) {
          if (!done.isCompleted) done.complete();
        },
      );
      completer.addListener(listener);
      await done.future;
      completer.removeListener(listener);
    }
  });
}

/// Fake iOS status bar, so the shots read as real device captures.
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: AppTheme.sansFontName,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppTheme.ink,
      height: 1.0,
    );

    return SizedBox(
      height: device.statusBarHeight,
      child: Padding(
        padding: EdgeInsets.only(
          left: 34,
          right: 28,
          bottom: device.statusBarHeight > 30 ? 12 : 4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('9:41', style: style),
            const Spacer(),
            const Icon(Icons.signal_cellular_alt, size: 17, color: AppTheme.ink),
            const SizedBox(width: 6),
            const Icon(Icons.wifi, size: 17, color: AppTheme.ink),
            const SizedBox(width: 6),
            Transform.rotate(
              angle: 1.5708,
              child: const Icon(
                Icons.battery_full,
                size: 20,
                color: AppTheme.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
