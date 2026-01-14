import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for managing currency display throughout the app
class CurrencyHelper {
  static const String _defaultCurrencySymbol = '\$';
  static const String _currencySymbolKey = 'currency_symbol';
  static String _cachedSymbol = _defaultCurrencySymbol;
  static bool _isInitialized = false;

  /// Gets the saved currency symbol
  static Future<String> getCurrencySymbol() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedSymbol = prefs.getString(_currencySymbolKey) ?? _defaultCurrencySymbol;
      _isInitialized = true;
      return _cachedSymbol;
    } catch (e) {
      // Return cached value or default if SharedPreferences fails
      return _cachedSymbol;
    }
  }

  /// Gets the cached currency symbol (synchronous)
  /// Returns default if not initialized yet
  static String getCachedSymbol() {
    return _cachedSymbol;
  }

  /// Formats a price with the selected currency
  static Future<String> formatPrice(double price) async {
    try {
      final symbol = await getCurrencySymbol();
      return '$symbol${price.toStringAsFixed(2)}';
    } catch (e) {
      // Fallback to cached symbol
      return '$_cachedSymbol${price.toStringAsFixed(2)}';
    }
  }

  /// Formats a price with the cached currency (synchronous)
  static String formatPriceCached(double price) {
    if (!_isInitialized) {
      // Try to initialize synchronously (this is a fallback)
      return '$_defaultCurrencySymbol${price.toStringAsFixed(2)}';
    }
    return '$_cachedSymbol${price.toStringAsFixed(2)}';
  }

  /// Initializes the currency cache
  static Future<void> initialize() async {
    await getCurrencySymbol();
  }

  /// Clears the cache (useful for testing or reset)
  static void clearCache() {
    _cachedSymbol = _defaultCurrencySymbol;
    _isInitialized = false;
  }
}

