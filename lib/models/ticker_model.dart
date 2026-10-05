import '../core/utils/helpers.dart';

class TickerModel {
  const TickerModel({
    required this.symbol,
    this.priceChange = 0.0,
    this.priceChangePercent = 0.0,
    this.weightedAvgPrice = 0.0,
    this.lastPrice = 0.0,
    this.openPrice = 0.0,
    this.highPrice = 0.0,
    this.lowPrice = 0.0,
    this.volume = 0.0,
    this.quoteVolume = 0.0,
  });

  final String symbol;
  final double priceChange;
  final double priceChangePercent;
  final double weightedAvgPrice;
  final double lastPrice;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double volume;
  final double quoteVolume;

  factory TickerModel.fromJson(Map<String, dynamic> json) {
    return TickerModel(
      symbol: json['symbol'] as String? ?? '',
      priceChange: Helpers.parseDouble(json['priceChange']),
      priceChangePercent: Helpers.parseDouble(json['priceChangePercent']),
      weightedAvgPrice: Helpers.parseDouble(json['weightedAvgPrice']),
      lastPrice: Helpers.parseDouble(json['lastPrice']),
      openPrice: Helpers.parseDouble(json['openPrice']),
      highPrice: Helpers.parseDouble(json['highPrice']),
      lowPrice: Helpers.parseDouble(json['lowPrice']),
      volume: Helpers.parseDouble(json['volume']),
      quoteVolume: Helpers.parseDouble(json['quoteVolume']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'priceChange': priceChange,
      'priceChangePercent': priceChangePercent,
      'weightedAvgPrice': weightedAvgPrice,
      'lastPrice': lastPrice,
      'openPrice': openPrice,
      'highPrice': highPrice,
      'lowPrice': lowPrice,
      'volume': volume,
      'quoteVolume': quoteVolume,
    };
  }
}
