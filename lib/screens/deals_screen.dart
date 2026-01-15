import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen for finding Red Bull deals and savings
class DealsScreen extends StatelessWidget {
  const DealsScreen({super.key});

  /// Opens sharpsavings.online with Red Bull search
  Future<void> _openSharpSavings(BuildContext context) async {
    try {
      final url = Uri.parse('https://sharpsavings.online/search?q=Red+Bull');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open sharpsavings.online'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deals & Savings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.local_offer,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Find Red Bull Deals',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search for the best Red Bull prices and deals',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Main Search Button
            ElevatedButton(
              onPressed: () => _openSharpSavings(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Search SharpSavings.online',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
              const SizedBox(height: 24),

              // Info Cards
              _buildInfoCard(
                context,
                icon: Icons.savings,
                title: 'Save Money',
                description:
                    'Find the best prices on Red Bull energy drinks and save on your favorite flavors.',
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                icon: Icons.local_drink,
                title: 'All Flavors',
                description:
                    'Search for deals on all Red Bull flavors including Original, Sugarfree, Zero, and Limited Editions.',
                color: const Color(0xFFFFCC00),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                icon: Icons.update,
                title: 'Updated Daily',
                description:
                    'SharpSavings.online updates deals regularly so you always find the latest offers.',
                color: Colors.blue,
              ),
              const SizedBox(height: 24),

              // Additional Search Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tips for Finding Deals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTipItem(
                        'Check multiple retailers',
                        Icons.store,
                      ),
                      _buildTipItem(
                        'Look for bulk purchase discounts',
                        Icons.shopping_cart,
                      ),
                      _buildTipItem(
                        'Subscribe to deal alerts',
                        Icons.notifications,
                      ),
                      _buildTipItem(
                        'Compare prices across stores',
                        Icons.compare_arrows,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
