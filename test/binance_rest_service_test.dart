import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:crypto_app/core/network/network_exceptions.dart';
import 'package:crypto_app/services/binance_rest_service.dart';

void main() {
  group('BinanceRestService', () {
    test('fetchExchangeInfo parses symbols successfully', () async {
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
                  'symbol': 'ETHUSDT',
                  'baseAsset': 'ETH',
                  'quoteAsset': 'USDT',
                  'status': 'TRADING',
                },
              ]
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = BinanceRestService(client: mockClient);
      final symbols = await service.fetchExchangeInfo();

      expect(symbols.length, 2);
      expect(symbols.first.symbol, 'BTCUSDT');
      expect(symbols.first.baseAsset, 'BTC');
    });

    test('fetchTickerPrice returns correct double', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'symbol': 'BTCUSDT', 'price': '84339.01'}),
          200,
        );
      });

      final service = BinanceRestService(client: mockClient);
      final price = await service.fetchTickerPrice('BTCUSDT');

      expect(price, 84339.01);
    });

    test('fetch24hrTicker parses ticker successfully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'symbol': 'BTCUSDT',
            'lastPrice': '84339.01',
            'priceChangePercent': '2.45',
            'highPrice': '85000.00',
            'lowPrice': '82000.00',
            'volume': '15000.00',
            'quoteVolume': '1250000000.00',
          }),
          200,
        );
      });

      final service = BinanceRestService(client: mockClient);
      final ticker = await service.fetch24hrTicker('BTCUSDT');

      expect(ticker.symbol, 'BTCUSDT');
      expect(ticker.lastPrice, 84339.01);
      expect(ticker.priceChangePercent, 2.45);
    });

    test('throws ApiException on HTTP error', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'code': -1121, 'msg': 'Invalid symbol.'}),
          400,
        );
      });

      final service = BinanceRestService(client: mockClient);
      expect(
        () => service.fetch24hrTicker('INVALID'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
