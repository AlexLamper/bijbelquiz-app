import '../../../core/avatar/avatar_catalog.dart';

class LeaderboardEntry {
  final String id;
  final String name;
  final int xp;
  final int streak;
  final String? image;

  /// The player mascot. The ranking draws this rather than a profile photo, so
  /// every row is recognisable even for accounts that never uploaded one.
  final AvatarConfig avatar;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.xp,
    this.streak = 0,
    this.image,
    this.avatar = AvatarConfig.fallback,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['_id']?.toString() ?? '';

    return LeaderboardEntry(
      id: id,
      name: json['name'] as String? ?? 'Speler',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      image: json['image'] as String?,
      avatar: AvatarConfig.resolve(
        json['avatar'] is Map
            ? Map<String, dynamic>.from(json['avatar'] as Map)
            : null,
        id,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'xp': xp,
      'streak': streak,
      'image': image,
      'avatar': avatar.toJson(),
    };
  }
}
