import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_app/core/network/network_exceptions.dart';
import 'package:crypto_app/models/coin_model.dart';
import 'package:crypto_app/models/kline_model.dart';
import 'package:crypto_app/providers/coin_details_provider.dart';
import 'package:crypto_app/repositories/crypto_repository.dart';

class FakeDetailsRepository extends CryptoRepository {
  FakeDetailsRepository({
    this.mockCoin,
    this.mockKlines = const [],
    this.shouldThrow = false,
  });

  final CoinModel? mockCoin;
  final List<KlineModel> mockKlines;
  final bool shouldThrow;

  @override
  Future<CoinModel> getCoinDetails(String symbol) async {
    if (shouldThrow) {
      throw const NetworkException(message: 'Failed to load details');
    }
    return mockCoin ??
        CoinModel(
          symbol: symbol,
          baseAsset: 'BTC',
          quoteAsset: 'USDT',
          price: 84000.0,
        );
  }

  @override
  Future<List<KlineModel>> getKlines(
    String symbol, {
    String interval = '1h',
    int limit = 50,
  }) async {
    if (shouldThrow) {
      throw const NetworkException(message: 'Failed to load klines');
    }
    return mockKlines;
  }
}

void main() {
  final sampleKlines = [
    const KlineModel(
      openTime: 1600000000000,
      open: 83000.0,
      high: 84500.0,
      low: 82500.0,
      close: 84000.0,
      volume: 1200.0,
      closeTime: 1600003600000,
    ),
  ];

  group('CoinDetailsProvider', () {
    test('successful coin details and chart data loading', () async {
      final provider = CoinDetailsProvider(
        repository: FakeDetailsRepository(mockKlines: sampleKlines),
      );

      await provider.loadCoinDetails('BTCUSDT');

      expect(provider.symbol, 'BTCUSDT');
      expect(provider.coin, isNotNull);
      expect(provider.coin!.symbol, 'BTCUSDT');
      expect(provider.klines.length, 1);
      expect(provider.currentPrice, 84000.0);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('error state on details fetch failure', () async {
      final provider = CoinDetailsProvider(
        repository: FakeDetailsRepository(shouldThrow: true),
      );

      await provider.loadCoinDetails('BTCUSDT');

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, 'Failed to load details');
      expect(provider.coin, isNull);
    });

    test('timeframe change triggers chart reload', () async {
      final provider = CoinDetailsProvider(
        repository: FakeDetailsRepository(mockKlines: sampleKlines),
      );

      await provider.loadCoinDetails('BTCUSDT');
      expect(provider.selectedTimeframe, '1h');

      await provider.setTimeframe('4h');

      expect(provider.selectedTimeframe, '4h');
      expect(provider.klines.length, 1);
      expect(provider.isChartLoading, isFalse);
      expect(provider.chartErrorMessage, isNull);
    });

    test('updateLivePrice updates currentPrice and coin price', () async {
      final provider = CoinDetailsProvider(
        repository: FakeDetailsRepository(mockKlines: sampleKlines),
      );

      await provider.loadCoinDetails('BTCUSDT');
      expect(provider.currentPrice, 84000.0);

      provider.updateLivePrice(84550.0);
      expect(provider.currentPrice, 84550.0);
      expect(provider.coin!.price, 84550.0);
    });
  });
}
