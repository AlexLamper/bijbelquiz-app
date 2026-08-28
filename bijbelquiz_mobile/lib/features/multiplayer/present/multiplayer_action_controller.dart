import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/multiplayer_repository.dart';
import '../domain/multiplayer_models.dart';

final multiplayerActionControllerProvider =
    AsyncNotifierProvider.autoDispose<MultiplayerActionController, void>(
      MultiplayerActionController.new,
    );

/// What this account may do right now, straight from the server.
///
/// The app used to gate hosting on `profile.isPremium` alone, which hid the
/// free games every account gets: the quota lives on the server and is only
/// spent when a game actually starts, so only the server can answer this.
final multiplayerCapabilityProvider =
    FutureProvider.autoDispose<MultiplayerCapability>((ref) async {
      return ref.watch(multiplayerRepositoryProvider).getCapability();
    });

/// The unfinished room this account is already in, if any.
final activeMultiplayerRoomProvider =
    FutureProvider.autoDispose<MultiplayerRoom?>((ref) async {
      return ref.watch(multiplayerRepositoryProvider).getActiveRoom();
    });

class MultiplayerActionController extends AsyncNotifier<void> {
  MultiplayerRepository get _repository =>
      ref.read(multiplayerRepositoryProvider);

  @override
  Future<void> build() async {}

  /// Creating a room is free for everyone; the credit is spent by starting the
  /// game. The server returns `PREMIUM_REQUIRED` with its own Dutch message
  /// when the caller has nothing left, and that message is what the player
  /// sees, so there is no second copy of the rule here.
  Future<MultiplayerRoom> createRoom({
    required String quizId,
    int maxPlayers = 4,
  }) async {
    state = const AsyncValue.loading();
    try {
      final room = await _repository.createRoom(
        quizId: quizId,
        maxPlayers: maxPlayers,
      );
      state = const AsyncValue.data(null);
      return room;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<MultiplayerRoom> joinRoom({
    required String roomCode,
    bool viaInvite = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final room = await _repository.joinRoom(roomCode, viaInvite: viaInvite);
      state = const AsyncValue.data(null);
      return room;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
