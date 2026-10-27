import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import '../data/admin_repository.dart';
import 'admin_grant_sheet.dart';
import 'widgets/admin_rows.dart';
import 'widgets/admin_ui.dart';

/// Gebruikers: search, filter, sort and page through every account.
class AdminUsersTab extends ConsumerStatefulWidget {
  const AdminUsersTab({super.key});

  @override
  ConsumerState<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends ConsumerState<AdminUsersTab> {
  AdminUserQuery _query = const AdminUserQuery();
  final _search = TextEditingController();
  Timer? _debounce;

  final List<AdminUserRow> _users = [];
  AdminUserPage? _lastPage;
  Object? _error;
  bool _loading = false;
  bool _loadingMore = false;

  /// Bumped on every new search so a slow, older answer is dropped.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final gen = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getUsers(_query.copyWith(page: 1));
      if (!mounted || gen != _generation) return;
      setState(() {
        _users
          ..clear()
          ..addAll(page.users);
        _lastPage = page;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || gen != _generation) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final last = _lastPage;
    if (last == null || !last.hasMore || _loadingMore) return;
    final gen = _generation;
    setState(() => _loadingMore = true);
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getUsers(_query.copyWith(page: last.page + 1));
      if (!mounted || gen != _generation) return;
      setState(() {
        _users.addAll(page.users);
        _lastPage = page;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      showAdminError(context, e);
    }
  }

  void _setQuery(AdminUserQuery q) {
    if (q == _query) return;
    _query = q;
    _reload();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _setQuery(_query.copyWith(q: text, page: 1));
    });
  }

  Future<void> _pick<T>({
    required String title,
    required List<(T, String)> options,
    required T current,
    required ValueChanged<T> onPicked,
  }) async {
    final picked = await showModalBottomSheet<(T,)>(
      context: context,
      backgroundColor: AppTheme.paper,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => AdminChoiceSheet<T>(
        title: title,
        options: options,
        current: current,
      ),
    );
    if (picked != null) onPicked(picked.$1);
  }

  Future<void> _grantByEmail() async {
    final result = await showAdminGrantSheet(
      context,
      askEmail: true,
      submit: (request, email) => ref
          .read(adminRepositoryProvider)
          .grantPremiumByEmail(email ?? '', request),
    );
    if (result == null || !mounted) return;
    AppNotice.success(
      context,
      adminGrantSuccessText(result),
      title: 'Premium gegeven',
    );
    _reload();
  }

  static const _sorts = <(String, String)>[
    ('createdAt', 'Aanmelddatum'),
    ('lastActive', 'Laatst actief'),
    ('name', 'Naam'),
    ('email', 'E-mail'),
    ('xp', 'XP'),
    ('quizzesPlayed', 'Quizzen gespeeld'),
    ('premiumUntil', 'Premium tot'),
  ];

  String _premiumLabel() {
    if (_query.source != null) return AdminLabels.premiumSource(_query.source!);
    return switch (_query.premium) {
      'yes' => 'Premium',
      'no' => 'Gratis',
      _ => 'Premium: alle',
    };
  }

