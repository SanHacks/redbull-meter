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

  @override
  String toString() {
    return 'LogWithFlavor(log: $log, flavor: $flavor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogWithFlavor && other.log == log && other.flavor == flavor;
  }

  @override
  int get hashCode {
    return Object.hash(log, flavor);
  }
}

