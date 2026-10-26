import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/preview_config.dart';
import '../../auth/present/auth_controller.dart';
import '../../profile/present/profile_provider.dart';
import 'pending_attempt_store.dart';

/// How many different quizzes a player without Premium may play.
const int kFreeQuizLimit = 3;

/// Where the player stands against the free-quiz limit.
class FreeQuizAllowance {
  const FreeQuizAllowance({
    required this.isPremium,
    required this.playedQuizIds,
  });

  /// Premium players are never limited.
  final bool isPremium;

  /// Quizzes already finished (account) or played as a guest on this device.
  final Set<String> playedQuizIds;

  int get used => playedQuizIds.length;

  /// Free quizzes left, for the "Nog N gratis quizzen" line.
  int get remaining =>
      isPremium ? kFreeQuizLimit : (kFreeQuizLimit - used).clamp(0, kFreeQuizLimit);

  bool get limitReached => !isPremium && used >= kFreeQuizLimit;

  /// A quiz the player already played stays open, so the free quizzes can be
  /// replayed; a new quiz needs a free slot or Premium.
  bool canPlay(String quizId, {String? slug}) {
    if (isPremium) return true;
    if (playedQuizIds.contains(quizId)) return true;
    if (slug != null && playedQuizIds.contains(slug)) return true;
    return used < kFreeQuizLimit;
  }
}

/// Free-quiz allowance for the current player.
///
/// Signed in: the account's finished quizzes and Premium flag from the
/// profile. Guest: the attempts parked on this device until they sign in.
final freeQuizAllowanceProvider = FutureProvider.autoDispose<FreeQuizAllowance>((
  ref,
) async {
  if (PreviewConfig.enabled) {
    return const FreeQuizAllowance(isPremium: false, playedQuizIds: {'q1'});
  }

  final hasSession = await ref.watch(hasSessionProvider.future);
  final pending = await ref.watch(pendingAttemptsProvider.future);
  final pendingIds = {for (final a in pending) a.quizId};

  if (!hasSession) {
    return FreeQuizAllowance(isPremium: false, playedQuizIds: pendingIds);
  }

  try {
    final profile = await ref.watch(profileProvider.future);
    return FreeQuizAllowance(
      isPremium: profile.isPremium,
      playedQuizIds: {...profile.playedQuizIds, ...pendingIds},
    );
  } catch (_) {
    // Without a profile we cannot tell; never lock someone out on a network
    // hiccup - the next successful load applies the limit again.
    return const FreeQuizAllowance(isPremium: true, playedQuizIds: {});
  }
});
