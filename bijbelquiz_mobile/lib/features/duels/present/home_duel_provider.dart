import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/duels_repository.dart';

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

/// The duel to show on Home: the first one where it is the player's turn.
///
/// Built on the same list as the Duels tab, so Home costs no extra request.
/// Any failure - offline, signed out - simply hides the card.
final homeDuelProvider = FutureProvider<DuelCardData?>((ref) async {
  try {
    final list = await ref.watch(duelListProvider.future);
    if (list.myTurn.isEmpty) return null;
    final duel = list.myTurn.first;
    return DuelCardData(
      duelId: duel.id,
      opponentName: duel.opponentName,
      myScore: duel.myScore,
      opponentScore: duel.opponentScore,
      round: duel.currentRound,
      totalRounds: duel.totalRounds,
    );
  } catch (_) {
    return null;
  }
});