  @override
  Widget build(BuildContext context) {
    final q = _query;
    final sortLabel = _sorts
        .firstWhere((s) => s.$1 == q.sort, orElse: () => _sorts.first)
        .$2;
    final total = _lastPage?.total;

    final filters = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterButton(
            label: q.platform == null
                ? 'Platform: alle'
                : AdminLabels.platform(q.platform),
            active: q.platform != null,
            onTap: () => _pick<String?>(
              title: 'Aangemeld via',
              current: q.platform,
              options: [
                (null, 'Alle platforms'),
                for (final k in kAdminPlatformKeys) (k, AdminLabels.platform(k)),
              ],
              onPicked: (v) => _setQuery(q.copyWith(platform: v, page: 1)),
            ),
          ),
          const SizedBox(width: 8),
          _FilterButton(
            label: _premiumLabel(),
            active: q.premium != null || q.source != null,
            onTap: () => _pick<String?>(
              title: 'Premium',
              current: q.source ?? q.premium,
              options: [
                (null, 'Iedereen'),
                ('yes', 'Alleen Premium'),
                ('no', 'Alleen gratis'),
                for (final s in kAdminPremiumSources)
                  (s, 'Premium via ${AdminLabels.premiumSource(s).toLowerCase()}'),
              ],
              onPicked: (v) {
                if (v == null || v == 'yes' || v == 'no') {
                  _setQuery(q.copyWith(premium: v, source: null, page: 1));
                } else {
                  _setQuery(q.copyWith(premium: 'yes', source: v, page: 1));
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          _FilterButton(
            label: switch (q.test) {
              'exclude' => 'Zonder testaccounts',
              'only' => 'Alleen testaccounts',
              _ => 'Testaccounts: ja',
            },
            active: q.test != 'include',
            onTap: () => _pick<String>(
              title: 'Testaccounts',
              current: q.test,
              options: const [
                ('include', 'Meetellen'),
                ('exclude', 'Verbergen'),
                ('only', 'Alleen testaccounts'),
              ],
              onPicked: (v) => _setQuery(q.copyWith(test: v, page: 1)),
            ),
          ),
          const SizedBox(width: 8),
          _FilterButton(
            label: '$sortLabel ${q.order == 'asc' ? '↑' : '↓'}',
            active: q.sort != 'createdAt' || q.order != 'desc',
            onTap: () => _pick<String>(
              title: 'Sorteren op',
              current: '${q.sort}:${q.order}',
              options: [
                for (final s in _sorts) ...[
                  ('${s.$1}:desc', '${s.$2} (hoog naar laag / nieuw eerst)'),
                  ('${s.$1}:asc', '${s.$2} (laag naar hoog / oud eerst)'),
                ],
              ],
              onPicked: (v) {
                final parts = v.split(':');
                _setQuery(q.copyWith(sort: parts[0], order: parts[1], page: 1));
              },
            ),
          ),
        ],
      ),
    );

    Widget list;
    if (_loading && _users.isEmpty) {
      list = const AdminSkeletonList(cards: 2, rows: 5);
    } else if (_error != null && _users.isEmpty) {
      list = AdminErrorView(error: _error!, onRetry: _reload);
    } else {
      list = NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels > n.metrics.maxScrollExtent - 400) _loadMore();
          return false;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    total == null
                        ? ''
                        : '${AdminFormat.number(total)} '
                              '${total == 1 ? 'gebruiker' : 'gebruikers'}',
                    style: AppTheme.caption,
                  ),
                ),
                if (_loading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_users.isEmpty)
              const AdminEmptyCard('Geen gebruikers gevonden met deze filters.')
            else
              BqListCard(
                children: [
                  for (final u in _users)
                    AdminUserTile(
                      user: u,
                      onTap: () async {
                        await context.push('/beheer/gebruikers/${u.id}');
                        // A grant made in the detail shows up in the list.
                        if (mounted) _reload();
                      },
                    ),
                ],
              ),
            if (_lastPage?.hasMore ?? false) ...[
              const SizedBox(height: 12),
              BqButton(
                label: 'Meer laden',
                style: BqButtonStyle.secondary,
                height: 46,
                loading: _loadingMore,
                onPressed: _loadMore,
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: _onSearch,
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'Zoek op naam of e-mail',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12),
                      child: BqIcon(
                        BqIcons.search,
                        size: 18,
                        color: AppTheme.inkFaint,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 42,
                      minHeight: 42,
                    ),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Wissen',
                            icon: const BqIcon(BqIcons.close, size: 16),
                            onPressed: () {
                              _search.clear();
                              _onSearch('');
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BqCircleButton(
                icon: BqIcons.crown,
                label: 'Premium geven via e-mail',
                size: 46,
                onTap: _grantByEmail,
              ),
            ],
          ),
        ),
        filters,
        const SizedBox(height: 10),
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.lapis,
            backgroundColor: AppTheme.paperRaised,
            onRefresh: _reload,
            child: list,
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppTheme.lapisTint : AppTheme.paperRaised,
      shape: StadiumBorder(
        side: BorderSide(color: active ? AppTheme.lapisSoft : AppTheme.rule),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: active ? AppTheme.lapisStrong : AppTheme.inkSoft,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.expand_more,
                size: 18,
                color: active ? AppTheme.lapis : AppTheme.inkFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A list of options in a sheet; pops `(value,)` so null is a real choice.
class AdminChoiceSheet<T> extends StatelessWidget {
  const AdminChoiceSheet({
    super.key,
    required this.title,
    required this.options,
    required this.current,
  });

  final String title;
  final List<(T, String)> options;
  final T current;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Text(title, style: AppTheme.displayTitle),
          const SizedBox(height: 12),
          BqListCard(
            children: [
              for (final (value, label) in options)
                BqListRow(
                  title: label,
                  showChevron: false,
                  trailing: value == current
                      ? const BqIcon(
                          BqIcons.check,
                          size: 18,
                          color: AppTheme.lapis,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop((value,)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
