import 'package:bijbelquiz_mobile/features/multiplayer/domain/multiplayer_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// A snapshot in the shape `GET /api/multiplayer/rooms/:code` returns, taken
/// from `docs/multiplayer-api.md` in the website repository.
Map<String, dynamic> snapshot({
  String status = 'in_progress',
  bool revealed = false,
  int revision = 7,
  int? serverTimeMs,
}) {
  return {
    'id': 'room-1',
    'code': 'pxn72n',
    'quizId': 'quiz-1',
    'quizTitle': 'Genesis',
    'hostUserId': 'host',
    'maxPlayers': 4,
    'currentQuestionIndex': 0,
    'totalQuestions': 16,
    'status': status,
    'players': [
      {
        'id': 'host',
        'name': 'Host',
        'avatar': {
          'character': 'uil',
          'color': 'lapis',
          'background': 'nacht',
          'accessory': 'bril',
        },
        'score': 3,
        'correctAnswers': 3,
        'isHost': true,
        'isConnected': true,
        'hasAnswered': true,
        'answeredCorrectly': revealed ? true : null,
        'scoreGained': revealed ? 1 : null,
      },
      {
        'id': 'p2',
        'name': 'Speler Twee',
        'score': 1,
        'correctAnswers': 1,
        'isHost': false,
        'isConnected': false,
        'hasAnswered': false,
        'answeredCorrectly': null,
        'scoreGained': null,
      },
    ],
    'currentQuestion': {
      'id': 'q1',
      'text': 'Wie schreef Genesis?',
      'bibleReference': 'Genesis 1:1',
      'questionNumber': 1,
      'totalQuestions': 16,
      'remainingSeconds': 17,
      'deadlineAtMs': 1767000000000,
      'answers': [
        {'id': 'a1', 'text': 'Mozes', 'count': revealed ? 2 : null},
        {'id': 'a2', 'text': 'David', 'count': revealed ? 1 : null},
      ],
      'yourAnswerId': 'a1',
      'correctAnswerId': revealed ? 'a1' : null,
      'explanation': revealed ? 'Traditioneel toegeschreven aan Mozes.' : null,
    },
    'resultPhaseEndsAtMs': revealed ? 1767000012000 : null,
    'serverTimeMs': serverTimeMs ?? 1766999983000,
    'revision': revision,
  };
}

