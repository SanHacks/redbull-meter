import 'flavor.dart';
import 'log.dart';

/// Combined model for displaying log entries with their associated flavor details
class LogWithFlavor {
  final Log log;
  final Flavor flavor;

  /// Constructor for LogWithFlavor model
  LogWithFlavor({
    required this.log,
    required this.flavor,
  });
}

