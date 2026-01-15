import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/flavor.dart';
import '../models/log.dart';
import '../models/log_with_flavor.dart';
import '../models/achievement.dart';
import '../models/streak.dart';
import '../models/goal.dart';

/// Helper class for managing SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Gets the database instance, creating it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('redbull_meter.db');
    return _database!;
  }

  /// Initializes the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5, // Increment version to trigger onUpgrade for gamification features
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Handles database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE flavors ADD COLUMN image_path TEXT');
    }
    
    if (oldVersion < 3) {
      // Legacy Monster Energy flavors migration
      await db.delete('flavors');
    }
    
    if (oldVersion < 4) {
      // Clear existing flavors to replace with Red Bull flavors
      await db.delete('flavors');
      
      // Insert Red Bull flavors (250ml cans, 80mg caffeine standard)
      final redBullFlavors = [
        {'name': 'Red Bull Original', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-original.webp'},
        {'name': 'Red Bull Sugarfree', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-sugarfree.webp'},
        {'name': 'Red Bull Zero', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-zero.webp'},
        {'name': 'Red Bull Red Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-red-edition.webp'},
        {'name': 'Red Bull Blue Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-blue-edition.webp'},
        {'name': 'Red Bull Yellow Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-yellow-edition.webp'},
        {'name': 'Red Bull Green Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-green-edition.webp'},
        {'name': 'Red Bull Purple Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-purple-edition.webp'},
        {'name': 'Red Bull Peach Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-peach-edition.webp'},
        {'name': 'Red Bull Summer Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-summer-edition.webp'},
        {'name': 'Red Bull Winter Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-winter-edition.webp'},
        {'name': 'Red Bull Amber Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-amber-edition.webp'},
      ];

      for (var flavor in redBullFlavors) {
        await db.insert('flavors', flavor);
      }
    }
    
    if (oldVersion < 5) {
      // Create achievements table
      await db.execute('''
        CREATE TABLE achievements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          achievement_type TEXT NOT NULL,
          unlocked_at TEXT,
          progress INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES users (id),
          UNIQUE(user_id, achievement_type)
        )
      ''');
      
      // Create streaks table
      await db.execute('''
        CREATE TABLE streaks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          current_streak INTEGER NOT NULL DEFAULT 0,
          longest_streak INTEGER NOT NULL DEFAULT 0,
          last_drink_date TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id),
          UNIQUE(user_id)
        )
      ''');
      
      // Create goals table
      await db.execute('''
        CREATE TABLE goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          goal_type TEXT NOT NULL,
          target_value REAL NOT NULL,
          current_value REAL NOT NULL DEFAULT 0,
          period_start TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id),
          UNIQUE(user_id, goal_type, period_start)
        )
      ''');
      
      // Initialize streak for default user
      final defaultUser = await getDefaultUser();
      if (defaultUser != null) {
        await db.insert('streaks', {
          'user_id': defaultUser.id,
          'current_streak': 0,
          'longest_streak': 0,
          'last_drink_date': null,
        });
      }
    }
  }

  /// Creates the database tables
  Future<void> _createDB(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE
      )
    ''');

    // Create flavors table
    await db.execute('''
      CREATE TABLE flavors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        ml INTEGER NOT NULL,
        caffeine_mg INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        image_path TEXT
      )
    ''');

    // Create logs table
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        flavor_id INTEGER NOT NULL,
        price_paid REAL NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (flavor_id) REFERENCES flavors (id)
      )
    ''');

    // Create achievements table
    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        achievement_type TEXT NOT NULL,
        unlocked_at TEXT,
        progress INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id),
        UNIQUE(user_id, achievement_type)
      )
    ''');

    // Create streaks table
    await db.execute('''
      CREATE TABLE streaks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        current_streak INTEGER NOT NULL DEFAULT 0,
        longest_streak INTEGER NOT NULL DEFAULT 0,
        last_drink_date TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        UNIQUE(user_id)
      )
    ''');

    // Create goals table
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        goal_type TEXT NOT NULL,
        target_value REAL NOT NULL,
        current_value REAL NOT NULL DEFAULT 0,
        period_start TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        UNIQUE(user_id, goal_type, period_start)
      )
    ''');

    // Insert default user
    await db.insert('users', {'username': 'default_user'});

    // Insert Red Bull flavors (250ml cans, 80mg caffeine standard)
    final defaultFlavors = [
      {'name': 'Red Bull Original', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-original.webp'},
      {'name': 'Red Bull Sugarfree', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-sugarfree.webp'},
      {'name': 'Red Bull Zero', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-zero.webp'},
      {'name': 'Red Bull Red Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-red-edition.webp'},
      {'name': 'Red Bull Blue Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-blue-edition.webp'},
      {'name': 'Red Bull Yellow Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-yellow-edition.webp'},
      {'name': 'Red Bull Green Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-green-edition.webp'},
      {'name': 'Red Bull Purple Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-purple-edition.webp'},
      {'name': 'Red Bull Peach Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-peach-edition.webp'},
      {'name': 'Red Bull Summer Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-summer-edition.webp'},
      {'name': 'Red Bull Winter Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-winter-edition.webp'},
      {'name': 'Red Bull Amber Edition', 'ml': 250, 'caffeine_mg': 80, 'is_active': 1, 'image_path': 'assets/images/flavors/redbull-amber-edition.webp'},
    ];

    for (var flavor in defaultFlavors) {
      await db.insert('flavors', flavor);
    }
    
    // Initialize streak for default user
    final defaultUserMap = await db.query('users', limit: 1);
    if (defaultUserMap.isNotEmpty) {
      final defaultUserId = defaultUserMap.first['id'] as int;
      await db.insert('streaks', {
        'user_id': defaultUserId,
        'current_streak': 0,
        'longest_streak': 0,
        'last_drink_date': null,
      });
    }
  }

  // USER OPERATIONS

  /// Creates a new user
  Future<User> createUser(User user) async {
    try {
      final db = await database;
      final id = await db.insert('users', user.toMap());
      return user.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Gets a user by ID
  Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /// Gets the default user (for single-user app)
  Future<User?> getDefaultUser() async {
    final db = await database;
    final maps = await db.query('users', limit: 1);

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // FLAVOR OPERATIONS

  /// Creates a new flavor
  Future<Flavor> createFlavor(Flavor flavor) async {
    try {
      final db = await database;
      final id = await db.insert('flavors', flavor.toMap());
      return flavor.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to create flavor: $e');
    }
  }

  /// Gets all active flavors
  Future<List<Flavor>> getActiveFlavors() async {
    try {
      final db = await database;
      final maps = await db.query(
        'flavors',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'name ASC',
      );

      return maps.map((map) => Flavor.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets all flavors (including inactive)
  Future<List<Flavor>> getAllFlavors() async {
    final db = await database;
    final maps = await db.query('flavors', orderBy: 'name ASC');
    return maps.map((map) => Flavor.fromMap(map)).toList();
  }

  /// Gets a flavor by ID
  Future<Flavor?> getFlavor(int id) async {
    final db = await database;
    final maps = await db.query(
      'flavors',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Flavor.fromMap(maps.first);
    }
    return null;
  }

  /// Updates a flavor
  Future<int> updateFlavor(Flavor flavor) async {
    try {
      final db = await database;
      return await db.update(
        'flavors',
        flavor.toMap(),
        where: 'id = ?',
        whereArgs: [flavor.id],
      );
    } catch (e) {
      throw Exception('Failed to update flavor: $e');
    }
  }

  /// Deletes a flavor
  Future<int> deleteFlavor(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'flavors',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete flavor: $e');
    }
  }

  // LOG OPERATIONS

  /// Creates a new log entry
  Future<Log> createLog(Log log) async {
    try {
      final db = await database;
      final id = await db.insert('logs', log.toMap());
      return log.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to create log entry: $e');
    }
  }

  /// Gets all logs
  Future<List<Log>> getAllLogs() async {
    final db = await database;
    final maps = await db.query('logs', orderBy: 'timestamp DESC');
    return maps.map((map) => Log.fromMap(map)).toList();
  }

  /// Gets logs for a specific date
  Future<List<LogWithFlavor>> getLogsByDate(String date) async {
    try {
      final db = await database;
      final maps = await db.rawQuery('''
        SELECT l.*, f.name, f.ml, f.caffeine_mg, f.is_active, f.image_path
        FROM logs l
        INNER JOIN flavors f ON l.flavor_id = f.id
        WHERE DATE(l.timestamp) = DATE(?)
        ORDER BY l.timestamp DESC
      ''', [date]);

      return maps.map((map) {
        return LogWithFlavor(
          log: Log.fromMap(map),
          flavor: Flavor.fromMap(map),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets all logs with flavor details
  Future<List<LogWithFlavor>> getLogsWithFlavors() async {
    try {
      final db = await database;
      final maps = await db.rawQuery('''
        SELECT l.*, f.name, f.ml, f.caffeine_mg, f.is_active, f.image_path
        FROM logs l
        INNER JOIN flavors f ON l.flavor_id = f.id
        ORDER BY l.timestamp DESC
      ''');

      return maps.map((map) {
        return LogWithFlavor(
          log: Log.fromMap(map),
          flavor: Flavor.fromMap(map),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets today's caffeine total
  Future<int> getTodaysCaffeineTotal() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT SUM(f.caffeine_mg) as total
        FROM logs l
        INNER JOIN flavors f ON l.flavor_id = f.id
        WHERE DATE(l.timestamp) = DATE('now', 'localtime')
      ''');

      final total = result.first['total'];
      return total != null ? (total as num).toInt() : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Gets today's drink count
  Future<int> getTodaysDrinkCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM logs
        WHERE DATE(timestamp) = DATE('now', 'localtime')
      ''');

      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Gets today's total spending
  Future<double> getTodaysTotalSpending() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT SUM(price_paid) as total
        FROM logs
        WHERE DATE(timestamp) = DATE('now', 'localtime')
      ''');

      final total = result.first['total'];
      return total != null ? (total as num).toDouble() : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Gets weekly statistics for a specific week
  /// [startDate] should be the start of the week (Monday) in 'yyyy-MM-dd' format
  Future<Map<String, dynamic>> getWeeklyStats({String? startDate}) async {
    final db = await database;
    final weekStart = startDate ?? 
        DateFormat('yyyy-MM-dd').format(
          DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1))
        );
    
    final result = await db.rawQuery('''
      SELECT 
        DATE(l.timestamp) as date,
        COUNT(*) as drinks,
        SUM(f.caffeine_mg) as caffeine,
        SUM(l.price_paid) as spending
      FROM logs l
      INNER JOIN flavors f ON l.flavor_id = f.id
      WHERE DATE(l.timestamp) >= DATE(?)
        AND DATE(l.timestamp) < DATE(?, '+7 days')
      GROUP BY DATE(l.timestamp)
      ORDER BY DATE(l.timestamp) ASC
    ''', [weekStart, weekStart]);

    int totalDrinks = 0;
    int totalCaffeine = 0;
    double totalSpending = 0.0;
    final dailyData = <String, Map<String, dynamic>>{};

    for (var row in result) {
      final date = row['date'] as String;
      final drinks = (row['drinks'] as num?)?.toInt() ?? 0;
      final caffeine = (row['caffeine'] as num?)?.toInt() ?? 0;
      final spending = (row['spending'] as num?)?.toDouble() ?? 0.0;

      totalDrinks += drinks;
      totalCaffeine += caffeine;
      totalSpending += spending;

      dailyData[date] = {
        'drinks': drinks,
        'caffeine': caffeine,
        'spending': spending,
      };
    }

    return {
      'totalDrinks': totalDrinks,
      'totalCaffeine': totalCaffeine,
      'totalSpending': totalSpending,
      'dailyData': dailyData,
    };
  }

  /// Gets monthly statistics for a specific month
  /// [year] and [month] should be the year and month (1-12) to query
  /// Returns weekly aggregated data for the month
  Future<Map<String, dynamic>> getMonthlyStats({int? year, int? month}) async {
    final db = await database;
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;
    final monthStart = '$targetYear-${targetMonth.toString().padLeft(2, '0')}-01';
    
    // Get daily data first
    final dailyResult = await db.rawQuery('''
      SELECT 
        DATE(l.timestamp) as date,
        COUNT(*) as drinks,
        SUM(f.caffeine_mg) as caffeine,
        SUM(l.price_paid) as spending
      FROM logs l
      INNER JOIN flavors f ON l.flavor_id = f.id
      WHERE strftime('%Y-%m', l.timestamp) = strftime('%Y-%m', ?)
      GROUP BY DATE(l.timestamp)
      ORDER BY DATE(l.timestamp) ASC
    ''', [monthStart]);

    // Aggregate by week
    final weeklyData = <String, Map<String, dynamic>>{};
    int totalDrinks = 0;
    int totalCaffeine = 0;
    double totalSpending = 0.0;

    for (var row in dailyResult) {
      final dateStr = row['date'] as String;
      final date = DateTime.parse(dateStr);
      // Get the start of the week (Monday) for this date
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final weekKey = DateFormat('yyyy-MM-dd').format(weekStart);
      
      final drinks = (row['drinks'] as num?)?.toInt() ?? 0;
      final caffeine = (row['caffeine'] as num?)?.toInt() ?? 0;
      final spending = (row['spending'] as num?)?.toDouble() ?? 0.0;

      if (weeklyData.containsKey(weekKey)) {
        weeklyData[weekKey]!['drinks'] = 
            (weeklyData[weekKey]!['drinks'] as int) + drinks;
        weeklyData[weekKey]!['caffeine'] = 
            (weeklyData[weekKey]!['caffeine'] as int) + caffeine;
        weeklyData[weekKey]!['spending'] = 
            (weeklyData[weekKey]!['spending'] as double) + spending;
      } else {
        weeklyData[weekKey] = {
          'drinks': drinks,
          'caffeine': caffeine,
          'spending': spending,
        };
      }

      totalDrinks += drinks;
      totalCaffeine += caffeine;
      totalSpending += spending;
    }

    return {
      'totalDrinks': totalDrinks,
      'totalCaffeine': totalCaffeine,
      'totalSpending': totalSpending,
      'dailyData': weeklyData, // Actually weekly data for monthly view
      'year': targetYear,
      'month': targetMonth,
    };
  }

  /// Gets most drank flavor statistics
  Future<List<Map<String, dynamic>>> getMostDrankFlavors({int limit = 10}) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        f.id,
        f.name,
        f.image_path,
        COUNT(l.id) as drink_count,
        SUM(f.caffeine_mg) as total_caffeine,
        SUM(l.price_paid) as total_spending
      FROM logs l
      INNER JOIN flavors f ON l.flavor_id = f.id
      GROUP BY f.id, f.name, f.image_path
      ORDER BY drink_count DESC
      LIMIT ?
    ''', [limit]);

    return result.map((row) => {
      'id': row['id'] as int,
      'name': row['name'] as String,
      'imagePath': row['image_path'] as String?,
      'drinkCount': (row['drink_count'] as num?)?.toInt() ?? 0,
      'totalCaffeine': (row['total_caffeine'] as num?)?.toInt() ?? 0,
      'totalSpending': (row['total_spending'] as num?)?.toDouble() ?? 0.0,
    }).toList();
  }

  /// Deletes a log entry
  Future<int> deleteLog(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'logs',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete log entry: $e');
    }
  }

  /// Closes the database connection
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // ACHIEVEMENT OPERATIONS

  /// Gets all achievements for a user
  Future<List<Achievement>> getAllAchievements(int userId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'achievements',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'unlocked_at DESC, achievement_type ASC',
      );
      return maps.map((map) => Achievement.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets a specific achievement for a user
  Future<Achievement?> getAchievement(int userId, String achievementType) async {
    try {
      final db = await database;
      final maps = await db.query(
        'achievements',
        where: 'user_id = ? AND achievement_type = ?',
        whereArgs: [userId, achievementType],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return Achievement.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Creates or updates an achievement
  Future<Achievement> upsertAchievement(Achievement achievement) async {
    try {
      final db = await database;
      final existing = await getAchievement(achievement.userId, achievement.achievementType);
      
      if (existing != null) {
        // Update existing achievement
        await db.update(
          'achievements',
          achievement.toMap(),
          where: 'user_id = ? AND achievement_type = ?',
          whereArgs: [achievement.userId, achievement.achievementType],
        );
        return achievement.copyWith(id: existing.id);
      } else {
        // Insert new achievement
        final id = await db.insert('achievements', achievement.toMap());
        return achievement.copyWith(id: id);
      }
    } catch (e) {
      throw Exception('Failed to upsert achievement: $e');
    }
  }

  /// Unlocks an achievement
  Future<void> unlockAchievement(int userId, String achievementType) async {
    try {
      final db = await database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      
      // Try to update existing achievement
      final count = await db.rawUpdate('''
        UPDATE achievements
        SET unlocked_at = ?, progress = 1
        WHERE user_id = ? AND achievement_type = ?
      ''', [now, userId, achievementType]);
      
      // If no rows were updated, insert a new achievement
      if (count == 0) {
        await db.insert('achievements', {
          'user_id': userId,
          'achievement_type': achievementType,
          'unlocked_at': now,
          'progress': 1,
        });
      }
    } catch (e) {
      // If update/insert failed, try insert with ignore
      try {
        final db = await database;
        final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        await db.insert('achievements', {
          'user_id': userId,
          'achievement_type': achievementType,
          'unlocked_at': now,
          'progress': 1,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e2) {
        throw Exception('Failed to unlock achievement: $e2');
      }
    }
  }

  /// Updates achievement progress
  Future<void> updateAchievementProgress(int userId, String achievementType, int progress) async {
    try {
      final db = await database;
      final existing = await getAchievement(userId, achievementType);
      
      if (existing != null) {
        await db.update(
          'achievements',
          {'progress': progress},
          where: 'user_id = ? AND achievement_type = ?',
          whereArgs: [userId, achievementType],
        );
      } else {
        await db.insert('achievements', {
          'user_id': userId,
          'achievement_type': achievementType,
          'progress': progress,
          'unlocked_at': null,
        });
      }
    } catch (e) {
      throw Exception('Failed to update achievement progress: $e');
    }
  }

  // STREAK OPERATIONS

  /// Gets the streak for a user
  Future<Streak?> getCurrentStreak(int userId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'streaks',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return Streak.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Updates the streak when a drink is logged
  Future<Streak> updateStreak(int userId, String drinkDate) async {
    try {
      final db = await database;
      final streak = await getCurrentStreak(userId);
      
      if (streak == null) {
        // Create new streak
        final newStreak = Streak(
          userId: userId,
          currentStreak: 1,
          longestStreak: 1,
          lastDrinkDate: drinkDate,
        );
        final id = await db.insert('streaks', newStreak.toMap());
        return newStreak.copyWith(id: id);
      }

      final lastDate = streak.lastDrinkDate;
      int newStreak = 1;
      
      if (lastDate != null) {
        final last = DateTime.parse(lastDate);
        final current = DateTime.parse(drinkDate);
        final daysDiff = current.difference(last).inDays;
        
        if (daysDiff == 0) {
          // Same day, don't change streak
          newStreak = streak.currentStreak;
        } else if (daysDiff == 1) {
          // Consecutive day, increment streak
          newStreak = streak.currentStreak + 1;
        } else {
          // Streak broken, reset to 1
          newStreak = 1;
        }
      }

      final longestStreak = newStreak > streak.longestStreak 
          ? newStreak 
          : streak.longestStreak;

      final updatedStreak = streak.copyWith(
        currentStreak: newStreak,
        longestStreak: longestStreak,
        lastDrinkDate: drinkDate,
      );

      await db.update(
        'streaks',
        updatedStreak.toMap(),
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      return updatedStreak;
    } catch (e) {
      throw Exception('Failed to update streak: $e');
    }
  }

  // GOAL OPERATIONS

  /// Gets all goals for a user
  Future<List<Goal>> getAllGoals(int userId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'goals',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'goal_type ASC, period_start DESC',
      );
      return maps.map((map) => Goal.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets a goal for a specific period
  Future<Goal?> getGoal(int userId, String goalType, String periodStart) async {
    try {
      final db = await database;
      final maps = await db.query(
        'goals',
        where: 'user_id = ? AND goal_type = ? AND period_start = ?',
        whereArgs: [userId, goalType, periodStart],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return Goal.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Creates or updates a goal
  Future<Goal> upsertGoal(Goal goal) async {
    try {
      final db = await database;
      final existing = await getGoal(goal.userId, goal.goalType, goal.periodStart);
      
      if (existing != null) {
        // Update existing goal
        await db.update(
          'goals',
          goal.toMap(),
          where: 'user_id = ? AND goal_type = ? AND period_start = ?',
          whereArgs: [goal.userId, goal.goalType, goal.periodStart],
        );
        return goal.copyWith(id: existing.id);
      } else {
        // Insert new goal
        final id = await db.insert('goals', goal.toMap());
        return goal.copyWith(id: id);
      }
    } catch (e) {
      throw Exception('Failed to upsert goal: $e');
    }
  }

  /// Updates goal progress
  Future<void> updateGoalProgress(int userId, String goalType, String periodStart, double value) async {
    try {
      final db = await database;
      await db.rawUpdate('''
        UPDATE goals
        SET current_value = ?
        WHERE user_id = ? AND goal_type = ? AND period_start = ?
      ''', [value, userId, goalType, periodStart]);
    } catch (e) {
      throw Exception('Failed to update goal progress: $e');
    }
  }

  /// Deletes a goal
  Future<int> deleteGoal(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'goals',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  /// Checks and unlocks achievements based on current stats
  Future<List<String>> checkAndUnlockAchievements(int userId) async {
    final unlocked = <String>[];
    
    try {
      final db = await database;
      
      // Get user stats
      final totalDrinks = await db.rawQuery('''
        SELECT COUNT(*) as count FROM logs WHERE user_id = ?
      ''', [userId]);
      final drinkCount = (totalDrinks.first['count'] as int?) ?? 0;

      final totalCaffeine = await db.rawQuery('''
        SELECT SUM(f.caffeine_mg) as total
        FROM logs l
        INNER JOIN flavors f ON l.flavor_id = f.id
        WHERE l.user_id = ?
      ''', [userId]);
      final caffeineTotal = (totalCaffeine.first['total'] as num?)?.toInt() ?? 0;

      final uniqueFlavors = await db.rawQuery('''
        SELECT COUNT(DISTINCT flavor_id) as count
        FROM logs
        WHERE user_id = ?
      ''', [userId]);
      final flavorCount = (uniqueFlavors.first['count'] as int?) ?? 0;

      final streak = await getCurrentStreak(userId);
      final streakDays = streak?.currentStreak ?? 0;

      // Check First Wing
      if (drinkCount >= 1) {
        final achievement = await getAchievement(userId, 'first_wing');
        if (achievement == null || !achievement.isUnlocked) {
          await unlockAchievement(userId, 'first_wing');
          unlocked.add('first_wing');
        }
      }

      // Check Daily Warrior (7-day streak)
      if (streakDays >= 7) {
        final achievement = await getAchievement(userId, 'daily_warrior');
        if (achievement == null || !achievement.isUnlocked) {
          await unlockAchievement(userId, 'daily_warrior');
          unlocked.add('daily_warrior');
        }
      }

      // Check Weekly Champion (30-day streak)
      if (streakDays >= 30) {
        final achievement = await getAchievement(userId, 'weekly_champion');
        if (achievement == null || !achievement.isUnlocked) {
          await unlockAchievement(userId, 'weekly_champion');
          unlocked.add('weekly_champion');
        }
      }

      // Check Caffeine Master
      if (caffeineTotal >= 1000) {
        final achievement = await getAchievement(userId, 'caffeine_master');
        if (achievement == null || !achievement.isUnlocked) {
          await unlockAchievement(userId, 'caffeine_master');
          unlocked.add('caffeine_master');
        }
      }

      // Check Flavor Explorer
      if (flavorCount >= 5) {
        final achievement = await getAchievement(userId, 'flavor_explorer');
        if (achievement == null || !achievement.isUnlocked) {
          await unlockAchievement(userId, 'flavor_explorer');
          unlocked.add('flavor_explorer');
        }
      }

      // Check Red Bull Fanatic
      if (drinkCount >= 100) {
        final achievement = await getAchievement(userId, 'redbull_fanatic');
        if (achievement == null || !achievement.isUnlocked) {
          await unlockAchievement(userId, 'redbull_fanatic');
          unlocked.add('redbull_fanatic');
        }
      }

      // Check Collector
      if (flavorCount >= 12) {
        final achievement = await getAchievement(userId, 'collector');
        if (achievement == null || !achievement.isUnlocked) {
          await unlockAchievement(userId, 'collector');
          unlocked.add('collector');
        }
      }

      // Update progress for in-progress achievements
      await updateAchievementProgress(userId, 'redbull_fanatic', drinkCount);
      await updateAchievementProgress(userId, 'caffeine_master', caffeineTotal);
      await updateAchievementProgress(userId, 'flavor_explorer', flavorCount);
      await updateAchievementProgress(userId, 'collector', flavorCount);
      await updateAchievementProgress(userId, 'daily_warrior', streakDays);
      await updateAchievementProgress(userId, 'weekly_champion', streakDays);

    } catch (e) {
      // Silently fail - achievements are not critical
    }

    return unlocked;
  }
}

