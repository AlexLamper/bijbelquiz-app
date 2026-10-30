import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_widgets.dart';
import '../../../../core/ui/bq.dart';
import '../../../quiz/data/quiz_repository.dart';
import '../../../quiz/domain/quiz.dart';
import '../../../quiz/present/quiz_order.dart';
import '../../domain/multiplayer_models.dart';
import 'mp_ui.dart';

/// Premium quizzes are excluded from the multiplayer picker: a host must not
/// be able to route a whole room past the premium-quiz gate.
const QuizQuery multiplayerQuizQuery = QuizQuery(
  limit: 25,
  includePremium: false,
);

/// Room sizes offered, matching `PLAYER_OPTIONS` on the website. The last rung
/// is replaced by whatever ceiling the server reports for Premium.
const List<int> _basePlayerOptions = [2, 3, 4, 6, 8, 10, 12];

/// Seconds per question the host may pick. `0` hands every step to the host.
const List<int> _tempoOptions = [0, 30, 60, 90];

/// What the host picked in the sheet.
class HostSetup {
  const HostSetup({
    required this.quiz,
    required this.maxPlayers,
    required this.readChapterFirst,
    required this.questionTimerSeconds,
    this.upgradeRequested = false,
  });

  final Quiz quiz;
  final int maxPlayers;

  /// Show the Bible chapter before the first question. The server ignores
  /// this when the quiz has no single resolvable chapter.
  final bool readChapterFirst;

  /// Seconds per question. `0` = the host advances every step by hand.
  final int questionTimerSeconds;

  /// The host tapped the "vraagt om Premium" line: open the paywall instead
  /// of making a room.
  final bool upgradeRequested;
}

/// "Kies een quiz" - step 1 picks the quiz, step 2 holds the host options
/// (room size, read the chapter first, tempo) that the redesigned Samen
/// spelen card has no room for.
///
/// With [showOptions] false the sheet closes as soon as a quiz is tapped
/// (changing the quiz from the lobby keeps the room's own settings).
Future<HostSetup?> showHostSetupSheet(
  BuildContext context, {
  String? initialQuizId,
  int initialMaxPlayers = 4,
  bool initialReadChapterFirst = false,
  int initialQuestionTimerSeconds = 0,
  MultiplayerCapability? capability,
  bool showOptions = true,
  String confirmLabel = 'Kamer maken',
  String? hint,
}) {
  return showModalBottomSheet<HostSetup>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppTheme.paperRaised,
    builder: (_) => _HostSetupSheet(
      initialQuizId: initialQuizId,
      initialMaxPlayers: initialMaxPlayers,
      initialReadChapterFirst: initialReadChapterFirst,
      initialQuestionTimerSeconds: initialQuestionTimerSeconds,
      capability: capability,
      showOptions: showOptions,
      confirmLabel: confirmLabel,
      hint: hint,
    ),
  );
}

class _HostSetupSheet extends ConsumerStatefulWidget {
  const _HostSetupSheet({
    required this.initialQuizId,
    required this.initialMaxPlayers,
    required this.initialReadChapterFirst,
    required this.initialQuestionTimerSeconds,
    required this.capability,
    required this.showOptions,
    required this.confirmLabel,
    required this.hint,
  });

  final String? initialQuizId;
  final int initialMaxPlayers;
  final bool initialReadChapterFirst;
  final int initialQuestionTimerSeconds;
  final MultiplayerCapability? capability;
  final bool showOptions;
  final String confirmLabel;
  final String? hint;

  @override
  ConsumerState<_HostSetupSheet> createState() => _HostSetupSheetState();
}

class _HostSetupSheetState extends ConsumerState<_HostSetupSheet> {
  late String? _quizId = widget.initialQuizId;
  late int _maxPlayers = widget.initialMaxPlayers;
  late bool _readChapterFirst = widget.initialReadChapterFirst;
  late int _tempo = widget.initialQuestionTimerSeconds;

  Quiz? _quiz;
  bool _onOptions = false;

  void _pickQuiz(Quiz quiz) {
    if (!widget.showOptions) {
      Navigator.of(context).pop(
        HostSetup(
          quiz: quiz,
          maxPlayers: _maxPlayers,
          readChapterFirst: _readChapterFirst,
          questionTimerSeconds: _tempo,
        ),
      );
      return;
    }
    setState(() {
      _quizId = quiz.id;
      _quiz = quiz;
      _onOptions = true;
    });
  }

