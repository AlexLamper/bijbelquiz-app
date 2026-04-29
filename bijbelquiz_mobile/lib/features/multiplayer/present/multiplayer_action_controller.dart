import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/multiplayer_api_exception.dart';
import '../data/multiplayer_repository.dart';
import '../domain/multiplayer_models.dart';

final multiplayerActionControllerProvider =
    AsyncNotifierProvider.autoDispose<MultiplayerActionController, void>(
      MultiplayerActionController.new,
    );

class MultiplayerActionController extends AsyncNotifier<void> {
  MultiplayerRepository get _repository => ref.read(multiplayerRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<MultiplayerRoom> createRoom({
    required String quizId,
    required bool hasPremiumAccess,
  }) async {
    if (!hasPremiumAccess) {
      throw const MultiplayerApiException(
        code: 'PREMIUM_REQUIRED',
        message: 'Kamer hosten is alleen beschikbaar voor premium leden.',
      );
    }

    state = const AsyncValue.loading();
    try {
      final room = await _repository.createRoom(quizId: quizId);
      state = const AsyncValue.data(null);
      return room;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<MultiplayerRoom> joinRoom({required String roomCode}) async {
    state = const AsyncValue.loading();
    try {
      final room = await _repository.joinRoom(roomCode);
      state = const AsyncValue.data(null);
      return room;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
