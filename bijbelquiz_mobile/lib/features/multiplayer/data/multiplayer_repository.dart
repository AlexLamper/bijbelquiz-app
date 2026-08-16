import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../auth/present/auth_controller.dart';
import '../domain/multiplayer_models.dart';
import 'multiplayer_api_exception.dart';

final multiplayerRepositoryProvider = Provider<MultiplayerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MultiplayerRepository(apiClient);
});

/// Fetched once per app run: the cadence numbers never change mid-session and
/// every open room would otherwise ask for them again.
final multiplayerConfigProvider = FutureProvider<MultiplayerConfig>((ref) async {
  return ref.watch(multiplayerRepositoryProvider).getConfig();
});

/// The multiplayer HTTP client.
///
/// Every path below is documented in `docs/multiplayer-api.md`. There is no
/// socket transport: the app is deployed against Vercel, where API routes are
/// serverless functions that cannot hold a connection open, so the server owns
/// the state machine and clients drive it by polling.
class MultiplayerRepository {
  MultiplayerRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Timing constants. Falls back to the documented defaults rather than
  /// failing, since a missing config must not block a game from starting.
  Future<MultiplayerConfig> getConfig() async {
    try {
      final response = await _apiClient.dio.get('/multiplayer/config');
      final data = _toMap(response.data);
      if (data == null) return MultiplayerConfig.fallback;
      return MultiplayerConfig.fromJson(data);
    } catch (_) {
      return MultiplayerConfig.fallback;
    }
  }

  /// What this user may do, so the paywall can appear before they pick a quiz.
  Future<MultiplayerCapability> getCapability() async {
    return _guard(
      fallbackMessage: 'Kon je speelruimte niet ophalen.',
      request: () async {
        final response = await _apiClient.dio.get('/multiplayer/rooms');
        final data = _toMap(response.data);
        if (data == null) return MultiplayerCapability.unknown;
        return MultiplayerCapability.fromJson(data);
      },
    );
  }

  Future<MultiplayerRoom> createRoom({
    required String quizId,
    int maxPlayers = 4,
  }) {
    return _guard(
      fallbackMessage: 'Kon geen kamer maken.',
      request: () async {
        final response = await _apiClient.dio.post(
          '/multiplayer/rooms',
          data: {'quizId': quizId, 'maxPlayers': maxPlayers},
        );
        return _extractRoom(response.data);
      },
    );
  }

  /// The unfinished room this user is already in, if any.
  ///
  /// Called on a cold start so a crash, a reboot or an incoming call drops the
  /// player back into their game instead of an empty lobby list.
  Future<MultiplayerRoom?> getActiveRoom() async {
    try {
      final response = await _apiClient.dio.get('/multiplayer/rooms/active');
      final data = _toMap(response.data);
      final room = data?['room'];
      if (room == null) return null;
      return _extractRoom(response.data);
    } catch (_) {
      return null;
    }
  }

  /// Joins a room.
  ///
  /// [viaInvite] appends the same `?bron=uitnodiging` marker the website puts
  /// on a shared link, so a join that started as a share-sheet tap is
  /// attributable in the funnel rather than looking like somebody who typed a
  /// code they got by other means.
  Future<MultiplayerRoom> joinRoom(String roomCode, {bool viaInvite = false}) {
    final code = roomCode.toUpperCase();
    final query = viaInvite
        ? '?${AppConfig.inviteSourceParam}=${AppConfig.inviteSourceValue}'
        : '';
    return _guard(
      fallbackMessage: 'Kon niet deelnemen aan kamer $code.',
      request: () async {
        final response = await _apiClient.dio.post(
          '/multiplayer/rooms/$code/join$query',
        );
        return _extractRoom(response.data);
      },
    );
  }

  /// The polling endpoint. Doubles as the heartbeat that keeps this player
  /// marked online, which is why it runs even while nothing on screen moves.
  Future<MultiplayerRoom> getRoomSnapshot(String roomCode) {
    final code = roomCode.toUpperCase();
    return _guard(
      fallbackMessage: 'Kon kamer $code niet laden.',
      request: () async {
        final response = await _apiClient.dio.get('/multiplayer/rooms/$code');
        return _extractRoom(response.data);
      },
    );
  }

  Future<MultiplayerRoom> startMatch(String roomCode) {
    final code = roomCode.toUpperCase();
    return _guard(
      fallbackMessage: 'Kon de quiz niet starten.',
      request: () async {
        final response = await _apiClient.dio.post(
          '/multiplayer/rooms/$code/start',
        );
        return _extractRoom(response.data);
      },
    );
  }

  /// Ends the reveal pause early. Host only, and only during
  /// `question_result`. Idempotent: if the pause already elapsed the server
  /// returns the current snapshot instead of failing.
  Future<MultiplayerRoom> advance(String roomCode) {
    final code = roomCode.toUpperCase();
    return _guard(
      fallbackMessage: 'Kon niet doorgaan naar de volgende vraag.',
      request: () async {
        final response = await _apiClient.dio.post(
          '/multiplayer/rooms/$code/advance',
        );
        return _extractRoom(response.data);
      },
    );
  }

