import '../core/utils/helpers.dart';

/// Real-time ticker model received from Binance WebSocket `<symbol>@ticker` stream.
class WsTickerModel {
  const WsTickerModel({
    required this.symbol,
    required this.currentPrice,
    this.priceChange = 0.0,
    this.priceChangePercent = 0.0,
    this.highPrice = 0.0,
    this.lowPrice = 0.0,
    this.volume = 0.0,
    this.eventTime = 0,
  });

  final String symbol;
  final double currentPrice;
  final double priceChange;
  final double priceChangePercent;
  final double highPrice;
  final double lowPrice;
  final double volume;
  final int eventTime;

  factory WsTickerModel.fromJson(Map<String, dynamic> json) {
    return WsTickerModel(
      symbol: json['s'] as String? ?? '',
      currentPrice: Helpers.parseDouble(json['c']),
      priceChange: Helpers.parseDouble(json['p']),
      priceChangePercent: Helpers.parseDouble(json['P']),
      highPrice: Helpers.parseDouble(json['h']),
      lowPrice: Helpers.parseDouble(json['l']),
      volume: Helpers.parseDouble(json['v']),
      eventTime: json['E'] is int
          ? json['E'] as int
          : int.tryParse(json['E']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': symbol,
      'c': currentPrice.toString(),
      'p': priceChange.toString(),
      'P': priceChangePercent.toString(),
      'h': highPrice.toString(),
      'l': lowPrice.toString(),
      'v': volume.toString(),
      'E': eventTime,
    };
  }
}
