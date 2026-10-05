import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_app/core/network/network_exceptions.dart';
import 'package:crypto_app/models/coin_model.dart';
import 'package:crypto_app/providers/market_provider.dart';
import 'package:crypto_app/repositories/crypto_repository.dart';

class FakeCryptoRepository extends CryptoRepository {
  FakeCryptoRepository({
    this.mockCoins = const [],
    this.shouldThrow = false,
  });

  final List<CoinModel> mockCoins;
  final bool shouldThrow;

  @override
  Future<List<CoinModel>> getMarketCoins({String quoteAsset = 'USDT'}) async {
    if (shouldThrow) {
      throw const NetworkException(message: 'Failed to connect');
    }
    return mockCoins;
  }
}

void main() {
  final sampleCoins = [
    const CoinModel(
      symbol: 'BTCUSDT',
      baseAsset: 'BTC',
      quoteAsset: 'USDT',
      price: 84000.0,
      priceChangePercent: 3.5,
      quoteVolume: 1000000.0,
    ),
    const CoinModel(
      symbol: 'ETHUSDT',
      baseAsset: 'ETH',
      quoteAsset: 'USDT',
      price: 3200.0,
      priceChangePercent: -1.2,
      quoteVolume: 500000.0,
    ),
    const CoinModel(
      symbol: 'SOLUSDT',
      baseAsset: 'SOL',
      quoteAsset: 'USDT',
      price: 150.0,
      priceChangePercent: 8.0,
      quoteVolume: 250000.0,
    ),
  ];

  group('MarketProvider', () {
    test('initial state is correct', () {
      final provider = MarketProvider(
        repository: FakeCryptoRepository(mockCoins: sampleCoins),
      );

      expect(provider.status, MarketStatus.initial);
      expect(provider.coins, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.searchQuery, isEmpty);
    });

    test('successful market data loading updates state to success', () async {
      final provider = MarketProvider(
        repository: FakeCryptoRepository(mockCoins: sampleCoins),
      );

      await provider.loadMarketData();

      expect(provider.status, MarketStatus.success);
      expect(provider.coins.length, 3);
      expect(provider.errorMessage, isNull);
    });

    test('error state on repository failure', () async {
      final provider = MarketProvider(
        repository: FakeCryptoRepository(shouldThrow: true),
      );

      await provider.loadMarketData();

      expect(provider.status, MarketStatus.error);
      expect(provider.errorMessage, 'Failed to connect');
      expect(provider.coins, isEmpty);
    });

    test('search filters coins by symbol and baseAsset case-insensitively', () async {
      final provider = MarketProvider(
        repository: FakeCryptoRepository(mockCoins: sampleCoins),
      );
      await provider.loadMarketData();

      provider.search('eth');
      expect(provider.coins.length, 1);
      expect(provider.coins.first.symbol, 'ETHUSDT');

      provider.search('SOL');
      expect(provider.coins.length, 1);
      expect(provider.coins.first.symbol, 'SOLUSDT');
    });

    test('search with no results sets empty state', () async {
      final provider = MarketProvider(
        repository: FakeCryptoRepository(mockCoins: sampleCoins),
      );
      await provider.loadMarketData();

      provider.search('XYZNONEXISTENT');
      expect(provider.coins, isEmpty);
      expect(provider.isEmpty, isTrue);
    });

    test('clearing search restores full coin list', () async {
      final provider = MarketProvider(
        repository: FakeCryptoRepository(mockCoins: sampleCoins),
      );
      await provider.loadMarketData();

      provider.search('BTC');
      expect(provider.coins.length, 1);

      provider.clearSearch();
      expect(provider.coins.length, 3);
      expect(provider.searchQuery, isEmpty);
    });

    test('sorting orders coins properly', () async {
      final provider = MarketProvider(
        repository: FakeCryptoRepository(mockCoins: sampleCoins),
      );
      await provider.loadMarketData();

      // Price ascending
      provider.setSort(MarketSortOption.priceAsc);
      expect(provider.coins.first.symbol, 'SOLUSDT'); // 150.0
      expect(provider.coins.last.symbol, 'BTCUSDT'); // 84000.0

      // Price descending
      provider.setSort(MarketSortOption.priceDesc);
      expect(provider.coins.first.symbol, 'BTCUSDT'); // 84000.0
      expect(provider.coins.last.symbol, 'SOLUSDT'); // 150.0

      // Change descending (top gainers)
      provider.setSort(MarketSortOption.changeDesc);
      expect(provider.coins.first.symbol, 'SOLUSDT'); // +8.0%

      // Change ascending (top losers)
      provider.setSort(MarketSortOption.changeAsc);
      expect(provider.coins.first.symbol, 'ETHUSDT'); // -1.2%
    });

    test('updateFavoriteStatus toggles isFavorite in memory', () async {
      final provider = MarketProvider(
        repository: FakeCryptoRepository(mockCoins: sampleCoins),
      );
      await provider.loadMarketData();

      provider.updateFavoriteStatus('BTCUSDT', true);
      final btc = provider.coins.firstWhere((c) => c.symbol == 'BTCUSDT');
      expect(btc.isFavorite, isTrue);
    });
  });
}
