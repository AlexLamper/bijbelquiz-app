import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/present/auth_controller.dart';
import '../../../core/api/api_client.dart';
import '../domain/leaderboard_entry.dart';

enum LeaderboardPeriod { week, month, all }

extension LeaderboardPeriodX on LeaderboardPeriod {
  String get apiValue {
    switch (this) {
      case LeaderboardPeriod.week:
        return 'week';
      case LeaderboardPeriod.month:
        return 'month';
      case LeaderboardPeriod.all:
        return 'all';
    }
  }
}

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LeaderboardRepository(apiClient);
});

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((
  ref,
) async {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.getLeaderboard(period: LeaderboardPeriod.all);
});

final leaderboardByPeriodProvider =
    FutureProvider.autoDispose.family<List<LeaderboardEntry>, LeaderboardPeriod>(
      (ref, period) async {
        final repository = ref.watch(leaderboardRepositoryProvider);
        return repository.getLeaderboard(period: period);
      },
    );

class LeaderboardRepository {
  final ApiClient _apiClient;

  LeaderboardRepository(this._apiClient);

  Future<List<LeaderboardEntry>> getLeaderboard({
    LeaderboardPeriod period = LeaderboardPeriod.all,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/leaderboard',
        queryParameters: {'period': period.apiValue},
      );
      final data = response.data;

      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map) {
        if (data['leaderboard'] is List) {
          items = data['leaderboard'] as List;
        } else if (data['entries'] is List) {
          items = data['entries'] as List;
        }
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(LeaderboardEntry.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Failed to load leaderboard: $e');
    }
  }
}
