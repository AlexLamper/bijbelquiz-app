import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import '../../profile/present/profile_provider.dart';
import '../data/admin_repository.dart';
import 'admin_grant_sheet.dart';
import 'widgets/admin_rows.dart';
import 'widgets/admin_ui.dart';

/// Everything about one account, plus "Premium geven" / "Premium intrekken".
class AdminUserDetailScreen extends ConsumerWidget {
  const AdminUserDetailScreen({super.key, required this.userId});

  final String userId;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/beheer');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isAdmin = profileAsync.maybeWhen(
      data: (p) => p.isAdmin,
      orElse: () => false,
    );
    final async = isAdmin ? ref.watch(adminUserDetailProvider(userId)) : null;
    final name = async?.asData?.value.user.row.displayName;

    Widget body;
    if (profileAsync.isLoading && !profileAsync.hasValue) {
      body = const AdminSkeletonList();
    } else if (!isAdmin) {
      body = const Padding(
        padding: EdgeInsets.all(20),
        child: AdminEmptyCard('Dit scherm is alleen voor beheerders.'),
      );
    } else {
      body = RefreshIndicator(
        color: AppTheme.lapis,
        backgroundColor: AppTheme.paperRaised,
        onRefresh: () async {
          ref.invalidate(adminUserDetailProvider(userId));
          try {
            await ref.read(adminUserDetailProvider(userId).future);
          } catch (_) {}
        },
        child: async!.when(
          skipLoadingOnRefresh: true,
          loading: () => const AdminSkeletonList(cards: 5),
          error: (e, _) => AdminErrorView(
            error: e,
            onRetry: () => ref.invalidate(adminUserDetailProvider(userId)),
          ),
          data: (detail) => AdminUserDetailBody(
            detail: detail,
            onChanged: () => ref.invalidate(adminUserDetailProvider(userId)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: BqTopBar(
                title: name ?? 'Gebruiker',
                subtitle: 'Beheer',
                onBack: () => _back(context),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// The detail content, separate from the provider so tests can pump it.
class AdminUserDetailBody extends ConsumerStatefulWidget {
  const AdminUserDetailBody({
    super.key,
    required this.detail,
    required this.onChanged,
    this.now,
  });

  final AdminUserDetail detail;

  /// Called after a grant or revoke so the screen reloads.
  final VoidCallback onChanged;
  final DateTime? now;

  @override
  ConsumerState<AdminUserDetailBody> createState() =>
      _AdminUserDetailBodyState();
}

class _AdminUserDetailBodyState extends ConsumerState<AdminUserDetailBody> {
  bool _revoking = false;

  /// What the last action returned, shown until the reload lands.
  AdminUserDetail? _optimistic;

  AdminUserDetail get _d => _optimistic ?? widget.detail;

  @override
  void didUpdateWidget(covariant AdminUserDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail != widget.detail) _optimistic = null;
  }

  Future<void> _grant() async {
    final d = _d;
    final result = await showAdminGrantSheet(
      context,
      userName: d.user.row.displayName,
      currentGrant: d.premium.manual,
      now: widget.now,
      submit: (request, _) => ref
          .read(adminRepositoryProvider)
          .grantPremium(d.user.row.id, request),
    );
    if (result == null || !mounted) return;
    setState(() => _optimistic = d.withPremium(result.premium, entry: result.grant));
    AppNotice.success(
      context,
      adminGrantSuccessText(result, userName: d.user.row.displayName),
      title: 'Premium gegeven',
    );
    widget.onChanged();
  }

  Future<void> _revoke() async {
    final d = _d;
    final note = await showModalBottomSheet<(String,)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _RevokeSheet(name: d.user.row.displayName),
    );
    if (note == null || !mounted) return;
    setState(() => _revoking = true);
    try {
      final result = await ref
          .read(adminRepositoryProvider)
          .revokePremium(d.user.row.id, note: note.$1);
      if (!mounted) return;
      setState(() {
        _revoking = false;
        _optimistic = d.withPremium(result.premium, entry: result.grant);
      });
      AppNotice.success(
        context,
        result.premium.active
            ? 'De gift is gestopt. ${d.user.row.displayName} heeft nog '
                  'Premium via ${AdminLabels.premiumSource(result.premium.source ?? '').toLowerCase()}.'
            : 'De gift is gestopt. ${d.user.row.displayName} heeft geen '
                  'Premium meer.',
        title: 'Premium ingetrokken',
      );
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      setState(() => _revoking = false);
      showAdminError(context, e);
    }
  }

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    AppNotice.info(context, '$label gekopieerd.');
  }

  @override
  Widget build(BuildContext context) {
    final d = _d;
    final u = d.user;
    final row = u.row;
    final p = d.premium;
    final now = widget.now;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        // Header card -------------------------------------------------------
        BqCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  BqAvatar(name: row.displayName, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.displayTitle,
                        ),
                        GestureDetector(
                          onLongPress: row.email.isEmpty
                              ? null
                              : () => _copy('E-mailadres', row.email),
                          child: Text(
                            row.email.isEmpty ? '-' : row.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  AdminPlatformPill(platform: row.signupPlatform),
                  BqPill(
                    label: AdminLabels.method(row.signupMethod),
                    background: AppTheme.paperSunken,
                    foreground: AppTheme.inkSoft,
                    height: 22,
                    fontSize: 11,
                  ),
                  if (p.state.active)
                    BqPill(
                      label: 'Premium',
                      icon: const BqIcon(BqIcons.crown, size: 12),
                      background: AppTheme.goldTint,
                      foreground: AppTheme.goldText,
                      height: 22,
                      fontSize: 11,
                    )
                  else
                    const BqPill(
                      label: 'Gratis',
                      background: AppTheme.paperSunken,
                      foreground: AppTheme.inkMuted,
                      height: 22,
                      fontSize: 11,
                    ),
                  if (row.isAdmin)
                    const BqPill(label: 'Beheerder', height: 22, fontSize: 11),
                  if (row.isInternal)
                    const BqPill(
                      label: 'Testaccount',
                      background: AppTheme.paperSunken,
                      foreground: AppTheme.inkMuted,
                      height: 22,
                      fontSize: 11,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AdminStatGrid(
          columns: 3,
          stats: [
            AdminStat('XP', AdminFormat.number(row.xp)),
            AdminStat(
              'Niveau',
              '${row.level}',
              hint: u.levelTitle.isEmpty ? null : u.levelTitle,
            ),
            AdminStat('Quizzen', AdminFormat.number(row.quizzesPlayed)),
            AdminStat('Gem. score', '${u.averageScore}%'),
            AdminStat('Reeks', '${u.streak}', hint: 'beste ${u.bestStreak}'),
            AdminStat('Badges', '${u.badges.length}'),
          ],
        ),

        // Premium ------------------------------------------------------------
        const SizedBox(height: 28),
        const AdminSectionTitle('Premium'),
        _PremiumCard(detail: d, now: now),
        const SizedBox(height: 12),
        BqButton(
          label: d.canRevoke ? 'Einddatum wijzigen' : 'Premium geven',
          icon: const BqIcon(BqIcons.crown, size: 18),
          onPressed: _grant,
        ),
        if (d.canRevoke) ...[
          const SizedBox(height: 4),
          BqButton(
            label: 'Premium intrekken',
            style: BqButtonStyle.secondary,
            height: 46,
            loading: _revoking,
            onPressed: _revoking ? null : _revoke,
          ),
        ],

        // Account ------------------------------------------------------------
        const SizedBox(height: 28),
        const AdminSectionTitle('Account'),
        AdminKvCard(
          rows: [
            ('Aangemeld', AdminFormat.dateTime(row.createdAt)),
            (
              'Aangemeld via',
              '${AdminLabels.platform(row.signupPlatform)}'
                  '${row.signupPlatformDerived ? ' (afgeleid)' : ''}',
            ),
            ('Aanmeldmethode', AdminLabels.method(row.signupMethod)),
            (
              'Inloggen met',
              [
                if (u.authPassword) 'wachtwoord',
                if (u.authGoogle) 'Google',
                if (u.authApple) 'Apple',
              ].join(', ').ifEmpty('-'),
            ),
            (
              'Laatst actief',
              '${AdminFormat.relative(row.lastActiveAt, now: now)}'
                  '${row.lastSeenPlatform != null ? ' · ${AdminLabels.platformShort(row.lastSeenPlatform)}' : ''}',
            ),
            ('Laatste quiz', AdminFormat.dateTime(u.lastPlayedAt)),
            ('Rol', row.isAdmin ? 'Beheerder' : 'Speler'),
            if (u.multiplayerGamesHosted > 0)
              ('Spellen gehost', '${u.multiplayerGamesHosted}'),
            if (u.onboarding['knowledgeLevel'] != null)
              ('Kennisniveau', '${u.onboarding['knowledgeLevel']}'),
            if (u.onboarding['bibleReadingFrequency'] != null)
              ('Leest de Bijbel', '${u.onboarding['bibleReadingFrequency']}'),
          ],
        ),
        const SizedBox(height: 12),
        AdminKvCard(
          rows: [
            ('Quizpogingen', AdminFormat.number(d.counts.attempts)),
            (
              'Duels',
              '${d.counts.duelsTotal} (${d.counts.duelsFinished} klaar, '
                  '${d.counts.duelsWon} gewonnen)',
            ),
            (
              'Speelgroepen',
              '${d.counts.playerGroupsOwned} eigen, '
                  '${d.counts.playerGroupsMember} lid',
            ),
            (
              'Groepslicenties',
              '${d.counts.groupLicensesOwned} eigen, '
                  '${d.counts.groupLicensesMember} lid',
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _copy('Account-id', row.id),
          child: Text(
            'Account-id: ${row.id} (tik om te kopiëren)',
            style: AppTheme.caption.copyWith(
              fontSize: 12,
              color: AppTheme.inkFaint,
            ),
          ),
        ),

        // Platforms ----------------------------------------------------------
        const SizedBox(height: 28),
        const AdminSectionTitle(
          'Waar actief',
          caption: 'Uit de metingen van de laatste 400 dagen',
        ),
        if (d.platformHistory.isEmpty)
          const AdminEmptyCard('Geen metingen voor dit account.')
        else
          BqListCard(
            children: [
              for (final h in d.platformHistory)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      AdminPlatformPill(platform: h.platform),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${AdminFormat.date(h.firstAt)} - ${AdminFormat.date(h.lastAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.caption,
                        ),
                      ),
                      Text(
                        '${h.sessions} bezoeken',
                        style: AppTheme.bodyStrong.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
            ],
          ),

        // Payments -----------------------------------------------------------
        const SizedBox(height: 28),
        const AdminSectionTitle('Betalingen'),
        if (d.payments.isEmpty)
          const AdminEmptyCard('Geen betalingen van dit account.')
        else
          BqListCard(
            children: [
              for (final pay in d.payments) AdminPaymentTile(payment: pay),
            ],
          ),

        // Attempts -----------------------------------------------------------
        const SizedBox(height: 28),
        const AdminSectionTitle('Laatste quizzen'),
        if (d.recentAttempts.isEmpty)
          const AdminEmptyCard('Nog geen quiz gespeeld.')
        else
          BqListCard(
            children: [
              for (final a in d.recentAttempts)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      BqRing(
                        value: a.totalQuestions > 0
                            ? a.score / a.totalQuestions
                            : 0,
                        color: AppTheme.positive,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.quizTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.bodyStrong,
                            ),
                            Text(
                              AdminFormat.dateTime(a.completedAt),
                              style: AppTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${a.score}/${a.totalQuestions}',
                            style: AppTheme.bodyStrong.copyWith(fontSize: 14),
                          ),
                          Text('+${a.xpEarned} XP', style: AppTheme.caption),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),

        // Grant log ----------------------------------------------------------
        const SizedBox(height: 28),
        const AdminSectionTitle(
          'Geschiedenis Premium-giften',
          caption: 'Wie gaf of trok in, wanneer en waarom',
        ),
        if (d.grantLog.isEmpty)
          const AdminEmptyCard('Nog nooit handmatig Premium gegeven.')
        else
          BqListCard(
            children: [
              for (final g in d.grantLog) _GrantLogRow(entry: g),
            ],
          ),
      ],
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

/// One row per Premium source with its state and end date.
class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.detail, this.now});

  final AdminUserDetail detail;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final p = detail.premium;
    final s = p.stripe;
    final m = p.manual;

    Widget row(
      String source,
      bool active,
      String title,
      String subtitle, {
      String? extra,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: active ? adminSourceColor(source) : AppTheme.ruleStrong,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.bodyStrong),
                  Text(subtitle, style: AppTheme.caption),
                  if (extra != null)
                    Text(
                      extra,
                      style: AppTheme.caption.copyWith(
                        fontSize: 12,
                        color: AppTheme.inkFaint,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AdminStatusPill(
              label: active ? 'Actief' : 'Uit',
              status: active ? 'active' : 'off',
            ),
          ],
        ),
      );
    }

    String until(DateTime? d) => d == null
        ? 'geen einddatum'
        : 'tot ${AdminFormat.date(d)} (${AdminFormat.remaining(d, now: now)})';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BqCard(
          color: p.state.active ? AppTheme.goldTint : AppTheme.paperRaised,
          borderColor: p.state.active ? const Color(0xFFF0DFAE) : AppTheme.rule,
          child: Row(
            children: [
              BqIcon(
                BqIcons.crown,
                size: 26,
                color: p.state.active ? null : AppTheme.inkFaint,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.state.active ? 'Premium actief' : 'Geen Premium',
                      style: AppTheme.displayBase.copyWith(
                        color: p.state.active ? AppTheme.goldInk : AppTheme.ink,
                      ),
                    ),
                    Text(
                      p.state.active
                          ? 'Via ${AdminLabels.premiumSource(p.state.source ?? '').toLowerCase()}'
                                ' · ${until(p.state.until)}'
                          : 'Dit account speelt gratis.',
                      style: AppTheme.caption.copyWith(
                        color: p.state.active ? AppTheme.goldText : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        BqListCard(
          children: [
            row(
              'manual',
              m.active,
              'Handmatig gegeven',
              m.active
                  ? (m.legacy
                        ? 'Oude gift zonder einddatum'
                        : until(m.until))
                  : 'Geen gift',
              extra: m.active
                  ? [
                      if (m.grantedBy != null) 'door ${m.grantedBy!.display}',
                      if (m.grantedAt != null) AdminFormat.date(m.grantedAt),
                      if (m.note != null) '"${m.note}"',
                    ].join(' · ').ifEmpty('-')
                  : null,
            ),
            row(
              'stripe',
              s.active,
              'Website (Stripe)',
              s.isKnown
                  ? [
                      if (s.plan != null) s.plan == 'yearly' ? 'jaar' : 'maand',
                      if (s.status != null) s.status!,
                      if (s.currentPeriodEnd != null)
                        '${s.cancelAtPeriodEnd ? 'stopt' : 'verlengt'} '
                            '${AdminFormat.date(s.currentPeriodEnd)}',
                    ].join(' · ').ifEmpty('bekend')
                  : 'Geen abonnement',
              extra: s.trialEnd != null
                  ? 'Proefperiode tot ${AdminFormat.date(s.trialEnd)}'
                  : null,
            ),
            row(
              'store',
              p.storeActive,
              'App Store / Google Play',
              p.storeExpiresAt == null
                  ? (p.storeActive ? 'actief' : 'Geen abonnement')
                  : '${p.storeActive ? 'loopt tot' : 'liep tot'} '
                        '${AdminFormat.date(p.storeExpiresAt)}',
            ),
            row(
              'lifetime',
              p.lifetime,
              'Levenslang',
              p.lifetime ? 'Gekocht, geen einddatum' : 'Niet gekocht',
            ),
            row(
              'group',
              p.groupActive,
              'Groepslicentie',
              p.groupActive
                  ? until(p.groupUntil)
                  : (p.groupLicenses.isEmpty ? 'Geen licentie' : 'Niet actief'),
              extra: p.groupLicenses.isEmpty
                  ? null
                  : p.groupLicenses
                        .map(
                          (l) =>
                              '${l.name} (${l.role == 'owner' ? 'eigenaar' : 'lid'})',
                        )
                        .join(', '),
            ),
          ],
        ),
      ],
    );
  }
}

class _GrantLogRow extends StatelessWidget {
  const _GrantLogRow({required this.entry});

  final AdminGrantEntry entry;

  @override
  Widget build(BuildContext context) {
    final g = entry;
    final duration = AdminGrantDuration.fromKey(g.duration);
    final what = g.isRevoke
        ? 'Ingetrokken'
        : (duration == AdminGrantDuration.lifetime
              ? 'Gegeven, levenslang'
              : 'Gegeven tot ${AdminFormat.date(g.until)}');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BqIconTile(
            size: 32,
            radius: 9,
            background: g.isRevoke ? AppTheme.coralTint : AppTheme.goldTint,
            child: g.isRevoke
                ? const BqIcon(BqIcons.close, size: 15, color: AppTheme.vermilion)
                : const BqIcon(BqIcons.crown, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(what, style: AppTheme.bodyStrong),
                Text(
                  [
                    AdminFormat.dateTime(g.at),
                    if (g.by != null) 'door ${g.by!.display}',
                    if (duration != null &&
                        duration != AdminGrantDuration.custom &&
                        duration != AdminGrantDuration.lifetime)
                      duration.label,
                  ].join(' · '),
                  style: AppTheme.caption,
                ),
                if (g.note != null)
                  Text(
                    '"${g.note}"',
                    style: AppTheme.caption.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.inkSoft,
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

class _RevokeSheet extends StatefulWidget {
  const _RevokeSheet({required this.name});

  final String name;

  @override
  State<_RevokeSheet> createState() => _RevokeSheetState();
}

class _RevokeSheetState extends State<_RevokeSheet> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Premium intrekken?', style: AppTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
              'De handmatige gift van ${widget.name} stopt nu. Premium via '
              'Stripe, de store, levenslang of een groepslicentie blijft.',
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 16),
            const Text('Reden (optioneel)', style: AppTheme.metaLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _note,
              maxLength: 300,
              decoration: const InputDecoration(
                hintText: 'Bijvoorbeeld: per ongeluk gegeven',
                counterText: '',
              ),
            ),
            const SizedBox(height: 20),
            BqButton(
              label: 'Intrekken',
              style: BqButtonStyle.coral,
              onPressed: () => Navigator.of(context).pop((_note.text,)),
            ),
            const SizedBox(height: 4),
            BqButton(
              label: 'Annuleren',
              style: BqButtonStyle.secondary,
              height: 46,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
