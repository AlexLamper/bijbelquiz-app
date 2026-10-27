import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/present/auth_controller.dart';
import '../../../core/api/api_client.dart';
import 'admin_json.dart';
import 'admin_models.dart';

export 'admin_models.dart';

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
    required this.netCentsAllTime,
    required this.netCentsLast30d,
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

  /// Euro after refunds, what the web dashboard shows as "Netto omzet".
  final int netCentsAllTime;
  final int netCentsLast30d;
  final List<AdminPayment> recentPayments;
  final AdminHealth? health;

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final breakdown =
        (json['breakdown'] as Map?)?.cast<String, dynamic>() ?? {};
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
      // An older server sends only gross amounts.
      netCentsAllTime:
          (revenue['netCentsAllTime'] as num?)?.toInt() ??
          (revenue['grossCentsAllTime'] as num?)?.toInt() ??
          0,
      netCentsLast30d:
          (revenue['netCentsLast30d'] as num?)?.toInt() ??
          (revenue['grossCentsLast30d'] as num?)?.toInt() ??
          0,
      recentPayments:
          (json['recentPayments'] as List<dynamic>?)
              ?.map((e) => AdminPayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      health: json['health'] is Map
          ? AdminHealth.fromJson(
              (json['health'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}

class AdminRepository {
  AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  Dio get _dio => _apiClient.dio;

  // -------------------------------------------------------------------------
  // Transport
  // -------------------------------------------------------------------------

  /// Runs [request] and turns failures into [AdminApiException] /
  /// [AdminEndpointMissing].
  ///
  /// A 404 (or 405) without a JSON `{error}` body is the framework's own "no
  /// such route" page: the server predates this endpoint. A 404 *with* an
  /// `error` field is the endpoint saying the thing does not exist.
  Future<Map<String, dynamic>> _call(
    String what,
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      if (data is Map) return jMap(data);
      throw AdminApiException(
        response.statusCode,
        'Onverwacht antwoord van de server voor $what.',
      );
    } on DioException catch (e) {
      throw mapAdminError(e, what);
    }
  }

  static Object mapAdminError(DioException e, String what) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map ? jStringOrNull(data['error']) : null;
    if ((status == 404 || status == 405) && message == null) {
      return AdminEndpointMissing(what);
    }
    if (status != null) {
      return AdminApiException(
        status,
        message ??
            switch (status) {
              401 => 'Je sessie is verlopen. Log opnieuw in.',
              403 => 'Dit account is geen beheerder.',
              _ => 'De server gaf een fout ($status) bij $what.',
            },
        field: data is Map ? jStringOrNull(data['field']) : null,
      );
    }
    return e;
  }

  // -------------------------------------------------------------------------
  // Endpoints
  // -------------------------------------------------------------------------

  /// Legacy premium figures (`/admin/stats`), kept for older servers.
  Future<AdminStats> getStats() async {
    final data = await _call(
      'de premiumcijfers',
      () => _dio.get('/admin/stats'),
    );
    return AdminStats.fromJson(data);
  }

  Future<AdminOverview> getOverview({bool deep = false}) async {
    final data = await _call(
      'het overzicht',
      () => _dio.get('/admin/overview', queryParameters: {if (deep) 'deep': 1}),
    );
    return AdminOverview.fromJson(data);
  }

  Future<AdminUserPage> getUsers(AdminUserQuery query) async {
    final data = await _call(
      'de gebruikerslijst',
      () => _dio.get('/admin/users', queryParameters: query.toQuery()),
    );
    return AdminUserPage.fromJson(data);
  }

  Future<AdminUserDetail> getUser(String id) async {
    final data = await _call(
      'de gebruikersdetails',
      () => _dio.get('/admin/users/${Uri.encodeComponent(id)}'),
    );
    return AdminUserDetail.fromJson(data);
  }

  Future<AdminGrantResult> grantPremium(
    String userId,
    AdminGrantRequest request,
  ) async {
    final data = await _call(
      'Premium geven',
      () => _dio.post(
        '/admin/users/${Uri.encodeComponent(userId)}/premium',
        data: request.toJson(),
      ),
    );
    return AdminGrantResult.fromJson(data);
  }

  Future<AdminGrantResult> grantPremiumByEmail(
    String email,
    AdminGrantRequest request,
  ) async {
    final data = await _call(
      'Premium geven',
      () => _dio.post(
        '/admin/premium-grants',
        data: {'email': email.trim(), ...request.toJson()},
      ),
    );
    return AdminGrantResult.fromJson(data);
  }

  Future<AdminGrantResult> revokePremium(String userId, {String? note}) async {
    final data = await _call(
      'Premium intrekken',
      () => _dio.delete(
        '/admin/users/${Uri.encodeComponent(userId)}/premium',
        data: {if (note != null && note.trim().isNotEmpty) 'note': note.trim()},
      ),
    );
    return AdminGrantResult.fromJson(data);
  }

  Future<AdminQuizList> getQuizzes({String? status, String q = ''}) async {
    final data = await _call(
      'de quizmoderatie',
      () => _dio.get(
        '/admin/quizzes',
        queryParameters: {
          'status': ?status,
          if (q.trim().isNotEmpty) 'q': q.trim(),
        },
      ),
    );
    return AdminQuizList.fromJson(data);
  }

  Future<AdminQuizRow?> updateQuiz(
    String id,
    AdminQuizAction action, {
    bool? isPremium,
  }) async {
    final data = await _call(
      'de quizmoderatie',
      () => _dio.patch(
        '/admin/quizzes/${Uri.encodeComponent(id)}',
        data: {
          'action': action.name,
          if (action == AdminQuizAction.premium) 'isPremium': isPremium,
        },
      ),
    );
    return data['quiz'] is Map
        ? AdminQuizRow.fromJson(jMap(data['quiz']))
        : null;
  }

  Future<AdminPaymentPage> getPayments(AdminPaymentQuery query) async {
    final data = await _call(
      'de betalingenlijst',
      () => _dio.get('/admin/payments', queryParameters: query.toQuery()),
    );
    return AdminPaymentPage.fromJson(data);
  }

  Future<AdminHealth> getPaymentsHealth({bool deep = false}) async {
    final data = await _call(
      'de betaalcontrole',
      () => _dio.get(
        '/admin/payments/health',
        queryParameters: {if (deep) 'deep': 1},
      ),
    );
    return AdminHealth.fromJson(data);
  }

  Future<AdminFunnel> getFunnel({int days = 30}) async {
    final data = await _call(
      'de funnel',
      () => _dio.get('/admin/funnel', queryParameters: {'days': days}),
    );
    return AdminFunnel.fromJson(data);
  }
}

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiClientProvider)),
);

