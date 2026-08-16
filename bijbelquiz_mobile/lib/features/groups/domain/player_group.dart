import '../../../core/avatar/avatar_catalog.dart';

/// One member of a saved group.
class PlayerGroupMember {
  final String id;
  final String name;
  final bool isOwner;
  final AvatarConfig avatar;

  const PlayerGroupMember({
    required this.id,
    required this.name,
    this.isOwner = false,
    this.avatar = AvatarConfig.fallback,
  });

  factory PlayerGroupMember.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';

    return PlayerGroupMember(
      id: id,
      name: json['name'] as String? ?? 'Speler',
      isOwner: json['isOwner'] == true,
      avatar: AvatarConfig.resolve(
        json['avatar'] is Map
            ? Map<String, dynamic>.from(json['avatar'] as Map)
            : null,
        id,
      ),
    );
  }
}

/// A group of players kept after the game they met in.
///
/// Mirrors `PlayerGroupSummary` in `src/lib/player-groups.ts`. Deliberately
/// unrelated to the group *licence*, which is billing: this one is free and
/// social, and the two only share a word.
class PlayerGroup {
  final String id;
  final String name;
  final int memberCount;
  final bool isOwner;
  final String? createdFromRoomCode;
  final List<PlayerGroupMember> members;

  const PlayerGroup({
    required this.id,
    required this.name,
    required this.memberCount,
    this.isOwner = false,
    this.createdFromRoomCode,
    this.members = const [],
  });

  factory PlayerGroup.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];

    return PlayerGroup(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Groep',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      isOwner: json['isOwner'] == true,
      createdFromRoomCode: json['createdFromRoomCode'] as String?,
      members: rawMembers is List
          ? rawMembers
                .whereType<Map>()
                .map(
                  (member) =>
                      PlayerGroupMember.fromJson(
                        Map<String, dynamic>.from(member),
                      ),
                )
                .toList()
          : const [],
    );
  }
}
