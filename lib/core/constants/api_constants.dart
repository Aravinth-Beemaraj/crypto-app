class ApiConstants {
  ApiConstants._();

  /// API base URL.
  static const String baseUrl = 'https://data-api.binance.vision/api/v3';

  /// Exchange information endpoint.
  static const String exchangeInfo = '$baseUrl/exchangeInfo';

  /// Ticker price endpoint.
  static const String tickerPrice = '$baseUrl/ticker/price';

  /// Ticker 24hr statistics endpoint.
  static const String ticker24hr = '$baseUrl/ticker/24hr';

  /// Kline / candlestick endpoint.
  static const String klines = '$baseUrl/klines';

  // WebSocket
  static const String wsBaseUrl = 'wss://stream.binance.com:9443/ws';

  static String tickerStreamUrl(String symbol) {
    return '$wsBaseUrl/${symbol.toLowerCase()}@ticker';
  }
}
