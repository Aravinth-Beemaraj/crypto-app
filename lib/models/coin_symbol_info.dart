class CoinSymbolInfo {
  const CoinSymbolInfo({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.status,
  });

  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final String status;

  factory CoinSymbolInfo.fromJson(Map<String, dynamic> json) {
    return CoinSymbolInfo(
      symbol: json['symbol'] as String? ?? '',
      baseAsset: json['baseAsset'] as String? ?? '',
      quoteAsset: json['quoteAsset'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'baseAsset': baseAsset,
      'quoteAsset': quoteAsset,
      'status': status,
    };
  }
}
