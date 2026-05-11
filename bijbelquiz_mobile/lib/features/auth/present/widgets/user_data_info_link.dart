import 'package:flutter/material.dart';

/// Subtle link that explains how user data is handled.
Widget buildUserDataInfoLink(BuildContext context) {
  final theme = Theme.of(context);

  return Opacity(
    opacity: 0.72,
    child: TextButton(
      onPressed: () => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Hoe we met je gegevens omgaan'),
          content: SingleChildScrollView(
            child: Text(
              'Bij het inloggen of registreren gebruiken we alleen gegevens die '
              'nodig zijn om je account te laten werken, zoals je naam, e-mailadres '
              'en inloggegevens.\n\n'
              'Je gegevens worden via beveiligde verbindingen verzonden en we delen '
              'ze niet voor advertenties zonder jouw toestemming.\n\n'
              'Je kunt altijd je account laten verwijderen. Neem hiervoor contact op '
              'met support vanuit de app of via onze supportkanalen. Na verwijdering '
              'worden je accountgegevens verwijderd volgens ons privacybeleid.',
              style: theme.textTheme.bodyMedium,
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Meer over gegevensgebruik',
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: const Color(0xFF8A8F98),
          decoration: TextDecoration.underline,
        ),
      ),
    ),
  );
}