  void _confirm({bool upgrade = false}) {
    final quiz = _quiz;
    if (quiz == null) return;
    Navigator.of(context).pop(
      HostSetup(
        quiz: quiz,
        maxPlayers: _maxPlayers,
        readChapterFirst: _readChapterFirst,
        questionTimerSeconds: _tempo,
        upgradeRequested: upgrade,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.ruleStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
            child: Row(
              children: [
                if (_onOptions) ...[
                  BqCircleButton(
                    icon: BqIcons.chevronLeft,
                    label: 'Andere quiz kiezen',
                    onTap: () => setState(() => _onOptions = false),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _onOptions ? 'Kamer instellen' : 'Kies een quiz',
                        style: AppTheme.displayTitle.copyWith(fontSize: 20),
                      ),
                      if (!_onOptions && widget.hint != null)
                        Text(widget.hint!, style: AppTheme.caption),
                    ],
                  ),
                ),
                BqCircleButton(
                  icon: BqIcons.close,
                  label: 'Sluiten',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
          Flexible(child: _onOptions ? _buildOptions() : _buildQuizList()),
          if (_onOptions)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.ruleSoft)),
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: BqButton(
                    label: widget.confirmLabel,
                    onPressed: _quiz == null ? null : _confirm,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Step 1 - quiz list
  // -------------------------------------------------------------------------

  Widget _buildQuizList() {
    final quizzesAsync = ref.watch(quizzesProvider(multiplayerQuizQuery));

    return quizzesAsync.when(
      data: (catalogue) {
        // Bible order, chapters as numbers, like the library.
        final quizzes = sortedInBibleOrder(catalogue);
        if (quizzes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Text(
              'Geen quizzen gevonden om een kamer te starten.',
              style: AppTheme.bodyMuted,
            ),
          );
        }

        return SafeArea(
          top: false,
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: quizzes.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, thickness: 1, color: AppTheme.ruleSoft),
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return _QuizPickRow(
                quiz: quiz,
                selected: quiz.id == _quizId,
                onTap: () => _pickQuiz(quiz),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 140, child: AppLoader(size: 24)),
      error: (error, _) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: MpNotice(
          title: 'Kan quizzen niet laden',
          message: 'Controleer je verbinding en probeer het opnieuw.',
          action: MpSecondaryButton(
            label: 'Opnieuw proberen',
            height: 44,
            expand: false,
            fontSize: 14,
            onPressed: () => ref.invalidate(
              quizzesProvider(multiplayerQuizQuery),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Step 2 - host options
  // -------------------------------------------------------------------------

  Widget _buildOptions() {
    final quiz = _quiz!;
    final capability = widget.capability;
    final isPremiumHost = capability?.isPremium ?? false;
    final maxPlayersFree = capability?.maxPlayersFree ?? 4;
    final maxPlayersPremium = capability?.maxPlayersPremium ?? 20;
    final freeGamesLeft = capability?.freeRoomsRemaining;

    // The premium ceiling replaces the last rung rather than being appended,
    // so a server that lowers it never leaves an unreachable option behind.
    final playerOptions = <int>{
      ..._basePlayerOptions.where((count) => count < maxPlayersPremium),
      maxPlayersPremium,
    }.toList()..sort();
    if (!playerOptions.contains(_maxPlayers)) {
      _maxPlayers = playerOptions.contains(maxPlayersFree)
          ? maxPlayersFree
          : playerOptions.first;
    }
    final playerCapExceeded = !isPremiumHost && _maxPlayers > maxPlayersFree;

    final passage = quiz.passage;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MpQuizRow(
            title: quiz.title,
            subtitle: _quizSubtitle(quiz),
            trailing: MpTextLink(
              label: 'Wijzig',
              onTap: () => setState(() => _onOptions = false),
            ),
          ),
          const SizedBox(height: 20),
          MpSectionLabel(
            'Aantal spelers',
            trailing: Text(
              'Max. $_maxPlayers',
              style: AppTheme.caption.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final width = (constraints.maxWidth - gap * 3) / 4;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final count in playerOptions)
                    SizedBox(
                      width: width,
                      child: _OptionChip(
                        label: '$count',
                        semanticsLabel:
                            !isPremiumHost && count > maxPlayersFree
                            ? '$count spelers, Premium'
                            : '$count spelers',
                        selected: _maxPlayers == count,
                        locked: !isPremiumHost && count > maxPlayersFree,
                        onTap: () => setState(() => _maxPlayers = count),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            isPremiumHost
                ? 'Jij bent de host en kunt tot $maxPlayersPremium spelers '
                      'uitnodigen.'
                : 'Gratis tot $maxPlayersFree spelers. Een gratis spel telt '
                      'pas mee als je het spel echt start.',
            style: AppTheme.caption,
          ),
          // One line, not a second paywall block: the host only needs to know
          // this number is out of reach and what buys it.
          if (playerCapExceeded) ...[
            const SizedBox(height: 6),
            Semantics(
              button: true,
              child: InkWell(
                onTap: () => _confirm(upgrade: true),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$_maxPlayers spelers vraagt om Premium. Gratis speel je '
                      'tot $maxPlayersFree spelers.',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.lapis,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.lapis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (freeGamesLeft != null && freeGamesLeft > 2) ...[
            const SizedBox(height: 4),
            Text(
              'Je hebt nog $freeGamesLeft gratis spellen om te hosten.',
              style: AppTheme.caption,
            ),
          ],
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 1, color: AppTheme.ruleSoft),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lees eerst het hoofdstuk',
                      style: AppTheme.bodyStrong,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      passage != null
                          ? 'Iedereen leest eerst ${passage.label}.'
                          : 'Werkt alleen bij quizzen over 1 hoofdstuk.',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: _readChapterFirst,
                onChanged: (value) => setState(() => _readChapterFirst = value),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: AppTheme.ruleSoft),
          const SizedBox(height: 16),
          const MpSectionLabel('Tempo per vraag'),
          const SizedBox(height: 8),
          _TempoToggle(
            value: _tempo,
            onChanged: (seconds) => setState(() => _tempo = seconds),
          ),
          const SizedBox(height: 8),
          Text(
            _tempo == 0
                ? 'Jij gaat zelf door naar de antwoorden en de volgende vraag.'
                : 'Iedereen krijgt $_tempo seconden per vraag.',
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }
}

String _quizSubtitle(Quiz quiz) {
  // The label is written for an uppercase badge; here it reads as a word.
  final difficulty = quiz.difficultyLabelNl.trim();
  final parts = <String>[
    if (quiz.questionCount > 0)
      quiz.questionCount == 1 ? '1 vraag' : '${quiz.questionCount} vragen',
    if (difficulty.isNotEmpty)
      '${difficulty[0].toUpperCase()}${difficulty.substring(1).toLowerCase()}',
  ];
  return parts.join(' · ');
}

class _QuizPickRow extends StatelessWidget {
  const _QuizPickRow({
    required this.quiz,
    required this.selected,
    required this.onTap,
  });

  final Quiz quiz;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              MpQuizTile(title: quiz.title),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.bodyStrong,
                    ),
                    Text(_quizSubtitle(quiz), style: AppTheme.caption),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (selected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppTheme.lapis,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const BqIcon(
                    BqIcons.check,
                    size: 14,
                    color: AppTheme.inkInverted,
                  ),
                )
              else
                const BqIcon(
                  BqIcons.chevronRight,
                  size: 18,
                  color: AppTheme.inkFaint,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Room-size chip: 44px, lapis when picked, a lock on Premium-only sizes.
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.semanticsLabel,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final String label;
  final String semanticsLabel;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppTheme.lapisStrong : AppTheme.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppTheme.lapisTint : AppTheme.paperRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: BorderSide(
            color: selected ? AppTheme.lapis : AppTheme.rule,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (locked) ...[
                  BqIcon(BqIcons.lock, size: 13, color: AppTheme.goldText),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented tempo picker, styled like the Ranglijst period toggle.
class _TempoToggle extends StatelessWidget {
  const _TempoToggle({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE0DDD5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tempoOptions.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              flex: _tempoOptions[i] == 0 ? 5 : 3,
              child: _TempoSegment(
                label: _tempoOptions[i] == 0
                    ? 'Host bepaalt'
                    : '${_tempoOptions[i]}s',
                semanticsLabel: _tempoOptions[i] == 0
                    ? 'Host bepaalt het tempo'
                    : '${_tempoOptions[i]} seconden per vraag',
                selected: value == _tempoOptions[i],
                onTap: () => onChanged(_tempoOptions[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TempoSegment extends StatelessWidget {
  const _TempoSegment({
    required this.label,
    required this.semanticsLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String semanticsLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.paperRaised : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppTheme.rule : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              color: selected ? AppTheme.lapis : AppTheme.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}
