import '../../../core/avatar/avatar_catalog.dart';

/// The multiplayer wire format, as documented in `docs/multiplayer-api.md` of
/// the website repository.
///
/// There are no sockets involved: the server owns the state machine and the
/// client polls `GET /rooms/:code`. Everything needed to render a round arrives
/// in a single [MultiplayerRoom], including the absolute deadlines the app
/// counts down against.
enum MultiplayerRoomStatus { lobby, inProgress, questionResult, finished, unknown }

extension MultiplayerRoomStatusX on MultiplayerRoomStatus {
  static MultiplayerRoomStatus fromRaw(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'lobby':
        return MultiplayerRoomStatus.lobby;
      case 'in_progress':
      case 'inprogress':
      case 'playing':
        return MultiplayerRoomStatus.inProgress;
      case 'question_result':
      case 'questionresult':
      case 'review':
        return MultiplayerRoomStatus.questionResult;
      case 'finished':
      case 'completed':
        return MultiplayerRoomStatus.finished;
      default:
        return MultiplayerRoomStatus.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case MultiplayerRoomStatus.lobby:
        return 'lobby';
      case MultiplayerRoomStatus.inProgress:
        return 'in_progress';
      case MultiplayerRoomStatus.questionResult:
        return 'question_result';
      case MultiplayerRoomStatus.finished:
        return 'finished';
      case MultiplayerRoomStatus.unknown:
        return 'unknown';
    }
  }
}

/// Timing constants served by `GET /multiplayer/config`.
///
/// Fetched once and reused, so the app never hardcodes a cadence the server
/// might change. The values below are the server's current defaults and only
/// apply when that call fails.
class MultiplayerConfig {
  const MultiplayerConfig({
    this.questionTimerSeconds = 20,
    this.questionResultDelayMs = 12000,
    this.playerOfflineAfterMs = 30000,
    this.minPlayersToStart = 2,
    this.lobbyPollMs = 2000,
    this.inProgressPollMs = 900,
    this.questionResultPollMs = 1200,
    this.finishedPollMs = 4000,
  });

  final int questionTimerSeconds;
  final int questionResultDelayMs;
  final int playerOfflineAfterMs;
  final int minPlayersToStart;
  final int lobbyPollMs;
  final int inProgressPollMs;
  final int questionResultPollMs;
  final int finishedPollMs;

  static const MultiplayerConfig fallback = MultiplayerConfig();

  factory MultiplayerConfig.fromJson(Map<String, dynamic> json) {
    final intervals = _asMap(json['pollIntervalsMs']) ?? const {};

    return MultiplayerConfig(
      questionTimerSeconds: _asInt(json['questionTimerSeconds'], fallback: 20),
      questionResultDelayMs: _asInt(
        json['questionResultDelayMs'],
        fallback: 12000,
      ),
      playerOfflineAfterMs: _asInt(
        json['playerOfflineAfterMs'],
        fallback: 30000,
      ),
      minPlayersToStart: _asInt(json['minPlayersToStart'], fallback: 2),
      lobbyPollMs: _asInt(intervals['lobby'], fallback: 2000),
      inProgressPollMs: _asInt(intervals['in_progress'], fallback: 900),
      questionResultPollMs: _asInt(
        intervals['question_result'],
        fallback: 1200,
      ),
      finishedPollMs: _asInt(intervals['finished'], fallback: 4000),
    );
  }

  Duration pollIntervalFor(MultiplayerRoomStatus status) {
    switch (status) {
      case MultiplayerRoomStatus.inProgress:
        return Duration(milliseconds: inProgressPollMs);
      case MultiplayerRoomStatus.questionResult:
        return Duration(milliseconds: questionResultPollMs);
      case MultiplayerRoomStatus.finished:
        return Duration(milliseconds: finishedPollMs);
      case MultiplayerRoomStatus.lobby:
      case MultiplayerRoomStatus.unknown:
        return Duration(milliseconds: lobbyPollMs);
    }
  }
}

/// What the caller is allowed to do, from `GET /multiplayer/rooms`.
class MultiplayerCapability {
  const MultiplayerCapability({
    required this.canCreateRoom,
    required this.isPremium,
    required this.freeRoomsRemaining,
    required this.freeRoomsQuota,
    required this.maxPlayersForUser,
    this.maxPlayersFree = 4,
    this.maxPlayersPremium = 20,
    this.onMonthlyAllowance = false,
    this.monthlyRoomsQuota = 1,
  });

  final bool canCreateRoom;
  final bool isPremium;

  /// Null for Premium, which is unlimited.
  final int? freeRoomsRemaining;
  final int freeRoomsQuota;
  final int maxPlayersForUser;

