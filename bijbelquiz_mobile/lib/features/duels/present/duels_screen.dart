import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/bq.dart';

/// Number of duels waiting for the player's turn - drives the tab badge.
final duelsTurnCountProvider = Provider<int>((ref) => 0);

/// Duels tab. Placeholder until the duels feature lands.
class DuelsScreen extends ConsumerWidget {
  const DuelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SafeArea(
      bottom: false,
      child: Padding(
        padding: bqPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BqPageTitle('Duels'),
            SizedBox(height: 16),
            Text('Binnenkort', style: AppTheme.bodyMuted),
          ],
        ),
      ),
    );
  }
}
