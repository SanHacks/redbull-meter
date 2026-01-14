/// Application-wide constants
class AppConstants {
  // Colors
  static const int redBullRed = 0xFFFF0000;
  static const int redBullYellow = 0xFFFFCC00;
  static const int darkBackground = 0xFF1E1E1E;
  static const int lightBackground = 0xFF0F0F0F;
  
  // Database
  static const String databaseName = 'redbull_meter.db';
  static const int databaseVersion = 4;
  static const String defaultUsername = 'default_user';
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormat = 'HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'EEEE, MMM dd, yyyy';
  
  // Limits
  static const int dailyDrinkLimit = 10;
  static const int maxFlavorNameLength = 100;
  static const double minPrice = 0.0;
  static const double maxPrice = 10000.0;
  
  // Default values (Red Bull standard: 250ml, 80mg caffeine)
  static const int defaultMl = 250;
  static const int defaultCaffeineMg = 80;
  
  // UI
  static const double cardBorderRadius = 20.0;
  static const double smallBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  
  // Private constructor to prevent instantiation
  AppConstants._();
}
