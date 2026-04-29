import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../auth/present/auth_controller.dart';
import '../domain/multiplayer_models.dart';
import 'multiplayer_api_exception.dart';

final multiplayerRepositoryProvider = Provider<MultiplayerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MultiplayerRepository(apiClient);
});

class MultiplayerRepository {
  final ApiClient _apiClient;

  MultiplayerRepository(this._apiClient);

  Future<MultiplayerRoom> createRoom({
    required String quizId,
    int maxPlayers = 4,
  }) async {
    return _guard(
      action: 'createRoom',
      fallbackMessage: 'Kon geen kamer maken.',
      request: () async {
        final response = await _apiClient.dio.post(
          '/multiplayer/rooms',
          data: {'quizId': quizId, 'maxPlayers': maxPlayers},
        );
        final room = _extractRoom(response.data);
        return room;
      },
    );
  }

  Future<MultiplayerRoom> joinRoom(String roomCode) async {
    final normalizedCode = roomCode.toUpperCase();
    return _guard(
      action: 'joinRoom',
      fallbackMessage: 'Kon niet deelnemen aan kamer $normalizedCode.',
      request: () async {
        final response = await _apiClient.dio.post(
          '/multiplayer/rooms/$normalizedCode/join',
        );
        final room = _extractRoom(response.data);
        return room;
      },
    );
  }

  Future<MultiplayerRoom> getRoomSnapshot(String roomCode) async {
    final normalizedCode = roomCode.toUpperCase();
    return _guard(
      action: 'getRoomSnapshot',
      fallbackMessage: 'Kon kamer $normalizedCode niet laden.',
      request: () async {
        final response = await _apiClient.dio.get(
          '/multiplayer/rooms/$normalizedCode',
        );
        return _extractRoom(response.data);
      },
    );
  }

  Future<void> startMatch(String roomCode) async {
    final normalizedCode = roomCode.toUpperCase();
    return _guard(
      action: 'startMatch',
      fallbackMessage: 'Kon de quiz niet starten.',
      request: () async {
        await _apiClient.dio.post('/multiplayer/rooms/$normalizedCode/start');
      },
    );
  }

  Future<void> stopMatch(String roomCode) async {
    final normalizedCode = roomCode.toUpperCase();
    const fallbackMessage = 'Kon de quiz niet stoppen.';

    final postPathVariants = <String>[
      '/multiplayer/rooms/$normalizedCode/stop',
      '/multiplayer/rooms/$normalizedCode/end',
      '/multiplayer/rooms/$normalizedCode/finish',
    ];

    for (final path in postPathVariants) {
      try {
        await _apiClient.dio.post(path);
        return;
      } on DioException catch (error) {
        final apiException = _parseDioException(
          error,
          fallbackMessage: fallbackMessage,
        );

        // If the room is already gone, stopping is effectively complete.
        if (apiException.code == 'ROOM_NOT_FOUND') {
          return;
        }

        if (apiException.code == 'NOT_FOUND') {
          continue;
        }

        throw apiException;
      }
    }

    try {
      await _apiClient.dio.delete('/multiplayer/rooms/$normalizedCode');
      return;
    } on DioException catch (error) {
      final apiException = _parseDioException(
        error,
        fallbackMessage: fallbackMessage,
      );

      if (apiException.code == 'ROOM_NOT_FOUND') {
        return;
      }

      throw apiException;
    }
  }

  Future<void> submitAnswer({
    required String roomCode,
    required String questionId,
    required String answerId,
  }) async {
    final normalizedCode = roomCode.toUpperCase();
    return _guard(
      action: 'submitAnswer',
      fallbackMessage: 'Kon antwoord niet insturen.',
      request: () async {
        await _apiClient.dio.post(
          '/multiplayer/rooms/$normalizedCode/answer',
          data: {'questionId': questionId, 'answerId': answerId},
        );
      },
    );
  }

  Future<List<MultiplayerLeaderboardEntry>> getResults(String roomCode) async {
    final normalizedCode = roomCode.toUpperCase();
    return _guard(
      action: 'getResults',
      fallbackMessage: 'Kon resultaten niet laden.',
      request: () async {
        final response = await _apiClient.dio.get(
          '/multiplayer/rooms/$normalizedCode/results',
        );
        final data = response.data;
        final rawList = _extractLeaderboardList(data);
        return rawList
            .map((entry) => MultiplayerLeaderboardEntry.fromJson(entry))
            .toList();
      },
    );
  }

  Future<void> leaveRoom(String roomCode) async {
    final normalizedCode = roomCode.toUpperCase();
    return _guard(
      action: 'leaveRoom',
      fallbackMessage: 'Kon kamer niet verlaten.',
      request: () async {
        await _apiClient.dio.post('/multiplayer/rooms/$normalizedCode/leave');
      },
    );
  }

  MultiplayerRoom _extractRoom(dynamic data) {
    if (data is Map<String, dynamic>) {
      final roomData = data['room'];
      if (roomData is Map<String, dynamic>) {
        return MultiplayerRoom.fromJson(roomData);
      }
      return MultiplayerRoom.fromJson(data);
    }

    if (data is Map<dynamic, dynamic>) {
      final normalized = Map<String, dynamic>.from(data);
      final roomData = normalized['room'];
      if (roomData is Map<dynamic, dynamic>) {
        return MultiplayerRoom.fromJson(Map<String, dynamic>.from(roomData));
      }
      return MultiplayerRoom.fromJson(normalized);
    }

    throw Exception('Invalid room response format.');
  }

  List<Map<String, dynamic>> _extractLeaderboardList(dynamic data) {
    if (data is List<dynamic>) {
      return data
          .whereType<Map<dynamic, dynamic>>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final candidates = [data['results'], data['leaderboard']];
      for (final candidate in candidates) {
        if (candidate is List<dynamic>) {
          return candidate
              .whereType<Map<dynamic, dynamic>>()
              .map((entry) => Map<String, dynamic>.from(entry))
              .toList();
        }
      }
    }

    if (data is Map<dynamic, dynamic>) {
      return _extractLeaderboardList(Map<String, dynamic>.from(data));
    }

    return const [];
  }

  Future<T> _guard<T>({
    required String action,
    required String fallbackMessage,
    required Future<T> Function() request,
  }) async {
    try {
      return await request();
    } on DioException catch (error) {
      final apiException = _parseDioException(
        error,
        fallbackMessage: fallbackMessage,
      );
      throw apiException;
    } catch (error) {
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

    final code = _valueAsString(errorMap?['code']) ??
        _fallbackCode(
          error,
          responseMap: responseMap,
          errorMap: errorMap,
        );
    final message =
        _valueAsString(errorMap?['message']) ??
        _valueAsString(responseMap?['message']) ??
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
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'NETWORK_ERROR';
    }

    final statusCode = error.response?.statusCode;
    switch (statusCode) {
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
    final messageCandidates = <String?>[
      _valueAsString(errorMap?['message']),
      _valueAsString(responseMap?['message']),
      _valueAsString(errorMap?['code']),
    ];

    for (final candidate in messageCandidates) {
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
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map<dynamic, dynamic>) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  String? _valueAsString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

}
