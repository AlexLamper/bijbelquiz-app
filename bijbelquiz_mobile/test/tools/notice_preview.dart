// Renders the styled error notice once, to eyeball the styling.
//
//   flutter test test/tools/notice_preview.dart
//
// Writes `build/notice_preview.png` (a dev artifact, not a store asset).

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bijbelquiz_mobile/core/errors/app_error.dart';
import 'package:bijbelquiz_mobile/core/theme/app_theme.dart';
import 'package:bijbelquiz_mobile/core/ui/app_notice.dart';
import 'package:bijbelquiz_mobile/features/multiplayer/data/multiplayer_api_exception.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final entry in const {
      'Inter': [
        'assets/fonts/Inter-Regular.ttf',
        'assets/fonts/Inter-Medium.ttf',
        'assets/fonts/Inter-SemiBold.ttf',
      ],
      'Newsreader': [
        'assets/fonts/Newsreader-Regular.ttf',
        'assets/fonts/Newsreader-Medium.ttf',
        'assets/fonts/Newsreader-SemiBold.ttf',
      ],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final path in entry.value) {
        final bytes = await File(path).readAsBytes();
        loader.addFont(Future.value(ByteData.view(bytes.buffer)));
      }
      await loader.load();
    }

    const relative =
        'bin/cache/artifacts/material_fonts/materialicons-regular.otf';
    var probe = Directory(Platform.resolvedExecutable).parent;
    var font = File('${probe.path}/$relative');
    for (var i = 0; i < 8 && !font.existsSync(); i++) {
      probe = probe.parent;
      font = File('${probe.path}/$relative');
    }
    if (font.existsSync()) {
      final loader = FontLoader('MaterialIcons');
      loader.addFont(Future.value(ByteData.view(font.readAsBytesSync().buffer)));
      await loader.load();
    }
  });

  testWidgets('notice styling', (tester) async {
    tester.view.physicalSize = const Size(1290, 1200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    late BuildContext ctx;

    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              ctx = context;
              return const Scaffold(backgroundColor: AppTheme.paper);
            },
          ),
        ),
      ),
    );

    AppNotice.error(
      ctx,
      const MultiplayerApiException(
        code: 'ROOM_NOT_FOUND',
        message: 'Room not found',
        statusCode: 404,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Kamer niet gevonden'), findsOneWidget);
    expect(find.textContaining('404'), findsNothing);
    expect(AppError.from(Exception('boom')).title, 'Er ging iets mis');

    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 3.0);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('build')..createSync(recursive: true);
      File('${dir.path}/notice_preview.png').writeAsBytesSync(
        data!.buffer.asUint8List(),
      );
      image.dispose();
    });
  });
}
