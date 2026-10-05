import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_app/repositories/crypto_repository.dart';
import 'package:crypto_app/services/binance_rest_service.dart';
import 'package:crypto_app/storage/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CryptoRepository', () {
    late CryptoRepository repository;
    late LocalStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'watchlist_symbols': ['BTCUSDT'],
      });
      storage = LocalStorage();

      final mockClient = MockClient((request) async {
        if (request.url.path.contains('exchangeInfo')) {
          return http.Response(
            jsonEncode({
              'symbols': [
                {
                  'symbol': 'BTCUSDT',
                  'baseAsset': 'BTC',
                  'quoteAsset': 'USDT',
                  'status': 'TRADING',
                },
                {
                  'symbol': 'ETHBTC',
                  'baseAsset': 'ETH',
                  'quoteAsset': 'BTC',
                  'status': 'TRADING',
                },
              ]
            }),
            200,
          );
        }

        if (request.url.path.contains('ticker/24hr')) {
          return http.Response(
            jsonEncode([
              {
                'symbol': 'BTCUSDT',
                'lastPrice': '84339.01',
                'priceChangePercent': '2.45',
                'highPrice': '85000.00',
                'lowPrice': '82000.00',
                'volume': '15000.00',
                'quoteVolume': '1250000000.00',
              },
            ]),
            200,
          );
        }

        return http.Response('Not Found', 404);
      });

      repository = CryptoRepository(
        restService: BinanceRestService(client: mockClient),
        localStorage: storage,
      );
    });

    test('getMarketCoins filters for USDT and sets isFavorite', () async {
      await storage.init();
      final coins = await repository.getMarketCoins(quoteAsset: 'USDT');

      expect(coins.length, 1);
      final btc = coins.first;
      expect(btc.symbol, 'BTCUSDT');
      expect(btc.price, 84339.01);
      expect(btc.isFavorite, isTrue);
    });
  });
}
