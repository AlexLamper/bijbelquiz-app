import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../profile/present/profile_provider.dart';
import '../data/admin_repository.dart';

/// In-app copy of the website `/beheer` premium dashboard. Admin-only: the
/// server returns 403 to non-admins, and the screen also checks the profile
/// flag so a non-admin never even fires the request.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref
        .watch(profileProvider)
        .maybeWhen(data: (p) => p.isAdmin, orElse: () => false);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        backgroundColor: AppTheme.paper,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.ink),
          onPressed: () => context.pop(),
        ),
        title: const Text('Beheer', style: AppTheme.displayTitle),
      ),
      body: SafeArea(
        child: !isAdmin
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: AppEmptyState(
                  icon: Icons.lock_outline,
                  title: 'Geen toegang',
                  description: 'Dit scherm is alleen voor beheerders.',
                ),
              )
            : _AdminBody(ref: ref),
      ),
    );
  }
}

class _AdminBody extends StatelessWidget {
  const _AdminBody({required this.ref});

  final WidgetRef ref;

  static String _euro(int cents) {
    final value = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
    return '€ $value';
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);

    return RefreshIndicator(
      color: AppTheme.ink,
      backgroundColor: AppTheme.paperRaised,
      onRefresh: () async {
        ref.invalidate(adminStatsProvider);
        await ref.read(adminStatsProvider.future);
      },
      child: statsAsync.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 240), AppLoader()],
        ),
        error: (err, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 80),
            AppEmptyState(
              icon: Icons.error_outline,
              title: 'Kon cijfers niet laden',
              description: '$err',
            ),
          ],
        ),
        data: (stats) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            const GradientHeader(
              eyebrow: 'Beheercentrum',
              title: 'Premium & betalingen',
              subtitle:
                  'Dezelfde cijfers als op de website. Ververs om bij te werken.',
            ),
            const SizedBox(height: 24),
            StatStrip(
              stacked: true,
              items: [
                StatItem(
                  value: '${stats.premiumUsers}',
                  label: 'Premium accounts',
                ),
                StatItem(value: '${stats.premiumShare}%', label: 'Van totaal'),
                StatItem(
                  value: '${stats.totalUsers}',
                  label: 'Gebruikers',
                  ruleColor: AppTheme.positive,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (stats.health != null) ...[
              const SectionHeader(
                eyebrow: 'Betaal-pijplijn',
                title: 'Werkt betalen end-to-end',
              ),
              const SizedBox(height: 12),
              _HealthBlock(health: stats.health!),
              const SizedBox(height: 24),
            ],
            const SectionHeader(
              eyebrow: 'Verdeling',
              title: 'Hoe men premium is',
            ),
            const SizedBox(height: 12),
            RuleGrid(
              children: [
                _kv('Stripe (web)', '${stats.stripe}'),
                _kv('Store (app / RevenueCat)', '${stats.store}'),
                _kv('Levenslang', '${stats.lifetime}'),
                _kv('Groepslicentie', '${stats.group}'),
                if (stats.internalExcluded > 0)
                  _kv(
                    'Testaccounts (niet geteld)',
                    '${stats.internalExcluded}',
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(eyebrow: 'Omzet', title: 'Betalingen'),
            const SizedBox(height: 12),
            RuleGrid(
              children: [
                _kv('Omzet (30 dagen)', _euro(stats.grossCentsLast30d)),
                _kv('Omzet (totaal)', _euro(stats.grossCentsAllTime)),
                _kv('Betalingen voltooid', '${stats.paymentsCompleted}'),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              eyebrow: 'Recent',
              title: 'Laatste betalingen',
            ),
            const SizedBox(height: 12),
            if (stats.recentPayments.isEmpty)
              const AppCard(
                child: Text(
                  'Nog geen betalingen vastgelegd. Als er wel betaald is maar '
                  'hier niets staat, bereikt de webhook de server niet.',
                  style: AppTheme.bodyMuted,
                ),
              )
            else
              RuleGrid(
                children: [
                  for (final p in stats.recentPayments)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.bodyStrong,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.provider} · ${p.planType.isEmpty ? 'onbekend' : p.planType} · ${p.status}',
                                  style: AppTheme.caption.copyWith(
                                    color: AppTheme.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _euro(p.amountCents),
                            style: AppTheme.bodyStrong.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTheme.bodyMuted)),
          Text(
            value,
            style: AppTheme.bodyStrong.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// The betaal-pijplijn verdict: overall status, the 30-day click->pay funnel,
/// any "paid but no access" count, and every non-OK check with its fix.
class _HealthBlock extends StatelessWidget {
  const _HealthBlock({required this.health});

  final AdminHealth health;

  Color get _color => switch (health.overall) {
    'ok' => AppTheme.positive,
    'fail' => AppTheme.vermilion,
    _ => AppTheme.lapis,
  };

  String get _label => switch (health.overall) {
    'ok' => 'Alles staat goed',
    'fail' => 'Er is iets kapot',
    _ => 'Werkt, met aandachtspunten',
  };

  IconData get _icon => switch (health.overall) {
    'ok' => Icons.check_circle_outline,
    'fail' => Icons.error_outline,
    _ => Icons.warning_amber_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.paperRaised,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: _color.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(_icon, color: _color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label,
                      style: AppTheme.bodyStrong.copyWith(color: _color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '30 dagen: ${health.paywallShown} paywall - '
                      '${health.checkoutStarted} klikten betalen - '
                      '${health.purchaseCompleted} betaald',
                      style: AppTheme.caption.copyWith(color: AppTheme.inkSoft),
                    ),
                    Text(
                      'Stripe-sleutel: ${health.stripeKeyMode} - '
                      'app-aankopen: ${health.revenuecatConfigured ? "ingesteld" : "NIET ingesteld"}',
                      style: AppTheme.caption.copyWith(color: AppTheme.inkSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (health.accessGapCount > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.vermilionTint,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.vermilion.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              '${health.accessGapCount} account(s) hebben betaald maar zijn niet '
              'premium. Fix de webhook; zet toegang tijdelijk handmatig.',
              style: AppTheme.caption.copyWith(color: AppTheme.ink),
            ),
          ),
        ],
        if (health.issues.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Geen configuratieproblemen. ${health.okCount} checks geslaagd.',
              style: AppTheme.caption.copyWith(color: AppTheme.inkSoft),
            ),
          )
        else
          ...health.issues.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.paperRaised,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.rule),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          issue.status == 'fail'
                              ? Icons.error_outline
                              : Icons.warning_amber_outlined,
                          size: 15,
                          color: issue.status == 'fail'
                              ? AppTheme.vermilion
                              : AppTheme.lapis,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(issue.label, style: AppTheme.bodyStrong),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issue.detail,
                      style: AppTheme.caption.copyWith(color: AppTheme.inkSoft),
                    ),
                    if (issue.action != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '-> ${issue.action}',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
