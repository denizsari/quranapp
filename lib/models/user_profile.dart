class UserProfile {
  final String id;
  final String displayName;
  final int xp;
  final int level;
  final int streak;
  final int? lastActiveAt; // epoch ms (UTC)
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.xp,
    required this.level,
    required this.streak,
    this.lastActiveAt,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    int? xp,
    int? level,
    int? streak,
    int? lastActiveAt,
  }) =>
      UserProfile(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        xp: xp ?? this.xp,
        level: level ?? this.level,
        streak: streak ?? this.streak,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        displayName: json['displayName'] as String? ?? 'Guest',
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        level: (json['level'] as num?)?.toInt() ?? 1,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        lastActiveAt: (json['lastActiveAt'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'xp': xp,
        'level': level,
        'streak': streak,
        'lastActiveAt': lastActiveAt,
      };
}
