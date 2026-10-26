/// Duels - 1 tegen 1, om de beurt.
///
/// Mirrors the server's per-viewer view (`src/lib/duels/service.ts` on the
/// website): every field is already shaped for this player, so "me" and
/// "opponent" are never swapped here and nothing is hidden client side - the
/// server simply does not send the opponent's picks or the right answers for
/// a question before this player answered it.
library;

/// One box in the per-question score row.
enum DuelMark {
  correct,
  wrong,

  /// Not played yet.
  pending,

  /// The opponent played it, but you see their answer after answering too.
  hidden;

  static DuelMark parse(Object? raw) {
    switch (raw) {
      case 'correct':
        return DuelMark.correct;
      case 'wrong':
        return DuelMark.wrong;
      case 'hidden':
        return DuelMark.hidden;
      default:
        return DuelMark.pending;
    }
  }

  bool get isPlayed => this == DuelMark.correct || this == DuelMark.wrong;
}

/// Whose move it is, from this player's point of view.
enum DuelTurn {
  me,
  opponent,

  /// A random or invite duel still waiting for a second player.
  matching,

  /// Finished.
  none;

  static DuelTurn parse(Object? raw) {
    switch (raw) {
      case 'me':
        return DuelTurn.me;
      case 'opponent':
        return DuelTurn.opponent;
      case 'matching':
        return DuelTurn.matching;
      default:
        return DuelTurn.none;
    }
  }
}

enum DuelOutcome {
  won,
  lost,
  tie;

  static DuelOutcome? parse(Object? raw) {
    switch (raw) {
      case 'won':
        return DuelOutcome.won;
      case 'lost':
        return DuelOutcome.lost;
      case 'tie':
        return DuelOutcome.tie;
      default:
        return null;
    }
  }
}

