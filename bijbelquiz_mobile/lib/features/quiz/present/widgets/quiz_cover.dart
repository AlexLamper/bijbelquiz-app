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
  });

  final String imagePath;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final url = ServerImage.getFullUrl(imagePath);
    return SizedBox.expand(
      child: ColoredBox(
        color: background,
        child: url.isEmpty
            ? null
            : Image.network(
                url,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                gaplessPlayback: true,
                excludeFromSemantics: true,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
      ),
    );
  }
}
