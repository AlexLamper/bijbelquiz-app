/// Canned duels for design-preview mode (`PreviewConfig.enabled`).
///
/// Everything here is fabricated sample data that never reaches the API. It
/// is kept as a tiny in-memory "server" producing the same JSON as
/// `/api/mobile/duels`, so the screens parse it through the real models and a
/// round can actually be played in preview.
library;

class _PreviewQuestion {
  _PreviewQuestion(
    this.text,
    this.answers,
    this.correct, {
    this.mine,
    this.theirs,
    this.explanation,
    this.reference,
  });

  final String text;
  final List<String> answers;
  final int correct;
  int? mine;
  final int? theirs;
  final String? explanation;
  final String? reference;

  String idOf(int index) => 'a$index';
}

class _PreviewRound {
  _PreviewRound(this.topic, this.questions);

  final String topic;
  final List<_PreviewQuestion> questions;
}

class _PreviewDuel {
  _PreviewDuel({
    required this.id,
    required this.opponentName,
    required this.opponentLevel,
    required this.isChallenger,
    required this.rounds,
    this.finished = false,
  });

  final String id;
  final String opponentName;
  final int opponentLevel;
  final bool isChallenger;
  final List<_PreviewRound> rounds;
  final bool finished;
}

/// One filler question with the given picks, for duels nobody plays in preview.
_PreviewQuestion _filler(int n, {int? mine, int? theirs}) => _PreviewQuestion(
  'Voorbeeldvraag $n',
  const ['Antwoord A', 'Antwoord B', 'Antwoord C', 'Antwoord D'],
  0,
  mine: mine,
  theirs: theirs,
);

/// A round from two strings of `g` (goed), `f` (fout) and `-` (niet gespeeld).
_PreviewRound _marks(String topic, String mine, String theirs) {
  int? pick(String mark) => switch (mark) {
    'g' => 0,
    'f' => 1,
    _ => null,
  };
  return _PreviewRound(topic, [
    for (var i = 0; i < 3; i++)
      _filler(i + 1, mine: pick(mine[i]), theirs: pick(theirs[i])),
  ]);
}

class DuelsPreview {
  DuelsPreview._();

  static final DuelsPreview instance = DuelsPreview._();

  final List<_PreviewDuel> _duels = [
    _PreviewDuel(
      id: 'preview-lotte',
      opponentName: 'Lotte',
      opponentLevel: 9,
      isChallenger: true,
      rounds: [
        _marks('Genesis', 'ggg', 'gfg'),
        _PreviewRound('Richteren', [
          _PreviewQuestion(
            'Wie was de vader van Gideon?',
            ['Joas', 'Manoach', 'Elkana', 'Isaï'],
            0,
            theirs: 0,
            explanation: 'De engel van de HEERE verscheen aan Gideon, de zoon '
                'van Joas, terwijl hij tarwe dorste in de wijnpers.',
            reference: 'Richteren 6:11',
          ),
          _PreviewQuestion(
            'Hoeveel mannen liet God bij Gideon blijven voor de strijd tegen '
            'Midian?',
            ['100', '300', '10.000', '32.000'],
            1,
            theirs: 2,
            explanation: 'God liet alleen de mannen blijven die het water met '
                'hun hand naar hun mond brachten: driehonderd man.',
            reference: 'Richteren 7:7',
          ),
          _PreviewQuestion(
            'Welke rechter versloeg Sisera samen met Debora?',
            ['Ehud', 'Barak', 'Othniël', 'Jefta'],
            1,
            theirs: 1,
            explanation: 'Debora riep Barak, en samen trokken zij met tienduizend '
                'man op tegen Sisera.',
            reference: 'Richteren 4:14',
          ),
        ]),
        _PreviewRound('Johannes', [
          _PreviewQuestion(
            'Waar deed Jezus zijn eerste teken?',
            ['Kana', 'Kapernaüm', 'Nazareth', 'Bethlehem'],
            0,
            explanation: 'Op de bruiloft te Kana veranderde Jezus water in wijn.',
            reference: 'Johannes 2:11',
          ),
          _PreviewQuestion(
            'Wie kwam er bij nacht naar Jezus toe?',
            ['Zacheüs', 'Lazarus', 'Nikodemus', 'Jozef'],
            2,
            explanation: 'Nikodemus, een leidsman van de Joden, kwam bij nacht '
                'tot Jezus.',
            reference: 'Johannes 3:2',
          ),
          _PreviewQuestion(
            'Hoeveel dagen lag Lazarus al in het graf toen Jezus kwam?',
            ['2', '3', '4', '7'],
            2,
            explanation: 'Toen Jezus kwam, lag Lazarus al vier dagen in het graf.',
            reference: 'Johannes 11:17',
          ),
        ]),
      ],
    ),
    _PreviewDuel(
      id: 'preview-daan',
      opponentName: 'Daan',
      opponentLevel: 6,
      isChallenger: false,
      rounds: [
        _marks('Exodus', 'gff', 'fgf'),
        _marks('Psalmen', 'fff', '---'),
        _marks('Handelingen', '---', '---'),
      ],
    ),
    _PreviewDuel(
      id: 'preview-ruben',
      opponentName: 'Ruben',
      opponentLevel: 8,
      isChallenger: true,
      finished: true,
      rounds: [
        _marks('Ruth', 'ggg', 'gff'),
        _marks('Markus', 'ggf', 'gfg'),
        _marks('Daniël', 'gfg', 'gff'),
      ],
    ),
    _PreviewDuel(
      id: 'preview-noor',
      opponentName: 'Noor',
      opponentLevel: 5,
      isChallenger: false,
      finished: true,
      rounds: [
        _marks('Jona', 'gff', 'ggf'),
        _marks('Esther', 'fgg', 'fgg'),
        _marks('Lukas', 'gff', 'gff'),
      ],
    ),
  ];

