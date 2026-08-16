import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../data/multiplayer_api_exception.dart';
import '../data/multiplayer_repository.dart';
import '../domain/multiplayer_models.dart';

final multiplayerSessionControllerProvider = AsyncNotifierProvider.autoDispose
    .family<MultiplayerSessionController, MultiplayerSessionState, String>(
      MultiplayerSessionController.new,
    );

/// Drives one multiplayer room.
///
/// The server owns the game loop and advances it lazily on whatever request
/// arrives next, so a room only moves while somebody is polling. This class is
/// that somebody: a single timer per room, at the cadence the server asks for,
/// shortened to land just after a deadline so a transition shows up the moment
/// it happens rather than up to a full interval late.
///
/// It replaces an earlier WebSocket client. There is no socket endpoint - the
/// backend runs on serverless functions that cannot hold one open - so that
/// client failed on every connect and left the poll running at a flat four
/// seconds, which is why questions appeared to freeze and results arrived late.
class MultiplayerSessionController
    extends AsyncNotifier<MultiplayerSessionState> {
  MultiplayerSessionController(this.roomCode);

  /// A single 404 can be a blip. Latching on the first one strands the player
  /// on a dead-end screen for a room that is still running, so two in a row
  /// are required before the session is declared gone.
  static const int _roomNotFoundThreshold = 2;

  static const Duration _maxBackoff = Duration(seconds: 6);

  final String roomCode;

  late final MultiplayerRepository _repository;
  late final String _roomCode = roomCode.toUpperCase();

  MultiplayerConfig _config = MultiplayerConfig.fallback;
  Timer? _pollTimer;
  AppLifecycleListener? _lifecycleListener;

  bool _pollInFlight = false;
  bool _isShuttingDown = false;
  int _consecutiveRoomNotFound = 0;
  int _consecutiveFailures = 0;

  @override
  Future<MultiplayerSessionState> build() async {
    _repository = ref.read(multiplayerRepositoryProvider);

    ref.onDispose(() {
      _isShuttingDown = true;
      _pollTimer?.cancel();
      _pollTimer = null;
      _lifecycleListener?.dispose();
      _lifecycleListener = null;
    });

    // Mobile OSes freeze timers in the background, so a resumed app would
    // otherwise show whatever the room looked like before the phone slept.
    _lifecycleListener = AppLifecycleListener(
      onResume: () => unawaited(refreshRoom()),
    );

    _config = await _repository.getConfig();

    final room = await _repository.getRoomSnapshot(_roomCode);
    final initial = MultiplayerSessionState(
      room: room,
      leaderboard: room.status == MultiplayerRoomStatus.finished
          ? await _loadResultsOrEmpty()
          : const <MultiplayerLeaderboardEntry>[],
      clockOffsetMs: _offsetFor(room),
    );

    _scheduleNextPoll(initial);
    return initial;
  }

  /* ── Player actions ─────────────────────────────────────────────────── */

  /// Starts the game. Returns the server's error code on failure, or null on
  /// success, so the lobby can react to `PREMIUM_REQUIRED` in place instead of
  /// only showing the message.
  Future<String?> startMatch() async {
    try {
      _applySnapshot(await _repository.startMatch(_roomCode));
      return null;
    } on MultiplayerApiException catch (error) {
      _setError(error);
      return error.code;
    } catch (error) {
      _setError(error);
      return 'UNKNOWN_ERROR';
    }
  }

  /// Host only: ends the reveal pause without waiting it out.
  Future<void> advance() async {
    try {
      _applySnapshot(await _repository.advance(_roomCode));
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> submitAnswer({
    required String questionId,
    required String answerId,
  }) async {
    final current = state.asData?.value;
    if (current == null || current.hasAnswered) return;

    // Shown as chosen straight away; the snapshot that comes back confirms it
    // (or, if the server refused, clears it again below).
    state = AsyncValue.data(current.copyWith(pendingAnswerId: answerId));

    try {
      _applySnapshot(
        await _repository.submitAnswer(
          roomCode: _roomCode,
          questionId: questionId,
          answerId: answerId,
        ),
      );
    } on MultiplayerApiException catch (error) {
      // These three all mean "the room moved on"; the next poll shows the
      // truth, so nagging the player about them would be noise.
      const benign = {
        'QUESTION_MISMATCH',
        'ANSWER_ALREADY_SUBMITTED',
        'GAME_NOT_IN_PROGRESS',
      };

      final latest = state.asData?.value ?? current;
      state = AsyncValue.data(
        latest.copyWith(
          clearPendingAnswer: true,
          lastError: benign.contains(error.code) ? null : _messageOf(error),
        ),
      );
      unawaited(refreshRoom());
    } catch (error) {
      final latest = state.asData?.value ?? current;
      state = AsyncValue.data(
        latest.copyWith(
          clearPendingAnswer: true,
          lastError: _messageOf(error),
        ),
      );
    }
  }

  Future<void> loadResults() async {
    final current = state.asData?.value;
    if (current == null) return;

    try {
      final leaderboard = await _repository.getResults(_roomCode);
      state = AsyncValue.data(current.copyWith(leaderboard: leaderboard));
    } catch (error) {
      _setError(error);
    }
  }

  /// Leaves and stops polling. Safe to call twice.
  Future<void> leaveRoom() async {
    _stopPolling();
    await _repository.leaveRoom(_roomCode);
  }

  /// What the host's "Spel sluiten" does. The server has no separate stop
  /// endpoint: a host leaving the lobby deletes the room when nobody is left,
  /// and mid-game it preserves everyone's score.
  Future<void> stopMatch() => leaveRoom();

  /* ── Polling ────────────────────────────────────────────────────────── */

  /// Fetches a snapshot now. Used by pull-to-refresh, by the lifecycle
  /// listener, and by the poll timer itself.
  Future<void> refreshRoom({bool showLoading = false}) async {
    if (_pollInFlight || _isShuttingDown) return;
    _pollInFlight = true;

    final previous = state.asData?.value;
    if (showLoading && previous == null) {
      state = const AsyncValue.loading();
    }

    try {
      final room = await _repository.getRoomSnapshot(_roomCode);
      _consecutiveRoomNotFound = 0;
      _consecutiveFailures = 0;
      _applySnapshot(room);
    } on MultiplayerApiException catch (error, stackTrace) {
      if (error.code == 'ROOM_NOT_FOUND') {
        await _handleRoomNotFound(previous);
        return;
      }

      _consecutiveFailures += 1;
      if (previous != null) {
        // A transient failure must not blank a running game, so the last good
        // snapshot stays on screen with the error attached.
        state = AsyncValue.data(previous.copyWith(lastError: _messageOf(error)));
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    } catch (error, stackTrace) {
      _consecutiveFailures += 1;
      if (previous != null) {
        state = AsyncValue.data(previous.copyWith(lastError: _messageOf(error)));
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    } finally {
      _pollInFlight = false;
      _scheduleNextPoll(state.asData?.value);
    }
  }

  /// Replaces the visible snapshot, unless this one is stale.
  void _applySnapshot(MultiplayerRoom room) {
    final current = state.asData?.value;

    // `revision` increments on every server write. A snapshot that arrives
    // with a lower one overtook a fresher response on a slow link; showing it
    // would make the game jump backwards.
    if (current != null &&
        room.revision < current.room.revision &&
        room.status == current.room.status) {
      return;
    }

    final questionChanged =
        current?.room.currentQuestion?.id != room.currentQuestion?.id;

    state = AsyncValue.data(
      MultiplayerSessionState(
        room: room,
        leaderboard: current?.leaderboard ?? const <MultiplayerLeaderboardEntry>[],
        clockOffsetMs: _offsetFor(room),
        pendingAnswerId: questionChanged ? null : current?.pendingAnswerId,
        lastError: null,
      ),
    );

    if (room.status == MultiplayerRoomStatus.finished) {
      final existing = state.asData?.value;
      if (existing != null && existing.leaderboard.isEmpty) {
        unawaited(loadResults());
      }
    }

    _scheduleNextPoll(state.asData?.value);
  }

  /// Poll at the cadence the server asked for, unless a deadline lands sooner.
  ///
  /// Waiting out the full interval past a deadline is what makes a reveal or a
  /// next question appear a beat late; polling just after it instead means the
  /// transition is picked up as soon as the server will perform it.
  void _scheduleNextPoll(MultiplayerSessionState? session) {
    _pollTimer?.cancel();
    _pollTimer = null;

    if (_isShuttingDown || session == null) return;
    if (session.room.status == MultiplayerRoomStatus.finished) return;

    _pollTimer = Timer(_nextDelay(session), () {
      unawaited(refreshRoom());
    });
  }

  Duration _nextDelay(MultiplayerSessionState session) {
    if (_consecutiveFailures > 0) {
      final backoffMs = math.min(
        _maxBackoff.inMilliseconds,
        900 * math.pow(2, _consecutiveFailures).toInt(),
      );
      return Duration(milliseconds: backoffMs);
    }

    var delay = _config.pollIntervalFor(session.room.status);

    final deadlineMs = switch (session.room.status) {
      MultiplayerRoomStatus.inProgress => session.questionRemainingMs,
      MultiplayerRoomStatus.questionResult => session.resultPhaseRemainingMs,
      _ => null,
    };

    if (deadlineMs != null) {
      // 250ms past the deadline: enough for the server to have transitioned,
      // short enough that nobody notices the gap.
      final untilDeadline = Duration(milliseconds: deadlineMs + 250);
      if (untilDeadline < delay) delay = untilDeadline;
    }

    const floor = Duration(milliseconds: 400);
    return delay < floor ? floor : delay;
  }

  void _stopPolling() {
    _isShuttingDown = true;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /* ── Failure handling ───────────────────────────────────────────────── */

  Future<void> _handleRoomNotFound(MultiplayerSessionState? previous) async {
    _consecutiveRoomNotFound += 1;

    if (_consecutiveRoomNotFound < _roomNotFoundThreshold) {
      if (previous != null) {
        state = AsyncValue.data(
          previous.copyWith(
            lastError: 'Kamer even niet bereikbaar. Opnieuw verbinden...',
          ),
        );
      }
      return;
    }

    // A room that vanishes mid-game is usually one the host closed after the
    // last question. The final standings are still readable, so they are shown
    // rather than a dead end.
    if (previous != null &&
        previous.room.status != MultiplayerRoomStatus.lobby) {
      final leaderboard = await _loadResultsOrEmpty();
      if (leaderboard.isNotEmpty) {
        _stopPolling();
        state = AsyncValue.data(
          previous.copyWith(
            room: previous.room.asFinished(),
            leaderboard: leaderboard,
            clearPendingAnswer: true,
            lastError: 'De kamer is gesloten. Dit is de eindstand.',
          ),
        );
        return;
      }
    }

    _stopPolling();
    const message =
        'Deze kamer bestaat niet meer. Ga terug en start een nieuwe kamer.';

    if (previous != null) {
      state = AsyncValue.data(
        previous.copyWith(clearPendingAnswer: true, lastError: message),
      );
      return;
    }

    state = AsyncValue.error(
      const MultiplayerApiException(
        code: 'ROOM_NOT_FOUND',
        message: message,
      ),
      StackTrace.current,
    );
  }

  Future<List<MultiplayerLeaderboardEntry>> _loadResultsOrEmpty() async {
    try {
      return await _repository.getResults(_roomCode);
    } catch (_) {
      return const <MultiplayerLeaderboardEntry>[];
    }
  }

  void _setError(Object error) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(lastError: _messageOf(error)));
  }

  /// Local minus server time. Applied to every server deadline so a device
  /// with a wrong clock still counts down in step with everyone else.
  int _offsetFor(MultiplayerRoom room) =>
      DateTime.now().millisecondsSinceEpoch - room.serverTimeMs;

  String _messageOf(Object error) => AppError.messageOf(error);
}
