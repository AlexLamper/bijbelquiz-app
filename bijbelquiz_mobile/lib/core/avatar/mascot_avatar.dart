import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import 'avatar_catalog.dart';

/// Draws a player mascot at [size] logical pixels.
///
/// The figure is built as an SVG string by [buildAvatarSvg] and handed to
/// flutter_svg, which caches parsed pictures by that string. A leaderboard of a
/// hundred rows therefore parses at most one picture per distinct creature, and
/// none of them touch the network.
class MascotAvatar extends StatelessWidget {
  const MascotAvatar({
    super.key,
    required this.avatar,
    this.size = 40,
    this.bordered = false,
  });

  final AvatarConfig avatar;
  final double size;

  /// Hairline ring, matching how the app frames every other round element.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.string(
      buildAvatarSvg(avatar),
      width: size,
      height: size,
      semanticsLabel: describeAvatar(avatar),
    );

    if (!bordered) return picture;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.rule, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: picture,
    );
  }
}
