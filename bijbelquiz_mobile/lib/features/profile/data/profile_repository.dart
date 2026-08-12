import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../auth/present/auth_controller.dart';
import 'badge_catalog.dart';
import 'profile_model.dart';
import 'package:dio/dio.dart';

final profileRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<ProfileModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/profile');

      if (response.statusCode == 200 && response.data != null) {
        // Assume API sends `{ data: { ... } }` or just `{ ... }`
        final data = response.data['data'] ?? response.data;
        return ProfileModel.fromJson(data);
      } else {
        throw Exception('Geen profieldata gevonden');
      }
    } on DioException catch (e) {
      throw Exception('Fout bij ophalen profiel: ${e.message}');
    } catch (_) {
      throw Exception('Onbekende fout bij ophalen profiel');
    }
  }

  /// Achievement definitions straight from the database.
  ///
  /// `GET /api/mobile/badges` does not exist yet, so an empty list means
  /// "fall back to the built-in catalogue" rather than "no achievements".
  Future<List<BadgeDefinition>> getBadgeDefinitions() async {
    try {
      final response = await _apiClient.dio.get('/badges');
      final data = response.data;

      final items = data is List
          ? data
          : (data is Map && data['badges'] is List)
          ? data['badges'] as List
          : const [];

      return items
          .whereType<Map<String, dynamic>>()
          .map(BadgeDefinition.fromJson)
          .where((definition) => definition.code.isNotEmpty)
          .toList();
    } catch (_) {
      return const <BadgeDefinition>[];
    }
  }

  /// Forces the server to reconcile premium with RevenueCat and returns the
  /// resulting premium flag. RevenueCat does not re-send a webhook for an
  /// already-owned purchase or a restore, so without this call premium can
  /// stay locked on the server forever. Returns null if the endpoint is
  /// unreachable/undeployed so callers can fall back to polling /profile.
  Future<bool?> syncPremium() async {
    try {
      final response = await _apiClient.dio.post('/sync-premium');
      final data = response.data?['data'] ?? response.data;
      return (data?['isPremium'] as bool?) ?? false;
    } catch (_) {
      return null;
    }
  }
}