  static const List<(String, String, int)> _friends = [
    ('preview-lotte-user', 'Lotte', 9),
    ('preview-daan-user', 'Daan', 6),
    ('preview-ruben-user', 'Ruben', 8),
    ('preview-noor-user', 'Noor', 5),
  ];

  // -------------------------------------------------------------------------
  // Turn rules - same order as the server: A1 | B1 B2 | A2 A3 | B3
  // -------------------------------------------------------------------------

  bool _mineDone(_PreviewRound round) =>
      round.questions.every((q) => q.mine != null);

  bool _theirsDone(_PreviewRound round) =>
      round.questions.every((q) => q.theirs != null);

  /// (isMine, roundIndex) of the next move, or null when everything is played.
  (bool, int)? _turn(_PreviewDuel duel) {
    for (var r = 0; r < duel.rounds.length; r++) {
      final challengerStarts = r.isEven;
      final meFirst = challengerStarts == duel.isChallenger;
      final order = meFirst ? [true, false] : [false, true];
      for (final mine in order) {
        final done = mine ? _mineDone(duel.rounds[r]) : _theirsDone(duel.rounds[r]);
        if (!done) return (mine, r);
      }
    }
    return null;
  }

  String _mark(_PreviewQuestion q, int? pick) {
    if (pick == null) return 'pending';
    return pick == q.correct ? 'correct' : 'wrong';
  }

  String _theirMark(_PreviewQuestion q, bool finished) {
    if (q.theirs == null) return 'pending';
    if (q.mine == null && !finished) return 'hidden';
    return _mark(q, q.theirs);
  }

  Map<String, dynamic> _player(String id, String name, int level) => {
    'id': id,
    'name': name,
    'level': level,
  };

  Map<String, dynamic> _view(_PreviewDuel duel, {bool withQuestions = true}) {
    final turn = duel.finished ? null : _turn(duel);
    final finished = duel.finished || turn == null;
    var myScore = 0;
    var theirScore = 0;

    final rounds = <Map<String, dynamic>>[];
    for (var r = 0; r < duel.rounds.length; r++) {
      final round = duel.rounds[r];
      final mineMarks = round.questions.map((q) => _mark(q, q.mine)).toList();
      final theirMarks =
          round.questions.map((q) => _theirMark(q, finished)).toList();
      final roundMine = mineMarks.where((m) => m == 'correct').length;
      final roundTheirs = theirMarks.where((m) => m == 'correct').length;
      myScore += roundMine;
      theirScore += roundTheirs;

      final visible = finished ||
          round.questions.any((q) => q.mine != null) ||
          (turn.$1 && turn.$2 == r);

      rounds.add({
        'index': r,
        'number': r + 1,
        'topic': round.topic,
        'starter': (r.isEven == duel.isChallenger) ? 'me' : 'opponent',
        'myResults': mineMarks,
        'opponentResults': theirMarks,
        'myScore': roundMine,
        'opponentScore': roundTheirs,
        'questionsVisible': visible,
        'questions': !withQuestions || !visible
            ? const []
            : [
                for (var i = 0; i < round.questions.length; i++)
                  _questionJson(round.questions[i], i, finished),
              ],
      });
    }

    String? outcome;
    if (finished) {
      outcome = myScore == theirScore
          ? 'tie'
          : (myScore > theirScore ? 'won' : 'lost');
    }

    int? next;
    if (turn != null && turn.$1) {
      final qs = duel.rounds[turn.$2].questions;
      next = qs.indexWhere((q) => q.mine == null);
    }

    final noMovesYet = duel.rounds.every(
      (round) => round.questions.every((q) => q.mine == null),
    );

    return {
      'id': duel.id,
      'mode': 'friend',
      'status': finished ? 'finished' : 'active',
      'endReason': finished ? 'completed' : null,
      'isChallenger': duel.isChallenger,
      'me': _player('preview-user', 'Testspeler', 4),
      'opponent': _player(
        '${duel.id}-user',
        duel.opponentName,
        duel.opponentLevel,
      ),
      'myScore': myScore,
      'opponentScore': theirScore,
      'turn': finished ? 'none' : (turn.$1 ? 'me' : 'opponent'),
      'currentRound': finished ? duel.rounds.length : turn.$2 + 1,
      'totalRounds': duel.rounds.length,
      'questionsPerRound': 3,
      'nextQuestionIndex': next,
      'outcome': outcome,
      'canDecline': !finished && !duel.isChallenger && noMovesYet,
      'canForfeit': !finished && !(!duel.isChallenger && noMovesYet),
      'inviteUrl': null,
      'inviteToken': null,
      'xpEarned': 0,
      'rounds': rounds,
    };
  }

