import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/avatar/mascot_avatar.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/notifications/streak_reminder.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import '../../auth/present/auth_controller.dart';
import '../../profile/data/profile_model.dart';
import '../../profile/present/profile_provider.dart';
import '../data/quiz_preferences_controller.dart';
import '../domain/quiz_preferences.dart';

/// Instellingen - BijbelQuiz 2.0 (`R-Instellingen`).
///
/// Account, the evening reminder, the quiz preferences stored on the account,
/// Premium, privacy, and signing out. Reached from the gear on Profiel.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _loggingOut = false;

  /// Mirrors the fixed hour in [StreakReminder]; the reminder has no time
  /// setting of its own.
  static const String _reminderTime = '19:00';

  static const String _accountEmail = 'info@bijbelquiz.com';

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    // The controller also signs Google and RevenueCat out and flips
    // `hasSessionProvider`, which is what every screen reads to decide between
    // its two renderings.
    await ref.read(authControllerProvider.notifier).logout();
    ref.invalidate(profileProvider);

    // Signed out is a normal state: back to the home screen, not to a login
    // form.
    if (mounted) context.go('/home');
  }

  Future<void> _openPrivacy() async {
    final launched = await launchUrl(
      Uri.parse(AppConfig.privacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      AppNotice.error(
        context,
        const AppError(
          title: 'Link niet geopend',
          message: 'We konden deze pagina niet openen. Probeer het opnieuw.',
        ),
      );
    }
  }

  /// There is no self-service delete endpoint: deletion goes through support,
  /// as the data-use notice on the login screen explains. The mail is
  /// prefilled so the request names the account.
  Future<void> _requestDeletion(ProfileModel? profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Account verwijderen'),
        content: const Text(
          'Stuur ons een e-mail vanaf het adres van je account. We '
          'verwijderen dan je account en je voortgang volgens ons '
          'privacybeleid. Dit kan niet ongedaan worden gemaakt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.vermilion),
            child: const Text('E-mail sturen'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final account = profile == null || profile.email.isEmpty
        ? ''
        : ' (${profile.email})';
    final query = [
      'subject=${Uri.encodeComponent('Account verwijderen')}',
      'body=${Uri.encodeComponent('Graag mijn BijbelQuiz-account$account verwijderen.')}',
    ].join('&');
    final launched = await launchUrl(
      Uri.parse('mailto:$_accountEmail?$query'),
    );
    if (!launched && mounted) {
      AppNotice.info(
        context,
        'Mail ons op $_accountEmail om je account te laten verwijderen.',
      );
    }
  }

  Future<void> _toggleReminder(bool value, ProfileModel? profile) async {
    final result = await StreakReminder.instance.setEnabled(
      value,
      streak: profile?.streak ?? 0,
      lastPlayedAt: profile?.lastPlayedAt,
    );

    ref.invalidate(streakReminderEnabledProvider);

    if (!mounted) return;
    if (value && !result) {
      AppNotice.info(
        context,
        'Meldingen staan uit voor BijbelQuiz. Zet ze aan in de '
        'instellingen van je telefoon.',
      );
    }
  }

  Future<void> _pickTimer(QuizPreferences preferences) async {
    final choice = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppTheme.paperRaised,
      showDragHandle: true,
      builder: (sheetContext) => _TimerSheet(
        selected: preferences.questionTimerSeconds,
      ),
    );
    if (choice == null) return;
    ref.read(quizPreferencesProvider.notifier).setTimerSeconds(choice);
  }

  @override
  Widget build(BuildContext context) {
    final hasSession = ref.watch(hasSessionProvider).asData?.value ?? false;
    final profile = hasSession
        ? ref.watch(profileProvider).asData?.value
        : null;
    final reminderOn =
        ref.watch(streakReminderEnabledProvider).asData?.value ?? false;
    final preferences = ref.watch(quizPreferencesProvider);
    final prefs = ref.read(quizPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            BqTopBar(
              title: 'Instellingen',
              large: true,
              onBack: () => context.canPop() ? context.pop() : context.go('/profile'),
            ),
            const SizedBox(height: 16),
            _AccountCard(
              hasSession: hasSession,
              profile: profile,
              onTap: () =>
                  context.push(hasSession ? '/profile/edit' : '/login'),
            ),
            const SizedBox(height: 16),
            const _SectionTitle('Herinnering'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _SwitchRow(
                  icon: BqIcons.flame,
                  iconSize: 17,
                  tileColor: AppTheme.coralTint,
                  title: 'Reeksherinnering',
                  value: reminderOn,
                  onChanged: (value) => _toggleReminder(value, profile),
                ),
                const _ValueRow(
                  icon: BqIcons.clock,
                  title: 'Tijdstip',
                  value: _reminderTime,
                  valueColor: AppTheme.inkSoft,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SectionTitle('Spelen'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _ValueRow(
                  icon: BqIcons.clock,
                  title: 'Tijd per vraag',
                  value: _timerLabel(preferences.questionTimerSeconds),
                  onTap: () => _pickTimer(preferences),
                ),
                _SwitchRow(
                  icon: _Icons.bookOpen,
                  title: 'Eerst het hoofdstuk lezen',
                  value: preferences.readPassageFirst,
                  onChanged: prefs.setReadPassageFirst,
                ),
                _SwitchRow(
                  icon: BqIcons.book,
                  title: 'Bijbeltekst bij uitleg',
                  value: preferences.showBibleReferences,
                  onChanged: prefs.setShowBibleReferences,
                ),
                _SwitchRow(
                  icon: _Icons.textSize,
                  title: 'Grote vraagtekst',
                  value: preferences.largeQuestionText,
                  onChanged: prefs.setLargeQuestionText,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              children: [
                _ValueRow(
                  icon: BqIcons.crown,
                  iconSize: 18,
                  tileColor: AppTheme.goldTint,
                  title: 'Premium beheren',
                  onTap: () => context.push('/premium'),
                ),
                if (profile?.isAdmin ?? false)
                  _ValueRow(
                    icon: BqIcons.shield,
                    iconColor: AppTheme.lapis,
                    tileColor: AppTheme.lapisTint,
                    title: 'Beheer',
                    onTap: () => context.push('/beheer'),
                  ),
                _ValueRow(
                  icon: _Icons.shieldPlain,
                  title: 'Privacy',
                  onTap: _openPrivacy,
                ),
              ],
            ),
            if (hasSession) ...[
              const SizedBox(height: 16),
              _SettingsGroup(
                children: [
                  _TextRow(
                    title: 'Uitloggen',
                    color: AppTheme.vermilion,
                    loading: _loggingOut,
                    onTap: _logout,
                  ),
                  _TextRow(
                    title: 'Account verwijderen',
                    color: AppTheme.inkMuted,
                    showChevron: true,
                    onTap: () => _requestDeletion(profile),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _timerLabel(int seconds) =>
      seconds <= 0 ? 'Uit' : '$seconds sec';
}

/// Icons from the Instellingen design that are not in [BqIcons].
class _Icons {
  const _Icons._();

  static const String _s =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">';

  static const String shieldPlain =
      '$_s<path d="M12 3l7.5 3v5.5c0 4.4-3.2 8.2-7.5 9.5-4.3-1.3-7.5-5.1-7.5-9.5V6z"/></svg>';
  static const String bookOpen =
      '$_s<path d="M3 5.5h5a4 4 0 0 1 4 4V20a3 3 0 0 0-3-3H3z"/><path d="M21 5.5h-5a4 4 0 0 0-4 4V20a3 3 0 0 1 3-3h6z"/></svg>';
  static const String textSize =
      '$_s<path d="M4 7V5h10v2"/><path d="M9 5v14"/><path d="M7 19h4"/><path d="M14 12v-1.5h7V12"/><path d="M17.5 10.5V19"/><path d="M16 19h3"/></svg>';
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

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

/// White card with soft dividers between 50px rows.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => BqListCard(children: children);
}

/// 32px rounded tile holding a 17px icon.
class _RowIcon extends StatelessWidget {
  const _RowIcon({
    required this.icon,
    this.size = 17,
    this.background = const Color(0xFFF1EFEA),
    this.color = AppTheme.inkSoft,
  });

  final String icon;
  final double size;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return BqIconTile(
      size: 32,
      radius: 9,
      background: background,
      child: BqIcon(icon, size: size, color: color),
    );
  }
}

const TextStyle _rowTitle = TextStyle(
  fontFamily: AppTheme.sansFontName,
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: AppTheme.ink,
);

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const BqIcon(
      BqIcons.chevronRight,
      size: 18,
      color: AppTheme.inkFaint,
    );
  }
}

/// Icon, title and a switch. The whole row toggles.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.iconSize = 17,
    this.tileColor = const Color(0xFFF1EFEA),
  });

  final String icon;
  final double iconSize;
  final Color tileColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: title,
      excludeSemantics: true,
      onTap: () => onChanged(!value),
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              _RowIcon(icon: icon, size: iconSize, background: tileColor),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: _rowTitle)),
              const SizedBox(width: 10),
              _BqSwitch(value: value),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon, title, an optional value on the right and a chevron when it opens
/// something.
class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.icon,
    required this.title,
    this.value,
    this.valueColor = AppTheme.inkMuted,
    this.onTap,
    this.iconSize = 17,
    this.iconColor = AppTheme.inkSoft,
    this.tileColor = const Color(0xFFF1EFEA),
  });

  final String icon;
  final double iconSize;
  final Color iconColor;
  final Color tileColor;
  final String title;
  final String? value;
  final Color valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          _RowIcon(
            icon: icon,
            size: iconSize,
            color: iconColor,
            background: tileColor,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: _rowTitle)),
          if (value != null) ...[
            const SizedBox(width: 10),
            Text(
              value!,
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 15,
                fontWeight: valueColor == AppTheme.inkSoft
                    ? FontWeight.w700
                    : FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
          if (onTap != null) ...[const SizedBox(width: 8), const _Chevron()],
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      label: value == null ? title : '$title, $value',
      excludeSemantics: true,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

/// A text-only row (Uitloggen, Account verwijderen).
class _TextRow extends StatelessWidget {
  const _TextRow({
    required this.title,
    required this.color,
    required this.onTap,
    this.showChevron = false,
    this.loading = false,
  });

  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool showChevron;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      child: InkWell(
        onTap: loading ? null : onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: _rowTitle.copyWith(color: color),
                ),
              ),
              if (loading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                )
              else if (showChevron)
                const _Chevron(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 48x28 switch from the design: lapis when on, warm grey when off.
class _BqSwitch extends StatelessWidget {
  const _BqSwitch({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 48,
      height: 28,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? AppTheme.lapis : const Color(0xFFC9C6BE),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppTheme.paperRaised,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// The account at the top: mascot, name and how the player is signed in.
class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.hasSession,
    required this.profile,
    required this.onTap,
  });

  final bool hasSession;
  final ProfileModel? profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final String title;
    final String subtitle;
    if (!hasSession) {
      title = 'Je speelt zonder account';
      subtitle = 'Inloggen of een account aanmaken';
    } else if (p == null) {
      title = 'Je account';
      subtitle = 'Ingelogd';
    } else {
      title = p.name;
      subtitle = p.email.isEmpty ? 'Ingelogd' : 'Ingelogd als ${p.email}';
    }

    return BqCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Semantics(
        button: true,
        label: '$title, $subtitle',
        excludeSemantics: true,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              if (p != null)
                ClipOval(child: MascotAvatar(avatar: p.avatar, size: 40))
              else
                const BqIconTile(
                  size: 40,
                  radius: 20,
                  child: BqIcon(BqIcons.user, size: 20, color: AppTheme.lapis),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _rowTitle,
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const _Chevron(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with the timer choices the website also offers.
class _TimerSheet extends StatelessWidget {
  const _TimerSheet({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tijd per vraag', style: AppTheme.displayTitle),
            const SizedBox(height: 4),
            const Text(
              'Standaard uit. Zet een klok aan als je jezelf wilt uitdagen.',
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 14),
            BqListCard(
              children: [
                for (final choice in QuizPreferences.timerChoices)
                  Semantics(
                    button: true,
                    selected: choice == selected,
                    label: choice == 0 ? 'Uit' : '$choice seconden',
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(choice),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                choice == 0 ? 'Uit' : '$choice seconden',
                                style: _rowTitle.copyWith(
                                  color: choice == selected
                                      ? AppTheme.lapis
                                      : AppTheme.ink,
                                ),
                              ),
                            ),
                            if (choice == selected)
                              const BqIcon(
                                BqIcons.check,
                                size: 20,
                                color: AppTheme.lapis,
                              ),
                          ],
                        ),
                      ),
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
