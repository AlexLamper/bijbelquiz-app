import 'package:flutter/material.dart';

import '../errors/app_error.dart';
import '../theme/app_theme.dart';

/// Snackbars in the app's own editorial styling: paper card, hairline rule,
/// a coloured marker down the left edge instead of a filled banner.
///
/// Use [AppNotice.error] for anything thrown - it runs through [AppError], so
/// raw codes like `ROOM_NOT_FOUND (404)` never reach a player.
class AppNotice {
  const AppNotice._();

  /// Shows a Dutch, styled message for [error].
  static void error(BuildContext context, Object? error) {
    final mapped = AppError.from(error);
    _show(
      context,
      title: mapped.title,
      message: mapped.message,
      icon: mapped.icon,
      accent: AppTheme.vermilion,
    );
  }

  /// Neutral confirmation, e.g. "Kamercode gekopieerd."
  static void info(BuildContext context, String message, {String? title}) {
    _show(
      context,
      title: title,
      message: message,
      icon: Icons.info_outline,
      accent: AppTheme.lapis,
    );
  }

  /// Positive confirmation, e.g. a restored purchase.
  static void success(BuildContext context, String message, {String? title}) {
    _show(
      context,
      title: title,
      message: message,
      icon: Icons.check,
      accent: AppTheme.positive,
    );
  }

  static void _show(
    BuildContext context, {
    required String? title,
    required String message,
    required IconData icon,
    required Color accent,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 5),
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: _NoticeCard(
          title: title,
          message: message,
          icon: icon,
          accent: accent,
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.accent,
  });

  final String? title;
  final String message;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.rule),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // `border-l-2 border-vermilion` - the site's notice marker.
              Container(width: 3, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 18, color: accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title != null && title!.isNotEmpty) ...[
                              Text(
                                title!,
                                style: AppTheme.displayBase.copyWith(
                                  fontSize: 15,
                                  color: AppTheme.ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                            ],
                            Text(
                              message,
                              style: AppTheme.bodyMuted.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
