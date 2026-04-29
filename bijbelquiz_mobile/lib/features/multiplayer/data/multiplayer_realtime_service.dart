import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/config/app_config.dart';
import '../../auth/data/auth_local_storage.dart';

enum MultiplayerRealtimeEventType {
  roomJoined,
  playerJoined,
  playerLeft,
  questionStarted,
  progressUpdated,
  questionResolved,
  gameFinished,
  roomUpdated,
  error,
  unknown,
}

extension MultiplayerRealtimeEventTypeX on MultiplayerRealtimeEventType {
  static MultiplayerRealtimeEventType fromRaw(String? rawType) {
    switch (rawType?.toLowerCase()) {
      case 'room_joined':
        return MultiplayerRealtimeEventType.roomJoined;
      case 'player_joined':
        return MultiplayerRealtimeEventType.playerJoined;
      case 'player_left':
        return MultiplayerRealtimeEventType.playerLeft;
      case 'question_started':
        return MultiplayerRealtimeEventType.questionStarted;
      case 'progress_updated':
        return MultiplayerRealtimeEventType.progressUpdated;
      case 'question_resolved':
        return MultiplayerRealtimeEventType.questionResolved;
      case 'game_finished':
        return MultiplayerRealtimeEventType.gameFinished;
      case 'room_updated':
        return MultiplayerRealtimeEventType.roomUpdated;
      case 'error':
        return MultiplayerRealtimeEventType.error;
      default:
        return MultiplayerRealtimeEventType.unknown;
    }
  }
}

class MultiplayerRealtimeEvent {
  final MultiplayerRealtimeEventType type;
  final String rawType;
  final Map<String, dynamic> payload;

  const MultiplayerRealtimeEvent({
    required this.type,
    required this.rawType,
    required this.payload,
  });

  factory MultiplayerRealtimeEvent.fromDynamic(dynamic data) {
    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return MultiplayerRealtimeEvent.fromMap(decoded);
        }
        if (decoded is Map<dynamic, dynamic>) {
          return MultiplayerRealtimeEvent.fromMap(
            Map<String, dynamic>.from(decoded),
          );
        }
      }

      if (data is Map<String, dynamic>) {
        return MultiplayerRealtimeEvent.fromMap(data);
      }

      if (data is Map<dynamic, dynamic>) {
        return MultiplayerRealtimeEvent.fromMap(
          Map<String, dynamic>.from(data),
        );
      }
    } catch (_) {
      // Fall through to unknown event below.
    }

    return const MultiplayerRealtimeEvent(
      type: MultiplayerRealtimeEventType.unknown,
      rawType: 'unknown',
      payload: {},
    );
  }

  factory MultiplayerRealtimeEvent.fromMap(Map<String, dynamic> map) {
    final rawType =
        map['type']?.toString() ?? map['event']?.toString() ?? 'unknown';
    final payload = map['payload'];

    if (payload is Map<String, dynamic>) {
      return MultiplayerRealtimeEvent(
        type: MultiplayerRealtimeEventTypeX.fromRaw(rawType),
        rawType: rawType,
        payload: payload,
      );
    }

    if (payload is Map<dynamic, dynamic>) {
      return MultiplayerRealtimeEvent(
        type: MultiplayerRealtimeEventTypeX.fromRaw(rawType),
        rawType: rawType,
        payload: Map<String, dynamic>.from(payload),
      );
    }

    return MultiplayerRealtimeEvent(
      type: MultiplayerRealtimeEventTypeX.fromRaw(rawType),
      rawType: rawType,
      payload: const {},
    );
  }
}

class MultiplayerRealtimeService {
  final AuthLocalStorage _authLocalStorage;
  final StreamController<MultiplayerRealtimeEvent> _eventsController =
      StreamController<MultiplayerRealtimeEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  bool _isConnected = false;

  MultiplayerRealtimeService(this._authLocalStorage);

  Stream<MultiplayerRealtimeEvent> get events => _eventsController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect(String roomCode) async {
    await disconnect();

    final token = await _authLocalStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Geen sessietoken gevonden. Log opnieuw in.');
    }

    final wsUri = _buildWsUri(roomCode: roomCode, token: token);

    _channel = WebSocketChannel.connect(wsUri);

    final startedAt = DateTime.now();
    _subscription = _channel!.stream.listen(
      (dynamic message) {
        final event = MultiplayerRealtimeEvent.fromDynamic(message);
        if (!_eventsController.isClosed) {
          _eventsController.add(event);
        }
      },
      onError: (Object error) {
        _isConnected = false;
        if (!_eventsController.isClosed) {
          _eventsController.add(
            MultiplayerRealtimeEvent(
              type: MultiplayerRealtimeEventType.error,
              rawType: 'socket_error',
              payload: {'message': error.toString()},
            ),
          );
        }
      },
      onDone: () {
        _isConnected = false;
      },
      cancelOnError: false,
    );

    try {
      await _channel!.ready;
      _isConnected = true;
    } catch (error) {
      _isConnected = false;

      await _subscription?.cancel();
      _subscription = null;
      await _channel?.sink.close();
      _channel = null;
      rethrow;
    }
  }

  void send(Map<String, dynamic> message) {
    if (_channel == null || !_isConnected) {
      return;
    }

    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (error) {
      _isConnected = false;
      if (!_eventsController.isClosed) {
        _eventsController.add(
          MultiplayerRealtimeEvent(
            type: MultiplayerRealtimeEventType.error,
            rawType: 'socket_error',
            payload: {'message': error.toString()},
          ),
        );
      }
    }
  }

  void sendJoin(String roomCode) {
    send({
      'type': 'join_room',
      'payload': {'roomCode': roomCode.toUpperCase()},
    });
  }

  void sendLeave(String roomCode) {
    send({
      'type': 'leave_room',
      'payload': {'roomCode': roomCode.toUpperCase()},
    });
  }

  Future<void> disconnect() async {
    _isConnected = false;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _eventsController.close();
  }

  Uri _buildWsUri({required String roomCode, String? token}) {
    final apiUri = Uri.parse(AppConfig.effectiveApiBaseUrl);
    final wsScheme = apiUri.scheme == 'https' ? 'wss' : 'ws';

    final normalizedPath = apiUri.path.endsWith('/')
        ? apiUri.path.substring(0, apiUri.path.length - 1)
        : apiUri.path;

    final queryParameters = <String, String>{
      'roomCode': roomCode.toUpperCase(),
    };

    if (token != null && token.isNotEmpty) {
      queryParameters['token'] = token;
    }

    return apiUri.replace(
      scheme: wsScheme,
      path: '$normalizedPath/multiplayer/ws',
      queryParameters: queryParameters,
    );
  }

  String _redactWsUri(Uri uri) {
    final query = Map<String, String>.from(uri.queryParameters);
    if (query.containsKey('token')) {
      query['token'] = '***redacted***';
    }
    return uri.replace(queryParameters: query).toString();
  }

}
