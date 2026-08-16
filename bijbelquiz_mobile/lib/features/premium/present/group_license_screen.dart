import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/custom_text_field.dart';
import '../../../core/ui/primary_button.dart';
import '../../profile/present/profile_provider.dart';
import '../data/group_license_repository.dart';

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
      final license = await ref
          .read(groupLicenseRepositoryProvider)
          .join(code);

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
      AppNotice.info(context, 'Ga naar bijbelquiz.com/groepslicentie in je browser.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final licensesAsync = ref.watch(groupLicensesProvider);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        backgroundColor: AppTheme.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Groepslicentie', style: AppTheme.displaySmall),
        iconTheme: const IconThemeData(color: AppTheme.ink),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          const SectionHeader(
            eyebrow: 'Samen',
            title: 'Premium voor je hele groep',
            description:
                'Heeft je jeugdleider, dominee of docent een groepscode? Vul '
                'hem hieronder in en je hebt meteen Premium.',
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _codeController,
            label: 'Groepscode',
            hintText: 'Bijv. K7PQ2M',
            enabled: !_isJoining,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Meedoen',
            isLoading: _isJoining,
            onPressed: _join,
          ),
          const SizedBox(height: 32),
          licensesAsync.when(
            loading: () => const AppLoader(size: 20),
            error: (_, __) => const SizedBox.shrink(),
            data: (licenses) {
              if (licenses.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(eyebrow: 'Jouw groepen', title: 'Je doet mee'),
                  const SizedBox(height: 20),
                  for (final license in licenses) ...[
                    _LicenseCard(license: license),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const RuleLine(),
          const SizedBox(height: 20),
          const Text('EEN LICENTIE KOPEN', style: AppTheme.overline),
          const SizedBox(height: 10),
          const Text(
            'Een groepslicentie koop je op de website, omdat een aankoop in de '
            'App Store aan een enkel account vastzit en niet aan een groep.',
            style: AppTheme.bodyMuted,
          ),
          const SizedBox(height: 14),
          SiteOutlineButton(
            label: 'Open bijbelquiz.com',
            icon: Icons.open_in_new,
            onPressed: _openWebPurchase,
          ),
        ],
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.positiveTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.positive.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            license.isOwner ? 'JE BEHEERT DEZE GROEP' : 'JE DOET MEE',
            style: AppTheme.overline.copyWith(color: AppTheme.positive),
          ),
          const SizedBox(height: 8),
          Text(license.name, style: AppTheme.displaySmall),
          const SizedBox(height: 6),
          Text(
            '${license.seatsUsed} van ${license.seats} plekken bezet'
            '${expiry == null ? '' : ' - loopt tot ${_formatDate(expiry)}'}',
            style: AppTheme.bodyMuted,
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'januari', 'februari', 'maart', 'april', 'mei', 'juni',
      'juli', 'augustus', 'september', 'oktober', 'november', 'december',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
