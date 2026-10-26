import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/preview_config.dart';
import '../../auth/present/auth_controller.dart';
import '../domain/duel.dart';
import 'duels_preview.dart';

final duelsRepositoryProvider = Provider<DuelsRepository>((ref) {
  return DuelsRepository(ref.watch(apiClientProvider));
});

/// Every duel of this account, grouped for the Duels tab.
///
/// Not auto-disposed: the tab badge in the shell watches it all the time, and
/// Home reads it for the "wacht op jou" card. Guests get the empty list
/// without a request.
final duelListProvider = FutureProvider<DuelList>((ref) async {
  final repository = ref.watch(duelsRepositoryProvider);
  if (PreviewConfig.enabled) return repository.list();

  final hasSession = await ref.watch(hasSessionProvider.future);
  if (!hasSession) return DuelList.empty;
  return repository.list();
});

/// People to challenge: past opponents and player-group members for an empty
/// query, a name search otherwise.
final duelCandidatesProvider = FutureProvider.autoDispose
    .family<List<DuelCandidate>, String>((ref, query) async {
      return ref.watch(duelsRepositoryProvider).players(query: query);
    });

/// The link to share for an invite duel.
///
/// Built like `AppConfig.roomInviteUrl`: a page on the website, so somebody
/// without the app still lands somewhere, and the app opens it directly once
/// `/duel/*` is in the app-link files.
String duelInviteUrl(String token) =>
    '${AppConfig.baseUrl}/duel/${Uri.encodeComponent(token)}';

/// The message that goes with it, in step with `buildDuelInviteMessage` on
/// the website.
String duelInviteMessage(String token, String challengerName) {
  final name = challengerName.trim().isEmpty ? 'Iemand' : challengerName.trim();
  return [
    '$name daagt je uit voor een duel op BijbelQuiz!',
    '3 rondes van 3 vragen, om de beurt. Je speelt dit duel gratis.',
    '',
    duelInviteUrl(token),
  ].join('\n');
}

/// A failed duel request. [message] is Dutch and written for the player
/// (the server's own text whenever it sent one), so [toString] returns it as
/// is and `AppNotice.error` shows it verbatim.
class DuelApiException implements Exception {
  const DuelApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  final String code;
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// The duels HTTP client (`/api/mobile/duels`, see `src/lib/duels` on the
/// website). In preview mode every call is answered from [DuelsPreview].
class DuelsRepository {
  DuelsRepository(this._apiClient);

  final ApiClient _apiClient;

  DuelsPreview get _preview => DuelsPreview.instance;

  Future<DuelList> list() {
    if (PreviewConfig.enabled) {
      return Future.value(DuelList.fromJson(_preview.list()));
    }
    return _guard(
      fallback: 'Je duels konden niet laden.',
      request: () async {
        final response = await _apiClient.dio.get('/duels');
        return DuelList.fromJson(_map(response.data));
      },
    );
  }

  Future<Duel> get(String duelId) {
    if (PreviewConfig.enabled) {
      return Future.value(Duel.fromJson(_preview.duel(duelId)));
    }
    return _guard(
      fallback: 'Dit duel kon niet laden.',
      request: () async {
        final response = await _apiClient.dio.get(
          '/duels/${Uri.encodeComponent(duelId)}',
        );
        return Duel.fromJson(_map(_map(response.data)['duel']));
      },
    );
  }

  Future<DuelCreateResult> challengePlayer(String userId, {String? name}) {
    if (PreviewConfig.enabled) {
      return Future.value(
        DuelCreateResult.fromJson(_preview.create(opponentName: name)),
      );
    }
    return _create({'mode': 'friend', 'opponentId': userId});
  }

  Future<DuelCreateResult> challengeRandom() {
    if (PreviewConfig.enabled) {
      return Future.value(DuelCreateResult.fromJson(_preview.create()));
    }
    return _create({'mode': 'random'});
  }

  Future<DuelCreateResult> createInvite() {
    if (PreviewConfig.enabled) {
      return Future.value(DuelCreateResult.fromJson(_preview.create()));
    }
    return _create({'mode': 'invite'});
  }

  Future<DuelCreateResult> _create(Map<String, dynamic> body) {
    return _guard(
      fallback: 'Het duel kon niet worden gemaakt.',
      request: () async {
        final response = await _apiClient.dio.post('/duels', data: body);
        return DuelCreateResult.fromJson(_map(response.data));
      },
    );
  }

