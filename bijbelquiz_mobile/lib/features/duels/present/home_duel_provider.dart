import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the Home "Lotte wacht op jou" card needs to know about the duel where
/// it is the player's turn. Null = no duel waiting, the card is hidden.
class DuelCardData {
  const DuelCardData({
    required this.duelId,
    required this.opponentName,
    required this.myScore,
    required this.opponentScore,
    required this.round,
    required this.totalRounds,
  });

  final String duelId;
  final String opponentName;
  final int myScore;
  final int opponentScore;
  final int round;
  final int totalRounds;
}

/// The duel to show on Home. Implemented by the duels feature.
final homeDuelProvider = FutureProvider<DuelCardData?>((ref) async => null);
