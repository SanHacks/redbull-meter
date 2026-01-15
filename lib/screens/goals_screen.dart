import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/goal.dart';
import '../models/user.dart';
import '../utils/currency_helper.dart';

/// Screen for setting and tracking daily/weekly goals
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Goal> _goals = [];
  User? _user;
  bool _isLoading = true;
  String _selectedPeriod = 'daily'; // 'daily' or 'weekly'

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  /// Loads all goals for the user
  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);

    try {
      _user = await _db.getDefaultUser();
      if (_user != null) {
        final allGoals = await _db.getAllGoals(_user!.id!);
        final now = DateTime.now();
        final today = DateFormat('yyyy-MM-dd').format(now);
        final weekStart = DateFormat('yyyy-MM-dd').format(
          now.subtract(Duration(days: now.weekday - 1)),
        );

        // Filter goals for current period
        setState(() {
          _goals = allGoals
              .where((goal) {
                if (_selectedPeriod == 'daily') {
                  return goal.goalType.startsWith('daily_') &&
                      goal.periodStart == today;
                } else {
                  return goal.goalType.startsWith('weekly_') &&
                      goal.periodStart == weekStart;
                }
              })
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Creates or updates a goal
  Future<void> _createOrUpdateGoal(String goalType, double targetValue) async {
    if (_user == null) return;

    try {
      final now = DateTime.now();
      String periodStart;
      if (goalType.startsWith('daily_')) {
        periodStart = DateFormat('yyyy-MM-dd').format(now);
      } else {
        periodStart = DateFormat('yyyy-MM-dd').format(
          now.subtract(Duration(days: now.weekday - 1)),
        );
      }

      final goal = Goal(
        userId: _user!.id!,
        goalType: goalType,
        targetValue: targetValue,
        currentValue: 0.0,
        periodStart: periodStart,
      );

      await _db.upsertGoal(goal);
      _loadGoals();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shows dialog to set a goal
  Future<void> _showSetGoalDialog(String goalType) async {
    final definition = Goal.getTypeDefinition(goalType);
    if (definition == null) return;

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set ${definition['name']} Goal'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                definition['description'] as String,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target ${definition['unit']}',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target value';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final value = double.parse(controller.text);
                _createOrUpdateGoal(goalType, value);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
                children: [
                  // Period selector
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildPeriodButton('daily', 'Daily'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPeriodButton('weekly', 'Weekly'),
                        ),
                      ],
                    ),
                  ),
                  // Goals list
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadGoals,
                      child: _goals.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No goals set',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap the + button to set a goal',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _goals.length,
                              itemBuilder: (context, index) {
                                final goal = _goals[index];
                                return _buildGoalCard(goal);
                              },
                            ),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGoalTypeSelector(),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'Set Goal',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = period);
        _loadGoals();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF0000)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(definition['icon'] as String),
                    color: isCompleted
                        ? Colors.green[700]
                        : Colors.grey[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        definition['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        definition['description'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$displayValue / $displayTarget ${unit == 'currency' ? '' : unit}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? Colors.green[700]
                        : Colors.black87,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? Colors.green[700]
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGoalTypeSelector() async {
    final goalTypes = _selectedPeriod == 'daily'
        ? ['daily_drinks', 'daily_caffeine', 'daily_spending']
        : ['weekly_drinks', 'weekly_caffeine', 'weekly_spending'];

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Goal Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...goalTypes.map((type) {
              final definition = Goal.getTypeDefinition(type);
              if (definition == null) return const SizedBox.shrink();
              
              return ListTile(
                leading: Icon(_getIconData(definition['icon'] as String)),
                title: Text(definition['name'] as String),
                subtitle: Text(definition['description'] as String),
                onTap: () {
                  Navigator.pop(context);
                  _showSetGoalDialog(type);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_drink':
        return Icons.local_drink;
      case 'bolt':
        return Icons.bolt;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.flag;
    }
  }
}
