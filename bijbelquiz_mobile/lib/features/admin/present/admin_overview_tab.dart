import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import '../data/admin_repository.dart';
import 'admin_grant_sheet.dart';
import 'widgets/admin_rows.dart';
import 'widgets/admin_ui.dart';

/// Overzicht: every headline number on one scrolling page.
class AdminOverviewTab extends ConsumerWidget {
  const AdminOverviewTab({super.key, required this.onOpenSection});

  /// Switches the Beheer section (1 = Gebruikers, 2 = Quizzen, ...).
  final ValueChanged<int> onOpenSection;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(adminOverviewProvider);
    try {
      await ref.read(adminOverviewProvider.future);
    } catch (_) {
      // The error state renders it.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminOverviewProvider);
    return RefreshIndicator(
      color: AppTheme.lapis,
      backgroundColor: AppTheme.paperRaised,
      onRefresh: () => _refresh(ref),
      child: async.when(
        skipLoadingOnRefresh: true,
        loading: () => const AdminSkeletonList(cards: 5),
        error: (error, _) => error is AdminEndpointMissing
            ? const _LegacyOverview()
            : AdminErrorView(
                error: error,
                onRetry: () => ref.invalidate(adminOverviewProvider),
              ),
        data: (o) =>
            AdminOverviewBody(overview: o, onOpenSection: onOpenSection),
      ),
    );
  }
}

/// The overview content, separate from the provider so tests can pump it.
class AdminOverviewBody extends ConsumerStatefulWidget {
  const AdminOverviewBody({
    super.key,
    required this.overview,
    required this.onOpenSection,
  });

  final AdminOverview overview;
  final ValueChanged<int> onOpenSection;

  @override
  ConsumerState<AdminOverviewBody> createState() => _AdminOverviewBodyState();
}

class _AdminOverviewBodyState extends ConsumerState<AdminOverviewBody> {
  /// 0 = 7 dagen, 1 = 30 dagen, 2 = totaal.
  int _regPeriod = 1;

  /// 0 = vandaag, 1 = 7 dagen, 2 = 30 dagen.
  int _activePeriod = 1;

  /// 0 = 7 dagen, 1 = 30 dagen.
  int _playsPeriod = 1;

