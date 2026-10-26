import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/bq.dart';
import 'premium_controller.dart';
import 'widgets/paywall_parts.dart';

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

  /// Premium was already active when the screen opened: no pre-sell needed.
  bool _alreadyPremium = false;

  @override
  void initState() {
    super.initState();
    if (hasPremiumAccess(ref)) {
      _alreadyPremium = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      });
      return;
    }
    ref
        .read(analyticsProvider)
        .track(
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
    if (_alreadyPremium) {
      return const Scaffold(backgroundColor: AppTheme.paper);
    }
    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  PaywallCloseButton(
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/home'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Semantics(
                      label: 'Stap ${_page + 1} van 3',
                      child: ExcludeSemantics(
                        child: BqSegments(total: 3, done: _page + 1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
              child: BqButton(
                label: _page < 2 ? 'Verder' : 'Bekijk Premium',
                height: 56,
                fontSize: 17,
                radius: 14,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 33 / 28,
              color: AppTheme.ink,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTheme.bodyLead.copyWith(color: AppTheme.inkMuted),
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        const _StepHeading(
          title: 'Waar wil je in groeien?',
          subtitle: 'Dan laten we zien wat Premium daarvoor doet.',
        ),
        const SizedBox(height: 24),
        _GoalTile(
          icon: BqIcons.book,
          tint: AppTheme.lapisTint,
          iconColor: AppTheme.lapis,
          label: 'Meer Bijbelkennis',
          description: 'Begrijpen waarom een antwoord klopt.',
          active: selected == _Goal.knowledge,
          onTap: () => onSelect(_Goal.knowledge),
        ),
        const SizedBox(height: 12),
        _GoalTile(
          icon: BqIcons.flame,
          tint: AppTheme.coralTint,
          label: 'Elke dag iets leren',
          description: 'Een gewoonte opbouwen en vasthouden.',
          active: selected == _Goal.habit,
          onTap: () => onSelect(_Goal.habit),
        ),
        const SizedBox(height: 12),
        _GoalTile(
          icon: BqIcons.users,
          tint: AppTheme.positiveTint,
          iconColor: AppTheme.positive,
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
    required this.icon,
    required this.tint,
    required this.label,
    required this.description,
    required this.active,
    required this.onTap,
    this.iconColor,
  });

  final String icon;
  final Color tint;
  final Color? iconColor;
  final String label;
  final String description;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      inMutuallyExclusiveGroup: true,
      onTap: onTap,
      label: '$label. $description',
      excludeSemantics: true,
      child: Material(
        color: AppTheme.paperRaised,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          side: active
              ? const BorderSide(color: AppTheme.lapis, width: 2)
              : const BorderSide(color: AppTheme.rule),
        ),
        child: InkWell(
          onTap: onTap,
          highlightColor: AppTheme.ruleSoft.withValues(alpha: 0.6),
          splashColor: AppTheme.ruleSoft,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                BqIconTile(
                  background: tint,
                  size: 40,
                  child: BqIcon(icon, size: 22, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(description, style: AppTheme.caption),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _RadioMark(active: active),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppTheme.lapis : AppTheme.paperRaised,
        border: active
            ? null
            : Border.all(color: AppTheme.ruleStrong, width: 2),
      ),
      child: active
          ? const BqIcon(BqIcons.check, size: 14, color: AppTheme.inkInverted)
          : null,
    );
  }
}

class _ValueStep extends StatelessWidget {
  const _ValueStep({required this.benefits});

  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        const _StepHeading(
          title: 'Dit krijg je erbij',
          subtitle: 'Alles in een lidmaatschap, op web en app.',
        ),
        const SizedBox(height: 24),
        BqCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < benefits.length; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 14),
                  child: Row(
                    children: [
                      const PaywallCheck(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefits[i],
                          style: const TextStyle(
                            fontFamily: AppTheme.sansFontName,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 20 / 15,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadyStep extends StatelessWidget {
  const _ReadyStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: const [
        _StepHeading(
          title: 'Kies je plan',
          subtitle:
              'Op de volgende pagina zie je de prijzen. Opzeggen kan altijd.',
        ),
        SizedBox(height: 24),
        BqCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BqIconTile(
                size: 40,
                child: BqIcon(BqIcons.link, size: 20, color: AppTheme.lapis),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Je account werkt op web en app tegelijk. Een aankoop op je '
                  'telefoon geeft je ook Premium op de website, en andersom.',
                  style: AppTheme.bodyMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
