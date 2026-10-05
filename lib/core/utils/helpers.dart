import '../network/network_exceptions.dart';

class Helpers {
  Helpers._();

  static double parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static int parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool isPositiveChange(double change) => change >= 0;

  static String getCoinIconUrl(String baseAsset) {
    final asset = baseAsset.toLowerCase();
    return 'https://assets.coincap.io/assets/icons/$asset@2x.png';
  }

  static String getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    }
    if (error is ApiException) {
      return error.message;
    }
    if (error is WebSocketException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