  /// Submits an answer and returns the snapshot the server built right after,
  /// so the UI can settle immediately instead of waiting for the next poll.
  Future<MultiplayerRoom> submitAnswer({
    required String roomCode,
    required String questionId,
    required String answerId,
  }) {
    final code = roomCode.toUpperCase();
    return _guard(
      fallbackMessage: 'Kon antwoord niet insturen.',
      request: () async {
        final response = await _apiClient.dio.post(
          '/multiplayer/rooms/$code/answer',
          data: {'questionId': questionId, 'answerId': answerId},
        );
        return _extractRoom(response.data);
      },
    );
  }

  Future<List<MultiplayerLeaderboardEntry>> getResults(String roomCode) {
    final code = roomCode.toUpperCase();
    return _guard(
      fallbackMessage: 'Kon resultaten niet laden.',
      request: () async {
        final response = await _apiClient.dio.get(
          '/multiplayer/rooms/$code/results',
        );
        return _extractLeaderboardList(response.data)
            .map(MultiplayerLeaderboardEntry.fromJson)
            .toList();
      },
    );
  }

  /// Leaves the room. Idempotent and safe on a room that no longer exists, so
  /// failures are swallowed: navigation must never be blocked by cleanup.
  ///
  /// In the lobby this removes the player (deleting the room if they were the
  /// last, or handing the host role on). Mid-game it only marks them offline,
  /// so their score survives if they come back.
  Future<void> leaveRoom(String roomCode) async {
    final code = roomCode.toUpperCase();
    try {
      await _apiClient.dio.post('/multiplayer/rooms/$code/leave');
    } catch (_) {
      // Already gone, or offline. Either way there is nothing left to do.
    }
  }

  MultiplayerRoom _extractRoom(dynamic data) {
    final map = _toMap(data);
    if (map == null) {
      throw const MultiplayerApiException(
        code: 'INVALID_RESPONSE',
        message: 'Onverwacht antwoord van de server.',
      );
    }

    final room = _toMap(map['room']);
    return MultiplayerRoom.fromJson(room ?? map);
  }

  List<Map<String, dynamic>> _extractLeaderboardList(dynamic data) {
    if (data is List) {
      return data
          .map(_toMap)
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    final map = _toMap(data);
    if (map == null) return const [];

    for (final candidate in [map['results'], map['leaderboard']]) {
      if (candidate is List) {
        return candidate
            .map(_toMap)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }

    return const [];
  }

  Future<T> _guard<T>({
    required String fallbackMessage,
    required Future<T> Function() request,
  }) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw _parseDioException(error, fallbackMessage: fallbackMessage);
    } on MultiplayerApiException {
      rethrow;
    } catch (_) {
      throw MultiplayerApiException(
        code: 'UNKNOWN_ERROR',
        message: fallbackMessage,
      );
    }
  }

  MultiplayerApiException _parseDioException(
    DioException error, {
    required String fallbackMessage,
  }) {
    final statusCode = error.response?.statusCode;
    final responseMap = _toMap(error.response?.data);
    final errorMap = _toMap(responseMap?['error']);

    final code =
        _valueAsString(errorMap?['code']) ??
        _fallbackCode(error, responseMap: responseMap, errorMap: errorMap);

    // The server's messages are Dutch and contextual (they name the quota left,
    // the days remaining), so they are shown verbatim wherever present.
    final message =
        _valueAsString(errorMap?['message']) ??
        _valueAsString(responseMap?['message']) ??
        _valueAsString(responseMap?['error']) ??
        fallbackMessage;

    return MultiplayerApiException(
      code: code,
      message: message,
      statusCode: statusCode,
    );
  }

  String _fallbackCode(
    DioException error, {
    Map<String, dynamic>? responseMap,
    Map<String, dynamic>? errorMap,
  }) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return 'NETWORK_ERROR';
      default:
        break;
    }

    switch (error.response?.statusCode) {
      case 401:
        return 'UNAUTHORIZED';
      case 403:
        return 'FORBIDDEN';
      case 404:
        return _looksLikeRoomNotFound(responseMap, errorMap)
            ? 'ROOM_NOT_FOUND'
            : 'NOT_FOUND';
      case 409:
        return 'CONFLICT';
      default:
        return 'REQUEST_FAILED';
    }
  }

  bool _looksLikeRoomNotFound(
    Map<String, dynamic>? responseMap,
    Map<String, dynamic>? errorMap,
  ) {
    final candidates = <String?>[
      _valueAsString(errorMap?['message']),
      _valueAsString(responseMap?['message']),
      _valueAsString(errorMap?['code']),
    ];

    for (final candidate in candidates) {
      final normalized = candidate?.toLowerCase() ?? '';
      if (normalized.contains('room not found') ||
          normalized.contains('kamer niet gevonden') ||
          normalized.contains('room_not_found')) {
        return true;
      }
    }

    return false;
  }

  Map<String, dynamic>? _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  String? _valueAsString(dynamic value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }
}
