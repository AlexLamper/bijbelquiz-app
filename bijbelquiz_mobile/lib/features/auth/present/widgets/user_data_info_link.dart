import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Subtle link that explains how user data is handled.
Widget buildUserDataInfoLink(BuildContext context) {
  return TextButton(
    onPressed: () => showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hoe we met je gegevens omgaan'),
        content: const SingleChildScrollView(
          child: Text(
            'Bij het inloggen of registreren gebruiken we alleen gegevens die '
            'nodig zijn om je account te laten werken, zoals je naam, e-mailadres '
            'en inloggegevens.\n\n'
            'Je gegevens worden via beveiligde verbindingen verzonden en we delen '
            'ze niet voor advertenties zonder jouw toestemming.\n\n'
            'Je kunt altijd je account laten verwijderen. Neem hiervoor contact op '
            'via info@bijbelquiz.com of via de supportkanalen in de app. Na verwijdering '
            'worden je accountgegevens verwijderd volgens ons privacybeleid.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Sluiten'),
          ),
        ],
      ),
    ),
    style: TextButton.styleFrom(
      foregroundColor: AppTheme.inkMuted,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      minimumSize: const Size(0, 44),
    ),
    child: const Text(
      'Meer over gegevensgebruik',
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
