import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/achievement.dart';
import '../models/user.dart';

/// Screen displaying all achievements with progress indicators
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Achievement> _achievements = [];
  User? _user;
  String _filter = 'all'; // 'all', 'unlocked', 'locked'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  /// Loads all achievements for the user
  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      _user = await _db.getDefaultUser();
      if (_user != null) {
        final userAchievements = await _db.getAllAchievements(_user!.id!);
        
        // Get all achievement types and merge with user achievements
        final allTypes = Achievement.allTypes;
        final achievementMap = <String, Achievement>{};
        
        // Add user achievements
        for (var achievement in userAchievements) {
          achievementMap[achievement.achievementType] = achievement;
        }
        
        // Add missing achievements as locked
        for (var type in allTypes) {
          if (!achievementMap.containsKey(type)) {
            achievementMap[type] = Achievement(
              userId: _user!.id!,
              achievementType: type,
              progress: 0,
            );
          }
        }
        
        setState(() {
          _achievements = achievementMap.values.toList()
            ..sort((a, b) {
              // Sort: unlocked first, then by type
              if (a.isUnlocked && !b.isUnlocked) return -1;
              if (!a.isUnlocked && b.isUnlocked) return 1;
              return a.achievementType.compareTo(b.achievementType);
            });
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Gets filtered achievements based on current filter
  List<Achievement> get _filteredAchievements {
    switch (_filter) {
      case 'unlocked':
        return _achievements.where((a) => a.isUnlocked).toList();
      case 'locked':
        return _achievements.where((a) => !a.isUnlocked).toList();
      default:
        return _achievements;
    }
  }

  /// Gets achievement progress percentage
  double _getProgressPercentage(Achievement achievement) {
    final definition = Achievement.getDefinition(achievement.achievementType);
    if (definition == null) return 0.0;
    final target = definition['target'] as int;
    if (target <= 0) return 0.0;
    final progress = achievement.progress / target;
    return progress > 1.0 ? 1.0 : progress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
                children: [
                  // Filter buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildFilterButton('all', 'All'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFilterButton('unlocked', 'Unlocked'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFilterButton('locked', 'Locked'),
                        ),
                      ],
                    ),
                  ),
                  // Achievement count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_filteredAchievements.where((a) => a.isUnlocked).length} / ${_filteredAchievements.length} Unlocked',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${(_getProgressPercentage(_filteredAchievements.where((a) => !a.isUnlocked).isNotEmpty ? _filteredAchievements.where((a) => !a.isUnlocked).first : _achievements.first) * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFFFF0000),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Achievements grid
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadAchievements,
                      child: _filteredAchievements.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No achievements found',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: _filteredAchievements.length,
                              itemBuilder: (context, index) {
                                final achievement = _filteredAchievements[index];
                                return _buildAchievementCard(achievement);
                              },
                            ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildFilterButton(String filter, String label) {
    final isSelected = _filter == filter;
    return GestureDetector(
      onTap: () {
        setState(() => _filter = filter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.black
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final definition = Achievement.getDefinition(achievement.achievementType);
    final isUnlocked = achievement.isUnlocked;
    final progress = _getProgressPercentage(achievement);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.amber[50]
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                definition != null
                    ? _getIconData(definition['icon'] as String)
                    : Icons.star,
                size: 32,
                color: isUnlocked
                    ? Colors.amber[700]
                    : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 12),
            // Name
            Text(
              definition?['name'] ?? achievement.achievementType,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? Colors.black : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Description
            Text(
              definition?['description'] ?? '',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Progress bar
            if (!isUnlocked && definition != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.black,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${achievement.progress} / ${definition['target']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            else if (isUnlocked)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Unlocked',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
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
}
