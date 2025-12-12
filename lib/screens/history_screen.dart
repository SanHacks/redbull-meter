import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/log_with_flavor.dart';
import '../utils/currency_helper.dart';

/// Screen displaying drink history and statistics
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<LogWithFlavor> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  /// Loads all logs from the database
  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final logs = await _db.getLogsWithFlavors();
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
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
      _loadLogs();
    }
  }

  /// Groups logs by date
  Map<String, List<LogWithFlavor>> _groupLogsByDate() {
    final grouped = <String, List<LogWithFlavor>>{};
    for (var log in _logs) {
      final date = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(log.log.timestamp));
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(log);
    }
    return grouped;
  }

  /// Calculates statistics for a list of logs
  Map<String, dynamic> _calculateStats(List<LogWithFlavor> logs) {
    int totalDrinks = logs.length;
    int totalCaffeine = 0;
    double totalSpending = 0.0;

    for (var log in logs) {
      totalCaffeine += log.flavor.caffeineMg;
      totalSpending += log.log.pricePaid;
    }

    return {
      'drinks': totalDrinks,
      'caffeine': totalCaffeine,
      'spending': totalSpending,
    };
  }

  @override
  Widget build(BuildContext context) {
    final groupedLogs = _groupLogsByDate();
    final allTimeStats = _calculateStats(_logs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? _buildEmptyView()
              : RefreshIndicator(
                  onRefresh: _loadLogs,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildAllTimeStats(allTimeStats),
                      const SizedBox(height: 24),
                      ...groupedLogs.entries.map((entry) {
                        return _buildDateGroup(entry.key, entry.value);
                      }),
                    ],
                  ),
                ),
    );
  }

  /// Builds the view shown when no logs exist
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No history yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging your drinks to see them here',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the all-time statistics card
  Widget _buildAllTimeStats(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All-Time Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total Drinks',
                stats['drinks'].toString(),
                Icons.local_drink,
                Colors.green,
              ),
              _buildStatItem(
                'Total Caffeine',
                '${stats['caffeine']}mg',
                Icons.bolt,
                Colors.yellow,
              ),
              _buildStatItem(
                'Total Spent',
                CurrencyHelper.formatPriceCached(stats['spending']),
                Icons.account_balance_wallet,
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single stat item
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[400],
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds a group of logs for a specific date
  Widget _buildDateGroup(String date, List<LogWithFlavor> logs) {
    final dateObj = DateTime.parse(date);
    final dateStats = _calculateStats(logs);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == date;
    final isYesterday = DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(const Duration(days: 1))) ==
        date;

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = DateFormat('EEEE, MMM dd, yyyy').format(dateObj);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${dateStats['drinks']} drinks • ${dateStats['caffeine']}mg',
                  style: TextStyle(
                    color: Colors.green[300],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...logs.map((log) => _buildLogCard(log)),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Builds a card for a single log entry
  Widget _buildLogCard(LogWithFlavor logWithFlavor) {
    final log = logWithFlavor.log;
    final flavor = logWithFlavor.flavor;
    final time = DateFormat('HH:mm').format(DateTime.parse(log.timestamp));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Flavor image
            ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: flavor.imagePath != null
                    ? Image.asset(
                        flavor.imagePath!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.green.withOpacity(0.2),
                            child: const Icon(
                              Icons.local_drink,
                              color: Colors.green,
                              size: 32,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.local_drink,
                          color: Colors.green,
                          size: 32,
                        ),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 14,
                        color: Colors.blue[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${flavor.ml}ml',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.bolt,
                        size: 14,
                        color: Colors.yellow[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${flavor.caffeineMg}mg',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 14,
                        color: Colors.green[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        CurrencyHelper.formatPriceCached(log.pricePaid),
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              onPressed: () => _deleteLog(log.id!),
            ),
          ],
        ),
      ),
    );
  }
}

