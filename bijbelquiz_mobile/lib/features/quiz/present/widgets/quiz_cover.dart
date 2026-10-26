import 'package:flutter/material.dart';

import '../../../../core/ui/server_image.dart';

/// A quiz's cover art on a tinted backdrop.
///
/// Uses the same URL resolution as [ServerImage], but while the image loads,
/// or when it cannot be fetched, the tint shows instead of a grey error tile -
/// the cards then still read as designed.
class QuizCover extends StatelessWidget {
  const QuizCover({
    super.key,
    required this.imagePath,
    required this.background,
    this.thumbnailPath = '',
  });

  final String imagePath;
  final Color background;

  /// The small version of [imagePath]. Used when there is one; the original is
  /// the fallback for a cover whose thumbnail has not been generated yet.
  final String thumbnailPath;

  /// Decoded width. Covers are 1408px wide; no card shows more than a phone's
  /// width, and decoding the full image for each of hundreds of cards is what
  /// fills memory.
  static const int _decodeWidth = 640;

  Widget _image(String url, {Widget Function()? onError}) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      cacheWidth: _decodeWidth,
      filterQuality: FilterQuality.low,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) =>
          onError?.call() ?? const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final original = ServerImage.getFullUrl(imagePath);
    final thumbnail = ServerImage.getFullUrl(thumbnailPath);
    final Widget? child;
    if (thumbnail.isNotEmpty) {
      child = _image(
        thumbnail,
        onError: original.isEmpty ? null : () => _image(original),
      );
    } else if (original.isNotEmpty) {
      child = _image(original);
    } else {
      child = null;
    }

    return SizedBox.expand(child: ColoredBox(color: background, child: child));
  }
}
