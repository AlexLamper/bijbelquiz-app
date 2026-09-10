import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/present/auth_controller.dart';
import '../../../core/api/api_client.dart';

/// One recent row from the website's `Payment` collection.
class AdminPayment {
  const AdminPayment({
    required this.userName,
    required this.provider,
    required this.planType,
    required this.amountCents,
    required this.status,
    required this.createdAt,
  });

  final String userName;
  final String provider;
  final String planType;
  final int amountCents;
  final String status;
  final DateTime? createdAt;

  factory AdminPayment.fromJson(Map<String, dynamic> json) {
    return AdminPayment(
      userName: json['userName']?.toString() ?? 'Onbekend',
      provider: json['provider']?.toString() ?? 'stripe',
      planType: json['planType']?.toString() ?? '',
      amountCents: (json['amountCents'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

/// One non-OK check from the betaal-pijplijn report.
class AdminHealthIssue {
  const AdminHealthIssue({
    required this.label,
    required this.status,
    required this.detail,
    this.action,
  });

  final String label;

  /// `"warn"` or `"fail"`.
  final String status;
  final String detail;
  final String? action;

  factory AdminHealthIssue.fromJson(Map<String, dynamic> json) {
    return AdminHealthIssue(
      label: json['label']?.toString() ?? '',
      status: json['status']?.toString() ?? 'warn',
      detail: json['detail']?.toString() ?? '',
      action: json['action']?.toString(),
    );
  }
}

/// Trimmed `getPaymentsHealth()` output - "did paying work end to end".
class AdminHealth {
  const AdminHealth({
    required this.overall,
    required this.issues,
    required this.okCount,
    required this.accessGapCount,
    required this.paywallShown,
    required this.checkoutStarted,
    required this.purchaseCompleted,
    required this.stripeKeyMode,
    required this.revenuecatConfigured,
  });

  /// `"ok"` / `"warn"` / `"fail"`.
  final String overall;
  final List<AdminHealthIssue> issues;
  final int okCount;
  final int accessGapCount;
  final int paywallShown;
  final int checkoutStarted;
  final int purchaseCompleted;
  final String stripeKeyMode;
  final bool revenuecatConfigured;

  factory AdminHealth.fromJson(Map<String, dynamic> json) {
    final funnel = (json['funnel30d'] as Map?)?.cast<String, dynamic>() ?? {};
    return AdminHealth(
      overall: json['overall']?.toString() ?? 'warn',
      issues:
          (json['issues'] as List<dynamic>?)
              ?.map((e) => AdminHealthIssue.fromJson(
                    (e as Map).cast<String, dynamic>(),
                  ))
              .toList() ??
          const [],
      okCount: (json['okCount'] as num?)?.toInt() ?? 0,
      accessGapCount: (json['accessGapCount'] as num?)?.toInt() ?? 0,
      paywallShown: (funnel['paywallShown'] as num?)?.toInt() ?? 0,
      checkoutStarted: (funnel['checkoutStarted'] as num?)?.toInt() ?? 0,
      purchaseCompleted: (funnel['purchaseCompleted'] as num?)?.toInt() ?? 0,
      stripeKeyMode: json['stripeKeyMode']?.toString() ?? 'missing',
      revenuecatConfigured: json['revenuecatConfigured'] == true,
    );
  }
}

/// Mirrors `PremiumStats` from `src/lib/premium-stats.ts` on the website,
/// plus the trimmed `health` block from `/api/mobile/admin/stats`.
class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.premiumUsers,
    required this.premiumShare,
    required this.internalExcluded,
    required this.stripe,
    required this.store,
    required this.lifetime,
    required this.group,
    required this.paymentsCompleted,
    required this.grossCentsAllTime,
    required this.grossCentsLast30d,
    required this.recentPayments,
    this.health,
  });

  final int totalUsers;
  final int premiumUsers;
  final int premiumShare;
  final int internalExcluded;
  final int stripe;
  final int store;
  final int lifetime;
  final int group;
  final int paymentsCompleted;
  final int grossCentsAllTime;
  final int grossCentsLast30d;
  final List<AdminPayment> recentPayments;
  final AdminHealth? health;

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final breakdown = (json['breakdown'] as Map?)?.cast<String, dynamic>() ?? {};
    final revenue = (json['revenue'] as Map?)?.cast<String, dynamic>() ?? {};
    return AdminStats(
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      premiumUsers: (json['premiumUsers'] as num?)?.toInt() ?? 0,
      premiumShare: (json['premiumShare'] as num?)?.toInt() ?? 0,
      internalExcluded: (json['internalExcluded'] as num?)?.toInt() ?? 0,
      stripe: (breakdown['stripe'] as num?)?.toInt() ?? 0,
      store: (breakdown['store'] as num?)?.toInt() ?? 0,
      lifetime: (breakdown['lifetime'] as num?)?.toInt() ?? 0,
      group: (breakdown['group'] as num?)?.toInt() ?? 0,
      paymentsCompleted: (revenue['paymentsCompleted'] as num?)?.toInt() ?? 0,
      grossCentsAllTime: (revenue['grossCentsAllTime'] as num?)?.toInt() ?? 0,
      grossCentsLast30d: (revenue['grossCentsLast30d'] as num?)?.toInt() ?? 0,
      recentPayments:
          (json['recentPayments'] as List<dynamic>?)
              ?.map((e) => AdminPayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      health: json['health'] is Map
          ? AdminHealth.fromJson((json['health'] as Map).cast<String, dynamic>())
          : null,
    );
  }
}

class AdminRepository {
  AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AdminStats> getStats() async {
    final response = await _apiClient.dio.get('/admin/stats');
    final data = response.data;
    if (data is Map<String, dynamic>) return AdminStats.fromJson(data);
    if (data is Map) {
      return AdminStats.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Onverwacht antwoord van /admin/stats');
  }
}

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiClientProvider)),
);

final adminStatsProvider = FutureProvider.autoDispose<AdminStats>(
  (ref) => ref.watch(adminRepositoryProvider).getStats(),
);
