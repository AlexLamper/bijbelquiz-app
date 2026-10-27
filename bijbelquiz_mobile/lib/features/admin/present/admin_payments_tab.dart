import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/bq.dart';
import '../data/admin_repository.dart';
import 'admin_overview_tab.dart' show AdminRevenueSummary;
import 'widgets/admin_rows.dart';
import 'widgets/admin_ui.dart';

/// Betalingen: the pipeline health, the revenue summary and every payment,
/// filterable by channel and status.
class AdminPaymentsTab extends ConsumerStatefulWidget {
  const AdminPaymentsTab({super.key});

  @override
  ConsumerState<AdminPaymentsTab> createState() => _AdminPaymentsTabState();
}

class _AdminPaymentsTabState extends ConsumerState<AdminPaymentsTab> {
  AdminPaymentQuery _query = const AdminPaymentQuery();
  final List<AdminPaymentRow> _payments = [];
  AdminPaymentPage? _last;
  Object? _error;
  bool _loading = false;
  bool _loadingMore = false;
  int _generation = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _reload() async {
    final gen = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    ref.invalidate(adminPaymentsHealthProvider);
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getPayments(_withPage(1));
      if (!mounted || gen != _generation) return;
      setState(() {
        _payments
          ..clear()
          ..addAll(page.payments);
        _last = page;
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

  AdminPaymentQuery _withPage(int page) => AdminPaymentQuery(
    page: page,
    pageSize: _query.pageSize,
    provider: _query.provider,
    status: _query.status,
    q: _query.q,
  );

  Future<void> _loadMore() async {
    final last = _last;
    if (last == null || !last.hasMore || _loadingMore) return;
    final gen = _generation;
    setState(() => _loadingMore = true);
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getPayments(_withPage(last.page + 1));
      if (!mounted || gen != _generation) return;
      setState(() {
        _payments.addAll(page.payments);
        _last = page;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      showAdminError(context, e);
    }
  }

  void _set({Object? provider = _same, Object? status = _same, String? q}) {
    _query = AdminPaymentQuery(
      pageSize: _query.pageSize,
      provider: provider == _same ? _query.provider : provider as String?,
      status: status == _same ? _query.status : status as String?,
      q: q ?? _query.q,
    );
    _reload();
  }

  static const _providers = <(String?, String)>[
    (null, 'Alle'),
    ('stripe', 'Website'),
    ('revenuecat', 'App'),
  ];

  static const _statuses = <(String?, String)>[
    (null, 'Alle'),
    ('completed', 'Betaald'),
    ('trial', 'Proef'),
    ('pending', 'In behandeling'),
    ('failed', 'Mislukt'),
    ('refunded', 'Terugbetaald'),
    ('disputed', 'Betwist'),
  ];

  @override
  Widget build(BuildContext context) {
    final health = ref.watch(adminPaymentsHealthProvider);

    final children = <Widget>[
      // Health ---------------------------------------------------------------
      health.when(
        loading: () => const BqCard(child: AdminSkeletonBox(height: 44)),
        error: (e, _) => e is AdminEndpointMissing
            ? const SizedBox.shrink()
            : BqCard(
                child: Text(
                  'Betaalcontrole niet geladen: ${describeAdminError(e).$3}',
                  style: AppTheme.caption,
                ),
              ),
        data: (h) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminHealthCard(health: h),
            if (h.issues.isNotEmpty) ...[
              const SizedBox(height: 10),
              AdminHealthIssues(issues: h.issues),
            ],
            if (h.accessGaps.isNotEmpty) ...[
              const SizedBox(height: 20),
              const AdminSectionTitle(
                'Betaald zonder Premium',
                caption: 'Geef deze accounts tijdelijk handmatig Premium',
              ),
              BqListCard(
                children: [
                  for (final g in h.accessGaps)
                    BqListRow(
                      title: g.name.isEmpty ? g.email : g.name,
                      subtitle:
                          '${g.email} · ${g.reason}'
                          '${g.when != null ? ' · ${AdminFormat.date(g.when)}' : ''}',
                      subtitleColor: AppTheme.vermilion,
                      onTap: g.userId.isEmpty
                          ? null
                          : () => context.push('/beheer/gebruikers/${g.userId}'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    ];

    if (_loading && _payments.isEmpty && _last == null) {
      children.addAll(const [
        SizedBox(height: 20),
        BqCard(child: AdminSkeletonBox(height: 120)),
      ]);
    } else if (_error != null && _last == null) {
      children.add(
        AdminErrorView(error: _error!, onRetry: _reload, scrollable: false),
      );
    } else {
      final last = _last;
      if (last?.revenue != null) {
        children.addAll([
          const SizedBox(height: 28),
          const AdminSectionTitle('Omzet'),
          AdminRevenueSummary(revenue: last!.revenue!),
        ]);
      }
      children.addAll([
        const SizedBox(height: 28),
        AdminSectionTitle(
          'Alle betalingen',
          caption: last == null
              ? null
              : '${AdminFormat.number(last.total)} gevonden',
          trailing: _loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        TextField(
          onChanged: (v) {
            _debounce?.cancel();
            _debounce = Timer(
              const Duration(milliseconds: 350),
              () => mounted ? _set(q: v) : null,
            );
          },
          decoration: const InputDecoration(
            hintText: 'Zoek op naam of e-mail van de koper',
            isDense: true,
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: BqIcon(BqIcons.search, size: 18, color: AppTheme.inkFaint),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 42, minHeight: 42),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (key, label) in _providers)
              AdminChip(
                compact: true,
                label: label,
                selected: _query.provider == key,
                onTap: () => _set(provider: key),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (key, label) in _statuses)
              AdminChip(
                compact: true,
                label: label,
                selected: _query.status == key,
                onTap: () => _set(status: key),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_error != null)
          AdminErrorView(error: _error!, onRetry: _reload, scrollable: false)
        else if (_payments.isEmpty)
          const AdminEmptyCard('Geen betalingen met deze filters.')
        else
          BqListCard(
            children: [
              for (final p in _payments)
                AdminPaymentTile(
                  payment: p,
                  onTap: p.userId == null || p.userDeleted
                      ? null
                      : () => context.push('/beheer/gebruikers/${p.userId}'),
                ),
            ],
          ),
        if (last?.hasMore ?? false) ...[
          const SizedBox(height: 12),
          BqButton(
            label: 'Meer laden',
            style: BqButtonStyle.secondary,
            height: 46,
            loading: _loadingMore,
            onPressed: _loadMore,
          ),
        ],
      ]);
    }

    return RefreshIndicator(
      color: AppTheme.lapis,
      backgroundColor: AppTheme.paperRaised,
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: children,
      ),
    );
  }
}

const Object _same = Object();
