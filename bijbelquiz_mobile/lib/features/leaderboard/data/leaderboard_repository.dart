import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/present/auth_controller.dart';
import '../../../core/api/api_client.dart';
import '../domain/leaderboard_entry.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LeaderboardRepository(apiClient);
});

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((
  ref,
) async {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.getLeaderboard();
});

class LeaderboardRepository {
  final ApiClient _apiClient;

  LeaderboardRepository(this._apiClient);

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final response = await _apiClient.dio.get('/leaderboard');
      final data = response.data;

      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data.containsKey('leaderboard')) {
        items = data['leaderboard'];
      }
      return items.map((json) => LeaderboardEntry.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load leaderboard: $e');
    }
  }
}
