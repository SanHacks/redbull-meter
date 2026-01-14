/// Model class representing a drink log entry in the database
class Log {
  final int? id;
  final int userId;
  final int flavorId;
  final double pricePaid;
  final String timestamp;
  final String? notes;

  /// Constructor for Log model
  Log({
    this.id,
    required this.userId,
    required this.flavorId,
    required this.pricePaid,
    required this.timestamp,
    this.notes,
  });

  /// Converts Log object to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'flavor_id': flavorId,
      'price_paid': pricePaid,
      'timestamp': timestamp,
      'notes': notes,
    };
  }

  /// Creates a Log object from a database Map
  factory Log.fromMap(Map<String, dynamic> map) {
    return Log(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      flavorId: map['flavor_id'] as int,
      pricePaid: (map['price_paid'] as num).toDouble(),
      timestamp: map['timestamp'] as String,
      notes: map['notes'] as String?,
    );
  }

  /// Creates a copy of the Log with updated fields
  Log copyWith({
    int? id,
    int? userId,
    int? flavorId,
    double? pricePaid,
    String? timestamp,
    String? notes,
  }) {
    return Log(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      flavorId: flavorId ?? this.flavorId,
      pricePaid: pricePaid ?? this.pricePaid,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Log(id: $id, userId: $userId, flavorId: $flavorId, pricePaid: $pricePaid, timestamp: $timestamp, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Log &&
        other.id == id &&
        other.userId == userId &&
        other.flavorId == flavorId &&
        other.pricePaid == pricePaid &&
        other.timestamp == timestamp &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, flavorId, pricePaid, timestamp, notes);
  }
}

