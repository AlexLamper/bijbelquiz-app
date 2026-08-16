import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/avatar/avatar_catalog.dart';
import '../../auth/present/auth_controller.dart';
import 'badge_catalog.dart';
import 'profile_model.dart';
import 'package:dio/dio.dart';

final profileRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

/// What the server accepted after an identity change.
class IdentityUpdate {
  const IdentityUpdate({
    required this.name,
    required this.avatar,
    required this.nameChangeAllowedInDays,
  });

  final String name;
  final AvatarConfig avatar;
  final int nameChangeAllowedInDays;
}

/// Carries the server's own Dutch message straight to the UI.
class IdentityUpdateException implements Exception {
  const IdentityUpdateException(this.message);
  final String message;

  @override
  String toString() => message;
}

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

  /// Writes a new display name and/or mascot.
  ///
  /// `PUT /api/mobile/profile` runs the same `updateIdentity` the website
  /// posts to, so the 30 day rename cooldown and the mascot catalogue check
  /// behave the same on both platforms. The server's own error text is Dutch
  /// and contextual (it names the number of days left), so it is surfaced
  /// verbatim rather than replaced with a generic message.
  Future<IdentityUpdate> updateIdentity({
    String? name,
    AvatarConfig? avatar,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/profile',
        data: {
          if (name != null) 'name': name,
          if (avatar != null) 'avatar': avatar.toJson(),
        },
      );

      final data = response.data?['data'] ?? response.data;
      final map = data is Map ? Map<String, dynamic>.from(data) : const {};

      return IdentityUpdate(
        name: map['name'] as String? ?? name ?? '',
        avatar: map['avatar'] is Map
            ? AvatarConfig.fromJson(
                Map<String, dynamic>.from(map['avatar'] as Map),
              )
            : avatar ?? AvatarConfig.fallback,
        nameChangeAllowedInDays:
            (map['nameChangeAllowedInDays'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (error) {
      throw IdentityUpdateException(_serverMessage(error));
    } catch (_) {
      throw const IdentityUpdateException(
        'Opslaan is niet gelukt. Probeer het opnieuw.',
      );
    }
  }

  String _serverMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['error'] ?? data['message'];
      final text = message?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }

    return 'Opslaan is niet gelukt. Controleer je verbinding.';
  }

  /// Achievement definitions straight from the server catalogue.
  ///
  /// An empty list means "fall back to the built-in catalogue" rather than
  /// "no achievements", so an unreachable backend never blanks the screen.
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
