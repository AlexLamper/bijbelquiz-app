import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import '../data/admin_repository.dart';
import 'widgets/admin_ui.dart';

/// Quizzen: moderation per status, with approve / reject / publish /
/// unpublish and the Premium switch.
class AdminQuizzesTab extends ConsumerStatefulWidget {
  const AdminQuizzesTab({super.key});

  @override
  ConsumerState<AdminQuizzesTab> createState() => _AdminQuizzesTabState();
}

class _AdminQuizzesTabState extends ConsumerState<AdminQuizzesTab> {
  /// null = alle; starts on pending, the queue that needs action.
  String? _status = 'pending';
  String _q = '';

  static const _statuses = <(String?, String)>[
    ('pending', 'Wacht'),
    ('approved', 'Live'),
    ('rejected', 'Afgekeurd'),
    ('draft', 'Concept'),
    (null, 'Alle'),
  ];

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminQuizzesProvider(_status));
    final counts = async.asData?.value.counts ?? const <String, int>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              for (final (key, label) in _statuses) ...[
                AdminChip(
                  compact: true,
                  label: key != null && counts.containsKey(key)
                      ? '$label (${counts[key]})'
                      : label,
                  selected: _status == key,
                  onTap: () => setState(() => _status = key),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: TextField(
            onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
            decoration: const InputDecoration(
              hintText: 'Filter op titel of categorie',
              isDense: true,
              prefixIcon: Padding(
                padding: EdgeInsets.all(12),
                child: BqIcon(BqIcons.search, size: 18, color: AppTheme.inkFaint),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 42, minHeight: 42),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.lapis,
            backgroundColor: AppTheme.paperRaised,
            onRefresh: () async {
              ref.invalidate(adminQuizzesProvider(_status));
              try {
                await ref.read(adminQuizzesProvider(_status).future);
              } catch (_) {}
            },
            child: async.when(
              skipLoadingOnRefresh: true,
              loading: () => const AdminSkeletonList(cards: 3),
              error: (e, _) => AdminErrorView(
                error: e,
                onRetry: () => ref.invalidate(adminQuizzesProvider(_status)),
              ),
              data: (list) => AdminQuizListView(
                quizzes: [
                  for (final quiz in list.quizzes)
                    if (_q.isEmpty ||
                        quiz.title.toLowerCase().contains(_q) ||
                        (quiz.category ?? '').toLowerCase().contains(_q))
                      quiz,
                ],
                onAction: (quiz, action, {bool? isPremium}) async {
                  await ref
                      .read(adminRepositoryProvider)
                      .updateQuiz(quiz.id, action, isPremium: isPremium);
                  ref.invalidate(adminQuizzesProvider);
                  ref.invalidate(adminOverviewProvider);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

typedef AdminQuizActionCallback =
    Future<void> Function(
      AdminQuizRow quiz,
      AdminQuizAction action, {
      bool? isPremium,
    });

/// The list of quiz cards; separate from the provider for tests.
class AdminQuizListView extends StatelessWidget {
  const AdminQuizListView({
    super.key,
    required this.quizzes,
    required this.onAction,
  });

  final List<AdminQuizRow> quizzes;
  final AdminQuizActionCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        if (quizzes.isEmpty)
          const AdminEmptyCard('Geen quizzen met deze status.')
        else
          for (final quiz in quizzes) ...[
            AdminQuizCard(
              key: ValueKey(quiz.id),
              quiz: quiz,
              onAction: onAction,
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class AdminQuizCard extends StatefulWidget {
  const AdminQuizCard({super.key, required this.quiz, required this.onAction});

  final AdminQuizRow quiz;
  final AdminQuizActionCallback onAction;

  @override
  State<AdminQuizCard> createState() => _AdminQuizCardState();
}

class _AdminQuizCardState extends State<AdminQuizCard> {
  AdminQuizAction? _busy;
  late AdminQuizRow _quiz = widget.quiz;

  @override
  void didUpdateWidget(covariant AdminQuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quiz != widget.quiz) _quiz = widget.quiz;
  }

  Future<void> _run(AdminQuizAction action, {bool? isPremium}) async {
    final before = _quiz;
    setState(() {
      _busy = action;
      // Optimistic: the switch moves at once.
      if (action == AdminQuizAction.premium) {
        _quiz = _quiz.copyWith(isPremium: isPremium);
      }
    });
    try {
      await widget.onAction(before, action, isPremium: isPremium);
      if (!mounted) return;
      setState(() => _busy = null);
      AppNotice.success(context, switch (action) {
        AdminQuizAction.approve => '"${before.title}" is goedgekeurd.',
        AdminQuizAction.reject => '"${before.title}" is afgekeurd.',
        AdminQuizAction.publish => '"${before.title}" staat live.',
        AdminQuizAction.unpublish => '"${before.title}" is offline gehaald.',
        AdminQuizAction.premium =>
          isPremium == true
              ? '"${before.title}" is nu alleen voor Premium.'
              : '"${before.title}" is nu gratis te spelen.',
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = null;
        _quiz = before;
      });
      showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _quiz;
    final actions = <(AdminQuizAction, String, BqButtonStyle)>[
      if (q.status == 'pending') ...[
        (AdminQuizAction.approve, 'Goedkeuren', BqButtonStyle.primary),
        (AdminQuizAction.reject, 'Afkeuren', BqButtonStyle.secondary),
      ] else if (q.status == 'approved' || q.status == 'published')
        (AdminQuizAction.unpublish, 'Offline halen', BqButtonStyle.secondary)
      else if (q.status == 'rejected')
        (AdminQuizAction.approve, 'Toch goedkeuren', BqButtonStyle.secondary)
      else
        (AdminQuizAction.publish, 'Publiceren', BqButtonStyle.primary),
    ];
    return BqCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.title, style: AppTheme.displayBase),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (q.category != null) q.category!,
                        '${q.questionCount} vragen',
                        if (q.plays30d != null) '${q.plays30d}x gespeeld (30 d)',
                      ].join(' · '),
                      style: AppTheme.caption,
                    ),
                    if (q.createdBy != null || q.createdAt != null)
                      Text(
                        [
                          if (q.createdBy != null) 'door ${q.createdBy}',
                          if (q.createdAt != null) AdminFormat.date(q.createdAt),
                        ].join(' · '),
                        style: AppTheme.caption.copyWith(
                          fontSize: 12,
                          color: AppTheme.inkFaint,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AdminStatusPill(
                label: AdminLabels.quizStatus(q.status),
                status: q.status,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppTheme.ruleSoft),
          Semantics(
            toggled: q.isPremium,
            label: 'Alleen voor Premium',
            child: InkWell(
              onTap: _busy != null
                  ? null
                  : () => _run(AdminQuizAction.premium, isPremium: !q.isPremium),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const BqIcon(BqIcons.crown, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Alleen voor Premium',
                        style: AppTheme.bodyStrong,
                      ),
                    ),
                    Switch(
                      value: q.isPremium,
                      onChanged: _busy != null
                          ? null
                          : (v) => _run(AdminQuizAction.premium, isPremium: v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: BqButton(
                    label: actions[i].$2,
                    style: actions[i].$3,
                    height: 42,
                    fontSize: 14,
                    loading: _busy == actions[i].$1,
                    onPressed: _busy != null ? null : () => _run(actions[i].$1),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
