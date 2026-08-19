/// How the reader wants to play a quiz.
///
/// Stored on the account rather than on the device, so the choices made on the
/// quiz start screen here are the same ones the website uses - `settings` on
/// the user document, normalised by `src/lib/user-settings.ts`.
class QuizPreferences {
  const QuizPreferences({
    this.questionTimerSeconds = 0,
    this.readPassageFirst = false,
    this.showBibleReferences = true,
    this.largeQuestionText = false,
  });

  /// Seconds allowed per question. `0` means no timer, which is the default:
  /// a countdown on a Bible study quiz is a choice, never the starting point.
  final int questionTimerSeconds;

  /// Read the chapter the quiz is about before the first question.
  final bool readPassageFirst;

  /// Show the bible reference under an explanation.
  final bool showBibleReferences;

  final bool largeQuestionText;

  /// The choices the timer control offers. Mirrors `QUESTION_TIMER_CHOICES`.
  static const List<int> timerChoices = [0, 30, 60, 90];

  bool get hasTimer => questionTimerSeconds > 0;

  static int normalizeTimer(Object? value) {
    final parsed = value is num ? value.toInt() : int.tryParse('${value ?? ''}');
    return timerChoices.contains(parsed) ? parsed! : 0;
  }

  factory QuizPreferences.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const QuizPreferences();

    return QuizPreferences(
      questionTimerSeconds: normalizeTimer(json['questionTimerSeconds']),
      readPassageFirst: json['readPassageFirst'] == true,
      showBibleReferences: json['showBibleReferences'] != false,
      largeQuestionText: json['questionFontSize'] == 'large',
    );
  }

  /// Only the fields this app owns; anything else on the account is left alone.
  Map<String, dynamic> toSettingsPatch() => {
    'questionTimerSeconds': questionTimerSeconds,
    'readPassageFirst': readPassageFirst,
    'showBibleReferences': showBibleReferences,
    'questionFontSize': largeQuestionText ? 'large' : 'normal',
  };

  QuizPreferences copyWith({
    int? questionTimerSeconds,
    bool? readPassageFirst,
    bool? showBibleReferences,
    bool? largeQuestionText,
  }) {
    return QuizPreferences(
      questionTimerSeconds: questionTimerSeconds ?? this.questionTimerSeconds,
      readPassageFirst: readPassageFirst ?? this.readPassageFirst,
      showBibleReferences: showBibleReferences ?? this.showBibleReferences,
      largeQuestionText: largeQuestionText ?? this.largeQuestionText,
    );
  }
}
