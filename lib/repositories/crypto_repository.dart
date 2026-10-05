import 'package:flutter/foundation.dart';

import '../models/coin_model.dart';
import '../models/coin_symbol_info.dart';
import '../models/kline_model.dart';
import '../models/ws_ticker_model.dart';
import '../services/binance_rest_service.dart';
import '../services/binance_websocket_service.dart';
import '../storage/local_storage.dart';

class CryptoRepository {
  CryptoRepository({
    BinanceRestService? restService,
    BinanceWebSocketService? wsService,
    this.localStorage,
  })  : _restService = restService ?? BinanceRestService(),
        _wsService = wsService ?? BinanceWebSocketService();

  final BinanceRestService _restService;
  final BinanceWebSocketService _wsService;
  final LocalStorage? localStorage;

  BinanceWebSocketService get wsService => _wsService;

  List<CoinSymbolInfo>? _cachedSymbols;

  Future<List<CoinSymbolInfo>> getSymbols() async {
    if (_cachedSymbols != null && _cachedSymbols!.isNotEmpty) {
      return _cachedSymbols!;
    }
    _cachedSymbols = await _restService.fetchExchangeInfo();
    return _cachedSymbols!;
  }

  Future<List<CoinModel>> getMarketCoins({String quoteAsset = 'USDT'}) async {
    final allSymbols = await getSymbols();

    final targetSymbols = allSymbols.where((s) {
      return s.quoteAsset.toUpperCase() == quoteAsset.toUpperCase() &&
          s.status.toUpperCase() == 'TRADING';
    }).toList();

    final tickers = await _restService.fetch24hrTickers();
    final tickerMap = {for (final t in tickers) t.symbol: t};

    final favorites = localStorage?.getWatchlistSymbols().toSet() ?? {};

    final coins = <CoinModel>[];
    for (final info in targetSymbols) {
      final ticker = tickerMap[info.symbol];
      coins.add(
        CoinModel.fromSymbolAndTicker(
          symbolInfo: info,
          ticker: ticker,
          isFavorite: favorites.contains(info.symbol),
        ),
      );
    }

    coins.sort((a, b) => b.quoteVolume.compareTo(a.quoteVolume));
    debugPrint('[MARKET] symbols received=${allSymbols.length}');
    debugPrint('[MARKET] tickers received=${tickers.length}');
    debugPrint('[MARKET] coins displayed=${coins.length}');
    debugPrint('[MARKET] batch ticker requests=1');
    debugPrint('[MARKET] per-coin ticker requests=0');
    return coins;
  }

  Future<CoinModel> getCoinDetails(String symbol) async {
    final ticker = await _restService.fetch24hrTicker(symbol);
    final isFav = localStorage?.isFavorite(symbol) ?? false;

    String baseAsset = symbol;
    String quoteAsset = 'USDT';
    if (symbol.toUpperCase().endsWith('USDT')) {
      baseAsset = symbol.substring(0, symbol.length - 4);
      quoteAsset = 'USDT';
    }

    return CoinModel(
      symbol: symbol,
      baseAsset: baseAsset,
      quoteAsset: quoteAsset,
      price: ticker.lastPrice,
      priceChangePercent: ticker.priceChangePercent,
      high24h: ticker.highPrice,
      low24h: ticker.lowPrice,
      volume: ticker.volume,
      quoteVolume: ticker.quoteVolume,
      isFavorite: isFav,
    );
  }

  Future<List<KlineModel>> getKlines(
    String symbol, {
    String interval = '1h',
    int limit = 50,
  }) {
    return _restService.fetchKlines(
      symbol,
      interval: interval,
      limit: limit,
    );
  }

  Future<double> getLatestPrice(String symbol) {
    return _restService.fetchTickerPrice(symbol);
  }

  Stream<WsTickerModel> subscribeTicker(String symbol) {
    return _wsService.subscribeTicker(symbol);
  }

  void unsubscribeTicker() {
    _wsService.disconnect();
  }

  void dispose() {
    _wsService.dispose();
    _restService.dispose();
  }
}
