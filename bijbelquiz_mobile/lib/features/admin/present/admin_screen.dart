import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/bq.dart';
import '../../profile/present/profile_provider.dart';
import 'admin_funnel_tab.dart';
import 'admin_overview_tab.dart';
import 'admin_payments_tab.dart';
import 'admin_quizzes_tab.dart';
import 'admin_users_tab.dart';
import 'widgets/admin_ui.dart';

/// The in-app Beheer area: the same figures and actions as the website's
/// `/beheer`, laid out for a phone.
///
/// Admin-only: the server answers 403 to anyone else, and this screen also
/// checks the profile flag so a non-admin never fires a request.
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key, this.initialSection = 0});

  /// Index into [AdminScreen.sections].
  final int initialSection;

  static const List<String> sections = [
    'Overzicht',
    'Gebruikers',
    'Quizzen',
    'Betalingen',
    'Funnel',
  ];

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  late int _section = widget.initialSection.clamp(
    0,
    AdminScreen.sections.length - 1,
  );

  void _back() {
    if (_section != 0) {
      setState(() => _section = 0);
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final isAdmin = profileAsync.maybeWhen(
      data: (p) => p.isAdmin,
      orElse: () => false,
    );

    return PopScope(
      // The system back gesture first returns to Overzicht, then leaves.
      canPop: _section == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _section = 0);
      },
      child: Scaffold(
        backgroundColor: AppTheme.paper,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: BqTopBar(
                  title: 'Beheer',
                  large: true,
                  onBack: _back,
                  trailing: isAdmin
                      ? const BqPill(
                          label: 'Admin',
                          icon: BqIcon(
                            BqIcons.shield,
                            size: 14,
                            color: AppTheme.lapis,
                          ),
                        )
                      : null,
                ),
              ),
              if (profileAsync.isLoading && !profileAsync.hasValue)
                const Expanded(child: AdminSkeletonList())
              else if (!isAdmin)
                const Expanded(child: _NoAccess())
              else ...[
                AdminSegmentedControl(
                  labels: AdminScreen.sections,
                  selected: _section,
                  onSelected: (i) => setState(() => _section = i),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: IndexedStack(
                    index: _section,
                    children: [
                      AdminOverviewTab(
                        onOpenSection: (i) => setState(() => _section = i),
                      ),
                      const AdminUsersTab(),
                      const AdminQuizzesTab(),
                      const AdminPaymentsTab(),
                      const AdminFunnelTab(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NoAccess extends StatelessWidget {
  const _NoAccess();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      children: [
        BqCard(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            children: [
              const BqIconTile(
                size: 48,
                radius: 14,
                background: AppTheme.paperSunken,
                child: BqIcon(BqIcons.lock, size: 22, color: AppTheme.inkMuted),
              ),
              const SizedBox(height: 14),
              const Text(
                'Geen toegang',
                textAlign: TextAlign.center,
                style: AppTheme.displayTitle,
              ),
              const SizedBox(height: 6),
              Text(
                'Dit scherm is alleen voor beheerders.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
