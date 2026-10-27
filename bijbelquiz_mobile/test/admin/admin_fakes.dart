import 'dart:convert';
import 'dart:io';

import 'package:bijbelquiz_mobile/core/api/api_client.dart';
import 'package:bijbelquiz_mobile/features/admin/data/admin_repository.dart';
import 'package:bijbelquiz_mobile/features/auth/data/auth_local_storage.dart';

/// Reads `test/fixtures/admin/<name>.json` (real responses from the local
/// server, or the contract examples).
Map<String, dynamic> fixture(String name) {
  final text = File('test/fixtures/admin/$name.json').readAsStringSync();
  return (jsonDecode(text) as Map).cast<String, dynamic>();
}

/// Token storage that never touches the secure-storage plugin.
class FakeAuthStorage extends AuthLocalStorage {
  FakeAuthStorage([this.token]);

  final String? token;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> deleteToken() async {}
}

ApiClient fakeApiClient() => ApiClient(FakeAuthStorage('t'));

/// An [AdminRepository] that answers from fixtures and records writes.
class FakeAdminRepository extends AdminRepository {
  FakeAdminRepository({this.missing = const {}, this.grantError})
    : super(fakeApiClient());

  /// Endpoint names that answer like an older server (404 page).
  final Set<String> missing;

  /// Thrown by [grantPremium] when set.
  Object? grantError;

  final List<AdminGrantRequest> grants = [];
  final List<String> revokes = [];
  final List<(String, AdminQuizAction, bool?)> quizActions = [];

  void _check(String name, String what) {
    if (missing.contains(name)) throw AdminEndpointMissing(what);
  }

  @override
  Future<AdminStats> getStats() async => AdminStats.fromJson(fixture('stats'));

  @override
  Future<AdminOverview> getOverview({bool deep = false}) async {
    _check('overview', 'het overzicht');
    return AdminOverview.fromJson(fixture('overview'));
  }

  @override
  Future<AdminUserPage> getUsers(AdminUserQuery query) async {
    _check('users', 'de gebruikerslijst');
    return AdminUserPage.fromJson(fixture('users'));
  }

  @override
  Future<AdminUserDetail> getUser(String id) async {
    _check('user', 'de gebruikersdetails');
    if (id == 'manual') {
      return AdminUserDetail.fromJson(fixture('user_detail_manual'));
    }
    // A busy account: the real detail plus contract payments and a grant
    // history, so every block of the screen has rows.
    return AdminUserDetail.fromJson({
      ...fixture('user_detail_active'),
      'payments': fixture('payments_contract')['payments'],
      'grantLog': [
        fixture('revoke_response')['grant'],
        ...fixture('user_detail_manual')['grantLog'] as List,
      ],
    });
  }

  @override
  Future<AdminGrantResult> grantPremium(
    String userId,
    AdminGrantRequest request,
  ) async {
    if (grantError != null) throw grantError!;
    grants.add(request);
    return AdminGrantResult.fromJson(fixture('grant_response'));
  }

  @override
  Future<AdminGrantResult> grantPremiumByEmail(
    String email,
    AdminGrantRequest request,
  ) async {
    grants.add(request);
    return AdminGrantResult.fromJson(fixture('grant_response'));
  }

  @override
  Future<AdminGrantResult> revokePremium(String userId, {String? note}) async {
    revokes.add(userId);
    return AdminGrantResult.fromJson(fixture('revoke_response'));
  }

  @override
  Future<AdminQuizList> getQuizzes({String? status, String q = ''}) async {
    _check('quizzes', 'de quizmoderatie');
    final all = AdminQuizList.fromJson(fixture('quizzes'));
    // Give the list a pending item so the moderation buttons render.
    final quizzes = [
      AdminQuizRow(
        id: 'pending1',
        title: 'Een nieuwe quiz over de profeet Jona en de grote vis',
        status: 'pending',
        category: 'Profeten',
        questionCount: 12,
        createdBy: 'Beheerder',
        createdAt: DateTime.utc(2026, 10, 26),
      ),
      ...all.quizzes,
    ];
    return AdminQuizList(
      counts: {...all.counts, 'pending': 1},
      quizzes: status == null
          ? quizzes
          : quizzes.where((x) => x.status == status).toList(),
    );
  }

  @override
  Future<AdminQuizRow?> updateQuiz(
    String id,
    AdminQuizAction action, {
    bool? isPremium,
  }) async {
    quizActions.add((id, action, isPremium));
    return null;
  }

  @override
  Future<AdminPaymentPage> getPayments(AdminPaymentQuery query) async {
    _check('payments', 'de betalingenlijst');
    return AdminPaymentPage.fromJson(fixture('payments_contract'));
  }

  @override
  Future<AdminHealth> getPaymentsHealth({bool deep = false}) async {
    _check('health', 'de betaalcontrole');
    return AdminHealth.fromJson(fixture('payments_health'));
  }

  @override
  Future<AdminFunnel> getFunnel({int days = 30}) async {
    _check('funnel', 'de funnel');
    return AdminFunnel.fromJson(fixture('funnel'));
  }
}
