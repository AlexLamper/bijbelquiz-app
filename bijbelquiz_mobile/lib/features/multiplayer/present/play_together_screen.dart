import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../profile/present/profile_provider.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/domain/quiz.dart';
import 'multiplayer_action_controller.dart';

enum _PlayMode { create, join }

class PlayTogetherScreen extends ConsumerStatefulWidget {
  const PlayTogetherScreen({super.key});

  @override
  ConsumerState<PlayTogetherScreen> createState() => _PlayTogetherScreenState();
}

class _PlayTogetherScreenState extends ConsumerState<PlayTogetherScreen> {
  final TextEditingController _roomCodeController = TextEditingController();

  String? _selectedQuizId;
  _PlayMode _mode = _PlayMode.create;

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_selectedQuizId == null || _selectedQuizId!.isEmpty) {
      _showMessage('Selecteer eerst een quiz.');
      return;
    }

    try {
      final profile = await ref.read(profileProvider.future);
      if (!profile.isPremium) {
        if (!mounted) return;
        _showMessage('Kamer hosten is een premium functie.');
        context.push('/premium');
        return;
      }

      final room = await ref
          .read(multiplayerActionControllerProvider.notifier)
          .createRoom(
            quizId: _selectedQuizId!,
            hasPremiumAccess: profile.isPremium,
          );
      if (!mounted) return;
      context.push('/play-together/room/${room.code}');
    } catch (error) {
      final message = _toMessage(error);
      if (message.toLowerCase().contains('premium')) {
        if (!mounted) return;
        _showMessage('Kamer hosten is een premium functie.');
        context.push('/premium');
        return;
      }

      _showMessage(message);
    }
  }

  Future<void> _joinRoom() async {
    final roomCode = _roomCodeController.text
        .trim()
        .replaceAll(' ', '')
        .toUpperCase();

    if (roomCode.isEmpty) {
      _showMessage('Voer een kamercode in.');
      return;
    }

    if (roomCode.length < 4) {
      _showMessage('Kamercode lijkt te kort. Controleer de code.');
      return;
    }

    try {
      final room = await ref
          .read(multiplayerActionControllerProvider.notifier)
          .joinRoom(roomCode: roomCode);
      if (!mounted) return;
      context.push('/play-together/room/${room.code}');
    } catch (error) {
      _showMessage(_toMessage(error));
    }
  }

  Future<void> _startRoomForQuiz(String quizId) async {
    setState(() {
      _mode = _PlayMode.create;
      _selectedQuizId = quizId;
    });

    await _createRoom();
  }

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = ref.watch(quizzesProvider(const QuizQuery(limit: 25)));
    final actionState = ref.watch(multiplayerActionControllerProvider);
    final profileAsync = ref.watch(profileProvider);
    final bool? hasPremiumAccess = profileAsync.asData?.value.isPremium;
    final hostingLocked = hasPremiumAccess == false;

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            const GradientHeader(
              eyebrow: 'Samen spelen',
              title: 'Speciaal ontworpen voor groepen',
              subtitle:
                  'Van gezin tot jeugdvereniging — iedereen speelt mee. Geen '
                  'installatie, gewoon een code delen en direct beginnen.',
            ),
            const SizedBox(height: 28),
            // Mode toggle — same button pair as the site's filter row.
            Row(
              children: [
                _ModeButton(
                  label: 'Kamer maken',
                  active: _mode == _PlayMode.create,
                  locked: hostingLocked,
                  onTap: () => setState(() => _mode = _PlayMode.create),
                ),
                const SizedBox(width: 8),
                _ModeButton(
                  label: 'Deelnemen',
                  active: _mode == _PlayMode.join,
                  onTap: () => setState(() => _mode = _PlayMode.join),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _mode == _PlayMode.create
                  ? _CreateRoomForm(
                      key: const ValueKey('create-form'),
                      quizzesAsync: quizzesAsync,
                      selectedQuizId: _selectedQuizId,
                      isBusy: actionState.isLoading,
                      hasPremiumAccess: !hostingLocked,
                      onSelectQuiz: (id) {
                        setState(() {
                          _selectedQuizId = id;
                        });
                      },
                      onCreateRoom: _createRoom,
                      onUpgrade: () {
                        context.push('/premium');
                      },
                    )
                  : _JoinRoomForm(
                      key: const ValueKey('join-form'),
                      controller: _roomCodeController,
                      isBusy: actionState.isLoading,
                      onJoin: _joinRoom,
                    ),
            ),
            const SizedBox(height: 44),
            const SectionHeader(
              eyebrow: 'Zo werkt het',
              title: 'In drie stappen',
            ),
            const SizedBox(height: 24),
            const _HowItWorksGrid(),
            const SizedBox(height: 44),
            SectionHeader(
              eyebrow: 'Snelstart',
              title: 'Start direct een kamer',
              description:
                  'Kies een quiz en open meteen een nieuwe kamer voor je groep.',
            ),
            const SizedBox(height: 24),
            _QuickStartQuizzes(
              quizzesAsync: quizzesAsync,
              isBusy: actionState.isLoading,
              hasPremiumAccess: !hostingLocked,
              onStartRoom: _startRoomForQuiz,
              onUpgrade: () {
                context.push('/premium');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static String _toMessage(Object error) {
    final raw = error.toString();
    if (raw.contains('PREMIUM_REQUIRED')) {
      return 'Kamer hosten is een premium functie.';
    }

    return raw.startsWith('Exception: ')
        ? raw.replaceFirst('Exception: ', '')
        : raw;
  }
}

/// `h-9 rounded-md border-rule bg-paper-raised px-4` / active `bg-ink`.
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.locked = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppTheme.ink : AppTheme.paperRaised,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: onTap,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: active ? AppTheme.ink : AppTheme.rule),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (locked) ...[
                Icon(
                  Icons.lock_outline,
                  size: 13,
                  color: active ? AppTheme.inkInverted : AppTheme.inkMuted,
                ),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  color: active ? AppTheme.inkInverted : AppTheme.ink,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateRoomForm extends StatelessWidget {
  const _CreateRoomForm({
    super.key,
    required this.quizzesAsync,
    required this.selectedQuizId,
    required this.isBusy,
    required this.hasPremiumAccess,
    required this.onSelectQuiz,
    required this.onCreateRoom,
    required this.onUpgrade,
  });

  final AsyncValue<List<Quiz>> quizzesAsync;
  final String? selectedQuizId;
  final bool isBusy;
  final bool hasPremiumAccess;
  final ValueChanged<String?> onSelectQuiz;
  final Future<void> Function() onCreateRoom;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    if (!hasPremiumAccess) {
      // `dark:bg-lapis/10 border-lapis/35` — the site's accent notice block.
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.lapisTint,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.lapis.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Eyebrow('Premium vereist'),
            const SizedBox(height: 16),
            const Text('Hosten is Premium', style: AppTheme.displaySmall),
            const SizedBox(height: 10),
            const Text(
              'Upgrade om je eigen kamer te starten, een quiz te kiezen en '
              'vrienden live uit te dagen. Deelnemen met een kamercode blijft '
              'gratis.',
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 20),
            SiteButton(
              label: 'Bekijk Premium',
              trailingIcon: Icons.arrow_forward,
              onPressed: onUpgrade,
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('NIEUWE KAMER', style: AppTheme.overline),
          const SizedBox(height: 16),
          quizzesAsync.when(
            data: (quizzes) {
              if (quizzes.isEmpty) {
                return const Text(
                  'Geen quizzen gevonden om een kamer te starten.',
                  style: AppTheme.bodyMuted,
                );
              }

              final effectiveValue =
                  (selectedQuizId == null ||
                      quizzes.every((quiz) => quiz.id != selectedQuizId))
                  ? quizzes.first.id
                  : selectedQuizId;

              if (effectiveValue != selectedQuizId) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onSelectQuiz(effectiveValue);
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('KIES EEN QUIZ', style: AppTheme.overline),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: effectiveValue,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppTheme.inkMuted,
                    ),
                    dropdownColor: AppTheme.paperRaised,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 15,
                      color: AppTheme.ink,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                    ),
                    items: quizzes
                        .map(
                          (quiz) => DropdownMenuItem<String>(
                            value: quiz.id,
                            child: Text(
                              quiz.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (context) {
                      return quizzes
                          .map(
                            (quiz) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                quiz.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList();
                    },
                    onChanged: isBusy ? null : onSelectQuiz,
                  ),
                  const SizedBox(height: 20),
                  SiteButton(
                    label: 'Start kamer',
                    trailingIcon: Icons.arrow_forward,
                    loading: isBusy,
                    onPressed: isBusy ? null : onCreateRoom,
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: AppLoader(size: 20),
            ),
            error: (err, _) => Text(
              'Fout bij laden quizzen: $err',
              style: AppTheme.bodyMuted.copyWith(color: AppTheme.destructive),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinRoomForm extends StatelessWidget {
  const _JoinRoomForm({
    super.key,
    required this.controller,
    required this.isBusy,
    required this.onJoin,
  });

  final TextEditingController controller;
  final bool isBusy;
  final Future<void> Function() onJoin;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('DEELNEMEN MET CODE', style: AppTheme.overline),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            enabled: !isBusy,
            textCapitalization: TextCapitalization.characters,
            cursorColor: AppTheme.ink,
            cursorWidth: 1.4,
            textAlign: TextAlign.center,
            // Room codes read as data — serif, tabular, wide tracking.
            style: const TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontSize: 26,
              letterSpacing: 6,
              color: AppTheme.ink,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
            decoration: const InputDecoration(
              hintText: 'AB12CD',
              hintStyle: TextStyle(
                fontFamily: AppTheme.displayFontName,
                fontSize: 26,
                letterSpacing: 6,
                color: AppTheme.ruleStrong,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 18),
            ),
          ),
          const SizedBox(height: 20),
          SiteButton(
            label: 'Deelnemen',
            trailingIcon: Icons.arrow_forward,
            loading: isBusy,
            onPressed: isBusy ? null : onJoin,
          ),
        ],
      ),
    );
  }
}

/// The site's numbered `01 / 02 / 03` process grid.
class _HowItWorksGrid extends StatelessWidget {
  const _HowItWorksGrid();

  @override
  Widget build(BuildContext context) {
    return const RuleGrid(
      children: [
        _StepTile(
          index: '01',
          title: 'Maak of join een kamer',
          subtitle: 'De host kiest een quiz en deelt de code',
        ),
        _StepTile(
          index: '02',
          title: 'Speel live tegelijk',
          subtitle: 'Iedereen krijgt dezelfde vragen en timer',
        ),
        _StepTile(
          index: '03',
          title: 'Bekijk de eindranglijst',
          subtitle: 'Vergelijk scores en daag elkaar opnieuw uit',
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  final String index;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index,
            style: const TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontSize: 14,
              color: AppTheme.lapis,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.displayBase),
                const SizedBox(height: 5),
                Text(subtitle.toUpperCase(), style: AppTheme.overline),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartQuizzes extends StatelessWidget {
  const _QuickStartQuizzes({
    required this.quizzesAsync,
    required this.isBusy,
    required this.hasPremiumAccess,
    required this.onStartRoom,
    required this.onUpgrade,
  });

  final AsyncValue<List<Quiz>> quizzesAsync;
  final bool isBusy;
  final bool hasPremiumAccess;
  final Future<void> Function(String quizId) onStartRoom;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return quizzesAsync.when(
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const AppCard(
            child: Text(
              'Geen quizzen beschikbaar om een kamer te starten.',
              style: AppTheme.bodyMuted,
            ),
          );
        }

        final visible = quizzes.take(4).toList();

        return RuleGrid(
          children: [
            for (final quiz in visible)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.displayBase,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${quiz.questionCount} VRAGEN',
                            style: AppTheme.overline,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SiteOutlineButton(
                      label: hasPremiumAccess ? 'Start' : 'Premium',
                      icon: hasPremiumAccess ? null : Icons.lock_outline,
                      expand: false,
                      height: 36,
                      onPressed: isBusy
                          ? null
                          : hasPremiumAccess
                          ? () => onStartRoom(quiz.id)
                          : onUpgrade,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: AppLoader(size: 20),
      ),
      error: (err, _) => AppCard(
        child: Text(
          'Kan quizzen niet laden: $err',
          style: AppTheme.bodyMuted.copyWith(color: AppTheme.destructive),
        ),
      ),
    );
  }
}
