import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
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
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text(
              'Speel Samen',
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.sansFontName,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ModeCard(
                    active: _mode == _PlayMode.create,
                    title: 'Kamer Maken',
                    subtitle: hostingLocked
                        ? 'Alleen voor premium'
                        : 'Host een match',
                    icon: Icons.add_rounded,
                    locked: hostingLocked,
                    badgeLabel: hostingLocked ? 'Premium' : null,
                    onTap: () {
                      setState(() {
                        _mode = _PlayMode.create;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeCard(
                    active: _mode == _PlayMode.join,
                    title: 'Deelnemen',
                    subtitle: 'Gebruik code',
                    icon: Icons.group_add_rounded,
                    onTap: () {
                      setState(() {
                        _mode = _PlayMode.join;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
            const SizedBox(height: 14),
            const _HowItWorksCard(),
            const SizedBox(height: 14),
            _QuickStartQuizzesCard(
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.active,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.badgeLabel,
    this.locked = false,
  });

  final bool active;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? badgeLabel;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final cardColor = active ? AppTheme.accent : Colors.white;
    final titleColor = active ? Colors.white : AppTheme.ink;
    final subtitleColor = active ? const Color(0xFFE9EFFF) : AppTheme.muted;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 132,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? AppTheme.accent : AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: 0.24)
                    : AppTheme.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                locked ? Icons.lock_rounded : icon,
                size: 18,
                color: active ? Colors.white : AppTheme.accent,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (badgeLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withValues(alpha: 0.24)
                          : const Color(0xFFE8EEFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeLabel!,
                      style: TextStyle(
                        color: active ? Colors.white : AppTheme.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCDD9F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: AppTheme.accent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hosten is Premium',
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Upgrade om je eigen kamer te starten, quiz te kiezen en vrienden live uit te dagen.',
              style: TextStyle(
                color: AppTheme.muted,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Je kunt nog steeds gratis deelnemen met een kamercode.',
              style: TextStyle(color: AppTheme.muted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onUpgrade,
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('Bekijk Premium'),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nieuwe kamer',
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          quizzesAsync.when(
            data: (quizzes) {
              if (quizzes.isEmpty) {
                return const Text(
                  'Geen quizzen gevonden om een kamer te starten.',
                  style: TextStyle(color: AppTheme.muted),
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
                children: [
                  DropdownButtonFormField<String>(
                    value: effectiveValue,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Kies een quiz',
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isBusy ? null : onCreateRoom,
                      icon: isBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.rocket_launch_rounded),
                      label: const Text('Start kamer'),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Text(
              'Fout bij laden quizzen: $err',
              style: const TextStyle(color: Colors.redAccent),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deelnemen met code',
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: !isBusy,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'Bijv. AB12CD',
              prefixIcon: Icon(Icons.vpn_key_rounded),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isBusy ? null : onJoin,
              icon: const Icon(Icons.meeting_room_rounded),
              label: const Text('Deelnemen'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoe Het Werkt',
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12),
          _StepTile(
            icon: Icons.add_circle_outline_rounded,
            title: '1. Maak of join een kamer',
            subtitle: 'De host kiest een quiz en deelt de code.',
          ),
          SizedBox(height: 10),
          _StepTile(
            icon: Icons.timer_outlined,
            title: '2. Speel live tegelijk',
            subtitle: 'Iedereen krijgt dezelfde vragen en timer.',
          ),
          SizedBox(height: 10),
          _StepTile(
            icon: Icons.emoji_events_outlined,
            title: '3. Bekijk de eindranglijst',
            subtitle: 'Vergelijk scores en daag elkaar opnieuw uit.',
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppTheme.accentSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppTheme.accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickStartQuizzesCard extends StatelessWidget {
  const _QuickStartQuizzesCard({
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start een kamer',
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kies direct een quiz en open meteen een nieuwe kamer.',
            style: TextStyle(
              color: AppTheme.muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          quizzesAsync.when(
            data: (quizzes) {
              if (quizzes.isEmpty) {
                return const Text(
                  'Geen quizzen beschikbaar om een kamer te starten.',
                  style: TextStyle(color: AppTheme.muted),
                );
              }

              final visible = quizzes.take(4).toList();

              return Column(
                children: visible.map((quiz) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: AppTheme.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quiz.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${quiz.questionCount} vragen',
                                style: const TextStyle(
                                  color: AppTheme.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: isBusy
                              ? null
                              : hasPremiumAccess
                              ? () => onStartRoom(quiz.id)
                              : onUpgrade,
                          icon: Icon(
                            hasPremiumAccess
                                ? Icons.play_arrow_rounded
                                : Icons.lock_rounded,
                            size: 16,
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(112, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          label: Text(
                            hasPremiumAccess ? 'Start kamer' : 'Premium',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Text(
              'Kan kamers niet laden: $err',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
