import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleLogoIcon extends StatelessWidget {
  final double size;

  const GoogleLogoIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/google_logo.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