int _int(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

String? _string(Object? value) {
  final text = value?.toString().trim();
  return (text == null || text.isEmpty) ? null : text;
}

bool _bool(Object? value) => value == true;

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

Map<String, dynamic>? _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<Map<String, dynamic>> _maps(Object? value) {
  if (value is! List) return const [];
  return value.map(_map).whereType<Map<String, dynamic>>().toList();
}

List<DuelMark> _marks(Object? value) {
  if (value is! List) return const [];
  return value.map(DuelMark.parse).toList();
}

class DuelPlayer {
  const DuelPlayer({required this.id, required this.name, this.level = 1});

  final String id;
  final String name;
  final int level;

  factory DuelPlayer.fromJson(Map<String, dynamic> json) {
    return DuelPlayer(
      id: _string(json['id']) ?? '',
      name: _string(json['name']) ?? 'Speler',
      level: _int(json['level'], 1),
    );
  }
}

class DuelAnswerOption {
  const DuelAnswerOption({required this.id, required this.text});

  final String id;
  final String text;

  factory DuelAnswerOption.fromJson(Map<String, dynamic> json) {
    return DuelAnswerOption(
      id: _string(json['id']) ?? '',
      text: _string(json['text']) ?? '',
    );
  }
}

class DuelQuestion {
  const DuelQuestion({
    required this.index,
    required this.text,
    required this.answers,
    this.myAnswerId,
    this.myResult = DuelMark.pending,
    this.opponentAnswerId,
    this.opponentResult = DuelMark.pending,
    this.correctAnswerId,
    this.explanation,
    this.bibleReference,
    this.xpEarned = 0,
  });

  final int index;
  final String text;
  final List<DuelAnswerOption> answers;
  final String? myAnswerId;
  final DuelMark myResult;
  final String? opponentAnswerId;
  final DuelMark opponentResult;

  /// Only known once this player answered (or the duel is over).
  final String? correctAnswerId;
  final String? explanation;
  final String? bibleReference;
  final int xpEarned;

  bool get isAnswered => myAnswerId != null;

  factory DuelQuestion.fromJson(Map<String, dynamic> json) {
    return DuelQuestion(
      index: _int(json['index']),
      text: _string(json['text']) ?? '',
      answers: _maps(json['answers']).map(DuelAnswerOption.fromJson).toList(),
      myAnswerId: _string(json['myAnswerId']),
      myResult: DuelMark.parse(json['myResult']),
      opponentAnswerId: _string(json['opponentAnswerId']),
      opponentResult: DuelMark.parse(json['opponentResult']),
      correctAnswerId: _string(json['correctAnswerId']),
      explanation: _string(json['explanation']),
      bibleReference: _string(json['bibleReference']),
      xpEarned: _int(json['xpEarned']),
    );
  }
}

class DuelRound {
  const DuelRound({
    required this.index,
    required this.topic,
    required this.starterIsMe,
    required this.myResults,
    required this.opponentResults,
    required this.myScore,
    required this.opponentScore,
    required this.questionsVisible,
    required this.questions,
  });

  final int index;
  final String topic;
  final bool starterIsMe;
  final List<DuelMark> myResults;
  final List<DuelMark> opponentResults;
  final int myScore;
  final int opponentScore;
  final bool questionsVisible;
  final List<DuelQuestion> questions;

  int get number => index + 1;

  bool get iPlayed => myResults.isNotEmpty && myResults.every((m) => m.isPlayed);

  factory DuelRound.fromJson(Map<String, dynamic> json) {
    return DuelRound(
      index: _int(json['index']),
      topic: _string(json['topic']) ?? 'Gemengd',
      starterIsMe: json['starter'] == 'me',
      myResults: _marks(json['myResults']),
      opponentResults: _marks(json['opponentResults']),
      myScore: _int(json['myScore']),
      opponentScore: _int(json['opponentScore']),
      questionsVisible: _bool(json['questionsVisible']),
      questions: _maps(json['questions']).map(DuelQuestion.fromJson).toList(),
    );
  }
}

class Duel {
  const Duel({
    required this.id,
    required this.mode,
    required this.status,
    required this.endReason,
    required this.isChallenger,
    required this.me,
    required this.opponent,
    required this.myScore,
    required this.opponentScore,
    required this.turn,
    required this.currentRound,
    required this.totalRounds,
    required this.questionsPerRound,
    required this.nextQuestionIndex,
    required this.outcome,
    required this.canDecline,
    required this.canForfeit,
    required this.inviteUrl,
    required this.inviteToken,
    required this.xpEarned,
    required this.rounds,
    this.lastMoveAt,
    this.finishedAt,
  });

  final String id;

  /// `friend`, `random` or `invite`.
  final String mode;

  /// `open`, `active` or `finished`.
  final String status;

  /// `completed`, `forfeit`, `declined`, `cancelled`, `timeout` or `expired`.
  final String? endReason;
  final bool isChallenger;
  final DuelPlayer me;

  /// Null while a random or invite duel waits for a second player.
  final DuelPlayer? opponent;
  final int myScore;

  /// Only the answers this player may already see.
  final int opponentScore;
  final DuelTurn turn;

  /// 1-based.
  final int currentRound;
  final int totalRounds;
  final int questionsPerRound;

  /// The question to play next, when it is this player's turn.
  final int? nextQuestionIndex;
  final DuelOutcome? outcome;
  final bool canDecline;
  final bool canForfeit;
  final String? inviteUrl;
  final String? inviteToken;
  final int xpEarned;
  final List<DuelRound> rounds;
  final DateTime? lastMoveAt;
  final DateTime? finishedAt;

  bool get isFinished => status == 'finished';
  bool get isMyTurn => turn == DuelTurn.me;
  int get currentRoundIndex => (currentRound - 1).clamp(0, rounds.isEmpty ? 0 : rounds.length - 1);
  DuelRound? get currentRoundData =>
      rounds.isEmpty ? null : rounds[currentRoundIndex];

  /// Who this is against, also before anybody joined.
  String get opponentName {
    final name = opponent?.name;
    if (name != null && name.isNotEmpty) return name;
    return mode == 'invite' ? 'Uitnodiging' : 'Willekeurige speler';
  }

  /// "3 - 2", always from this player's side.
  String get scoreLabel => '$myScore - $opponentScore';

  factory Duel.fromJson(Map<String, dynamic> json) {
    final opponent = _map(json['opponent']);
    return Duel(
      id: _string(json['id']) ?? '',
      mode: _string(json['mode']) ?? 'friend',
      status: _string(json['status']) ?? 'active',
      endReason: _string(json['endReason']),
      isChallenger: _bool(json['isChallenger']),
      me: DuelPlayer.fromJson(_map(json['me']) ?? const {}),
      opponent: opponent == null ? null : DuelPlayer.fromJson(opponent),
      myScore: _int(json['myScore']),
      opponentScore: _int(json['opponentScore']),
      turn: DuelTurn.parse(json['turn']),
      currentRound: _int(json['currentRound'], 1),
      totalRounds: _int(json['totalRounds'], 3),
      questionsPerRound: _int(json['questionsPerRound'], 3),
      nextQuestionIndex: json['nextQuestionIndex'] == null
          ? null
          : _int(json['nextQuestionIndex']),
      outcome: DuelOutcome.parse(json['outcome']),
      canDecline: _bool(json['canDecline']),
      canForfeit: _bool(json['canForfeit']),
      inviteUrl: _string(json['inviteUrl']),
      inviteToken: _string(json['inviteToken']),
      xpEarned: _int(json['xpEarned']),
      rounds: _maps(json['rounds']).map(DuelRound.fromJson).toList(),
      lastMoveAt: _date(json['lastMoveAt']),
      finishedAt: _date(json['finishedAt']),
    );
  }
}

class DuelRecord {
  const DuelRecord({this.wins = 0, this.losses = 0, this.ties = 0});

  final int wins;
  final int losses;
  final int ties;

  factory DuelRecord.fromJson(Map<String, dynamic> json) {
    return DuelRecord(
      wins: _int(json['wins']),
      losses: _int(json['losses']),
      ties: _int(json['ties']),
    );
  }
}

/// The Duels tab: grouped exactly like its three sections.
class DuelList {
  const DuelList({
    required this.myTurn,
    required this.waiting,
    required this.finished,
    required this.record,
    required this.turnCount,
  });

  final List<Duel> myTurn;
  final List<Duel> waiting;
  final List<Duel> finished;
  final DuelRecord record;
  final int turnCount;

  static const DuelList empty = DuelList(
    myTurn: [],
    waiting: [],
    finished: [],
    record: DuelRecord(),
    turnCount: 0,
  );

  bool get isEmpty => myTurn.isEmpty && waiting.isEmpty && finished.isEmpty;

  factory DuelList.fromJson(Map<String, dynamic> json) {
    List<Duel> list(Object? raw) => _maps(raw).map(Duel.fromJson).toList();
    final myTurn = list(json['myTurn']);
    return DuelList(
      myTurn: myTurn,
      waiting: list(json['waiting']),
      finished: list(json['finished']),
      record: DuelRecord.fromJson(_map(json['record']) ?? const {}),
      turnCount: json['turnCount'] == null
          ? myTurn.length
          : _int(json['turnCount']),
    );
  }
}

/// What one submitted answer came back with.
class DuelAnswerOutcome {
  const DuelAnswerOutcome({
    required this.roundIndex,
    required this.questionIndex,
    required this.isCorrect,
    required this.roundComplete,
    required this.question,
    required this.duel,
  });

  final int roundIndex;
  final int questionIndex;
  final bool isCorrect;
  final bool roundComplete;

  /// The answered question, now with the right answer, the explanation and -
  /// if they already played it - the opponent's pick.
  final DuelQuestion question;
  final Duel duel;

  factory DuelAnswerOutcome.fromJson(Map<String, dynamic> json) {
    final result = _map(json['result']) ?? const <String, dynamic>{};
    return DuelAnswerOutcome(
      roundIndex: _int(result['roundIndex']),
      questionIndex: _int(result['questionIndex']),
      isCorrect: _bool(result['isCorrect']),
      roundComplete: _bool(result['roundComplete']),
      question: DuelQuestion.fromJson(result),
      duel: Duel.fromJson(_map(json['duel']) ?? const {}),
    );
  }
}

class DuelCreateResult {
  const DuelCreateResult({
    required this.duel,
    required this.created,
    required this.matched,
    this.inviteUrl,
    this.inviteToken,
    this.inviteMessage,
  });

  final Duel duel;

  /// False when the server handed back a duel that already existed.
  final bool created;

  /// Random only: joined somebody else's open duel.
  final bool matched;
  final String? inviteUrl;
  final String? inviteToken;
  final String? inviteMessage;

  factory DuelCreateResult.fromJson(Map<String, dynamic> json) {
    return DuelCreateResult(
      duel: Duel.fromJson(_map(json['duel']) ?? const {}),
      created: _bool(json['created']),
      matched: _bool(json['matched']),
      inviteUrl: _string(json['inviteUrl']),
      inviteToken: _string(json['inviteToken']),
      inviteMessage: _string(json['inviteMessage']),
    );
  }
}

class DuelInvitePreview {
  const DuelInvitePreview({required this.challenger, required this.joinable});

  final DuelPlayer challenger;
  final bool joinable;

  factory DuelInvitePreview.fromJson(Map<String, dynamic> json) {
    return DuelInvitePreview(
      challenger: DuelPlayer.fromJson(_map(json['challenger']) ?? const {}),
      joinable: _bool(json['joinable']),
    );
  }
}

/// Somebody to challenge: a past opponent, a player-group member, or a
/// search hit.
class DuelCandidate {
  const DuelCandidate({required this.player, required this.source});

  final DuelPlayer player;

  /// `duel`, `group` or `search`.
  final String source;

  factory DuelCandidate.fromJson(Map<String, dynamic> json) {
    return DuelCandidate(
      player: DuelPlayer.fromJson(json),
      source: _string(json['source']) ?? 'search',
    );
  }
}
