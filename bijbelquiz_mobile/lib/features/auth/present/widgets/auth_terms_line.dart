import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_notice.dart';

/// "... ga je akkoord met de voorwaarden en het privacybeleid." with both
/// words opening the page in the browser.
class AuthTermsLine extends StatefulWidget {
  const AuthTermsLine({
    super.key,
    this.prefix = 'Door verder te gaan ga je akkoord met de ',
    this.fontSize = 12,
  });

  final String prefix;
  final double fontSize;

  @override
  State<AuthTermsLine> createState() => _AuthTermsLineState();
}

class _AuthTermsLineState extends State<AuthTermsLine> {
  late final TapGestureRecognizer _terms = TapGestureRecognizer()
    ..onTap = () => _open(AppConfig.termsOfUseUrl);
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()
    ..onTap = () => _open(AppConfig.privacyPolicyUrl);

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      AppNotice.error(
        context,
        const AppError(
          title: 'Link niet geopend',
          message: 'We konden deze pagina niet openen. Probeer het opnieuw.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const link = TextStyle(
      fontWeight: FontWeight.w700,
      color: AppTheme.lapis,
      decoration: TextDecoration.underline,
      decorationColor: AppTheme.lapis,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: widget.prefix),
          TextSpan(text: 'voorwaarden', style: link, recognizer: _terms),
          const TextSpan(text: ' en het '),
          TextSpan(text: 'privacybeleid', style: link, recognizer: _privacy),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppTheme.sansFontName,
        fontSize: widget.fontSize,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: AppTheme.inkMuted,
      ),
    );
  }
}
