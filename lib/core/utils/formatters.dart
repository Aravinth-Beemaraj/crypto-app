import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _standardCurrency = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final DateFormat _defaultDateFormat = DateFormat('MMM dd, HH:mm');
  static final DateFormat _timeOnlyFormat = DateFormat('HH:mm');
  static final DateFormat _dateOnlyFormat = DateFormat('MMM dd');

  static String formatCurrency(double? value, {String symbol = '\$'}) {
    if (value == null) return '-';
    if (value == 0) return '${symbol}0.00';

    final isNegative = value < 0;
    final abs = value.abs();

    String formatted;
    if (abs >= 1000) {
      formatted = _standardCurrency.format(abs).replaceAll('\$', '');
    } else if (abs >= 1) {
      formatted = abs.toStringAsFixed(2);
    } else if (abs >= 0.01) {
      formatted = abs.toStringAsFixed(4);
    } else if (abs >= 0.0001) {
      formatted = abs.toStringAsFixed(6);
    } else {
      formatted = abs.toStringAsFixed(8);
    }

    return isNegative ? '-$symbol$formatted' : '$symbol$formatted';
  }

  static String formatCompact(double? value) {
    if (value == null) return '-';
    if (value == 0) return '0.00';

    final isNegative = value < 0;
    final abs = value.abs();

    String formatted;
    if (abs >= 1e12) {
      formatted = '${(abs / 1e12).toStringAsFixed(2)}T';
    } else if (abs >= 1e9) {
      formatted = '${(abs / 1e9).toStringAsFixed(2)}B';
    } else if (abs >= 1e6) {
      formatted = '${(abs / 1e6).toStringAsFixed(2)}M';
    } else if (abs >= 1e3) {
      formatted = '${(abs / 1e3).toStringAsFixed(2)}K';
    } else {
      formatted = abs.toStringAsFixed(2);
    }

    return isNegative ? '-$formatted' : formatted;
  }

  static String formatPercentage(double? value, {bool includeSign = true}) {
    if (value == null) return '0.00%';
    final sign = includeSign && value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  static String formatVolume(double? value, {String prefix = ''}) {
    if (value == null) return '-';
    final compact = formatCompact(value);
    return prefix.isEmpty ? compact : '$prefix$compact';
  }

  static String formatDateTime(DateTime? dateTime, {String? pattern}) {
    if (dateTime == null) return '-';
    if (pattern != null) {
      return DateFormat(pattern).format(dateTime);
    }
    return _defaultDateFormat.format(dateTime);
  }

  static String formatTimestamp(int? timestampMillis, {String? pattern}) {
    if (timestampMillis == null || timestampMillis <= 0) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    return formatDateTime(dt, pattern: pattern);
  }

  static String formatChartTimestamp(int timestampMillis, String interval) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    switch (interval.toLowerCase()) {
      case '15m':
      case '1h':
      case '4h':
        return _timeOnlyFormat.format(dt);
      case '1d':
      case '1w':
        return _dateOnlyFormat.format(dt);
      default:
        return _timeOnlyFormat.format(dt);
    }
  }
}
