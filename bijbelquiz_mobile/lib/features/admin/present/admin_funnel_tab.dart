import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/bq.dart';
import '../data/admin_repository.dart';
import 'widgets/admin_ui.dart';

/// Funnel: paywall to purchase, plans, trials, hosts, activation and the
/// handover to BijbelStudie - the numbers the revenue plan runs on.
class AdminFunnelTab extends ConsumerStatefulWidget {
  const AdminFunnelTab({super.key});

  @override
  ConsumerState<AdminFunnelTab> createState() => _AdminFunnelTabState();
}

class _AdminFunnelTabState extends ConsumerState<AdminFunnelTab> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminFunnelProvider(_days));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Wrap(
            spacing: 8,
            children: [
              for (final d in const [7, 30, 90, 365])
                AdminChip(
                  compact: true,
                  label: d == 365 ? '1 jaar' : '$d dagen',
                  selected: _days == d,
                  onTap: () => setState(() => _days = d),
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.lapis,
            backgroundColor: AppTheme.paperRaised,
            onRefresh: () async {
              ref.invalidate(adminFunnelProvider(_days));
              try {
                await ref.read(adminFunnelProvider(_days).future);
              } catch (_) {}
            },
            child: async.when(
              skipLoadingOnRefresh: true,
              loading: () => const AdminSkeletonList(cards: 4),
              error: (e, _) => AdminErrorView(
                error: e,
                onRetry: () => ref.invalidate(adminFunnelProvider(_days)),
              ),
              data: (f) => AdminFunnelBody(funnel: f),
            ),
          ),
        ),
      ],
    );
  }
}

const Map<String, String> _triggerLabels = {
  'host_quota_exhausted': 'Gratis spellen op',
  'host_quota_warning': 'Waarschuwing bij spel 4-5',
  'host_player_cap': 'Spelerslimiet bereikt',
  'explanation_locked': 'Uitleg op slot',
  'premium_quiz_locked': 'Premium quiz',
  'review_locked': 'Terugkijken op slot',
  'gratis-limiet': 'Gratis quizzen op',
  'direct': 'Rechtstreeks bezoek',
  'geen': 'Geen paywall gezien',
};

const Map<String, String> _surfaceLabels = {
  'explanation': 'Onder de uitleg in de quiz',
  'result_primary': 'Hoofdknop op het resultaat',
  'result_wrong_answers': 'Foute antwoorden op het resultaat',
  'review': 'In de terugblik',
  'interstitial': 'Popup na een quiz',
  'interstitial_offer': 'Pro-link in de popup',
  'quiz_intro': 'Hint onder de startknop',
  'multiplayer_end': 'Einde van een spel samen',
  'landing': 'Blok op de homepage',
  'landing_cta': 'Slotregel van de homepage',
  'dashboard': 'Blok op het dashboard',
  'studie_page': 'Hoofdknop BijbelStudie-pagina',
  'studie_page_offer': 'Pro-link BijbelStudie-pagina',
  'quiz_list_empty': 'Zoeken zonder resultaat',
  'help': 'Hulpcentrum',
  'footer': 'Footer',
};

class AdminFunnelBody extends StatelessWidget {
  const AdminFunnelBody({super.key, required this.funnel});

  final AdminFunnel funnel;