  Future<DuelInvitePreview> invitePreview(String token) {
    if (PreviewConfig.enabled) {
      return Future.value(DuelInvitePreview.fromJson(_preview.invite()));
    }
    return _guard(
      fallback: 'Deze uitnodiging kon niet laden.',
      request: () async {
        final response = await _apiClient.dio.get(
          '/duels/invite/${Uri.encodeComponent(token)}',
        );
        return DuelInvitePreview.fromJson(_map(_map(response.data)['invite']));
      },
    );
  }

  /// Takes the empty seat of an invite duel. Free: no premium involved.
  Future<Duel> joinInvite(String token) {
    if (PreviewConfig.enabled) {
      return Future.value(Duel.fromJson(_preview.duel('preview-lotte')));
    }
    return _guard(
      fallback: 'Meedoen aan dit duel lukte niet.',
      request: () async {
        final response = await _apiClient.dio.post(
          '/duels/join',
          data: {'token': token},
        );
        return Duel.fromJson(_map(_map(response.data)['duel']));
      },
    );
  }

  Future<List<DuelCandidate>> players({String query = ''}) {
    if (PreviewConfig.enabled) {
      return Future.value(
        _preview.players(query).map(DuelCandidate.fromJson).toList(),
      );
    }
    return _guard(
      fallback: 'Spelers konden niet laden.',
      request: () async {
        final response = await _apiClient.dio.get(
          '/duels/players',
          queryParameters: {if (query.trim().isNotEmpty) 'q': query.trim()},
        );
        final players = _map(response.data)['players'];
        if (players is! List) return const <DuelCandidate>[];
        return players
            .whereType<Map>()
            .map((row) => DuelCandidate.fromJson(Map<String, dynamic>.from(row)))
            .toList();
      },
    );
  }

  /// One answer. Graded by the server; the result carries the right answer,
  /// the explanation and - if they already played it - the opponent's pick.
  Future<DuelAnswerOutcome> answer({
    required String duelId,
    required int roundIndex,
    required int questionIndex,
    required String answerId,
  }) {
    if (PreviewConfig.enabled) {
      return Future.value(
        DuelAnswerOutcome.fromJson(
          _preview.answer(duelId, roundIndex, questionIndex, answerId),
        ),
      );
    }
    return _guard(
      fallback: 'Je antwoord kon niet worden verstuurd.',
      request: () async {
        final response = await _apiClient.dio.post(
          '/duels/${Uri.encodeComponent(duelId)}/answer',
          data: {
            'roundIndex': roundIndex,
            'questionIndex': questionIndex,
            'answerId': answerId,
          },
        );
        return DuelAnswerOutcome.fromJson(_map(response.data));
      },
    );
  }

  Future<Duel> decline(String duelId) => _action(duelId, 'decline');

  /// Gives up, or cancels a duel nobody joined yet.
  Future<Duel> forfeit(String duelId) => _action(duelId, 'forfeit');

  Future<Duel> _action(String duelId, String action) {
    if (PreviewConfig.enabled) {
      return Future.value(Duel.fromJson(_preview.duel(duelId)));
    }
    return _guard(
      fallback: 'Dat lukte niet. Probeer het opnieuw.',
      request: () async {
        final response = await _apiClient.dio.post(
          '/duels/${Uri.encodeComponent(duelId)}/$action',
        );
        return Duel.fromJson(_map(_map(response.data)['duel']));
      },
    );
  }

  Future<T> _guard<T>({
    required String fallback,
    required Future<T> Function() request,
  }) async {
    try {
      return await request();
    } on DuelApiException {
      rethrow;
    } on DioException catch (error) {
      throw _fromDio(error, fallback);
    } catch (_) {
      throw DuelApiException(code: 'UNKNOWN_ERROR', message: fallback);
    }
  }

  /// The duel routes answer with `{ error: { code, message } }`; the message
  /// is Dutch and meant for the player, so it is passed on as written.
  DuelApiException _fromDio(DioException error, String fallback) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const DuelApiException(
          code: 'NETWORK_ERROR',
          message: 'Geen verbinding. Controleer je internet en probeer het opnieuw.',
        );
      default:
        break;
    }

    final status = error.response?.statusCode;
    final body = _map(error.response?.data);
    final envelope = _map(body['error']);
    final code = envelope['code']?.toString() ??
        (status == 401 ? 'UNAUTHORIZED' : 'REQUEST_FAILED');

    if (status == 401) {
      return DuelApiException(
        code: code,
        message: 'Je sessie is verlopen. Log opnieuw in om te duelleren.',
        statusCode: status,
      );
    }

    final message = envelope['message']?.toString().trim();
    return DuelApiException(
      code: code,
      message: (message == null || message.isEmpty) ? fallback : message,
      statusCode: status,
    );
  }

  Map<String, dynamic> _map(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}
