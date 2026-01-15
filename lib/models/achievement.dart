/// Achievement model representing user achievements/badges
class Achievement {
  final int? id;
  final int userId;
  final String achievementType;
  final String? unlockedAt;
  final int progress;

  Achievement({
    this.id,
    required this.userId,
    required this.achievementType,
    this.unlockedAt,
    this.progress = 0,
  });

  /// Creates an Achievement from a database map
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      achievementType: map['achievement_type'] as String,
      unlockedAt: map['unlocked_at'] as String?,
      progress: (map['progress'] as int?) ?? 0,
    );
  }

  /// Converts an Achievement to a database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'achievement_type': achievementType,
      'unlocked_at': unlockedAt,
      'progress': progress,
    };
  }

  /// Creates a copy of the Achievement with updated fields
  Achievement copyWith({
    int? id,
    int? userId,
    String? achievementType,
    String? unlockedAt,
    int? progress,
  }) {
    return Achievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementType: achievementType ?? this.achievementType,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }

  /// Checks if the achievement is unlocked
  bool get isUnlocked => unlockedAt != null;

  /// Achievement definitions with metadata
  static const Map<String, Map<String, dynamic>> definitions = {
    'first_wing': {
      'name': 'First Wing',
      'description': 'Log your first Red Bull drink',
      'icon': 'flight_takeoff',
      'target': 1,
    },
    'daily_warrior': {
      'name': 'Daily Warrior',
      'description': 'Maintain a 7-day drinking streak',
      'icon': 'local_fire_department',
      'target': 7,
    },
    'weekly_champion': {
      'name': 'Weekly Champion',
      'description': 'Maintain a 30-day drinking streak',
      'icon': 'emoji_events',
      'target': 30,
    },
    'caffeine_master': {
      'name': 'Caffeine Master',
      'description': 'Consume 1000mg of caffeine total',
      'icon': 'bolt',
      'target': 1000,
    },
    'flavor_explorer': {
      'name': 'Flavor Explorer',
      'description': 'Try 5 different Red Bull flavors',
      'icon': 'explore',
      'target': 5,
    },
    'budget_keeper': {
      'name': 'Budget Keeper',
      'description': 'Track spending for 7 consecutive days',
      'icon': 'account_balance_wallet',
      'target': 7,
    },
    'night_owl': {
      'name': 'Night Owl',
      'description': 'Log a drink after 10 PM',
      'icon': 'nightlight',
      'target': 1,
    },
    'early_bird': {
      'name': 'Early Bird',
      'description': 'Log a drink before 8 AM',
      'icon': 'wb_sunny',
      'target': 1,
    },
    'redbull_fanatic': {
      'name': 'Red Bull Fanatic',
      'description': 'Log 100 total drinks',
      'icon': 'favorite',
      'target': 100,
    },
    'collector': {
      'name': 'Collector',
      'description': 'Try all 12 Red Bull flavors',
      'icon': 'collections',
      'target': 12,
    },
  };

  /// Gets achievement metadata
  static Map<String, dynamic>? getDefinition(String type) {
    return definitions[type];
  }

  /// Gets all achievement types
  static List<String> get allTypes => definitions.keys.toList();

  @override
  String toString() {
    return 'Achievement(id: $id, userId: $userId, type: $achievementType, unlocked: $isUnlocked, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement &&
        other.id == id &&
        other.userId == userId &&
        other.achievementType == achievementType;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ achievementType.hashCode;
}