  @override
  Widget build(BuildContext context) {
    final f = funnel;
    String pct(num v) => AdminFormat.percent(v);
    final triggers = [...f.byTrigger]..sort((a, b) => b.shown.compareTo(a.shown));
    final surfaces = f.handoverBySurface.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        Text(
          'Laatste ${f.windowDays} dagen, testaccounts niet meegeteld.',
          style: AppTheme.caption.copyWith(color: AppTheme.inkFaint),
        ),
        const SizedBox(height: 10),
        AdminStatGrid(
          stats: [
            AdminStat('Paywall getoond', AdminFormat.number(f.paywallShown)),
            AdminStat('Aankopen', AdminFormat.number(f.paywallPurchases)),
            AdminStat(
              'Paywall-conversie',
              pct(f.paywallConversion),
              accent: AppTheme.gold,
            ),
            AdminStat(
              'Proef -> betaald',
              pct(f.trialConversion),
              hint:
                  '${AdminFormat.number(f.trialsConverted)} van '
                  '${AdminFormat.number(f.trialsStarted)} proefperiodes',
            ),
          ],
        ),
        const SizedBox(height: 28),
        const AdminSectionTitle(
          'Per paywall',
          caption: 'Welke paywall levert aankopen op',
        ),
        if (triggers.isEmpty)
          const AdminEmptyCard('Nog geen paywall getoond in deze periode.')
        else
          BqListCard(
            children: [
              for (final t in triggers)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _triggerLabels[t.trigger] ?? t.trigger,
                              style: AppTheme.bodyStrong.copyWith(fontSize: 14),
                            ),
                            Text(
                              '${AdminFormat.number(t.shown)} getoond · '
                              '${AdminFormat.number(t.purchases)} gekocht',
                              style: AppTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        pct(t.conversionRate),
                        style: AppTheme.statNumber.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        const SizedBox(height: 28),
        const AdminSectionTitle('Gekozen abonnement'),
        AdminSplitCard(
          emptyText: 'Nog geen aankopen in deze periode.',
          slices: [
            AdminSlice(
              label: 'Maand',
              value: f.plansMonthly,
              color: AppTheme.lapis,
            ),
            AdminSlice(label: 'Jaar', value: f.plansYearly, color: AppTheme.gold),
            AdminSlice(
              label: 'Levenslang',
              value: f.plansLifetime,
              color: AppTheme.coral,
            ),
          ],
          footer: Text(
            '${pct(f.nonMonthlyShare)} koos iets anders dan maandelijks.',
            style: AppTheme.caption,
          ),
        ),
        const SizedBox(height: 28),
        const AdminSectionTitle(
          'Samen spelen',
          caption: 'Hosts die de gratis spellen opmaken',
        ),
        AdminStatGrid(
          columns: 3,
          stats: [
            AdminStat('Hosts', AdminFormat.number(f.hostsStartedOne)),
            AdminStat(
              'Limiet bereikt',
              AdminFormat.number(f.hostsReachedQuota),
              hint: f.freeQuota > 0 ? '${f.freeQuota} gratis' : null,
            ),
            AdminStat('Deel', pct(f.hostsReachRate)),
          ],
        ),
        const SizedBox(height: 28),
        const AdminSectionTitle('Activatie'),
        AdminStatGrid(
          stats: [
            AdminStat('Quizzen afgerond', AdminFormat.number(f.quizzesCompleted)),
            AdminStat(
              'Eerste quiz afgerond',
              AdminFormat.number(f.firstQuizzesCompleted),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const AdminSectionTitle(
          'Naar BijbelStudie',
          caption: 'Doorverwijzingen na het spelen',
        ),
        AdminStatGrid(
          stats: [
            AdminStat('Klikken', AdminFormat.number(f.handoverClicks)),
            AdminStat(
              'Per afgeronde quiz',
              pct(f.handoverPerCompletion),
              accent: AppTheme.positive,
            ),
            AdminStat('Popup getoond', AdminFormat.number(f.handoverShown)),
            AdminStat(
              'Code gekopieerd',
              AdminFormat.number(f.handoverCodeCopies),
              hint: '${AdminFormat.number(f.handoverDismissals)} keer weggeklikt',
            ),
          ],
        ),
        if (surfaces.isNotEmpty) ...[
          const SizedBox(height: 12),
          BqCard(
            child: AdminBarList(
              slices: [
                for (final e in surfaces)
                  AdminSlice(
                    label: _surfaceLabels[e.key] ?? e.key,
                    value: e.value,
                    color: AppTheme.positive,
                  ),
              ],
            ),
          ),
        ],
        if (f.retentionFree != null || f.retentionPremium != null) ...[
          const SizedBox(height: 28),
          const AdminSectionTitle(
            'Na 30 dagen nog actief',
            caption: 'Gratis tegenover Premium',
          ),
          AdminStatGrid(
            stats: [
              if (f.retentionFree != null)
                AdminStat(
                  'Gratis',
                  pct(f.retentionFree!.rate),
                  hint:
                      '${AdminFormat.number(f.retentionFree!.part)} van '
                      '${AdminFormat.number(f.retentionFree!.base)}',
                ),
              if (f.retentionPremium != null)
                AdminStat(
                  'Premium',
                  pct(f.retentionPremium!.rate),
                  accent: AppTheme.gold,
                  hint:
                      '${AdminFormat.number(f.retentionPremium!.part)} van '
                      '${AdminFormat.number(f.retentionPremium!.base)}',
                ),
            ],
          ),
        ],
      ],
    );
  }
}
