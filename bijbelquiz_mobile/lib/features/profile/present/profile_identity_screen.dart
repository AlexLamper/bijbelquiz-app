import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/avatar/avatar_catalog.dart';
import '../../../core/avatar/mascot_avatar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/custom_text_field.dart';
import '../../../core/ui/primary_button.dart';
import '../../leaderboard/data/leaderboard_repository.dart';
import '../data/profile_repository.dart';
import 'profile_provider.dart';

/// Name and mascot, the two things a player owns.
///
/// The preview at the top redraws on every tap, so the picker below is a
/// direct manipulation of the figure rather than a form that is only revealed
/// once saved.
class ProfileIdentityScreen extends ConsumerStatefulWidget {
  const ProfileIdentityScreen({super.key});

  @override
  ConsumerState<ProfileIdentityScreen> createState() =>
      _ProfileIdentityScreenState();
}

class _ProfileIdentityScreenState extends ConsumerState<ProfileIdentityScreen> {
  final TextEditingController _nameController = TextEditingController();

  AvatarConfig? _draft;
  String? _savedName;
  int _cooldownDays = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _seedFrom(AvatarConfig avatar, String name, int cooldownDays) {
    if (_draft != null) return;
    _draft = avatar;
    _savedName = name;
    _cooldownDays = cooldownDays;
    _nameController.text = name;
  }

  void _setPart({
    String? character,
    String? color,
    String? background,
    String? accessory,
  }) {
    setState(() {
      _draft = _draft?.copyWith(
        character: character,
        color: color,
        background: background,
        accessory: accessory,
      );
    });
  }

  void _surpriseMe() {
    final random = math.Random();
    T take<T>(List<T> options) => options[random.nextInt(options.length)];

    setState(() {
      _draft = AvatarConfig(
        character: take(avatarCharacters).id,
        color: take(avatarColors).id,
        background: take(avatarBackgrounds).id,
        accessory: take(avatarAccessories).id,
      );
    });
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _isSaving) return;

    final nextName = _nameController.text.trim();
    final nameChanged = nextName != (_savedName ?? '');

    setState(() => _isSaving = true);

    try {
      final result = await ref
          .read(profileRepositoryProvider)
          .updateIdentity(name: nameChanged ? nextName : null, avatar: draft);

      // Name and mascot both show on the ranking, so its cache is dropped as
      // well rather than left showing the previous figure.
      ref.invalidate(profileProvider);
      ref.invalidate(leaderboardProvider);
      ref.invalidate(leaderboardByPeriodProvider);

      if (!mounted) return;
      setState(() {
        _savedName = result.name;
        _cooldownDays = result.nameChangeAllowedInDays;
        _draft = result.avatar;
      });

      AppNotice.success(context, 'Profiel bijgewerkt.');
      Navigator.of(context).pop();
    } on IdentityUpdateException catch (error) {
      if (!mounted) return;
      AppNotice.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        backgroundColor: AppTheme.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profiel bewerken', style: AppTheme.displaySmall),
        iconTheme: const IconThemeData(color: AppTheme.ink),
      ),
      body: profileAsync.when(
        loading: () => const AppLoader(),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: AppEmptyState(
            icon: Icons.error_outline,
            title: 'Profiel kon niet laden',
            description: '$error',
          ),
        ),
        data: (profile) {
          _seedFrom(
            profile.avatar,
            profile.name,
            profile.nameChangeAllowedInDays,
          );
          final draft = _draft ?? profile.avatar;
          final nameLocked = _cooldownDays > 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Center(
                child: Column(
                  children: [
                    MascotAvatar(avatar: draft, size: 132, bordered: true),
                    const SizedBox(height: 12),
                    Text(describeAvatar(draft), style: AppTheme.bodyMuted),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: _isSaving ? null : _surpriseMe,
                  icon: const Icon(Icons.casino_outlined, size: 18),
                  label: const Text('Verras me'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.inkSoft,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(eyebrow: 'Naam', title: 'Weergavenaam'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Naam',
                hintText: 'Hoe je op de ranglijst verschijnt',
                enabled: !nameLocked && !_isSaving,
              ),
              const SizedBox(height: 8),
              Text(
                nameLocked
                    ? 'Je kunt je naam over $_cooldownDays '
                          '${_cooldownDays == 1 ? 'dag' : 'dagen'} weer wijzigen.'
                    : 'Zichtbaar op de ranglijst en in multiplayer. '
                          'Eens per 30 dagen te wijzigen.',
                style: AppTheme.caption,
              ),
              const SizedBox(height: 32),
              const SectionHeader(
                eyebrow: 'Mascotte',
                title: 'Stel je figuur samen',
              ),
              const SizedBox(height: 20),
              _PartPicker(
                label: 'Figuur',
                options: avatarCharacters
                    .map(
                      (option) => _PartChoice(
                        id: option.id,
                        label: option.label,
                        preview: draft.copyWith(character: option.id),
                      ),
                    )
                    .toList(),
                selected: draft.character,
                onSelect: (value) => _setPart(character: value),
              ),
              const SizedBox(height: 24),
              _PartPicker(
                label: 'Kleur',
                options: avatarColors
                    .map(
                      (option) => _PartChoice(
                        id: option.id,
                        label: option.label,
                        swatch: _parseHex(option.base),
                      ),
                    )
                    .toList(),
                selected: draft.color,
                onSelect: (value) => _setPart(color: value),
              ),
              const SizedBox(height: 24),
              _PartPicker(
                label: 'Achtergrond',
                options: avatarBackgrounds
                    .map(
                      (option) => _PartChoice(
                        id: option.id,
                        label: option.label,
                        swatch: _parseHex(option.fill),
                      ),
                    )
                    .toList(),
                selected: draft.background,
                onSelect: (value) => _setPart(background: value),
              ),
              const SizedBox(height: 24),
              _PartPicker(
                label: 'Accessoire',
                options: avatarAccessories
                    .map(
                      (option) => _PartChoice(
                        id: option.id,
                        label: option.label,
                        preview: draft.copyWith(accessory: option.id),
                      ),
                    )
                    .toList(),
                selected: draft.accessory,
                onSelect: (value) => _setPart(accessory: value),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Opslaan',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          );
        },
      ),
    );
  }
}

Color _parseHex(String hex) {
  return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
}

class _PartChoice {
  const _PartChoice({
    required this.id,
    required this.label,
    this.preview,
    this.swatch,
  });

  final String id;
  final String label;

  /// Draw the whole mascot with this part applied.
  final AvatarConfig? preview;

  /// Or a colour chip, where a full figure would say nothing extra.
  final Color? swatch;
}

class _PartPicker extends StatelessWidget {
  const _PartPicker({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final List<_PartChoice> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTheme.eyebrow),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final active = option.id == selected;

            return Material(
              color: active ? AppTheme.lapisTint : AppTheme.paperRaised,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                onTap: () => onSelect(option.id),
                child: Container(
                  width: 74,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: active ? AppTheme.lapis : AppTheme.rule,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (option.preview != null)
                        MascotAvatar(avatar: option.preview!, size: 44)
                      else
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: option.swatch,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.rule),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.caption.copyWith(
                          color: active ? AppTheme.ink : AppTheme.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
