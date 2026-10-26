import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import '../../profile/present/profile_provider.dart';
import '../data/group_license_repository.dart';
import 'widgets/paywall_parts.dart';

const String _supportEmail = 'info@bijbelquiz.com';

/// Redeem a group code, and see the group you are in.
///
/// Buying a licence is deliberately a website job: an App Store purchase is
/// tied to one Apple ID and cannot hand Premium to thirty other accounts, so
/// the buy path opens the browser instead of an in-app product.
class GroupLicenseScreen extends ConsumerStatefulWidget {
  const GroupLicenseScreen({super.key});

  @override
  ConsumerState<GroupLicenseScreen> createState() => _GroupLicenseScreenState();
}

class _GroupLicenseScreenState extends ConsumerState<GroupLicenseScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length < 4) {
      AppNotice.info(context, 'Vul de volledige groepscode in.');
      return;
    }

    setState(() => _isJoining = true);

    try {
      final license = await ref.read(groupLicenseRepositoryProvider).join(code);

      // Premium is inherited from the group, so the profile has to be re-read
      // before any screen decides what this account may do.
      ref.invalidate(profileProvider);
      ref.invalidate(groupLicensesProvider);

      if (!mounted) return;
      _codeController.clear();
      AppNotice.success(context, 'Je hoort nu bij ${license.name}.');
    } on GroupLicenseException catch (error) {
      if (!mounted) return;
      AppNotice.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  Future<void> _openWebPurchase() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/groepslicentie');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      AppNotice.info(
        context,
        'Ga naar bijbelquiz.com/groepslicentie in je browser.',
      );
    }
  }

  Future<void> _mailSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: const {'subject': 'Groepslicentie'},
    );
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      AppNotice.info(context, 'Mail ons op $_supportEmail.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final licensesAsync = ref.watch(groupLicensesProvider);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const BqTopBar(title: 'Groepslicentie', large: true),
            const SizedBox(height: 14),
            const Text(
              'Heeft je jeugdleider, dominee of docent een groepscode? Vul hem '
              'hieronder in en je hebt meteen Premium.',
              style: AppTheme.bodyLead,
            ),
            const SizedBox(height: 18),
            BqCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _CardHeading(
                    icon: BqIcons.enter,
                    title: 'Meedoen met code',
                    subtitle: 'Premium via je groep',
                  ),
                  const SizedBox(height: 16),
                  _CodeField(
                    controller: _codeController,
                    enabled: !_isJoining,
                    onSubmitted: (_) => _join(),
                  ),
                  const SizedBox(height: 12),
                  BqButton(
                    label: 'Meedoen',
                    style: BqButtonStyle.tint,
                    loading: _isJoining,
                    onPressed: _isJoining ? null : _join,
                  ),
                ],
              ),
            ),
            licensesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (licenses) {
                if (licenses.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BqSectionHeader(title: 'Jouw groepen'),
                      const SizedBox(height: 10),
                      for (final license in licenses) ...[
                        _LicenseCard(license: license),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            BqCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _CardHeading(
                    icon: BqIcons.users,
                    iconColor: AppTheme.goldText,
                    tint: AppTheme.goldTint,
                    title: 'Premium voor je hele groep',
                    subtitle: 'Voor kerken, scholen en verenigingen',
                  ),
                  const SizedBox(height: 16),
                  const _Benefit('Alles van Premium voor elk lid'),
                  const SizedBox(height: 8),
                  const _Benefit('Een code die je voorleest in de zaal'),
                  const SizedBox(height: 8),
                  const _Benefit('Je beheert zelf wie er meedoet'),
                  const SizedBox(height: 14),
                  const Text(
                    'Een groepslicentie koop je op de website, omdat een '
                    'aankoop in de App Store aan een enkel account vastzit en '
                    'niet aan een groep.',
                    style: AppTheme.bodyMuted,
                  ),
                  const SizedBox(height: 14),
                  BqButton(
                    label: 'Open bijbelquiz.com',
                    icon: const BqIcon(BqIcons.link, size: 18),
                    onPressed: _openWebPurchase,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Semantics(
              link: true,
              label: 'Liever eerst overleggen? Mail $_supportEmail',
              onTap: _mailSupport,
              excludeSemantics: true,
              child: InkWell(
                onTap: _mailSupport,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Center(
                    child: Text.rich(
                      const TextSpan(
                        children: [
                          TextSpan(text: 'Liever eerst overleggen? Mail '),
                          TextSpan(
                            text: _supportEmail,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.lapis,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: AppTheme.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tint = AppTheme.lapisTint,
    this.iconColor = AppTheme.lapis,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BqIconTile(
          background: tint,
          child: BqIcon(icon, size: 22, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.displayTitle),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTheme.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PaywallCheck(size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 20 / 14,
                color: AppTheme.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      borderSide: const BorderSide(color: AppTheme.ruleStrong),
    );

    return TextField(
      controller: controller,
      enabled: enabled,
      textAlign: TextAlign.center,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enableSuggestions: false,
      onSubmitted: onSubmitted,
      cursorColor: AppTheme.lapis,
      style: const TextStyle(
        fontFamily: AppTheme.displayFontName,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 3,
        color: AppTheme.ink,
      ),
      decoration: InputDecoration(
        hintText: 'Bijv. K7PQ2M',
        hintStyle: const TextStyle(
          fontFamily: AppTheme.sansFontName,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: AppTheme.inkFaint,
        ),
        filled: true,
        fillColor: AppTheme.paperRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: border,
        enabledBorder: border,
        disabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppTheme.lapis, width: 2),
        ),
      ),
    );
  }
}

class _LicenseCard extends StatelessWidget {
  const _LicenseCard({required this.license});

  final GroupLicenseSummary license;

  @override
  Widget build(BuildContext context) {
    final expiry = license.expiresAt;
    final showCode = license.isOwner && license.joinCode.isNotEmpty;

    return BqCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BqPill(
            label: license.isOwner ? 'Je beheert deze groep' : 'Je doet mee',
            background: AppTheme.positiveTint,
            foreground: AppTheme.positive,
            icon: const BqIcon(
              BqIcons.check,
              size: 14,
              color: AppTheme.positive,
            ),
          ),
          const SizedBox(height: 10),
          Text(license.name, style: AppTheme.displayTitle),
          const SizedBox(height: 4),
          Text(
            '${license.seatsUsed} van ${license.seats} plekken bezet'
            '${expiry == null ? '' : ' - loopt tot ${_formatDate(expiry)}'}',
            style: AppTheme.bodyMuted,
          ),
          if (showCode) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text('Groepscode', style: AppTheme.bodyMuted),
                ),
                Text(
                  license.joinCode,
                  style: const TextStyle(
                    fontFamily: AppTheme.displayFontName,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppTheme.lapis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'januari',
      'februari',
      'maart',
      'april',
      'mei',
      'juni',
      'juli',
      'augustus',
      'september',
      'oktober',
      'november',
      'december',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
