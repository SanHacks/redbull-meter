/// Model class representing a user in the database
class User {
  final int? id;
  final String username;

  /// Constructor for User model
  User({
    this.id,
    required this.username,
  });

  /// Converts User object to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
    };
  }

  /// Creates a User object from a database Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
    );
  }

  /// Creates a copy of the User with updated fields
  User copyWith({
    int? id,
    String? username,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.username == username;
  }

  @override
  int get hashCode {
    return Object.hash(id, username);
  }
}

