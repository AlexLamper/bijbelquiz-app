import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../auth/present/auth_controller.dart';
import '../domain/season.dart';

final seasonRepositoryProvider = Provider<SeasonRepository>((ref) {
  return SeasonRepository(ref.watch(apiClientProvider));
});

/// The pack that is live right now, or null for most of the year.
final currentSeasonProvider = FutureProvider<SeasonPack?>((ref) async {
  return ref.watch(seasonRepositoryProvider).current();
});

/// Seasonal quiz packs.
///
/// The countdown is computed on the server and sent as a day count, so a phone
/// with a wrong clock cannot show a pack as expired - or as still running a
/// week after Christmas.
class SeasonRepository {
  SeasonRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<SeasonPack?> current() async {
    try {
      final response = await _apiClient.dio.get('/seasons/current');
      final data = response.data;
      if (data is! Map) return null;

      final season = data['season'];
      if (season is! Map) return null;

      return SeasonPack.fromJson(
        Map<String, dynamic>.from(season),
        data['quizzes'] is List ? data['quizzes'] as List : const [],
      );
    } catch (_) {
      // No season is the normal state for most of the year, and the home
      // screen must not show an error for it.
      return null;
    }
  }
}
