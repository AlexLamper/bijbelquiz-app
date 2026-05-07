import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../data/purchase_service.dart';
import 'premium_controller.dart';

enum _PremiumPlan { monthly, lifetime }

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  _PremiumPlan _selectedPlan = _PremiumPlan.monthly;

  void _showSuccess(bool isPremium) {
    if (isPremium) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Welkom bij Premium! 🎉'),
          content: const Text(
            'Je hebt nu volledige toegang tot alle premium functies. Veel plezier!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text('Super!'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aankopen hersteld.')),
      );
    }
  }

  void _onPurchase() {
    final notifier = ref.read(premiumControllerProvider.notifier);
    if (_selectedPlan == _PremiumPlan.monthly) {
      notifier.purchaseMonthly();
    } else {
      notifier.purchaseLifetime();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PremiumState>(premiumControllerProvider, (prev, next) {
      if (next.status == PurchaseStatus.success) {
        _showSuccess(next.isPremium);
        ref.read(premiumControllerProvider.notifier).clearStatus();
      } else if (next.status == PurchaseStatus.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(premiumControllerProvider.notifier).clearStatus();
      }
    });

    final premiumState = ref.watch(premiumControllerProvider);
    final isLoading = premiumState.status == PurchaseStatus.loading;

    final monthlyPackage = premiumState.packages
        .cast<Package?>()
        .firstWhere(
          (p) => p?.storeProduct.identifier == kRcMonthlyProductId,
          orElse: () => null,
        );
    final lifetimePackage = premiumState.packages
        .cast<Package?>()
        .firstWhere(
          (p) => p?.storeProduct.identifier == kRcLifetimeProductId,
          orElse: () => null,
        );

    final monthlyPrice = monthlyPackage?.storeProduct.priceString ?? '€5,99';
    final lifetimePrice = lifetimePackage?.storeProduct.priceString ?? '€74,99';

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Premium',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTheme.sansFontName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _PremiumHeroCard(),
            const SizedBox(height: 16),
            const _BenefitsCard(),
            const SizedBox(height: 18),
            const Text(
              'Kies je plan',
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.sansFontName,
              ),
            ),
            const SizedBox(height: 10),
            _PlanCard(
              title: 'Maandelijks',
              subtitle: 'Flexibel opzegbaar, volledige toegang',
              price: monthlyPrice,
              billingLabel: 'per maand',
              badge: 'Aanbevolen',
              selected: _selectedPlan == _PremiumPlan.monthly,
              onTap: () => setState(() => _selectedPlan = _PremiumPlan.monthly),
            ),
            const SizedBox(height: 10),
            _PlanCard(
              title: 'Lifetime toegang',
              subtitle: 'Eenmalig betalen, altijd premium',
              price: lifetimePrice,
              billingLabel: 'eenmalig',
              selected: _selectedPlan == _PremiumPlan.lifetime,
              onTap: () => setState(() => _selectedPlan = _PremiumPlan.lifetime),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _onPurchase,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.workspace_premium_rounded),
                label: Text(
                  isLoading
                      ? 'Verwerken…'
                      : 'Ga verder met ${_selectedPlan == _PremiumPlan.monthly ? 'Maandelijks' : 'Lifetime'}',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () => ref
                        .read(premiumControllerProvider.notifier)
                        .restorePurchases(),
                child: const Text('Aankopen herstellen'),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Betaling loopt via je app store account. Je kunt je maandabonnement op elk moment opzeggen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero card ────────────────────────────────────────────────────────────────

class _PremiumHeroCard extends StatelessWidget {
  const _PremiumHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4E66B8), Color(0xFF7F9CEF)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E66B8).withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -42,
            left: -26,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Bijbelquiz Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Speel zonder limieten',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFamily: AppTheme.sansFontName,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ontgrendel hosten, exclusieve quizzen en extra voortgangsfuncties voor jouw account.',
                style: TextStyle(
                  color: Color(0xFFE9EEFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Benefits ─────────────────────────────────────────────────────────────────

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        children: [
          _BenefitRow(
            icon: Icons.groups_2_rounded,
            title: 'Start je eigen multiplayer kamers',
          ),
          SizedBox(height: 10),
          _BenefitRow(
            icon: Icons.quiz_outlined,
            title: 'Toegang tot premium quizcollecties',
          ),
          SizedBox(height: 10),
          _BenefitRow(
            icon: Icons.bolt_rounded,
            title: 'Snellere voortgang met extra beloningen',
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.accentSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.accent, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Plan card ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.billingLabel,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String price;
  final String billingLabel;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppTheme.accent : const Color(0xFFB9C3D8),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  billingLabel,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