  Map<String, dynamic> _questionJson(
    _PreviewQuestion q,
    int index,
    bool finished,
  ) {
    final revealed = q.mine != null || finished;
    return {
      'index': index,
      'text': q.text,
      'answers': [
        for (var i = 0; i < q.answers.length; i++)
          {'id': q.idOf(i), 'text': q.answers[i]},
      ],
      'myAnswerId': q.mine == null ? null : q.idOf(q.mine!),
      'myResult': _mark(q, q.mine),
      'opponentAnswerId': revealed && q.theirs != null ? q.idOf(q.theirs!) : null,
      'opponentResult': _theirMark(q, finished),
      'correctAnswerId': revealed ? q.idOf(q.correct) : null,
      'explanation': revealed ? q.explanation : null,
      'bibleReference': revealed ? q.reference : null,
      'xpEarned': q.mine == q.correct ? 15 : 0,
    };
  }

  // -------------------------------------------------------------------------
  // The "endpoints"
  // -------------------------------------------------------------------------

  Map<String, dynamic> list() {
    final views = _duels.map((d) => _view(d, withQuestions: false)).toList();
    final myTurn = views.where((v) => v['turn'] == 'me').toList();
    return {
      'myTurn': myTurn,
      'waiting': views
          .where((v) => v['turn'] == 'opponent' || v['turn'] == 'matching')
          .toList(),
      'finished': views.where((v) => v['status'] == 'finished').toList(),
      'record': {'wins': 9, 'losses': 4, 'ties': 0},
      'turnCount': myTurn.length,
    };
  }

  Map<String, dynamic> duel(String id) {
    final duel = _duels.firstWhere((d) => d.id == id, orElse: () => _duels.first);
    return _view(duel);
  }

  Map<String, dynamic> answer(String id, int round, int question, String answerId) {
    final duel = _duels.firstWhere((d) => d.id == id, orElse: () => _duels.first);
    final q = duel.rounds[round].questions[question];
    q.mine ??= int.tryParse(answerId.replaceFirst('a', '')) ?? 0;
    final view = _view(duel);
    final roundView = (view['rounds'] as List)[round] as Map<String, dynamic>;
    final questionView =
        (roundView['questions'] as List)[question] as Map<String, dynamic>;
    return {
      'result': {
        ...questionView,
        'roundIndex': round,
        'questionIndex': question,
        'isCorrect': q.mine == q.correct,
        'roundComplete': _mineDone(duel.rounds[round]),
        'alreadyRecorded': false,
      },
      'duel': view,
    };
  }

  Map<String, dynamic> create({String? opponentName}) {
    final duel = opponentName == null
        ? _duels.first
        : _duels.firstWhere(
            (d) => d.opponentName == opponentName,
            orElse: () => _duels.first,
          );
    return {
      'duel': _view(duel),
      'created': false,
      'matched': false,
      'inviteUrl': null,
      'inviteToken': 'voorbeeld',
      'inviteMessage': null,
    };
  }

  List<Map<String, dynamic>> players(String? query) {
    final q = query?.trim().toLowerCase() ?? '';
    return [
      for (final (id, name, level) in _friends)
        if (q.isEmpty || name.toLowerCase().contains(q))
          {
            'id': id,
            'name': name,
            'level': level,
            'source': q.isEmpty ? 'duel' : 'search',
          },
    ];
  }

  Map<String, dynamic> invite() => {
    'challenger': _player('preview-lotte-user', 'Lotte', 9),
    'joinable': true,
  };
}
