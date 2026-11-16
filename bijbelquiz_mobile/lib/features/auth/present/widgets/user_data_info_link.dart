import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/tr.dart';

/// Subtle link that explains how user data is handled.
Widget buildUserDataInfoLink(BuildContext context) {
  return TextButton(
    onPressed: () => showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr.dataInfoTitle),
        content: SingleChildScrollView(
          child: Text(
            tr.dataInfoBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(tr.actionClose),
          ),
        ],
      ),
    ),
    style: TextButton.styleFrom(
      foregroundColor: AppTheme.inkMuted,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      minimumSize: const Size(0, 44),
    ),
    child: Text(
      tr.dataInfoMore,
      style: TextStyle(
        fontFamily: AppTheme.sansFontName,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.inkMuted,
        decoration: TextDecoration.underline,
        decorationColor: AppTheme.ruleStrong,
      ),
    ),
  );
}
