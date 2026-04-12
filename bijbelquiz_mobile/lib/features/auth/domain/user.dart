class User {
  final String id;
  final String name;
  final String email;
  final int xp;
  final bool isPremium;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.xp,
    this.isPremium = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      xp: json['xp'] as int? ?? 0,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }
}
