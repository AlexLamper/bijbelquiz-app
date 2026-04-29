enum MultiplayerRoomStatus {
  lobby,
  inProgress,
  questionResult,
  finished,
  unknown,
}

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

class MultiplayerPlayer {
  final String id;
  final String name;
  final int score;
  final int correctAnswers;
  final bool isHost;
  final bool isConnected;
  final bool hasAnswered;

  const MultiplayerPlayer({
    required this.id,
    required this.name,
    required this.score,
    required this.correctAnswers,
    required this.isHost,
    required this.isConnected,
    required this.hasAnswered,
  });

  factory MultiplayerPlayer.fromJson(Map<String, dynamic> json) {
    return MultiplayerPlayer(
      id: _asString(
        json['id'] ?? json['userId'] ?? json['playerId'] ?? json['_id'],
      ),
      name: _asString(json['name'] ?? json['displayName'] ?? json['username']),
      score: _asInt(json['score']),
      correctAnswers: _asInt(json['correctAnswers']),
      isHost: _asBool(json['isHost']),
      isConnected: _asBool(json['isConnected'], fallback: true),
      hasAnswered: _asBool(json['hasAnswered']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'correctAnswers': correctAnswers,
      'isHost': isHost,
      'isConnected': isConnected,
      'hasAnswered': hasAnswered,
    };
  }
}

class MultiplayerAnswerOption {
  final String id;
  final String text;
  final bool? isCorrect;

  const MultiplayerAnswerOption({
    required this.id,
    required this.text,
    this.isCorrect,
  });

