import '../core/utils/helpers.dart';
import 'coin_symbol_info.dart';
import 'ticker_model.dart';

class CoinModel {
  const CoinModel({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    this.price = 0.0,
    this.priceChangePercent = 0.0,
    this.high24h = 0.0,
    this.low24h = 0.0,
    this.volume = 0.0,
    this.quoteVolume = 0.0,
    this.marketCap = 0.0,
    this.isFavorite = false,
  });

  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final double price;
  final double priceChangePercent;
  final double high24h;
  final double low24h;
  final double volume;
  final double quoteVolume;
  final double marketCap;
  final bool isFavorite;

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      symbol: json['symbol'] as String? ?? '',
      baseAsset: json['baseAsset'] as String? ?? '',
      quoteAsset: json['quoteAsset'] as String? ?? '',
      price: Helpers.parseDouble(json['price'] ?? json['lastPrice']),
      priceChangePercent: Helpers.parseDouble(json['priceChangePercent']),
      high24h: Helpers.parseDouble(json['highPrice']),
      low24h: Helpers.parseDouble(json['lowPrice']),
      volume: Helpers.parseDouble(json['volume']),
      quoteVolume: Helpers.parseDouble(json['quoteVolume']),
    );
  }

  factory CoinModel.fromSymbolAndTicker({
    required CoinSymbolInfo symbolInfo,
    TickerModel? ticker,
    bool isFavorite = false,
  }) {
    return CoinModel(
      symbol: symbolInfo.symbol,
      baseAsset: symbolInfo.baseAsset,
      quoteAsset: symbolInfo.quoteAsset,
      price: ticker?.lastPrice ?? 0.0,
      priceChangePercent: ticker?.priceChangePercent ?? 0.0,
      high24h: ticker?.highPrice ?? 0.0,
      low24h: ticker?.lowPrice ?? 0.0,
      volume: ticker?.volume ?? 0.0,
      quoteVolume: ticker?.quoteVolume ?? 0.0,
      isFavorite: isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'baseAsset': baseAsset,
      'quoteAsset': quoteAsset,
      'price': price,
      'priceChangePercent': priceChangePercent,
      'highPrice': high24h,
      'lowPrice': low24h,
      'volume': volume,
      'quoteVolume': quoteVolume,
      'isFavorite': isFavorite,
    };
  }

  CoinModel copyWith({
    String? symbol,
    String? baseAsset,
    String? quoteAsset,
    double? price,
    double? priceChangePercent,
    double? high24h,
    double? low24h,
    double? volume,
    double? quoteVolume,
    double? marketCap,
    bool? isFavorite,
  }) {
    return CoinModel(
      symbol: symbol ?? this.symbol,
      baseAsset: baseAsset ?? this.baseAsset,
      quoteAsset: quoteAsset ?? this.quoteAsset,
      price: price ?? this.price,
      priceChangePercent: priceChangePercent ?? this.priceChangePercent,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      volume: volume ?? this.volume,
      quoteVolume: quoteVolume ?? this.quoteVolume,
      marketCap: marketCap ?? this.marketCap,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
