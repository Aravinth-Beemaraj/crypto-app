import '../core/utils/helpers.dart';

class KlineModel {
  const KlineModel({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.closeTime,
  });

  final int openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final int closeTime;

  factory KlineModel.fromList(List<dynamic> data) {
    return KlineModel(
      openTime: Helpers.parseInt(data[0]),
      open: Helpers.parseDouble(data[1]),
      high: Helpers.parseDouble(data[2]),
      low: Helpers.parseDouble(data[3]),
      close: Helpers.parseDouble(data[4]),
      volume: Helpers.parseDouble(data[5]),
      closeTime: Helpers.parseInt(data[6]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openTime': openTime,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'closeTime': closeTime,
    };
  }
}