  /// Room size a free account may pick, and the ceiling Premium unlocks. Read
  /// from the server rather than hardcoded, so raising the cap on the website
  /// does not need an app release to be told about it.
  final int maxPlayersFree;
  final int maxPlayersPremium;

  /// True once the one-off discovery pack is gone and the account runs on the
  /// monthly allowance. [freeRoomsRemaining] then counts this month, not the
  /// lifetime pack, and the copy has to change with it.
  final bool onMonthlyAllowance;

  /// Free hosted games a non-premium account gets back each calendar month.
  final int monthlyRoomsQuota;

  static const MultiplayerCapability unknown = MultiplayerCapability(
    canCreateRoom: true,
    isPremium: false,
    freeRoomsRemaining: null,
    freeRoomsQuota: 5,
    maxPlayersForUser: 4,
  );

  factory MultiplayerCapability.fromJson(Map<String, dynamic> json) {
    return MultiplayerCapability(
      canCreateRoom: _asBool(json['canCreateRoom'], fallback: true),
      isPremium: _asBool(json['isPremium']),
      freeRoomsRemaining: json['freeRoomsRemaining'] == null
          ? null
          : _asInt(json['freeRoomsRemaining']),
      freeRoomsQuota: _asInt(json['freeRoomsQuota'], fallback: 5),
      maxPlayersForUser: _asInt(json['maxPlayersForUser'], fallback: 4),
      maxPlayersFree: _asInt(json['maxPlayersFree'], fallback: 4),
      maxPlayersPremium: _asInt(json['maxPlayersPremium'], fallback: 20),
      onMonthlyAllowance: _asBool(json['onMonthlyAllowance']),
      monthlyRoomsQuota: _asInt(json['monthlyRoomsQuota'], fallback: 1),
    );
  }
}

class MultiplayerPlayer {
  const MultiplayerPlayer({
    required this.id,
    required this.name,
    required this.avatar,
    required this.score,
    required this.correctAnswers,
    required this.isHost,
    required this.isConnected,
    required this.hasAnswered,
    this.answeredCorrectly,
    this.scoreGained,
  });

  final String id;
  final String name;
  final AvatarConfig avatar;
  final int score;
  final int correctAnswers;
  final bool isHost;
  final bool isConnected;
  final bool hasAnswered;

  /// How this player did on the question that was just revealed. Null outside
  /// `question_result`, and null for anyone who let the timer run out.
  final bool? answeredCorrectly;

  /// Points gained on the revealed question, so the scoreboard can show the
  /// per-round delta next to the running total. Null outside the reveal.
  final int? scoreGained;

  factory MultiplayerPlayer.fromJson(Map<String, dynamic> json) {
    final id = _asString(
      json['id'] ?? json['userId'] ?? json['playerId'] ?? json['_id'],
    );

    return MultiplayerPlayer(
      id: id,
      name: _asString(json['name'] ?? json['displayName'] ?? json['username']),
      avatar: AvatarConfig.resolve(_asMap(json['avatar']), id),
      score: _asInt(json['score']),
      correctAnswers: _asInt(json['correctAnswers']),
      isHost: _asBool(json['isHost']),
      isConnected: _asBool(json['isConnected'], fallback: true),
      hasAnswered: _asBool(json['hasAnswered']),
      answeredCorrectly: _asNullableBool(json['answeredCorrectly']),
      scoreGained: json['scoreGained'] == null
          ? null
          : _asInt(json['scoreGained']),
    );
  }
}

class MultiplayerAnswerOption {
  const MultiplayerAnswerOption({
    required this.id,
    required this.text,
    this.count,
  });

  final String id;
  final String text;

  /// How many players picked this option. Null until the reveal, so the tally
  /// cannot be used to guess the answer mid-question.
  final int? count;

  factory MultiplayerAnswerOption.fromJson(Map<String, dynamic> json) {
    final id = _asString(json['id'] ?? json['_id'] ?? json['answerId']);
    return MultiplayerAnswerOption(
      id: id.isEmpty ? _asString(json['text']) : id,
      text: _asString(json['text']),
      count: json['count'] == null ? null : _asInt(json['count']),
    );
  }
}

class MultiplayerQuestionState {
  const MultiplayerQuestionState({
    required this.id,
    required this.text,
    required this.bibleReference,
    required this.questionNumber,
    required this.totalQuestions,
    required this.remainingSeconds,
    required this.deadlineAtMs,
    required this.answers,
    required this.yourAnswerId,
    required this.correctAnswerId,
    required this.explanation,
  });

  final String id;
  final String text;
  final String bibleReference;
  final int questionNumber;
  final int totalQuestions;