  factory MultiplayerAnswerOption.fromJson(Map<String, dynamic> json) {
    final id = _asString(json['id'] ?? json['_id'] ?? json['answerId']);
    return MultiplayerAnswerOption(
      id: id.isEmpty ? _asString(json['text']) : id,
      text: _asString(json['text']),
      isCorrect: _asNullableBool(
        json['isCorrect'] ?? json['correct'] ?? json['isAnswerCorrect'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

class MultiplayerQuestionState {
  final String id;
  final String text;
  final String bibleReference;
  final int questionNumber;
  final int totalQuestions;
  final int remainingSeconds;
  final String correctAnswerId;
  final String selectedAnswerId;
  final List<MultiplayerAnswerOption> answers;

  const MultiplayerQuestionState({
    required this.id,
    required this.text,
    required this.bibleReference,
    required this.questionNumber,
    required this.totalQuestions,
    required this.remainingSeconds,
    required this.correctAnswerId,
    required this.selectedAnswerId,
    required this.answers,
  });

  factory MultiplayerQuestionState.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'] as List<dynamic>? ?? const [];
    final answers = rawAnswers
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) {
          return MultiplayerAnswerOption.fromJson(Map<String, dynamic>.from(entry));
        })
        .toList();

    final correctAnswerData =
        _asMap(json['correctAnswer']) ??
        _asMap(json['correctOption']) ??
        _asMap(json['correct_answer']);

    var correctAnswerId = _asString(
      json['correctAnswerId'] ??
          json['correctOptionId'] ??
          json['correctChoiceId'] ??
          json['correct_answer_id'] ??
          correctAnswerData?['id'] ??
          correctAnswerData?['_id'] ??
          correctAnswerData?['answerId'],
    );

    if (correctAnswerId.isEmpty) {
      final explicitlyCorrect = answers.where((answer) => answer.isCorrect == true);
      if (explicitlyCorrect.isNotEmpty) {
        correctAnswerId = explicitlyCorrect.first.id;
      }
    }

    final selectedAnswerId = _asString(
      _extractAnswerId(
            json['selectedAnswerId'] ??
                json['myAnswerId'] ??
                json['submittedAnswerId'] ??
                json['myAnswer'] ??
                json['selectedAnswer'],
          ) ??
          '',
    );

    return MultiplayerQuestionState(
      id: _asString(json['id'] ?? json['questionId'] ?? json['_id']),
      text: _asString(json['text']),
      bibleReference: _asString(json['bibleReference']),
      questionNumber: _asInt(json['questionNumber']),
      totalQuestions: _asInt(json['totalQuestions']),
      remainingSeconds: _asInt(json['remainingSeconds'] ?? json['timeLeftSeconds']),
      correctAnswerId: correctAnswerId,
      selectedAnswerId: selectedAnswerId,
      answers: answers,
    );
  }

  String? get resolvedCorrectAnswerId {
    if (correctAnswerId.isNotEmpty) {
      return correctAnswerId;
    }

    for (final answer in answers) {
      if (answer.isCorrect == true) {
        return answer.id;
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'bibleReference': bibleReference,
      'questionNumber': questionNumber,
      'totalQuestions': totalQuestions,
      'remainingSeconds': remainingSeconds,
      'correctAnswerId': correctAnswerId,
      'selectedAnswerId': selectedAnswerId,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

class MultiplayerRoom {
  final String id;
  final String code;
  final String quizId;
  final String quizTitle;
  final int xpReward;
  final String hostUserId;
  final int maxPlayers;
  final int currentQuestionIndex;
  final int totalQuestions;
  final MultiplayerRoomStatus status;
  final List<MultiplayerPlayer> players;
  final MultiplayerQuestionState? currentQuestion;

  const MultiplayerRoom({
    required this.id,
    required this.code,
    required this.quizId,
    required this.quizTitle,
    required this.xpReward,
    required this.hostUserId,
    required this.maxPlayers,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.status,
    required this.players,
    required this.currentQuestion,
  });

  factory MultiplayerRoom.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'] as List<dynamic>? ?? const [];
    final questionData = _asMap(json['currentQuestion'] ?? json['question']);
    final quizData = _asMap(json['quiz']);

    return MultiplayerRoom(
      id: _asString(json['id'] ?? json['roomId'] ?? json['_id']),
      code: _asString(json['code'] ?? json['roomCode']).toUpperCase(),
      quizId: _asString(json['quizId']),
      quizTitle: _asString(json['quizTitle'] ?? json['title']),
      xpReward: _asInt(
        json['xpReward'] ??
            json['rewardXp'] ??
            quizData?['xpReward'] ??
            quizData?['rewardXp'],
        fallback: 50,
      ),
      hostUserId: _asString(json['hostUserId'] ?? json['hostId']),
      maxPlayers: _asInt(json['maxPlayers'], fallback: 4),
      currentQuestionIndex: _asInt(json['currentQuestionIndex']),
      totalQuestions: _asInt(json['totalQuestions']),
      status: MultiplayerRoomStatusX.fromRaw(_asString(json['status'])),
      players: rawPlayers
          .whereType<Map<dynamic, dynamic>>()
          .map((entry) {
            return MultiplayerPlayer.fromJson(Map<String, dynamic>.from(entry));
          })
          .toList(),
      currentQuestion: questionData == null
          ? null
          : MultiplayerQuestionState.fromJson(questionData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'xpReward': xpReward,
      'hostUserId': hostUserId,
      'maxPlayers': maxPlayers,
      'currentQuestionIndex': currentQuestionIndex,
      'totalQuestions': totalQuestions,
      'status': status.apiValue,
      'players': players.map((player) => player.toJson()).toList(),
      'currentQuestion': currentQuestion?.toJson(),
    };
  }
}

class MultiplayerLeaderboardEntry {
  final int rank;
  final String playerId;
  final String playerName;
  final int score;
  final int correctAnswers;

  const MultiplayerLeaderboardEntry({
    required this.rank,
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.correctAnswers,
  });

  factory MultiplayerLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return MultiplayerLeaderboardEntry(
      rank: _asInt(json['rank']),
      playerId: _asString(json['playerId'] ?? json['id'] ?? json['userId']),
      playerName: _asString(json['playerName'] ?? json['name']),
      score: _asInt(json['score']),
      correctAnswers: _asInt(json['correctAnswers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'playerId': playerId,
      'playerName': playerName,
      'score': score,
      'correctAnswers': correctAnswers,
    };
  }
}

class MultiplayerSessionState {
  final MultiplayerRoom room;
  final List<MultiplayerLeaderboardEntry> leaderboard;
  final bool hasSubmittedCurrentAnswer;
  final String? selectedAnswerId;
  final String? lastError;

  const MultiplayerSessionState({
    required this.room,
    required this.leaderboard,
    required this.hasSubmittedCurrentAnswer,
    this.selectedAnswerId,
    this.lastError,
  });

  MultiplayerSessionState copyWith({
    MultiplayerRoom? room,
    List<MultiplayerLeaderboardEntry>? leaderboard,
    bool? hasSubmittedCurrentAnswer,
    String? selectedAnswerId,
    bool clearSelectedAnswer = false,
    String? lastError,
  }) {
    return MultiplayerSessionState(
      room: room ?? this.room,
      leaderboard: leaderboard ?? this.leaderboard,
      hasSubmittedCurrentAnswer:
          hasSubmittedCurrentAnswer ?? this.hasSubmittedCurrentAnswer,
      selectedAnswerId: clearSelectedAnswer
          ? null
          : (selectedAnswerId ?? this.selectedAnswerId),
      lastError: lastError,
    );
  }
}

String _asString(dynamic value) {
  return value?.toString() ?? '';
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

String? _extractAnswerId(dynamic value) {
  if (value == null) return null;

  final asMap = _asMap(value);
  if (asMap != null) {
    final nested =
        asMap['id'] ?? asMap['_id'] ?? asMap['answerId'] ?? asMap['optionId'];
    final text = nested?.toString().trim();
    if (text != null && text.isNotEmpty) {
      return text;
    }
  }

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map<dynamic, dynamic>) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}
