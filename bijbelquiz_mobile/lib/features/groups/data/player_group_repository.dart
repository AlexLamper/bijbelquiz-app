import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/errors/app_error.dart';
import '../../auth/present/auth_controller.dart';
import '../../leaderboard/data/leaderboard_repository.dart';
import '../../leaderboard/domain/leaderboard_entry.dart';
import '../domain/player_group.dart';

final playerGroupRepositoryProvider = Provider<PlayerGroupRepository>((ref) {
  return PlayerGroupRepository(ref.watch(apiClientProvider));
});

/// Every group this account belongs to.
///
/// Not auto-disposed: the leaderboard screen and the play-together screen both
/// read it, and a user tabbing between them should not refetch each time.
final playerGroupsProvider = FutureProvider<List<PlayerGroup>>((ref) async {
  return ref.watch(playerGroupRepositoryProvider).list();
});

/// The key for one group's board. A record so the family argument compares by
/// value and switching period does not leak a provider per tap.
typedef PlayerGroupBoardKey = ({String groupId, LeaderboardPeriod period});

final playerGroupLeaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>, PlayerGroupBoardKey>((ref, key) async {
      return ref
          .watch(playerGroupRepositoryProvider)
          .leaderboard(groupId: key.groupId, period: key.period);
    });

/// Saved player groups.
///
/// Talks to `/api/mobile/player-groups`, which is an alias of the website's
/// route, so the two clients cannot drift apart on the rules.
class PlayerGroupRepository {
  PlayerGroupRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PlayerGroup>> list() {
    return _guard(
      fallback: 'Kon je groepen niet laden.',
      request: () async {
        final response = await _apiClient.dio.get('/player-groups');
        final data = response.data;
        final groups = data is Map ? data['groups'] : null;
        if (groups is! List) return const <PlayerGroup>[];

        return groups
            .whereType<Map>()
            .map((row) => PlayerGroup.fromJson(Map<String, dynamic>.from(row)))
            .toList();
      },
    );
  }

  /// Saves the players of a finished room. Idempotent per room, so a double
  /// tap on a slow connection returns the group that already exists.
  Future<PlayerGroup> createFromRoom(String roomCode, {String? name}) {
    return _guard(
      fallback: 'Groep bewaren is niet gelukt.',
      request: () async {
        final response = await _apiClient.dio.post(
          '/player-groups',
          data: {
            'roomCode': roomCode.toUpperCase(),
            if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
          },
        );

        final data = response.data;
        final group = data is Map ? data['group'] : null;
        if (group is! Map) {
          throw const AppError(
            title: 'Groep bewaren mislukt',
            message: 'De server gaf geen groep terug. Probeer het opnieuw.',
          );
        }

        return PlayerGroup.fromJson(Map<String, dynamic>.from(group));
      },
    );
  }

  Future<List<PlayerGroup>> rename(String groupId, String name) {
    return _patch({'groupId': groupId, 'name': name}, 'Hernoemen is niet gelukt.');
  }

  /// Passing your own id leaves the group.
  Future<List<PlayerGroup>> removeMember(String groupId, String memberId) {
    return _patch(
      {'groupId': groupId, 'removeMemberId': memberId},
      'Verwijderen is niet gelukt.',
    );
  }

  Future<List<LeaderboardEntry>> leaderboard({
    required String groupId,
    LeaderboardPeriod period = LeaderboardPeriod.all,
  }) {
    return _guard(
      fallback: 'Kon de stand van deze groep niet laden.',
      request: () async {
        final response = await _apiClient.dio.get(
          '/player-groups/$groupId/leaderboard',
          queryParameters: {'period': period.apiValue},
        );

        final data = response.data;
        final entries = data is Map ? data['entries'] : null;
        if (entries is! List) return const <LeaderboardEntry>[];

        return entries
            .whereType<Map>()
            .map(
              (row) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(row)),
            )
            .toList();
      },
    );
  }

  Future<List<PlayerGroup>> _patch(
    Map<String, dynamic> body,
    String fallback,
  ) {
    return _guard(
      fallback: fallback,
      request: () async {
        final response = await _apiClient.dio.patch('/player-groups', data: body);
        final data = response.data;
        final groups = data is Map ? data['groups'] : null;
        if (groups is! List) return const <PlayerGroup>[];

        return groups
            .whereType<Map>()
            .map((row) => PlayerGroup.fromJson(Map<String, dynamic>.from(row)))
            .toList();
      },
    );
  }

  /// Turns a failure into an [AppError] carrying the server's Dutch message.
  ///
  /// These routes answer with a bare `{ "error": "..." }` rather than the
  /// multiplayer routes' coded envelope, and those strings are written for the
  /// player ("Je hebt niet in deze kamer gespeeld"), so they are shown as-is.
  Future<T> _guard<T>({
    required String fallback,
    required Future<T> Function() request,
  }) async {
    try {
      return await request();
    } on AppError {
      rethrow;
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map ? data['error'] : null;

      throw AppError(
        title: 'Groepen',
        message: message is String && message.trim().isNotEmpty
            ? message
            : fallback,
      );
    } catch (_) {
      throw AppError(title: 'Groepen', message: fallback);
    }
  }
}