  /// The server's own countdown, used only until [deadlineAtMs] is known.
  final int remainingSeconds;

  /// Absolute deadline on the server clock. Rendering against this rather than
  /// [remainingSeconds] keeps the countdown smooth between polls.
  final int? deadlineAtMs;

  final List<MultiplayerAnswerOption> answers;

  /// What this player picked, echoed back so a reopened app still shows it.
  final String? yourAnswerId;

  /// Null until the room enters `question_result`.
  final String? correctAnswerId;
  final String? explanation;

  bool get isRevealed => correctAnswerId != null && correctAnswerId!.isNotEmpty;

  /// Total votes cast on this question, or null before the reveal.
  int? get totalVotes {
    if (answers.isEmpty || answers.first.count == null) return null;
    return answers.fold<int>(0, (sum, answer) => sum + (answer.count ?? 0));
  }

  factory MultiplayerQuestionState.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'] as List<dynamic>? ?? const [];
    final answers = rawAnswers
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .map(MultiplayerAnswerOption.fromJson)
        .toList();

    return MultiplayerQuestionState(
      id: _asString(json['id'] ?? json['questionId'] ?? json['_id']),
      text: _asString(json['text']),
      bibleReference: _asString(json['bibleReference']),
      questionNumber: _asInt(json['questionNumber']),
      totalQuestions: _asInt(json['totalQuestions']),
      remainingSeconds: _asInt(
        json['remainingSeconds'] ?? json['timeLeftSeconds'],
      ),
      deadlineAtMs: json['deadlineAtMs'] == null
          ? null
          : _asInt(json['deadlineAtMs']),
      answers: answers,
      yourAnswerId: _nullableId(
        json['yourAnswerId'] ?? json['selectedAnswerId'] ?? json['myAnswerId'],
      ),
      correctAnswerId: _nullableId(
        json['correctAnswerId'] ?? json['correctOptionId'],
      ),
      explanation: _nullableText(json['explanation']),
    );
  }
}

class MultiplayerRoom {
  const MultiplayerRoom({
    required this.id,
    required this.code,
    required this.quizId,
    required this.quizTitle,
    required this.hostUserId,
    required this.maxPlayers,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.status,
    required this.players,
    required this.currentQuestion,
    required this.resultPhaseEndsAtMs,
    required this.serverTimeMs,
    required this.revision,
  });

  final String id;
  final String code;
  final String quizId;
  final String quizTitle;
  final String hostUserId;
  final int maxPlayers;
  final int currentQuestionIndex;
  final int totalQuestions;
  final MultiplayerRoomStatus status;
  final List<MultiplayerPlayer> players;
  final MultiplayerQuestionState? currentQuestion;

  /// When the between-questions pause ends, on the server clock.
  final int? resultPhaseEndsAtMs;

  /// When the server built this snapshot. Subtracting it from the local clock
  /// gives the offset needed to render server deadlines on a device whose own
  /// clock is wrong.
  final int serverTimeMs;

  /// Monotonic per write. A snapshot with a lower revision than the one on
  /// screen overtook a fresher response and must be dropped.
  final int revision;

  factory MultiplayerRoom.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'] as List<dynamic>? ?? const [];
    final questionData = _asMap(json['currentQuestion'] ?? json['question']);

