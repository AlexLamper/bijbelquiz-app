import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/present/auth_controller.dart';
import '../data/multiplayer_api_exception.dart';
import '../data/multiplayer_realtime_service.dart';
import '../data/multiplayer_repository.dart';
import '../domain/multiplayer_models.dart';

final multiplayerSessionControllerProvider = AsyncNotifierProvider.autoDispose
    .family<MultiplayerSessionController, MultiplayerSessionState, String>(
      MultiplayerSessionController.new,
    );

class MultiplayerSessionController
    extends AsyncNotifier<MultiplayerSessionState> {
  MultiplayerSessionController(this.roomCode);

  static const int _roomNotFoundRetryThreshold = 3;

  final String roomCode;
  late final MultiplayerRepository _repository;
  late final MultiplayerRealtimeService _realtimeService;
  late final String _roomCode = roomCode.toUpperCase();

  StreamSubscription<MultiplayerRealtimeEvent>? _realtimeSubscription;
  Timer? _snapshotRefreshTimer;
  bool _refreshInProgress = false;
  bool _isShuttingDown = false;
  int _consecutiveRoomNotFound = 0;

  @override
  Future<MultiplayerSessionState> build() async {
    _repository = ref.read(multiplayerRepositoryProvider);
    final storage = ref.read(authStorageProvider);
    _realtimeService = MultiplayerRealtimeService(storage);

    ref.onDispose(() {
      unawaited(_shutdown());
    });

    final initialState = await _loadSnapshot(
      previous: null,
      resetAnswerSubmission: true,
    );

    unawaited(_connectRealtime());
    _startSnapshotRefresh();

    return initialState;
  }

  Future<void> refreshRoom({
    bool showLoading = false,
    bool resetAnswerSubmission = false,
  }) async {
    if (_refreshInProgress) return;
    _refreshInProgress = true;

    final existingState = state.asData?.value;
    if (showLoading) {
      state = const AsyncValue.loading();
    }

    try {
      final nextState = await _loadSnapshot(
        previous: existingState,
        resetAnswerSubmission: resetAnswerSubmission,
      );
      _consecutiveRoomNotFound = 0;
      state = AsyncValue.data(nextState);

      if (nextState.room.status == MultiplayerRoomStatus.questionResult) {
      }

      if (nextState.room.status == MultiplayerRoomStatus.finished &&
          _snapshotRefreshTimer != null) {
        _snapshotRefreshTimer?.cancel();
        _snapshotRefreshTimer = null;
      }
    } catch (e, st) {
      if (e is MultiplayerApiException && e.code == 'ROOM_NOT_FOUND') {
        await _handleRoomNotFound(existingState, source: 'refreshRoom');
        return;
      }

      if (existingState != null) {
        state = AsyncValue.data(
          existingState.copyWith(lastError: _errorText(e)),
        );
      } else {
        state = AsyncValue.error(e, st);
      }
    } finally {
      _refreshInProgress = false;
    }
  }

  Future<void> startMatch() async {
    try {
      await _repository.startMatch(_roomCode);
      await refreshRoom();
    } catch (e) {
      _setSessionError(_errorText(e));
    }
  }

  Future<void> stopMatch() async {
    try {
      await _repository.stopMatch(_roomCode);
      await refreshRoom();
    } catch (e) {
      if (e is MultiplayerApiException && e.code == 'ROOM_NOT_FOUND') {
        await _handleRoomNotFound(
          state.asData?.value,
          source: 'stopMatch',
        );
        return;
      }
      _setSessionError(_errorText(e));
    }
  }

  Future<void> submitAnswer({
    required String questionId,
    required String answerId,
  }) async {
    final current = state.asData?.value;
    if (current == null || current.hasSubmittedCurrentAnswer) return;

    state = AsyncValue.data(
      current.copyWith(
        hasSubmittedCurrentAnswer: true,
        selectedAnswerId: answerId,
      ),
    );

    try {
      await _repository.submitAnswer(
        roomCode: _roomCode,
        questionId: questionId,
        answerId: answerId,
      );
    } catch (e) {
      state = AsyncValue.data(
        current.copyWith(
          hasSubmittedCurrentAnswer: false,
          clearSelectedAnswer: true,
          lastError: _errorText(e),
        ),
      );
    }
  }

  Future<void> loadResults() async {
    final current = state.asData?.value;
    if (current == null) return;

    try {
      final leaderboard = await _repository.getResults(_roomCode);
      state = AsyncValue.data(
        current.copyWith(leaderboard: leaderboard, lastError: null),
      );
    } catch (e) {
      _setSessionError(_errorText(e));
    }
  }

  Future<void> leaveRoom() async {
    try {
      _realtimeService.sendLeave(_roomCode);
      await _repository.leaveRoom(_roomCode);
    } catch (_) {
      // Intentionally ignored to keep navigation responsive when cleanup fails.
    } finally {
      await _shutdown();
    }
  }

  Future<void> _shutdown() async {
    if (_isShuttingDown) return;
    _isShuttingDown = true;

    _snapshotRefreshTimer?.cancel();
    _snapshotRefreshTimer = null;
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    await _realtimeService.dispose();
  }

  Future<void> _connectRealtime() async {
    try {
      _realtimeSubscription = _realtimeService.events.listen((event) {
        unawaited(_handleRealtimeEvent(event));
      });

      await _realtimeService.connect(_roomCode);
      _realtimeService.sendJoin(_roomCode);
    } catch (e) {
      _setSessionError('Realtime verbinding niet beschikbaar. Verversing blijft actief.');
    }
  }

  Future<void> _handleRealtimeEvent(MultiplayerRealtimeEvent event) async {
    final payloadRoom = _roomFromPayload(event.payload);

    switch (event.type) {
      case MultiplayerRealtimeEventType.questionStarted:
        if (payloadRoom != null) {
          _applyRealtimeSnapshot(payloadRoom, resetAnswerSubmission: true);
        } else {
          await refreshRoom(resetAnswerSubmission: true);
        }
        return;
      case MultiplayerRealtimeEventType.gameFinished:
        if (payloadRoom != null) {
          _applyRealtimeSnapshot(
            payloadRoom,
            leaderboardOverride: _resultsFromPayload(event.payload),
          );
        } else {
          await refreshRoom();
        }

        final currentState = state.asData?.value;
        if (currentState == null || currentState.leaderboard.isEmpty) {
          await loadResults();
        }

        return;
      case MultiplayerRealtimeEventType.error:
        final code = event.payload['code']?.toString();
        final message = event.payload['message']?.toString();
        if (message != null && message.isNotEmpty) {
          final rawMessage = code != null && code.isNotEmpty
              ? '$code: $message'
              : message;
          _setSessionError(_errorText(rawMessage));
        }
        return;
      case MultiplayerRealtimeEventType.roomJoined:
      case MultiplayerRealtimeEventType.playerJoined:
      case MultiplayerRealtimeEventType.playerLeft:
      case MultiplayerRealtimeEventType.progressUpdated:
      case MultiplayerRealtimeEventType.questionResolved:
      case MultiplayerRealtimeEventType.roomUpdated:
      case MultiplayerRealtimeEventType.unknown:
        if (payloadRoom != null) {
          _applyRealtimeSnapshot(payloadRoom);
        } else {
          await refreshRoom();
        }
        return;
    }
  }

  void _startSnapshotRefresh() {
    _snapshotRefreshTimer?.cancel();
    _snapshotRefreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      unawaited(refreshRoom());
    });
  }

  void _setSessionError(String message) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(lastError: message));
  }

  void _applyRealtimeSnapshot(
    MultiplayerRoom room, {
    bool resetAnswerSubmission = false,
    List<MultiplayerLeaderboardEntry>? leaderboardOverride,
  }) {
    final current = state.asData?.value;
    final shouldResetAnswerSubmission =
        resetAnswerSubmission || _hasQuestionChanged(current?.room, room);

    state = AsyncValue.data(
      MultiplayerSessionState(
        room: room,
        leaderboard:
            leaderboardOverride ??
            current?.leaderboard ??
            const <MultiplayerLeaderboardEntry>[],
        hasSubmittedCurrentAnswer: shouldResetAnswerSubmission
            ? false
            : current?.hasSubmittedCurrentAnswer ?? false,
        selectedAnswerId: shouldResetAnswerSubmission
            ? null
            : current?.selectedAnswerId,
        lastError: null,
      ),
    );
  }

  Future<MultiplayerSessionState> _loadSnapshot({
    required MultiplayerSessionState? previous,
    required bool resetAnswerSubmission,
  }) async {
    final room = await _repository.getRoomSnapshot(_roomCode);
    var leaderboard =
        previous?.leaderboard ?? const <MultiplayerLeaderboardEntry>[];
    final shouldResetAnswerSubmission =
        resetAnswerSubmission || _hasQuestionChanged(previous?.room, room);

    if (room.status == MultiplayerRoomStatus.finished) {
      leaderboard = await _repository.getResults(_roomCode);
    }

    return MultiplayerSessionState(
      room: room,
      leaderboard: leaderboard,
      hasSubmittedCurrentAnswer: shouldResetAnswerSubmission
          ? false
          : previous?.hasSubmittedCurrentAnswer ?? false,
      selectedAnswerId: shouldResetAnswerSubmission
          ? null
          : previous?.selectedAnswerId,
      lastError: null,
    );
  }

  bool _hasQuestionChanged(MultiplayerRoom? previousRoom, MultiplayerRoom room) {
    final currentQuestionId = room.currentQuestion?.id;
    if (currentQuestionId == null || currentQuestionId.isEmpty) {
      return false;
    }

    final previousQuestionId = previousRoom?.currentQuestion?.id;
    return currentQuestionId != previousQuestionId;
  }

  Future<void> _handleRoomNotFound(
    MultiplayerSessionState? existingState, {
    required String source,
  }) async {
    _consecutiveRoomNotFound += 1;

    if (_consecutiveRoomNotFound < _roomNotFoundRetryThreshold) {
      if (existingState != null) {
        state = AsyncValue.data(
          existingState.copyWith(
            lastError:
                'Kamer tijdelijk niet bereikbaar. Opnieuw verbinden... '
                '($_consecutiveRoomNotFound/$_roomNotFoundRetryThreshold)',
          ),
        );
      }
      return;
    }

    if (existingState != null &&
        (existingState.room.status == MultiplayerRoomStatus.inProgress ||
            existingState.room.status == MultiplayerRoomStatus.questionResult ||
            existingState.room.status == MultiplayerRoomStatus.finished)) {
      try {
        final leaderboard = await _repository.getResults(_roomCode);
        final finishedRoom = _asFinishedRoom(existingState.room);
        await _pauseRealtimeAndPolling();
        state = AsyncValue.data(
          existingState.copyWith(
            room: finishedRoom,
            leaderboard: leaderboard,
            hasSubmittedCurrentAnswer: false,
            clearSelectedAnswer: true,
            lastError:
                'Kamer is gesloten tijdens het spel. Resultaten zijn geladen.',
          ),
        );
        return;
      } catch (error) {
        // Silently ignore fallback load failures
      }
    }

    await _pauseRealtimeAndPolling();
    const message =
        'Deze kamer bestaat niet meer of is gesloten. Ga terug en start een nieuwe kamer.';

    if (existingState != null) {
      state = AsyncValue.data(
        existingState.copyWith(
          hasSubmittedCurrentAnswer: false,
          clearSelectedAnswer: true,
          lastError: message,
        ),
      );
      return;
    }

    state = AsyncValue.error(Exception(message), StackTrace.current);
  }

  Future<void> _pauseRealtimeAndPolling() async {
    _snapshotRefreshTimer?.cancel();
    _snapshotRefreshTimer = null;
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    await _realtimeService.disconnect();
  }

  MultiplayerRoom _asFinishedRoom(MultiplayerRoom room) {
    return MultiplayerRoom(
      id: room.id,
      code: room.code,
      quizId: room.quizId,
      quizTitle: room.quizTitle,
      xpReward: room.xpReward,
      hostUserId: room.hostUserId,
      maxPlayers: room.maxPlayers,
      currentQuestionIndex: room.currentQuestionIndex,
      totalQuestions: room.totalQuestions,
      status: MultiplayerRoomStatus.finished,
      players: room.players,
      currentQuestion: null,
    );
  }

  String _errorText(Object error) {
    if (error is MultiplayerApiException) {
      switch (error.code) {
        case 'ROOM_NOT_FOUND':
          return 'Deze kamer bestaat niet meer of is gesloten. Ga terug en start een nieuwe kamer.';
        case 'NETWORK_ERROR':
          return 'Netwerkprobleem. Controleer je verbinding en probeer opnieuw.';
        default:
          return error.message;
      }
    }

    final text = error.toString();
    if (text.contains('WebSocketException') ||
        text.contains('WebSocketChannelException')) {
      return 'Realtime verbinding niet beschikbaar. Verversing blijft actief.';
    }

    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }
    return text;
  }

  MultiplayerRoom? _roomFromPayload(Map<String, dynamic> payload) {
    final roomData = payload['room'];
    if (roomData is Map<String, dynamic>) {
      return MultiplayerRoom.fromJson(roomData);
    }

    if (roomData is Map<dynamic, dynamic>) {
      return MultiplayerRoom.fromJson(Map<String, dynamic>.from(roomData));
    }

    return null;
  }

  List<MultiplayerLeaderboardEntry>? _resultsFromPayload(
    Map<String, dynamic> payload,
  ) {
    final rawResults = payload['results'] ?? payload['leaderboard'];
    if (rawResults is! List<dynamic>) {
      return null;
    }

    return rawResults.whereType<Map<dynamic, dynamic>>().map((entry) {
      return MultiplayerLeaderboardEntry.fromJson(
        Map<String, dynamic>.from(entry),
      );
    }).toList();
  }
}
