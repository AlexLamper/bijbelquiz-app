import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bijbelquiz_mobile/core/api/api_client.dart';
import 'package:bijbelquiz_mobile/features/admin/data/admin_repository.dart';

import 'admin/admin_fakes.dart';

/// Answers every request with a fixed status, body and content type, and
/// remembers the last request.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.status, this.body, {this.contentType = 'application/json'});

  final int status;
  final String body;
  final String contentType;
  RequestOptions? last;
  Object? lastBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    lastBody = options.data;
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

(AdminRepository, _StubAdapter) _repo(
  int status,
  Object body, {
  String contentType = 'application/json',
}) {
  final client = ApiClient(FakeAuthStorage('token'));
  final adapter = _StubAdapter(
    status,
    body is String ? body : jsonEncode(body),
    contentType: contentType,
  );
  client.dio.httpClientAdapter = adapter;
  return (AdminRepository(client), adapter);
}

void main() {
  group('overview', () {
    test('parses the real server response', () {
      final o = AdminOverview.fromJson(fixture('overview'));
      expect(o.usersTotal, 13);
      expect(o.registrationsToday.total, 4);
      expect(o.registrationsToday.of('web-desktop'), 4);
      expect(o.registrationsAllTime.of('web-mobile'), 8);
      expect(o.registrationsAllTime.of('android'), 0);
      expect(o.weekly, hasLength(12));
      expect(o.weekly.last.label, '26 okt');
      expect(o.byMethod['email'], 11);
      expect(o.active7d.of('android'), 8);
      expect(o.retention.base, 9);
      expect(o.retentionByPlatform['ios']!.rate, 100);
      expect(o.premiumTotal, 7);
      expect(o.premiumShare, closeTo(53.8, 0.01));
      expect(o.premiumBySource['manual'], 1);
      expect(o.conversion.base, 13);
      expect(o.paidConversion.part, 4);
      // `paid` has no accounts of its own: it borrows the total.
      expect(o.paidConversion.base, 13);
      expect(o.conversionByPlatform['web-desktop']!.rate, 75);
      expect(o.conversionNew30d.part, 3);
      expect(o.grantsActive, 1);
      expect(o.grantsExpiringIn7d, 1);
      expect(o.revenue.source('stripe').payments, 0);
      expect(o.quizzesTotal, 19);
      expect(o.plays30d.of('web'), 225);
      expect(o.health!.overall, 'fail');
      expect(o.health!.issues, isNotEmpty);
      expect(o.health!.hasFunnel, isFalse);
      expect(o.recentUsers.first.premium.source, 'group');
      expect(o.recentUsers.first.signupPlatformDerived, isTrue);
    });

    test('an empty object reads as zeros, not a crash', () {
      final o = AdminOverview.fromJson(const {});
      expect(o.usersTotal, 0);
      expect(o.weekly, isEmpty);
      expect(o.health, isNull);
      expect(o.revenue.currency, 'eur');
    });

    test('contract example: other currencies and revenue per source', () {
      final o = AdminOverview.fromJson({
        'revenue': fixture('payments_contract')['revenue'],
        'health': null,
      });
      expect(o.revenue.netCentsLast30d, 12345);
      expect(o.revenue.source('store').netCentsAllTime, 49999);
      expect(o.revenue.otherCurrenciesAllTime.single.currency, 'usd');
      expect(o.revenue.otherCurrenciesAllTime.single.netCents, 499);
      expect(o.health, isNull);
    });
  });

  group('users', () {
    test('list parses paging and rows', () {
      final page = AdminUserPage.fromJson(fixture('users'));
      expect(page.total, 13);
      expect(page.pages, 3);
      expect(page.hasMore, isTrue);
      expect(page.users, hasLength(5));
      final u = page.users.first;
      expect(u.id, isNotEmpty);
      expect(u.signupPlatform, 'web-desktop');
      expect(u.premium.active, isTrue);
      expect(u.premium.until, isNotNull);
      expect(u.lastActiveAt, isNull);
    });

    test('query only sends what is set', () {
      const q = AdminUserQuery();
      expect(q.toQuery(), {
        'sort': 'createdAt',
        'order': 'desc',
        'page': 1,
        'pageSize': 25,
      });
      final f = q.copyWith(
        q: ' anna ',
        platform: 'ios',
        premium: 'yes',
        source: 'manual',
        test: 'exclude',
        sort: 'lastActive',
        order: 'asc',
        page: 2,
      );
      expect(f.toQuery(), {
        'q': 'anna',
        'platform': 'ios',
        'premium': 'yes',
        'source': 'manual',
        'test': 'exclude',
        'sort': 'lastActive',
        'order': 'asc',
        'page': 2,
        'pageSize': 25,
      });
      expect(f.copyWith(platform: null).platform, isNull);
      expect(f.copyWith(page: 2), f);
    });

    test('detail parses every block', () {
      final d = AdminUserDetail.fromJson(fixture('user_detail'));
      expect(d.user.row.name, 'Noor');
      expect(d.user.levelTitle, 'Zoeker');
      expect(d.premium.groupActive, isTrue);
      expect(d.premium.groupLicenses.single.name, 'Jeugdgroep 16+');
      expect(d.premium.manual.active, isFalse);
      expect(d.premium.stripe.isKnown, isFalse);
      expect(d.platformHistory.single.sessions, 2);
      expect(d.counts.groupLicensesMember, 1);
      expect(d.canRevoke, isFalse);

      final active = AdminUserDetail.fromJson(fixture('user_detail_active'));
      expect(active.recentAttempts, isNotEmpty);
      expect(active.recentAttempts.first.quizTitle, isNotEmpty);
      expect(active.platformHistory.length, greaterThan(1));
    });

    test('detail with a manual grant and its audit trail', () {
      final d = AdminUserDetail.fromJson(fixture('user_detail_manual'));
      expect(d.premium.manual.active, isTrue);
      expect(d.premium.manual.until, isNotNull);
      expect(d.premium.manual.grantedBy!.email, 'beheer@voorbeeld.nl');
      expect(d.grantLog.single.action, 'grant');
      expect(d.grantLog.single.duration, '7d');
      expect(d.canRevoke, isTrue);
    });

    test('a revoke clears the manual grant and logs it', () {
      final d = AdminUserDetail.fromJson(fixture('user_detail_manual'));
      final revoked = AdminGrantResult.fromJson(fixture('revoke_response'));
      final after = d.withPremium(revoked.premium, entry: revoked.grant);
      expect(after.canRevoke, isFalse);
      expect(after.premium.state.active, isFalse);
      expect(after.grantLog.first.isRevoke, isTrue);
      expect(after.grantLog, hasLength(2));
    });
  });

  group('grants', () {
    test('request body per duration', () {
      expect(
        const AdminGrantRequest(duration: AdminGrantDuration.month1).toJson(),
        {'duration': '1m', 'until': null},
      );
      expect(
        AdminGrantRequest(
          duration: AdminGrantDuration.custom,
          until: DateTime(2026, 12, 31),
          note: '  Prijs  ',
        ).toJson(),
        {'duration': 'custom', 'until': '2026-12-31', 'note': 'Prijs'},
      );
      // A date is ignored for presets.
      expect(
        AdminGrantRequest(
          duration: AdminGrantDuration.lifetime,
          until: DateTime(2026, 12, 31),
        ).toJson()['until'],
        isNull,
      );
      expect(AdminGrantDuration.values.map((d) => d.key), [
        '7d',
        '1m',
        '3m',
        '1y',
        'lifetime',
        'custom',
      ]);
    });

    test('grant and revoke responses', () {
      final g = AdminGrantResult.fromJson(fixture('grant_response'));
      expect(g.premium.active, isTrue);
      expect(g.premium.source, 'manual');
      expect(g.grant!.duration, '1m');
      expect(g.grant!.by!.name, 'Beheerder');
      final r = AdminGrantResult.fromJson(fixture('revoke_response'));
      expect(r.premium.active, isFalse);
      expect(r.grant!.isRevoke, isTrue);
    });

    test('POST sends the body to the user path', () async {
      final (repo, adapter) = _repo(200, fixture('grant_response'));
      final result = await repo.grantPremium(
        'abc',
        const AdminGrantRequest(duration: AdminGrantDuration.days7, note: 'x'),
      );
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.path, '/admin/users/abc/premium');
      expect(adapter.lastBody, {'duration': '7d', 'until': null, 'note': 'x'});
      expect(result.premium.active, isTrue);
    });

    test('by e-mail adds the address', () async {
      final (repo, adapter) = _repo(200, {
        ...fixture('grant_response'),
        'user': fixture('users')['users'][0],
      });
      final result = await repo.grantPremiumByEmail(
        ' anna@example.nl ',
        const AdminGrantRequest(duration: AdminGrantDuration.months3),
      );
      expect(adapter.last!.path, '/admin/premium-grants');
      expect((adapter.lastBody as Map)['email'], 'anna@example.nl');
      expect((adapter.lastBody as Map)['duration'], '3m');
      expect(result.user!.name, 'Noor');
    });

    test('DELETE revokes', () async {
      final (repo, adapter) = _repo(200, fixture('revoke_response'));
      await repo.revokePremium('abc', note: 'oeps');
      expect(adapter.last!.method, 'DELETE');
      expect(adapter.lastBody, {'note': 'oeps'});
    });
  });

  group('quizzes, payments, funnel, health', () {
    test('quiz list', () {
      final list = AdminQuizList.fromJson(fixture('quizzes'));
      expect(list.counts['approved'], 19);
      expect(list.quizzes, hasLength(19));
      expect(list.quizzes.first.plays30d, isNotNull);
      expect(list.quizzes.first.createdBy, isNull);
    });

    test('quiz PATCH body', () async {
      final (repo, adapter) = _repo(200, {
        'ok': true,
        'quiz': fixture('quizzes')['quizzes'][0],
      });
      final quiz = await repo.updateQuiz(
        'q1',
        AdminQuizAction.premium,
        isPremium: true,
      );
      expect(adapter.last!.method, 'PATCH');
      expect(adapter.lastBody, {'action': 'premium', 'isPremium': true});
      expect(quiz!.title, 'Wie zei het?');

      await repo.updateQuiz('q1', AdminQuizAction.approve);
      expect(adapter.lastBody, {'action': 'approve'});
    });

    test('payments page with contract rows', () {
      final page = AdminPaymentPage.fromJson(fixture('payments_contract'));
      expect(page.hasMore, isTrue);
      expect(page.revenue!.paymentsCompleted, 140);
      final p = page.payments;
      expect(p[0].channel, 'app_store');
      expect(p[0].counted, isTrue);
      expect(p[1].channel, 'stripe');
      expect(p[1].isRenewal, isTrue);
      expect(p[1].status, 'refunded');
      expect(p[2].userId, isNull);
      expect(p[2].currency, 'usd');
      expect(p[2].refundedCents, 1000);

      final empty = AdminPaymentPage.fromJson(fixture('payments'));
      expect(empty.payments, isEmpty);
      expect(empty.revenue, isNotNull);
    });

    test('payments health with funnel and access gaps', () {
      final h = AdminHealth.fromJson(fixture('payments_health'));
      expect(h.overall, 'fail');
      expect(h.hasFunnel, isTrue);
      expect(h.paywallShown, 89);
      expect(h.purchaseCompleted, 2);
      expect(h.stripeKeyMode, 'missing');
      expect(h.accessGaps, isEmpty);

      final gaps = AdminHealth.fromJson({
        'overall': 'warn',
        'accessGaps': [
          {
            'userId': 'u1',
            'name': 'Anna',
            'email': 'a@b.nl',
            'reason': 'Betaald via Stripe, geen Premium',
            'when': '2026-10-20T10:00:00.000Z',
          },
        ],
      });
      expect(gaps.accessGapCount, 1);
      expect(gaps.accessGaps.single.when, isNotNull);
    });

    test('funnel report', () {
      final f = AdminFunnel.fromJson(fixture('funnel'));
      expect(f.windowDays, 30);
      expect(f.paywallShown, 89);
      expect(f.paywallConversion, closeTo(2.2, 0.01));
      expect(f.byTrigger.first.trigger, 'explanation_locked');
      expect(f.freeQuota, 5);
      expect(f.retentionFree, isNotNull);
    });

    test('legacy /admin/stats still parses', () {
      final s = AdminStats.fromJson(fixture('stats'));
      expect(s.totalUsers, greaterThan(0));
      expect(s.health, isNotNull);
      expect(s.health!.hasFunnel, isTrue);
    });
  });

  group('errors', () {
    test('an HTML 404 means the server is older', () async {
      final (repo, _) = _repo(
        404,
        '<!DOCTYPE html><html>404</html>',
        contentType: 'text/html; charset=utf-8',
      );
      expect(repo.getOverview(), throwsA(isA<AdminEndpointMissing>()));
    });

    test('a JSON 404 is a real "not found"', () async {
      final (repo, _) = _repo(404, {'error': 'Gebruiker niet gevonden.'});
      await expectLater(
        repo.getUser('abc'),
        throwsA(
          isA<AdminApiException>()
              .having((e) => e.statusCode, 'status', 404)
              .having((e) => e.message, 'message', 'Gebruiker niet gevonden.'),
        ),
      );
    });

    test('a 400 carries the field', () async {
      final (repo, _) = _repo(400, {
        'error': 'De einddatum moet in de toekomst liggen.',
        'field': 'until',
      });
      await expectLater(
        repo.grantPremium(
          'abc',
          AdminGrantRequest(
            duration: AdminGrantDuration.custom,
            until: DateTime(2020),
          ),
        ),
        throwsA(
          isA<AdminApiException>().having((e) => e.field, 'field', 'until'),
        ),
      );
    });

    test('403 for a non-admin', () async {
      final (repo, _) = _repo(403, {'error': 'Forbidden'});
      await expectLater(
        repo.getUsers(const AdminUserQuery()),
        throwsA(
          isA<AdminApiException>().having((e) => e.statusCode, 'status', 403),
        ),
      );
    });
  });
}
