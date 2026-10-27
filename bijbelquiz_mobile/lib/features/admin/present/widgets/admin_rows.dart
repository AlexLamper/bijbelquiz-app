import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/bq.dart';
import '../../data/admin_models.dart';
import 'admin_ui.dart';

/// One account in a list: avatar, name with a crown for Premium, e-mail, and
/// where/when it signed up and was last active.
class AdminUserTile extends StatelessWidget {
  const AdminUserTile({super.key, required this.user, this.onTap, this.now});

  final AdminUserRow user;
  final VoidCallback? onTap;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final premium = user.premium;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BqAvatar(name: user.displayName, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyStrong,
                      ),
                    ),
                    if (premium.active) ...[
                      const SizedBox(width: 6),
                      const BqIcon(BqIcons.crown, size: 15),
                    ],
                    if (user.isAdmin) ...[
                      const SizedBox(width: 6),
                      const BqIcon(
                        BqIcons.shield,
                        size: 14,
                        color: AppTheme.lapis,
                      ),
                    ],
                  ],
                ),
                Text(
                  user.email.isEmpty ? '-' : user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.caption,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AdminPlatformPill(platform: user.signupPlatform),
                    if (premium.active && premium.source != null)
                      BqPill(
                        label: AdminLabels.premiumSource(premium.source!),
                        background: AppTheme.goldTint,
                        foreground: AppTheme.goldText,
                        height: 22,
                        fontSize: 11,
                      ),
                    if (user.isInternal)
                      const BqPill(
                        label: 'Testaccount',
                        background: AppTheme.paperSunken,
                        foreground: AppTheme.inkMuted,
                        height: 22,
                        fontSize: 11,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Aangemeld ${AdminFormat.date(user.createdAt)} · '
                  'actief ${AdminFormat.relative(user.lastActiveAt, now: now)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.caption.copyWith(
                    fontSize: 12,
                    color: AppTheme.inkFaint,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: BqIcon(
                BqIcons.chevronRight,
                size: 18,
                color: AppTheme.inkFaint,
              ),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

/// Small pill with a coloured dot: where an account came from.
class AdminPlatformPill extends StatelessWidget {
  const AdminPlatformPill({super.key, required this.platform});

  final String? platform;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.paperSunken,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: adminPlatformColor(platform),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            AdminLabels.platformShort(platform),
            style: const TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.inkSoft,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// One payment: buyer, channel and plan, amount and status.
class AdminPaymentTile extends StatelessWidget {
  const AdminPaymentTile({super.key, required this.payment, this.onTap});

  final AdminPaymentRow payment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = payment;
    final flags = <String>[
      if (p.isRenewal) 'verlenging',
      if (p.isTest) 'test',
      if (p.isInternal) 'intern',
      if (!p.counted) 'niet geteld',
      if (p.userDeleted) 'account verwijderd',
    ];
    final plan = p.planType.isEmpty ? null : _plan(p.planType);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BqIconTile(
            size: 36,
            radius: 10,
            background: AppTheme.paperSunken,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: adminSourceColor(p.channel),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                Text(
                  [
                    AdminLabels.provider(p.channel),
                    ?plan,
                    AdminFormat.date(p.createdAt),
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.caption,
                ),
                if (flags.isNotEmpty)
                  Text(
                    flags.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption.copyWith(
                      fontSize: 12,
                      color: AppTheme.inkFaint,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AdminFormat.money(p.amountCents, p.currency),
                style: AppTheme.bodyStrong.copyWith(
                  fontSize: 14,
                  decoration: p.counted ? null : TextDecoration.lineThrough,
                  color: p.counted ? AppTheme.ink : AppTheme.inkMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              AdminStatusPill(
                label: AdminLabels.paymentStatus(p.status),
                status: p.status,
              ),
              if (p.refundedCents > 0 && p.status != 'refunded') ...[
                const SizedBox(height: 2),
                Text(
                  '-${AdminFormat.money(p.refundedCents, p.currency)}',
                  style: AppTheme.caption.copyWith(
                    fontSize: 12,
                    color: AppTheme.vermilion,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }

  static String _plan(String plan) => switch (plan) {
    'monthly' => 'maand',
    'yearly' => 'jaar',
    'lifetime' => 'levenslang',
    _ => plan,
  };
}

/// The betaal-pijplijn verdict: overall status, the 30-day click->pay
/// funnel when known, any "paid but no access" count and every non-OK check.
class AdminHealthCard extends StatelessWidget {
  const AdminHealthCard({super.key, required this.health, this.onTap});

  final AdminHealth health;
  final VoidCallback? onTap;

  (Color, Color, String, IconData) get _look => switch (health.overall) {
    'ok' => (
      AppTheme.positiveTint,
      AppTheme.positiveText,
      'Alles staat goed',
      Icons.check_circle_outline,
    ),
    'fail' => (
      AppTheme.coralTint,
      AppTheme.vermilion,
      'Er is iets kapot',
      Icons.error_outline,
    ),
    _ => (
      AppTheme.goldTint,
      AppTheme.goldText,
      'Werkt, met aandachtspunten',
      Icons.warning_amber_outlined,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (tint, fg, label, icon) = _look;
    final fails = health.issues.where((i) => i.status == 'fail').length;
    final warns = health.issues.length - fails;
    return BqCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                BqIconTile(
                  size: 40,
                  background: tint,
                  child: Icon(icon, color: fg, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTheme.displayBase.copyWith(color: fg),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${health.okCount} checks goed'
                        '${fails > 0 ? ' · $fails kapot' : ''}'
                        '${warns > 0 ? ' · $warns let op' : ''}',
                        style: AppTheme.caption,
                      ),
                      if (health.checkedAt != null)
                        Text(
                          'Gecontroleerd ${AdminFormat.dateTime(health.checkedAt)}',
                          style: AppTheme.caption.copyWith(
                            fontSize: 12,
                            color: AppTheme.inkFaint,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const BqIcon(
                    BqIcons.chevronRight,
                    size: 18,
                    color: AppTheme.inkFaint,
                  ),
              ],
            ),
          ),
          if (health.hasFunnel) ...[
            const Divider(height: 1, color: AppTheme.ruleSoft),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                '30 dagen: ${AdminFormat.number(health.paywallShown)} paywall · '
                '${AdminFormat.number(health.checkoutStarted)} klikten betalen · '
                '${AdminFormat.number(health.purchaseCompleted)} betaald',
                style: AppTheme.caption.copyWith(color: AppTheme.inkSoft),
              ),
            ),
            const Divider(height: 1, color: AppTheme.ruleSoft),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                'Stripe-sleutel: ${health.stripeKeyMode} · app-aankopen: '
                '${health.revenuecatConfigured ? 'ingesteld' : 'niet ingesteld'}',
                style: AppTheme.caption.copyWith(color: AppTheme.inkSoft),
              ),
            ),
          ],
          if (health.accessGapCount > 0) ...[
            const Divider(height: 1, color: AppTheme.ruleSoft),
            Container(
              color: AppTheme.coralTint,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                '${health.accessGapCount} account(s) hebben betaald maar zijn '
                'niet Premium. Controleer de webhook en geef tijdelijk '
                'handmatig Premium.',
                style: AppTheme.caption.copyWith(color: AppTheme.vermilion),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The checks that are not OK, each with what to do about it.
class AdminHealthIssues extends StatelessWidget {
  const AdminHealthIssues({super.key, required this.issues});

  final List<AdminHealthIssue> issues;

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return const AdminEmptyCard('Geen configuratieproblemen gevonden.');
    }
    return BqListCard(
      children: [
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(issue.label, style: AppTheme.bodyStrong),
                    ),
                    const SizedBox(width: 8),
                    AdminStatusPill(
                      label: issue.status == 'fail' ? 'Kapot' : 'Let op',
                      status: issue.status,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(issue.detail, style: AppTheme.caption),
                if (issue.action != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    issue.action!,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