/// Retry only what a retry can fix: never a missing endpoint (older server)
/// or a 4xx (no access, not found, bad input); a few times for the rest.
Duration? adminRetry(int retryCount, Object error) {
  if (error is AdminEndpointMissing) return null;
  if (error is AdminApiException && (error.statusCode ?? 500) < 500) {
    return null;
  }
  if (error is Error) return null;
  if (retryCount >= 2) return null;
  return Duration(seconds: 1 << retryCount);
}

/// Legacy figures; also the fallback when the server has no overview yet.
final adminStatsProvider = FutureProvider.autoDispose<AdminStats>(
  (ref) => ref.watch(adminRepositoryProvider).getStats(),
  retry: adminRetry,
);

final adminOverviewProvider = FutureProvider.autoDispose<AdminOverview>(
  (ref) => ref.watch(adminRepositoryProvider).getOverview(),
  retry: adminRetry,
);

final adminUserDetailProvider = FutureProvider.autoDispose
    .family<AdminUserDetail, String>(
      (ref, id) => ref.watch(adminRepositoryProvider).getUser(id),
      retry: adminRetry,
    );

final adminQuizzesProvider = FutureProvider.autoDispose
    .family<AdminQuizList, String?>(
      (ref, status) =>
          ref.watch(adminRepositoryProvider).getQuizzes(status: status),
      retry: adminRetry,
    );

final adminPaymentsHealthProvider = FutureProvider.autoDispose<AdminHealth>(
  (ref) => ref.watch(adminRepositoryProvider).getPaymentsHealth(),
  retry: adminRetry,
);

final adminFunnelProvider = FutureProvider.autoDispose.family<AdminFunnel, int>(
  (ref, days) => ref.watch(adminRepositoryProvider).getFunnel(days: days),
  retry: adminRetry,
);
