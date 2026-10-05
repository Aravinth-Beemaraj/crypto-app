import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_app/models/coin_model.dart';
import 'package:crypto_app/models/coin_symbol_info.dart';
import 'package:crypto_app/models/kline_model.dart';
import 'package:crypto_app/models/ticker_model.dart';

void main() {
  group('Models', () {
    test('CoinSymbolInfo parsing', () {
      final json = {
        'symbol': 'BTCUSDT',
        'baseAsset': 'BTC',
        'quoteAsset': 'USDT',
        'status': 'TRADING',
      };
      final model = CoinSymbolInfo.fromJson(json);
      expect(model.symbol, 'BTCUSDT');
      expect(model.baseAsset, 'BTC');
      expect(model.quoteAsset, 'USDT');
      expect(model.status, 'TRADING');
      expect(model.toJson(), json);
    });

    test('TickerModel parsing with string numeric values', () {
      final json = {
        'symbol': 'BTCUSDT',
        'priceChange': '-150.50',
        'priceChangePercent': '-1.25',
        'weightedAvgPrice': '65000.00',
        'lastPrice': '64850.50',
        'openPrice': '65001.00',
        'highPrice': '66000.00',
        'lowPrice': '64000.00',
        'volume': '12345.67',
        'quoteVolume': '800000000.50',
      };
      final ticker = TickerModel.fromJson(json);
      expect(ticker.symbol, 'BTCUSDT');
      expect(ticker.lastPrice, 64850.50);
      expect(ticker.priceChangePercent, -1.25);
      expect(ticker.highPrice, 66000.00);
      expect(ticker.lowPrice, 64000.00);
      expect(ticker.volume, 12345.67);
      expect(ticker.quoteVolume, 800000000.50);
    });

    test('KlineModel parsing from Binance array', () {
      final raw = [
        1499040000000,
        '0.01634790',
        '0.80000000',
        '0.01575800',
        '0.01577100',
        '148976.11427815',
        1499644799999,
      ];
      final kline = KlineModel.fromList(raw);
      expect(kline.openTime, 1490000000000 > 0 ? 1499040000000 : 0);
      expect(kline.open, 0.01634790);
      expect(kline.high, 0.80000000);
      expect(kline.low, 0.01575800);
      expect(kline.close, 0.01577100);
      expect(kline.volume, 148976.11427815);
      expect(kline.closeTime, 1499644799999);
    });

    test('CoinModel.fromSymbolAndTicker combination', () {
      const symbolInfo = CoinSymbolInfo(
        symbol: 'BTCUSDT',
        baseAsset: 'BTC',
        quoteAsset: 'USDT',
        status: 'TRADING',
      );
      const ticker = TickerModel(
        symbol: 'BTCUSDT',
        lastPrice: 85000.0,
        priceChangePercent: 2.5,
        highPrice: 86000.0,
        lowPrice: 83000.0,
        volume: 5000.0,
        quoteVolume: 425000000.0,
      );

      final coin = CoinModel.fromSymbolAndTicker(
        symbolInfo: symbolInfo,
        ticker: ticker,
        isFavorite: true,
      );

      expect(coin.symbol, 'BTCUSDT');
      expect(coin.baseAsset, 'BTC');
      expect(coin.quoteAsset, 'USDT');
      expect(coin.price, 85000.0);
      expect(coin.priceChangePercent, 2.5);
      expect(coin.isFavorite, isTrue);
    });
  });
}
