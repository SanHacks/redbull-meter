import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/log_with_flavor.dart';
import '../models/streak.dart';
import '../models/achievement.dart';
import '../models/goal.dart';
import '../models/user.dart';
import '../utils/currency_helper.dart';
import '../utils/image_helper.dart';
import '../utils/celebration_helper.dart';
import 'add_drink_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'achievements_screen.dart';
import 'goals_screen.dart';
import 'deals_screen.dart';

/// Home screen displaying today's drink statistics and recent drinks
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  int _caffeineTotal = 0;
  int _drinkCount = 0;
  double _totalSpending = 0.0;
  List<LogWithFlavor> _todaysLogs = [];
  bool _isLoading = true;
  Streak? _streak;
  List<Achievement> _recentAchievements = [];
  List<Goal> _todayGoals = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads today's statistics from the database
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _user = await _db.getDefaultUser();
    if (_user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final caffeine = await _db.getTodaysCaffeineTotal();
    final count = await _db.getTodaysDrinkCount();
    final spending = await _db.getTodaysTotalSpending();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final logs = await _db.getLogsByDate(today);

    // Load gamification data
    final streak = await _db.getCurrentStreak(_user!.id!);
    final allAchievements = await _db.getAllAchievements(_user!.id!);
    final unlockedAchievements = allAchievements
        .where((a) => a.isUnlocked)
        .toList()
      ..sort((a, b) {
        final aDate = a.unlockedAt ?? '';
        final bDate = b.unlockedAt ?? '';
        return bDate.compareTo(aDate);
      });
    
    final allGoals = await _db.getAllGoals(_user!.id!);
    final todayGoals = allGoals
        .where((g) => g.goalType.startsWith('daily_') && g.periodStart == today)
        .toList();

    // Check for new achievements
    final newlyUnlocked = await _db.checkAndUnlockAchievements(_user!.id!);
    
    // Update goals progress
    for (var goal in todayGoals) {
      double currentValue = 0.0;
      if (goal.goalType == 'daily_drinks') {
        currentValue = count.toDouble();
      } else if (goal.goalType == 'daily_caffeine') {
        currentValue = caffeine.toDouble();
      } else if (goal.goalType == 'daily_spending') {
        currentValue = spending;
      }
      
      if (currentValue != goal.currentValue) {
        await _db.updateGoalProgress(
          _user!.id!,
          goal.goalType,
          goal.periodStart,
          currentValue,
        );
        goal = goal.copyWith(currentValue: currentValue);
      }
    }

    setState(() {
      _caffeineTotal = caffeine;
      _drinkCount = count;
      _totalSpending = spending;
      _todaysLogs = logs;
      _streak = streak;
      _recentAchievements = unlockedAchievements.take(3).toList();
      _todayGoals = todayGoals;
      _isLoading = false;
    });

    // Show celebrations for newly unlocked achievements
    if (newlyUnlocked.isNotEmpty && mounted) {
      for (var achievementType in newlyUnlocked) {
        final definition = Achievement.getDefinition(achievementType);
        if (definition != null) {
          await CelebrationHelper.showAchievementUnlocked(
            context,
            achievementName: definition['name'] as String,
            description: definition['description'] as String,
            icon: _getIconData(definition['icon'] as String),
          );
        }
      }
    }

    // Check for streak milestones
    if (streak != null && streak.currentStreak > 0) {
      final milestoneInfo = streak.getMilestoneInfo();
      if (milestoneInfo['isMilestone'] == true && mounted) {
        await CelebrationHelper.showStreakMilestone(
          context,
          streakDays: streak.currentStreak,
        );
      }
    }

    // Check for completed goals
    for (var goal in todayGoals) {
      if (goal.isCompleted && mounted) {
        final definition = Goal.getTypeDefinition(goal.goalType);
        if (definition != null) {
          await CelebrationHelper.showGoalCompleted(
            context,
            goalName: definition['name'] as String,
          );
        }
      }
    }
  }

  /// Navigates to add drink screen and refreshes on return
  Future<void> _navigateToAddDrink() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDrinkScreen()),
    );
    _loadData();
  }

  /// Navigates to history screen and refreshes on return
  Future<void> _navigateToHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
    _loadData();
  }

  /// Navigates to settings screen
  Future<void> _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    // Reload currency and refresh display
    await CurrencyHelper.initialize();
    _loadData();
  }

  /// Navigates to statistics screen
  Future<void> _navigateToStatistics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatisticsScreen()),
    );
  }

  /// Navigates to achievements screen
  Future<void> _navigateToAchievements() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AchievementsScreen()),
    );
    _loadData();
  }

  /// Navigates to goals screen
  Future<void> _navigateToGoals() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoalsScreen()),
    );
    _loadData();
  }

  /// Navigates to deals screen
  Future<void> _navigateToDeals() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DealsScreen()),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'flight_takeoff':
        return Icons.flight_takeoff;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'bolt':
        return Icons.bolt;
      case 'explore':
        return Icons.explore;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'nightlight':
        return Icons.nightlight;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'favorite':
        return Icons.favorite;
      case 'collections':
        return Icons.collections;
      default:
        return Icons.star;
    }
  }

  /// Deletes a log entry with confirmation
  Future<void> _deleteLog(int logId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteLog(logId);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Red Bull Meter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_offer),
            onPressed: _navigateToDeals,
            tooltip: 'Deals',
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: _navigateToAchievements,
            tooltip: 'Achievements',
          ),
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: _navigateToGoals,
            tooltip: 'Goals',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToHistory,
            tooltip: 'History',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _navigateToStatistics,
            tooltip: 'Statistics',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Streak Card
                  if (_streak != null && _streak!.currentStreak > 0)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: _navigateToAchievements,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.local_fire_department,
                                  size: 32,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Wings Streak',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_streak!.currentStreak} Day${_streak!.currentStreak != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (_streak!.longestStreak > _streak!.currentStreak)
                                      Text(
                                        'Best: ${_streak!.longestStreak} days',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Achievements Preview
                  if (_recentAchievements.isNotEmpty)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: _navigateToAchievements,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recent Achievements',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _navigateToAchievements,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'View All',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: _recentAchievements.map((achievement) {
                                  final definition = Achievement.getDefinition(
                                    achievement.achievementType,
                                  );
                                  return Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.amber[50],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            definition != null
                                                ? _getIconData(definition['icon'] as String)
                                                : Icons.star,
                                            color: Colors.amber[700],
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          definition?['name'] ?? '',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Goals Progress
                  if (_todayGoals.isNotEmpty)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: _navigateToGoals,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Today\'s Goals',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _navigateToGoals,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Manage',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ..._todayGoals.map((goal) {
                                final definition = Goal.getTypeDefinition(goal.goalType);
                                if (definition == null) return const SizedBox.shrink();
                                
                                final progress = goal.progressPercentage;
                                final isCompleted = goal.isCompleted;
                                final unit = definition['unit'] as String;
                                final displayValue = unit == 'currency'
                                    ? CurrencyHelper.formatPriceCached(goal.currentValue)
                                    : goal.currentValue.toStringAsFixed(0);
                                final displayTarget = unit == 'currency'
                                    ? CurrencyHelper.formatPriceCached(goal.targetValue)
                                    : goal.targetValue.toStringAsFixed(0);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            definition['name'] as String,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '$displayValue / $displayTarget ${unit == 'currency' ? '' : unit}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isCompleted
                                                  ? Colors.green[700]
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isCompleted
                                                ? Colors.green
                                                : Colors.black,
                                          ),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Today's Stats Card
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Stats",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn(
                                'Drinks',
                                _drinkCount.toString(),
                                Icons.local_drink,
                                Colors.blue,
                              ),
                              _buildStatColumn(
                                'Caffeine',
                                '${_caffeineTotal}mg',
                                Icons.bolt,
                                Colors.amber,
                              ),
                              _buildStatColumn(
                                'Spent',
                                CurrencyHelper.formatPriceCached(_totalSpending),
                                Icons.attach_money,
                                Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                    const SizedBox(height: 16),

                  // Today's Drinks
                  const Text(
                    "Today's Drinks",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_todaysLogs.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.local_drink_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No drinks logged today',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the button below to add your first drink',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _todaysLogs.length,
                      itemBuilder: (context, index) {
                        final logWithFlavor = _todaysLogs[index];
                        return _buildLogCard(logWithFlavor);
                      },
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddDrink,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Add Drink',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// Builds a single statistics column
  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds a card for a single log entry
  Widget _buildLogCard(LogWithFlavor logWithFlavor) {
    final log = logWithFlavor.log;
    final flavor = logWithFlavor.flavor;
    final time = DateFormat('HH:mm').format(DateTime.parse(log.timestamp));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Flavor image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ImageHelper.buildFlavorImage(
                flavor.imagePath,
                60,
                60,
                isActive: true,
                fallbackColor: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flavor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${flavor.ml}ml',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.bolt,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${flavor.caffeineMg}mg',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        CurrencyHelper.formatPriceCached(log.pricePaid),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.grey[600],
                size: 22,
              ),
              onPressed: () => _deleteLog(log.id!),
            ),
          ],
        ),
      ),
    );
  }
}