  Future<void> _grantByEmail() async {
    final result = await showAdminGrantSheet(
      context,
      askEmail: true,
      submit: (request, email) => ref
          .read(adminRepositoryProvider)
          .grantPremiumByEmail(email ?? '', request),
    );
    if (result == null || !mounted) return;
    ref.invalidate(adminOverviewProvider);
    AppNotice.success(
      context,
      adminGrantSuccessText(result),
      title: 'Premium gegeven',
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.overview;
    final reg = switch (_regPeriod) {
      0 => o.registrations7d,
      1 => o.registrations30d,
      _ => o.registrationsAllTime,
    };
    final active = switch (_activePeriod) {
      0 => o.activeToday,
      1 => o.active7d,
      _ => o.active30d,
    };
    final plays = _playsPeriod == 0 ? o.plays7d : o.plays30d;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        Text(
          [
            if (o.generatedAt != null)
              'Bijgewerkt ${AdminFormat.dateTime(o.generatedAt)}',
            if (o.internalExcluded > 0)
              '${o.internalExcluded} testaccounts niet in Premium en omzet',
          ].join(' · '),
          style: AppTheme.caption.copyWith(color: AppTheme.inkFaint),
        ),
        const SizedBox(height: 10),
        AdminStatGrid(
          stats: [
            AdminStat('Gebruikers', AdminFormat.number(o.usersTotal)),
            AdminStat(
              'Nieuw (7 dagen)',
              AdminFormat.number(o.registrations7d.total),
              hint: 'vandaag ${AdminFormat.number(o.registrationsToday.total)}',
            ),
            AdminStat(
              'Actief (7 dagen)',
              AdminFormat.number(o.active7d.total),
              hint: 'vandaag ${AdminFormat.number(o.activeToday.total)}',
            ),
            AdminStat(
              'Premium',
              AdminFormat.number(o.premiumTotal),
              hint: '${AdminFormat.percent(o.premiumShare)} van de accounts',
              accent: AppTheme.gold,
            ),
            AdminStat(
              'Netto omzet (30 dagen)',
              AdminFormat.money(o.revenue.netCentsLast30d, o.revenue.currency),
            ),
            AdminStat(
              'Quizzen gespeeld (7 d)',
              AdminFormat.number(o.plays7d.total),
            ),
          ],
        ),
        if (o.health != null) ...[
          const SizedBox(height: 12),
          AdminHealthCard(
            health: o.health!,
            onTap: () => widget.onOpenSection(3),
          ),
        ],

        // ------------------------------------------------------------------
        const SizedBox(height: 28),
        AdminSectionTitle(
          'Gebruikers',
          caption: 'Aanmeldingen per periode en waar ze vandaan komen',
          trailing: _TextLink(
            label: 'Alle gebruikers',
            onTap: () => widget.onOpenSection(1),
          ),
        ),
        AdminStatGrid(
          columns: 4,
          stats: [
            AdminStat(
              'Vandaag',
              AdminFormat.number(o.registrationsToday.total),
            ),
            AdminStat('7 dagen', AdminFormat.number(o.registrations7d.total)),
            AdminStat('30 dagen', AdminFormat.number(o.registrations30d.total)),
            AdminStat(
              'Totaal',
              AdminFormat.number(o.registrationsAllTime.total),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _PeriodChips(
          labels: const ['7 dagen', '30 dagen', 'Totaal'],
          selected: _regPeriod,
          onSelected: (i) => setState(() => _regPeriod = i),
        ),
        const SizedBox(height: 10),
        AdminSplitCard(
          title: 'Aangemeld via',
          slices: platformSlices(reg.byPlatform),
          emptyText: 'Geen aanmeldingen in deze periode.',
        ),
        const SizedBox(height: 12),
        AdminWeeklyChart(weeks: o.weekly),
        const SizedBox(height: 12),
        AdminSplitCard(
          title: 'Aanmeldmethode',
          slices: [
            for (final key in _ordered(o.byMethod, const [
              'email',
              'google',
              'apple',
              'onbekend',
            ]))
              AdminSlice(
                label: AdminLabels.method(key),
                value: o.byMethod[key] ?? 0,
                color: switch (key) {
                  'email' => AppTheme.lapis,
                  'google' => AppTheme.coral,
                  'apple' => AppTheme.ink,
                  _ => const Color(0xFFC9C5BB),
                },
              ),
          ],
          emptyText: 'Nog geen aanmeldmethode bekend.',
        ),

        // ------------------------------------------------------------------
        const SizedBox(height: 28),
        const AdminSectionTitle(
          'Actief',
          caption: 'Quiz gespeeld, app geopend of ingelogd op de website',
        ),
        AdminStatGrid(
          columns: 3,
          stats: [
            AdminStat('Vandaag', AdminFormat.number(o.activeToday.total)),
            AdminStat('7 dagen', AdminFormat.number(o.active7d.total)),
            AdminStat('30 dagen', AdminFormat.number(o.active30d.total)),
          ],
        ),
        const SizedBox(height: 12),
        _PeriodChips(
          labels: const ['Vandaag', '7 dagen', '30 dagen'],
          selected: _activePeriod,
          onSelected: (i) => setState(() => _activePeriod = i),
        ),
        const SizedBox(height: 10),
        BqCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Actief per platform', style: AppTheme.displayBase),
              const SizedBox(height: 4),
              Text(
                'Wie op twee platforms actief was, telt bij allebei mee.',
                style: AppTheme.caption.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 10),
              if (active.byPlatform.isEmpty)
                Text('Niemand actief in deze periode.', style: AppTheme.caption)
              else
                AdminBarList(slices: platformSlices(active.byPlatform)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _RetentionCard(overview: o),

        // ------------------------------------------------------------------
        const SizedBox(height: 28),
        const AdminSectionTitle(
          'Premium',
          caption: 'Testaccounts niet meegeteld',
        ),
        AdminStatGrid(
          stats: [
            AdminStat(
              'Premium nu',
              AdminFormat.number(o.premiumTotal),
              accent: AppTheme.gold,
            ),
            AdminStat(
              'Conversie',
              AdminFormat.percent(o.conversion.rate),
              hint:
                  '${AdminFormat.number(o.conversion.part)} van '
                  '${AdminFormat.number(o.conversion.base)} accounts',
            ),
            AdminStat(
              'Betaald',
              AdminFormat.percent(o.paidConversion.rate),
              hint: '${AdminFormat.number(o.paidConversion.part)} accounts',
            ),
            AdminStat(
              'Nieuw (30 d) Premium',
              AdminFormat.percent(o.conversionNew30d.rate),
              hint:
                  '${AdminFormat.number(o.conversionNew30d.part)} van '
                  '${AdminFormat.number(o.conversionNew30d.base)}',
            ),
            AdminStat(
              'Handmatig gegeven',
              AdminFormat.number(o.grantsActive),
              hint: o.grantsExpiringIn7d > 0
                  ? '${o.grantsExpiringIn7d} loopt binnen 7 dagen af'
                  : 'geen loopt binnen 7 dagen af',
            ),
            AdminStat(
              'Groepslicentie',
              AdminFormat.number(o.premiumBySource['group'] ?? 0),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AdminSplitCard(
          title: 'Premium per bron',
          slices: [
            for (final key in _ordered(o.premiumBySource, kAdminPremiumSources))
              AdminSlice(
                label: AdminLabels.premiumSource(key),
                value: o.premiumBySource[key] ?? 0,
                color: adminSourceColor(key),
              ),
          ],
          emptyText: 'Nog geen Premium-accounts.',
        ),
        const SizedBox(height: 12),
        AdminSplitCard(
          title: 'Premium per aanmeldplatform',
          slices: platformSlices(o.premiumBySignupPlatform),
          emptyText: 'Nog geen Premium-accounts.',
        ),
        if (o.conversionByPlatform.isNotEmpty) ...[
          const SizedBox(height: 12),
          BqCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Conversie per platform',
                  style: AppTheme.displayBase,
                ),
                const SizedBox(height: 10),
                AdminBarList(
                  valueFormat: (v) => AdminFormat.percent(v),
                  slices: [
                    for (final key in _ordered(
                      o.conversionByPlatform,
                      kAdminPlatformKeys,
                    ))
                      AdminSlice(
                        label: AdminLabels.platformShort(key),
                        value: o.conversionByPlatform[key]!.rate,
                        color: adminPlatformColor(key),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        BqButton(
          label: 'Premium geven via e-mail',
          style: BqButtonStyle.tint,
          height: 48,
          icon: const BqIcon(BqIcons.crown, size: 18),
          onPressed: _grantByEmail,
        ),

        // ------------------------------------------------------------------
        const SizedBox(height: 28),
        AdminSectionTitle(
          'Omzet',
          caption: 'Netto, na terugbetalingen, in euro',
          trailing: _TextLink(
            label: 'Betalingen',
            onTap: () => widget.onOpenSection(3),
          ),
        ),
        AdminRevenueSummary(revenue: o.revenue),

        // ------------------------------------------------------------------
        const SizedBox(height: 28),
        AdminSectionTitle(
          'Quizzen',
          caption: o.playsDescription ?? 'Afgeronde quizzen, app en website',
          trailing: _TextLink(
            label: 'Moderatie',
            onTap: () => widget.onOpenSection(2),
          ),
        ),
        AdminStatGrid(
          stats: [
            AdminStat('Quizzen', AdminFormat.number(o.quizzesTotal)),
            AdminStat(
              'Wacht op keuring',
              AdminFormat.number(o.quizzesPending),
              accent: o.quizzesPending > 0 ? AppTheme.coral : null,
            ),
            AdminStat('Gespeeld (7 d)', AdminFormat.number(o.plays7d.total)),
            AdminStat('Gespeeld (30 d)', AdminFormat.number(o.plays30d.total)),
          ],
        ),
        const SizedBox(height: 12),
        _PeriodChips(
          labels: const ['7 dagen', '30 dagen'],
          selected: _playsPeriod,
          onSelected: (i) => setState(() => _playsPeriod = i),
        ),
        const SizedBox(height: 10),
        AdminSplitCard(
          title: 'Gespeeld in de app of op de website',
          slices: [
            for (final key in _ordered(plays.byPlatform, const [
              'web',
              'ios',
              'android',
            ]))
              AdminSlice(
                label: AdminLabels.platform(key),
                value: plays.of(key),
                color: adminPlatformColor(key),
              ),
          ],
          emptyText: 'Geen quizzen gespeeld in deze periode.',
        ),

        // ------------------------------------------------------------------
        if (o.health != null && o.health!.issues.isNotEmpty) ...[
          const SizedBox(height: 28),
          const AdminSectionTitle(
            'Betalingen',
            caption: 'Wat er niet goed staat in de betaal-pijplijn',
          ),
          AdminHealthIssues(issues: o.health!.issues),
        ],

        // ------------------------------------------------------------------
        const SizedBox(height: 28),
        AdminSectionTitle(
          'Nieuwste gebruikers',
          trailing: _TextLink(
            label: 'Alles',
            onTap: () => widget.onOpenSection(1),
          ),
        ),
        if (o.recentUsers.isEmpty)
          const AdminEmptyCard('Nog geen gebruikers.')
        else
          BqListCard(
            children: [
              for (final u in o.recentUsers)
                AdminUserTile(
                  user: u,
                  onTap: u.id.isEmpty
                      ? null
                      : () => context.push('/beheer/gebruikers/${u.id}'),
                ),
            ],
          ),
        const SizedBox(height: 28),
        AdminSectionTitle(
          'Laatste betalingen',
          trailing: _TextLink(
            label: 'Alles',
            onTap: () => widget.onOpenSection(3),
          ),
        ),
        if (o.recentPayments.isEmpty)
          const AdminEmptyCard(
            'Nog geen betalingen vastgelegd. Als er wel betaald is maar hier '
            'niets staat, bereikt de webhook de server niet.',
          )
        else
          BqListCard(
            children: [
              for (final p in o.recentPayments)
                AdminPaymentTile(
                  payment: p,
                  onTap: p.userId == null || p.userDeleted
                      ? null
                      : () => context.push('/beheer/gebruikers/${p.userId}'),
                ),
            ],
          ),
      ],
    );
  }
}

/// Slices for a per-platform count, in the fixed platform order. Keys the
/// app does not know yet are appended so nothing silently disappears.
List<AdminSlice> platformSlices(Map<String, int> counts) {
  return [
    for (final key in _ordered(counts, kAdminPlatformKeys))
      AdminSlice(
        label: AdminLabels.platform(key),
        value: counts[key] ?? 0,
        color: adminPlatformColor(key),
      ),
  ];
}

/// The known keys that have a value, in [order], then any unknown keys.
List<String> _ordered(Map<String, Object?> map, List<String> order) {
  return [
    for (final k in order)
      if (map.containsKey(k)) k,
    for (final k in map.keys)
      if (!order.contains(k)) k,
  ];
}

/// Net revenue: headline figures, Stripe vs store, other currencies.
class AdminRevenueSummary extends StatelessWidget {
  const AdminRevenueSummary({super.key, required this.revenue});

  final AdminRevenue revenue;

  @override
  Widget build(BuildContext context) {
    final r = revenue;
    final stripe = r.source('stripe');
    final store = r.source('store');
    String money(int c) => AdminFormat.money(c, r.currency);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminStatGrid(
          stats: [
            AdminStat('Netto (30 dagen)', money(r.netCentsLast30d)),
            AdminStat('Netto (totaal)', money(r.netCentsAllTime)),
            AdminStat(
              'Betalingen voltooid',
              AdminFormat.number(r.paymentsCompleted),
              hint: '${AdminFormat.number(r.renewalsAllTime)} verlengingen',
            ),
            AdminStat(
              'Terugbetaald',
              money(r.refundedCentsAllTime),
              accent: r.refundedCentsAllTime > 0 ? AppTheme.coral : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        AdminSplitCard(
          title: 'Website (Stripe) of app (store)',
          valueFormat: (v) => money(v.round()),
          emptyText: 'Nog geen omzet.',
          slices: [
            AdminSlice(
              label: 'Website (Stripe)',
              value: stripe.netCentsAllTime,
              color: adminSourceColor('stripe'),
              detail:
                  '${AdminFormat.number(stripe.payments)} betalingen · '
                  '30 d ${money(stripe.netCentsLast30d)}',
            ),
            AdminSlice(
              label: 'App Store / Google Play',
              value: store.netCentsAllTime,
              color: adminSourceColor('store'),
              detail:
                  '${AdminFormat.number(store.payments)} betalingen · '
                  '30 d ${money(store.netCentsLast30d)}',
            ),
          ],
        ),
        if (r.otherCurrenciesAllTime.isNotEmpty ||
            r.otherCurrenciesLast30d.isNotEmpty) ...[
          const SizedBox(height: 12),
          AdminKvCard(
            rows: [
              for (final c in r.otherCurrenciesAllTime)
                (
                  'Totaal in ${c.currency.toUpperCase()}',
                  AdminFormat.money(c.netCents, c.currency),
                ),
              for (final c in r.otherCurrenciesLast30d)
                (
                  '30 dagen in ${c.currency.toUpperCase()}',
                  AdminFormat.money(c.netCents, c.currency),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Andere valuta worden niet omgerekend en tellen niet mee in de '
            'euro-bedragen.',
            style: AppTheme.caption.copyWith(fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _RetentionCard extends StatelessWidget {
  const _RetentionCard({required this.overview});

  final AdminOverview overview;

  @override
  Widget build(BuildContext context) {
    final o = overview;
    final r = o.retention;
    return BqCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Blijven ze terugkomen',
                  style: AppTheme.displayBase,
                ),
              ),
              Text(
                AdminFormat.percent(r.rate),
                style: AppTheme.statNumber.copyWith(fontSize: 22),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            o.retentionDescription ??
                'Accounts ouder dan 30 dagen die in de laatste 7 dagen '
                    'actief waren',
            style: AppTheme.caption.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '${AdminFormat.number(r.part)} van ${AdminFormat.number(r.base)} accounts',
            style: AppTheme.caption,
          ),
          if (o.retentionByPlatform.isNotEmpty) ...[
            const SizedBox(height: 10),
            AdminBarList(
              valueFormat: (v) => AdminFormat.percent(v),
              slices: [
                for (final key in _ordered(
                  o.retentionByPlatform,
                  kAdminPlatformKeys,
                ))
                  AdminSlice(
                    label: AdminLabels.platformShort(key),
                    value: o.retentionByPlatform[key]!.rate,
                    color: adminPlatformColor(key),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Registrations per week, stacked by platform. Plain widgets.
class AdminWeeklyChart extends StatelessWidget {
  const AdminWeeklyChart({super.key, required this.weeks});

  final List<AdminWeek> weeks;

  static const double _height = 120;

  @override
  Widget build(BuildContext context) {
    final max = weeks.fold<int>(0, (m, w) => w.total > m ? w.total : m);
    final platforms = <String>{for (final w in weeks) ...w.byPlatform.keys};
    final order = [
      for (final k in kAdminPlatformKeys)
        if (platforms.contains(k)) k,
      for (final k in platforms)
        if (!kAdminPlatformKeys.contains(k)) k,
    ];
    return BqCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Aanmeldingen per week',
                  style: AppTheme.displayBase,
                ),
              ),
              if (max > 0)
                Text('max ${AdminFormat.number(max)}', style: AppTheme.caption),
            ],
          ),
          const SizedBox(height: 12),
          if (weeks.isEmpty || max == 0)
            Text('Nog geen aanmeldingen per week.', style: AppTheme.caption)
          else ...[
            SizedBox(
              height: _height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < weeks.length; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      child: _WeekBar(
                        week: weeks[i],
                        max: max,
                        order: order,
                        highlight: i == weeks.length - 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 0; i < weeks.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      // Every third label, so they never collide.
                      (weeks.length - 1 - i) % 3 == 0 ? weeks[i].label : '',
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: AppTheme.caption.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                for (final k in order)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: adminPlatformColor(k),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        AdminLabels.platformShort(k),
                        style: AppTheme.caption.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WeekBar extends StatelessWidget {
  const _WeekBar({
    required this.week,
    required this.max,
    required this.order,
    required this.highlight,
  });

  final AdminWeek week;
  final int max;
  final List<String> order;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final h = AdminWeeklyChart._height - 14;
    final barHeight = max > 0 ? (week.total / max) * h : 0.0;
    final known = week.byPlatform.values.fold<int>(0, (a, b) => a + b);
    // Older rows may only carry a total; show it as one neutral block.
    final parts = known == 0
        ? <(Color, int)>[(AppTheme.lapisSoft, week.total)]
        : [
            for (final k in order)
              if ((week.byPlatform[k] ?? 0) > 0)
                (adminPlatformColor(k), week.byPlatform[k]!),
          ];
    final sum = parts.fold<int>(0, (a, p) => a + p.$2);
    return Semantics(
      label: '${week.label}: ${week.total} aanmeldingen',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            week.total > 0 && highlight ? '${week.total}' : '',
            style: AppTheme.caption.copyWith(
              fontSize: 10,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (barHeight > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: barHeight.clamp(3.0, h),
                child: Column(
                  children: [
                    for (final p in parts)
                      Expanded(
                        flex: sum > 0 ? (p.$2 * 1000 ~/ sum).clamp(1, 1000) : 1,
                        child: ColoredBox(
                          color: p.$1,
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            Container(height: 2, color: AppTheme.ruleSoft),
        ],
      ),
    );
  }
}

class _PeriodChips extends StatelessWidget {
  const _PeriodChips({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length; i++)
          AdminChip(
            label: labels[i],
            selected: i == selected,
            compact: true,
            onTap: () => onSelected(i),
          ),
      ],
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: AppTheme.sansFontName,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.lapis,
          ),
        ),
      ),
    );
  }
}

/// Older servers have only `/admin/stats`: show those figures and say that
/// the server needs an update for the rest.
class _LegacyOverview extends ConsumerWidget {
  const _LegacyOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminStatsProvider);
    return async.when(
      loading: () => const AdminSkeletonList(),
      error: (e, _) => AdminErrorView(
        error: e,
        onRetry: () {
          ref.invalidate(adminStatsProvider);
          ref.invalidate(adminOverviewProvider);
        },
      ),
      data: (s) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          const AdminUpdateBanner(
            text:
                'Deze server heeft alleen de premiumcijfers. Werk de server '
                'bij voor aanmeldingen per platform, actieve gebruikers en '
                'quizzen.',
          ),
          const SizedBox(height: 12),
          AdminStatGrid(
            stats: [
              AdminStat('Gebruikers', AdminFormat.number(s.totalUsers)),
              AdminStat(
                'Premium',
                AdminFormat.number(s.premiumUsers),
                hint: '${s.premiumShare}% van de accounts',
                accent: AppTheme.gold,
              ),
              AdminStat(
                'Netto (30 dagen)',
                AdminFormat.money(s.netCentsLast30d),
              ),
              AdminStat('Netto (totaal)', AdminFormat.money(s.netCentsAllTime)),
            ],
          ),
          if (s.health != null) ...[
            const SizedBox(height: 12),
            AdminHealthCard(health: s.health!),
            const SizedBox(height: 12),
            AdminHealthIssues(issues: s.health!.issues),
          ],
          const SizedBox(height: 28),
          const AdminSectionTitle('Premium per bron'),
          AdminSplitCard(
            slices: [
              AdminSlice(
                label: AdminLabels.premiumSource('stripe'),
                value: s.stripe,
                color: adminSourceColor('stripe'),
              ),
              AdminSlice(
                label: AdminLabels.premiumSource('store'),
                value: s.store,
                color: adminSourceColor('store'),
              ),
              AdminSlice(
                label: AdminLabels.premiumSource('lifetime'),
                value: s.lifetime,
                color: adminSourceColor('lifetime'),
              ),
              AdminSlice(
                label: AdminLabels.premiumSource('group'),
                value: s.group,
                color: adminSourceColor('group'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const AdminSectionTitle('Laatste betalingen'),
          if (s.recentPayments.isEmpty)
            const AdminEmptyCard('Nog geen betalingen vastgelegd.')
          else
            BqListCard(
              children: [
                for (final p in s.recentPayments)
                  AdminPaymentTile(
                    payment: AdminPaymentRow(
                      id: '',
                      userName: p.userName,
                      provider: p.provider,
                      planType: p.planType,
                      amountCents: p.amountCents,
                      status: p.status,
                      createdAt: p.createdAt,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Lapis-tinted note that the server is older than the app.
class AdminUpdateBanner extends StatelessWidget {
  const AdminUpdateBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      color: AppTheme.lapisTint,
      borderColor: AppTheme.lapisSoft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.system_update_alt, size: 20, color: AppTheme.lapis),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Werk de server bij',
                  style: AppTheme.bodyStrong.copyWith(
                    color: AppTheme.lapisStrong,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.lapisMutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
