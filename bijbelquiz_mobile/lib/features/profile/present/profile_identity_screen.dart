import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/avatar/avatar_catalog.dart';
import '../../../core/avatar/mascot_avatar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/custom_text_field.dart';
import '../../../core/ui/bq.dart';
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
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: BqTopBar(
                title: 'Profiel bewerken',
                large: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
            Expanded(
              child: profileAsync.when(
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
                  return _buildEditor(profile.avatar);
                },
              ),
            ),
            // The save bar stays in reach while scrolling through the parts.
            if (profileAsync.hasValue)
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.paperRaised,
                  border: Border(top: BorderSide(color: AppTheme.rule)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: BqButton(
                  label: 'Opslaan',
                  loading: _isSaving,
                  onPressed: _save,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor(AvatarConfig fallback) {
    final draft = _draft ?? fallback;
    final nameLocked = _cooldownDays > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        BqCard(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.lapisTint, width: 4),
                ),
                child: ClipOval(child: MascotAvatar(avatar: draft, size: 124)),
              ),
              const SizedBox(height: 12),
              Text(
                describeAvatar(draft),
                textAlign: TextAlign.center,
                style: AppTheme.bodyMuted,
              ),
              const SizedBox(height: 14),
              // Unconstrained so the button hugs its label instead of
              // stretching across the card.
              UnconstrainedBox(
                child: BqButton(
                  label: 'Verras me',
                  style: BqButtonStyle.tint,
                  icon: const BqIcon(BqIcons.shuffle, size: 18),
                  height: 44,
                  expand: false,
                  fontSize: 15,
                  onPressed: _isSaving ? null : _surpriseMe,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Weergavenaam'),
        const SizedBox(height: 8),
        BqCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Stel je mascotte samen'),
        const SizedBox(height: 8),
        BqCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppTheme.sansFontName,
          fontSize: 16,
          height: 22 / 16,
          fontWeight: FontWeight.w800,
          color: AppTheme.ink,
        ),
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
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTheme.sansFontName,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.inkSoft,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final active = option.id == selected;

            return Semantics(
              button: true,
              selected: active,
              label: '$label: ${option.label}',
              excludeSemantics: true,
              onTap: () => onSelect(option.id),
              child: Material(
                color: active ? AppTheme.lapisTint : AppTheme.paperRaised,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  onTap: () => onSelect(option.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: active ? AppTheme.lapis : AppTheme.rule,
                        width: active ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        if (option.preview != null)
                          MascotAvatar(avatar: option.preview!, size: 42)
                        else
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: option.swatch,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.rule),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          option.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: active ? AppTheme.lapisStrong : AppTheme.inkMuted,
                          ),
                        ),
                      ],
                    ),
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
