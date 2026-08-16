int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

/// What the server made of a finished attempt.
///
/// Everything here is computed by `POST /api/mobile/progress`, which shares its
/// logic with the website's `/api/quiz/submit`. The app renders these numbers
/// as-is; deriving its own would put the two clients out of step again.
class QuizSubmissionResult {
  const QuizSubmissionResult({
    required this.xpEarned,
    required this.farmPrevented,
    required this.score,
    required this.totalQuestions,
    required this.xp,
    required this.level,
    required this.levelTitle,
    required this.streak,
    required this.badges,
    required this.newBadges,
  });

  /// XP added by this attempt. Zero on a replay that did not beat the old best.
  final int xpEarned;

  /// True when a better earlier attempt is why [xpEarned] is zero.
  final bool farmPrevented;

  /// Correct count as re-graded by the server.
  final int score;
  final int totalQuestions;

  /// Player totals after the attempt was applied.
  final int xp;
  final int level;
  final String levelTitle;
  final int streak;
  final List<String> badges;

  /// Badges this attempt unlocked, worth celebrating on the result screen.
  final List<String> newBadges;

  factory QuizSubmissionResult.fromJson(Map<String, dynamic> json) {
    List<String> stringList(dynamic value) =>
        (value as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const <String>[];

    return QuizSubmissionResult(
      xpEarned: _asInt(json['xpEarned'] ?? json['xpAwarded']),
      farmPrevented: json['farmPrevented'] as bool? ?? false,
      score: _asInt(json['score']),
      totalQuestions: _asInt(json['totalQuestions']),
      xp: _asInt(json['xp']),
      level: _asInt(json['level'], 1),
      levelTitle: json['levelTitle'] as String? ?? '',
      streak: _asInt(json['streak']),
      badges: stringList(json['badges']),
      newBadges: stringList(json['newBadges']),
    );
  }
}
