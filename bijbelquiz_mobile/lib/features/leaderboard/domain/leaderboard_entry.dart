class LeaderboardEntry {
  final String id;
  final String name;
  final int xp;
  final String? image;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.xp,
    this.image,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'xp': xp, 'image': image};
  }
}
