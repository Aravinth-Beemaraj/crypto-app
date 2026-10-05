/// Application-wide constants.
///
/// Contains app name, default configuration values, and other
/// non-API related constants used throughout the application.
class AppConstants {
  AppConstants._();

  /// Application display name.
  static const String appName = 'Crypto App';

  /// Default quote asset for market pairs.
  static const String defaultQuoteAsset = 'USDT';

  /// Default kline interval.
  static const String defaultKlineInterval = '1h';

  /// Available kline intervals for the timeframe selector.
  static const List<String> klineIntervals = [
    '15m',
    '1h',
    '4h',
    '1d',
    '1w',
  ];

  /// SharedPreferences key for the watchlist.
  static const String watchlistKey = 'watchlist_symbols';
}
