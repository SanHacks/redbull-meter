/// Streak model representing daily drinking streaks
class Streak {
  final int? id;
  final int userId;
  final int currentStreak;
  final int longestStreak;
  final String? lastDrinkDate; // Date in 'yyyy-MM-dd' format

  Streak({
    this.id,
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastDrinkDate,
  });

  /// Creates a Streak from a database map
  factory Streak.fromMap(Map<String, dynamic> map) {
    return Streak(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      currentStreak: (map['current_streak'] as int?) ?? 0,
      longestStreak: (map['longest_streak'] as int?) ?? 0,
      lastDrinkDate: map['last_drink_date'] as String?,
    );
  }

  /// Converts a Streak to a database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_drink_date': lastDrinkDate,
    };
  }

  /// Creates a copy of the Streak with updated fields
  Streak copyWith({
    int? id,
    int? userId,
    int? currentStreak,
    int? longestStreak,
    String? lastDrinkDate,
  }) {
    return Streak(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastDrinkDate: lastDrinkDate ?? this.lastDrinkDate,
    );
  }

  /// Checks if the streak is active (has at least 1 day)
  bool get isActive => currentStreak > 0;

  /// Gets milestone information
  /// Returns the next milestone and whether current streak is a milestone
  Map<String, dynamic> getMilestoneInfo() {
    final milestones = [7, 14, 30, 60, 100];
    int? nextMilestone;
    bool isMilestone = false;

    for (final milestone in milestones) {
      if (currentStreak >= milestone) {
        isMilestone = currentStreak == milestone;
      } else {
        nextMilestone = milestone;
        break;
      }
    }

    return {
      'isMilestone': isMilestone,
      'nextMilestone': nextMilestone,
      'currentStreak': currentStreak,
    };
  }

  @override
  String toString() {
    return 'Streak(id: $id, userId: $userId, current: $currentStreak, longest: $longestStreak, lastDate: $lastDrinkDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Streak &&
        other.id == id &&
        other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}