void main() {
  test('parses a full in-progress snapshot', () {
    final room = MultiplayerRoom.fromJson(snapshot());

    expect(room.code, 'PXN72N');
    expect(room.status, MultiplayerRoomStatus.inProgress);
    expect(room.totalQuestions, 16);
    expect(room.revision, 7);
    expect(room.serverTimeMs, 1766999983000);
    expect(room.players, hasLength(2));
    expect(room.isHost('host'), isTrue);
    expect(room.isHost('p2'), isFalse);
  });

  test('withholds the answer while the room is still answering', () {
    final question = MultiplayerRoom.fromJson(snapshot()).currentQuestion!;

    // The server deliberately sends null here so a client cannot reveal early;
    // the app must not treat that as "revealed with no answer".
    expect(question.correctAnswerId, isNull);
    expect(question.isRevealed, isFalse);
    expect(question.explanation, isNull);
    expect(question.answers.first.count, isNull);
    expect(question.totalVotes, isNull);
  });

  test('reads the reveal payload once the room enters question_result', () {
    final room = MultiplayerRoom.fromJson(
      snapshot(status: 'question_result', revealed: true),
    );
    final question = room.currentQuestion!;

    expect(question.isRevealed, isTrue);
    expect(question.correctAnswerId, 'a1');
    expect(question.explanation, isNotNull);
    expect(question.totalVotes, 3);
    expect(room.players.first.answeredCorrectly, isTrue);
    expect(room.players.first.scoreGained, 1);
    expect(room.resultPhaseEndsAtMs, 1767000012000);
  });

  test('echoes back what this player picked', () {
    final room = MultiplayerRoom.fromJson(snapshot());
    final session = MultiplayerSessionState(
      room: room,
      leaderboard: const [],
      clockOffsetMs: 0,
    );

    expect(session.selectedAnswerId, 'a1');
    expect(session.hasAnswered, isTrue);
  });

  test('an optimistic tap holds until the server echoes one', () {
    final raw = snapshot();
    (raw['currentQuestion'] as Map<String, dynamic>)['yourAnswerId'] = null;

    final session = MultiplayerSessionState(
      room: MultiplayerRoom.fromJson(raw),
      leaderboard: const [],
      clockOffsetMs: 0,
      pendingAnswerId: 'a2',
    );

    expect(session.selectedAnswerId, 'a2');
  });

  test('players carry their mascot, seeded when the room predates them', () {
    final room = MultiplayerRoom.fromJson(snapshot());

    expect(room.players.first.avatar.character, 'uil');
    expect(room.players.first.avatar.accessory, 'bril');
    // The second player has no stored avatar; a room created before mascots
    // shipped must still draw everyone.
    expect(room.players[1].avatar.character, isNotEmpty);
  });

  test('deadlines are rendered against the corrected local clock', () {
    final now = DateTime.now().millisecondsSinceEpoch;

    // A device running two minutes fast still has to show the same countdown
    // as everyone else, so the offset is applied rather than the raw deadline.
    final raw = snapshot(serverTimeMs: now - 120000);
    (raw['currentQuestion'] as Map<String, dynamic>)['deadlineAtMs'] =
        now - 120000 + 10000;

    final room = MultiplayerRoom.fromJson(raw);
    final session = MultiplayerSessionState(
      room: room,
      leaderboard: const [],
      clockOffsetMs: now - room.serverTimeMs,
    );

    final remaining = session.questionRemainingMs!;
    expect(remaining, greaterThan(9000));
    expect(remaining, lessThanOrEqualTo(10000));
  });

  test('an elapsed deadline clamps to zero rather than going negative', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final raw = snapshot(serverTimeMs: now);
    (raw['currentQuestion'] as Map<String, dynamic>)['deadlineAtMs'] =
        now - 5000;

    final session = MultiplayerSessionState(
      room: MultiplayerRoom.fromJson(raw),
      leaderboard: const [],
      clockOffsetMs: 0,
    );

    expect(session.questionRemainingMs, 0);
  });

  test('standings rank by score, then correct answers, then name', () {
    final room = MultiplayerRoom.fromJson(snapshot());
    expect(room.standings.map((player) => player.id), ['host', 'p2']);
  });

  test('config falls back to the documented defaults', () {
    const config = MultiplayerConfig.fallback;

    expect(
      config.pollIntervalFor(MultiplayerRoomStatus.inProgress),
      const Duration(milliseconds: 900),
    );
    expect(
      config.pollIntervalFor(MultiplayerRoomStatus.lobby),
      const Duration(milliseconds: 2000),
    );
  });

  test('config reads the server cadence when it is served', () {
    final config = MultiplayerConfig.fromJson({
      'questionTimerSeconds': 25,
      'questionResultDelayMs': 8000,
      'playerOfflineAfterMs': 30000,
      'minPlayersToStart': 3,
      'pollIntervalsMs': {
        'lobby': 1500,
        'in_progress': 700,
        'question_result': 1000,
        'finished': 5000,
      },
    });

    expect(config.minPlayersToStart, 3);
    expect(
      config.pollIntervalFor(MultiplayerRoomStatus.questionResult),
      const Duration(milliseconds: 1000),
    );
  });

  test('capability reports the free quota, null for premium', () {
    final free = MultiplayerCapability.fromJson({
      'canCreateRoom': true,
      'isPremium': false,
      'freeRoomsRemaining': 3,
      'freeRoomsQuota': 5,
      'maxPlayersForUser': 4,
    });

    expect(free.freeRoomsRemaining, 3);
    expect(free.maxPlayersForUser, 4);

    final premium = MultiplayerCapability.fromJson({
      'canCreateRoom': true,
      'isPremium': true,
      'freeRoomsRemaining': null,
      'freeRoomsQuota': 5,
      'maxPlayersForUser': 20,
    });

    expect(premium.freeRoomsRemaining, isNull);
    expect(premium.maxPlayersForUser, 20);
  });
}
