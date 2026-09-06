import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';

/// A short pre-sell funnel shown before the paywall, in the spirit of
/// bijbelstudie-app's `/pro-intro`: pick a goal, see what Premium does for that
/// goal, then continue to `/premium`. Keeps the paywall itself uncluttered and
/// lets the funnel attribute the sale to a motivation.
class PremiumIntroScreen extends ConsumerStatefulWidget {
  const PremiumIntroScreen({super.key, this.trigger = PaywallTrigger.direct});

  final String trigger;

  @override
  ConsumerState<PremiumIntroScreen> createState() => _PremiumIntroScreenState();
}

enum _Goal { knowledge, habit, together }

class _PremiumIntroScreenState extends ConsumerState<PremiumIntroScreen> {
  final PageController _pages = PageController();
  int _page = 0;
  _Goal _goal = _Goal.knowledge;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).track(
      AnalyticsEvents.paywallShown,
      props: {'trigger': widget.trigger, 'surface': 'premium_intro'},
    );
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _pages.nextPage(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    } else {
      context.replace('/premium?reden=${widget.trigger}');
    }
  }

  List<String> get _benefits {
    switch (_goal) {
      case _Goal.knowledge:
        return const [
          'Uitleg en bijbelverwijzing bij elke vraag',
          'Alle premium quizzen en verdiepingsreeksen',
          'Een volledige review na elke quiz',
        ];
      case _Goal.habit:
        return const [
          'Streakbescherming als je een dag mist',
          'Voortgang per bijbelboek',
          'Nieuwe seizoenspakketten en themaquizzen',
        ];
      case _Goal.together:
        return const [
          'Onbeperkt spellen hosten',
          'Tot 20 spelers tegelijk in een kamer',
          'Meedoen blijft altijd gratis',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.inkSoft),
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go('/home'),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 3; i++)
                          Container(
                            width: 22,
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            color: i <= _page
                                ? AppTheme.ink
                                : AppTheme.rule,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _GoalStep(
                    selected: _goal,
                    onSelect: (g) => setState(() => _goal = g),
                  ),
                  _ValueStep(benefits: _benefits),
                  const _ReadyStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SiteButton(
                label: _page < 2 ? 'Verder' : 'Bekijk Premium',
                trailingIcon: Icons.arrow_forward,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.selected, required this.onSelect});

  final _Goal selected;
  final ValueChanged<_Goal> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const GradientHeader(
          eyebrow: 'Premium',
          title: 'Waar wil je in groeien?',
          subtitle: 'Dan laten we zien wat Premium daarvoor doet.',
        ),
        const SizedBox(height: 24),
        _GoalTile(
          label: 'Meer Bijbelkennis',
          description: 'Begrijpen waarom een antwoord klopt.',
          active: selected == _Goal.knowledge,
          onTap: () => onSelect(_Goal.knowledge),
        ),
        const SizedBox(height: 12),
        _GoalTile(
          label: 'Elke dag iets leren',
          description: 'Een gewoonte opbouwen en vasthouden.',
          active: selected == _Goal.habit,
          onTap: () => onSelect(_Goal.habit),
        ),
        const SizedBox(height: 12),
        _GoalTile(
          label: 'Samen spelen',
          description: 'Met familie of een groep tegen elkaar.',
          active: selected == _Goal.together,
          onTap: () => onSelect(_Goal.together),
        ),
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.label,
    required this.description,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppTheme.lapisTint : AppTheme.paperRaised,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: active ? AppTheme.lapis : AppTheme.rule,
            ),
          ),
          child: Row(
            children: [
              Icon(
                active
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: active ? AppTheme.lapis : AppTheme.inkMuted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTheme.displayBase),
                    const SizedBox(height: 3),
                    Text(description, style: AppTheme.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueStep extends StatelessWidget {
  const _ValueStep({required this.benefits});

  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const GradientHeader(
          eyebrow: 'Met Premium',
          title: 'Dit krijg je erbij',
          subtitle: 'Alles in een lidmaatschap, op web en app.',
        ),
        const SizedBox(height: 24),
        for (final benefit in benefits) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check, size: 18, color: AppTheme.positive),
              const SizedBox(width: 12),
              Expanded(child: Text(benefit, style: AppTheme.bodyLead)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _ReadyStep extends StatelessWidget {
  const _ReadyStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: const [
        GradientHeader(
          eyebrow: 'Bijna klaar',
          title: 'Kies je plan',
          subtitle:
              'Op de volgende pagina zie je de prijzen. Opzeggen kan altijd.',
        ),
        SizedBox(height: 24),
        AppCard(
          child: Text(
            'Je account werkt op web en app tegelijk. Een aankoop op je telefoon '
            'geeft je ook Premium op de website, en andersom.',
            style: AppTheme.bodyMuted,
          ),
        ),
      ],
    );
  }
}
