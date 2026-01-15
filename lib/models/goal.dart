/// Goal model representing user-defined daily/weekly goals
class Goal {
  final int? id;
  final int userId;
  final String goalType; // 'daily_drinks', 'weekly_drinks', 'daily_caffeine', 'weekly_spending', etc.
  final double targetValue;
  final double currentValue;
  final String periodStart; // Date in 'yyyy-MM-dd' format

  Goal({
    this.id,
    required this.userId,
    required this.goalType,
    required this.targetValue,
    this.currentValue = 0.0,
    required this.periodStart,
  });

  /// Creates a Goal from a database map
  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      goalType: map['goal_type'] as String,
      targetValue: (map['target_value'] as num).toDouble(),
      currentValue: (map['current_value'] as num?)?.toDouble() ?? 0.0,
      periodStart: map['period_start'] as String,
    );
  }

  /// Converts a Goal to a database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'goal_type': goalType,
      'target_value': targetValue,
      'current_value': currentValue,
      'period_start': periodStart,
    };
  }

  /// Creates a copy of the Goal with updated fields
  Goal copyWith({
    int? id,
    int? userId,
    String? goalType,
    double? targetValue,
    double? currentValue,
    String? periodStart,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalType: goalType ?? this.goalType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      periodStart: periodStart ?? this.periodStart,
    );
  }

  /// Gets the progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (targetValue <= 0) return 0.0;
    final progress = currentValue / targetValue;
    return progress > 1.0 ? 1.0 : progress;
  }

  /// Checks if the goal is completed
  bool get isCompleted => currentValue >= targetValue;

  /// Gets the remaining value to reach the goal
  double get remaining {
    final remaining = targetValue - currentValue;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Goal type definitions
  static const Map<String, Map<String, dynamic>> typeDefinitions = {
    'daily_drinks': {
      'name': 'Daily Drinks',
      'description': 'Target number of drinks per day',
      'icon': 'local_drink',
      'unit': 'drinks',
    },
    'weekly_drinks': {
      'name': 'Weekly Drinks',
      'description': 'Target number of drinks per week',
      'icon': 'local_drink',
      'unit': 'drinks',
    },
    'daily_caffeine': {
      'name': 'Daily Caffeine',
      'description': 'Target caffeine intake per day',
      'icon': 'bolt',
      'unit': 'mg',
    },
    'weekly_caffeine': {
      'name': 'Weekly Caffeine',
      'description': 'Target caffeine intake per week',
      'icon': 'bolt',
      'unit': 'mg',
    },
    'daily_spending': {
      'name': 'Daily Spending',
      'description': 'Target spending limit per day',
      'icon': 'account_balance_wallet',
      'unit': 'currency',
    },
    'weekly_spending': {
      'name': 'Weekly Spending',
      'description': 'Target spending limit per week',
      'icon': 'account_balance_wallet',
      'unit': 'currency',
    },
  };

  /// Gets goal type metadata
  static Map<String, dynamic>? getTypeDefinition(String type) {
    return typeDefinitions[type];
  }

  /// Gets all goal types
  static List<String> get allTypes => typeDefinitions.keys.toList();

  @override
  String toString() {
    return 'Goal(id: $id, userId: $userId, type: $goalType, progress: ${currentValue}/${targetValue}, period: $periodStart)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal &&
        other.id == id &&
        other.userId == userId &&
        other.goalType == goalType &&
        other.periodStart == periodStart;
  }

  @override
  int get hashCode =>
      id.hashCode ^ userId.hashCode ^ goalType.hashCode ^ periodStart.hashCode;
}