    return MultiplayerRoom(
      id: _asString(json['id'] ?? json['roomId'] ?? json['_id']),
      code: _asString(json['code'] ?? json['roomCode']).toUpperCase(),
      quizId: _asString(json['quizId']),
      quizTitle: _asString(json['quizTitle'] ?? json['title']),
      hostUserId: _asString(json['hostUserId'] ?? json['hostId']),
      maxPlayers: _asInt(json['maxPlayers'], fallback: 4),
      currentQuestionIndex: _asInt(json['currentQuestionIndex']),
      totalQuestions: _asInt(json['totalQuestions']),
      status: MultiplayerRoomStatusX.fromRaw(_asString(json['status'])),
      players: rawPlayers
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(MultiplayerPlayer.fromJson)
          .toList(),
      currentQuestion: questionData == null
          ? null
          : MultiplayerQuestionState.fromJson(questionData),
      resultPhaseEndsAtMs: json['resultPhaseEndsAtMs'] == null
          ? null
          : _asInt(json['resultPhaseEndsAtMs']),
      serverTimeMs: _asInt(
        json['serverTimeMs'],
        fallback: DateTime.now().millisecondsSinceEpoch,
      ),
      revision: _asInt(json['revision']),
    );
  }

  MultiplayerPlayer? playerById(String? userId) {
    if (userId == null || userId.isEmpty) return null;
    for (final player in players) {
      if (player.id == userId) return player;
    }
    return null;
  }

  bool isHost(String? userId) =>
      userId != null && userId.isNotEmpty && hostUserId == userId;

  /// Players sorted the way the server ranks them: score, then correct
  /// answers, then name.
  List<MultiplayerPlayer> get standings {
    final sorted = [...players];
    sorted.sort((a, b) {
      if (b.score != a.score) return b.score.compareTo(a.score);
      if (b.correctAnswers != a.correctAnswers) {
        return b.correctAnswers.compareTo(a.correctAnswers);
      }
      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  MultiplayerRoom asFinished() {
    return MultiplayerRoom(
      id: id,
      code: code,
      quizId: quizId,
      quizTitle: quizTitle,
      hostUserId: hostUserId,
      maxPlayers: maxPlayers,
      currentQuestionIndex: currentQuestionIndex,
      totalQuestions: totalQuestions,
      status: MultiplayerRoomStatus.finished,
      players: players,
      currentQuestion: null,
      resultPhaseEndsAtMs: null,
      serverTimeMs: serverTimeMs,
      revision: revision,
    );
  }
}

class MultiplayerLeaderboardEntry {
  const MultiplayerLeaderboardEntry({
    required this.rank,
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.correctAnswers,
  });

  final int rank;
  final String playerId;
  final String playerName;
  final int score;
  final int correctAnswers;

  factory MultiplayerLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return MultiplayerLeaderboardEntry(
      rank: _asInt(json['rank']),
      playerId: _asString(json['playerId'] ?? json['id'] ?? json['userId']),
      playerName: _asString(json['playerName'] ?? json['name']),
      score: _asInt(json['score']),
      correctAnswers: _asInt(json['correctAnswers']),
    );
  }
}

/// Everything a multiplayer screen renders from.
class MultiplayerSessionState {
  const MultiplayerSessionState({
    required this.room,
    required this.leaderboard,
    required this.clockOffsetMs,
    this.pendingAnswerId,
    this.lastError,
  });

  final MultiplayerRoom room;
  final List<MultiplayerLeaderboardEntry> leaderboard;

  /// `localNow - serverTimeMs`, so a server deadline can be rendered against
  /// the device clock even when that clock is off.
  final int clockOffsetMs;

  /// Set the instant an answer is tapped, before the server confirms it. Once
  /// the snapshot echoes `yourAnswerId` this is redundant and ignored.
  final String? pendingAnswerId;

  final String? lastError;

  /// The answer this player is showing as chosen: the server's echo when it
  /// has arrived, the optimistic tap until then.
  String? get selectedAnswerId {
    final confirmed = room.currentQuestion?.yourAnswerId;
    if (confirmed != null && confirmed.isNotEmpty) return confirmed;
    return pendingAnswerId;
  }

  bool get hasAnswered => selectedAnswerId != null;

  /// Milliseconds left on the current countdown, or null when nothing is
  /// running. Uses the absolute deadline so it stays accurate between polls.
  int? remainingMsFor(int? deadlineAtMs) {
    if (deadlineAtMs == null) return null;
    final localDeadline = deadlineAtMs + clockOffsetMs;
    final remaining = localDeadline - DateTime.now().millisecondsSinceEpoch;
    return remaining < 0 ? 0 : remaining;
  }

  int? get questionRemainingMs =>
      remainingMsFor(room.currentQuestion?.deadlineAtMs);

  int? get resultPhaseRemainingMs => remainingMsFor(room.resultPhaseEndsAtMs);

  MultiplayerSessionState copyWith({
    MultiplayerRoom? room,
    List<MultiplayerLeaderboardEntry>? leaderboard,
    int? clockOffsetMs,
    String? pendingAnswerId,
    bool clearPendingAnswer = false,
    String? lastError,
  }) {
    return MultiplayerSessionState(
      room: room ?? this.room,
      leaderboard: leaderboard ?? this.leaderboard,
      clockOffsetMs: clockOffsetMs ?? this.clockOffsetMs,
      pendingAnswerId: clearPendingAnswer
          ? null
          : (pendingAnswerId ?? this.pendingAnswerId),
      lastError: lastError,
    );
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

String? _nullableId(dynamic value) {
  if (value == null) return null;

  final asMap = _asMap(value);
  if (asMap != null) {
    final nested =
        asMap['id'] ?? asMap['_id'] ?? asMap['answerId'] ?? asMap['optionId'];
    final text = nested?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

String? _nullableText(dynamic value) {
  final text = value?.toString().trim();
  return (text == null || text.isEmpty) ? null : text;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return fallback;
}

bool? _asNullableBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}
