import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:crypto_app/core/theme/app_theme.dart';
import 'package:crypto_app/models/coin_model.dart';
import 'package:crypto_app/providers/coin_details_provider.dart';
import 'package:crypto_app/providers/market_provider.dart';
import 'package:crypto_app/providers/watchlist_provider.dart';
import 'package:crypto_app/repositories/crypto_repository.dart';
import 'package:crypto_app/screens/coin_details/coin_details_screen.dart';
import 'package:crypto_app/screens/statistics/market_statistics_screen.dart';
import 'package:crypto_app/storage/local_storage.dart';

class MockStatsRepository extends CryptoRepository {
  MockStatsRepository({this.coins = const []});

  final List<CoinModel> coins;

  @override
  Future<List<CoinModel>> getMarketCoins({String quoteAsset = 'USDT'}) async {
    return coins;
  }

  @override
  Future<CoinModel> getCoinDetails(String symbol) async {
    return coins.firstWhere(
      (c) => c.symbol == symbol,
      orElse: () => CoinModel(
        symbol: symbol,
        baseAsset: symbol.replaceAll('USDT', ''),
        quoteAsset: 'USDT',
        price: 85000.0,
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleCoins = [
    const CoinModel(
      symbol: 'BTCUSDT',
      baseAsset: 'BTC',
      quoteAsset: 'USDT',
      price: 85000.0,
      priceChangePercent: 3.5,
      volume: 15000.0,
      quoteVolume: 1275000000.0,
    ),
    const CoinModel(
      symbol: 'ETHUSDT',
      baseAsset: 'ETH',
      quoteAsset: 'USDT',
      price: 3400.0,
      priceChangePercent: -2.0,
      volume: 40000.0,
      quoteVolume: 136000000.0,
    ),
    const CoinModel(
      symbol: 'SOLUSDT',
      baseAsset: 'SOL',
      quoteAsset: 'USDT',
      price: 180.0,
      priceChangePercent: 8.2,
      volume: 500000.0,
      quoteVolume: 90000000.0,
    ),
  ];

  Widget buildTestWidget({
    required MarketProvider marketProvider,
    ThemeMode themeMode = ThemeMode.dark,
    bool isEmbedded = true,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MarketProvider>.value(value: marketProvider),
        ChangeNotifierProvider<WatchlistProvider>(
          create: (_) => WatchlistProvider(storage: LocalStorage()),
        ),
        ChangeNotifierProvider<CoinDetailsProvider>(
          create: (_) => CoinDetailsProvider(),
        ),
      ],
      child: MaterialApp(
        themeMode: themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(
          body: MarketStatisticsScreen(isEmbedded: isEmbedded),
        ),
      ),
    );
  }

  group('MarketStatisticsScreen Tests', () {
    testWidgets('1. Displays key metric cards with calculated Binance data',
        (tester) async {
      final repo = MockStatsRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);
      await marketProvider.loadMarketData();

      await tester.pumpWidget(
        buildTestWidget(marketProvider: marketProvider),
      );
      await tester.pumpAndSettle();

      expect(find.text('Market Statistics'), findsOneWidget);
      expect(find.text('24h Total Volume'), findsOneWidget);
      expect(find.text('Active Markets'), findsOneWidget);
      expect(find.text('3 Pairs'), findsOneWidget);
      expect(find.text('Market Sentiment'), findsOneWidget);
      expect(find.text('24h Avg Change'), findsOneWidget);
    });

    testWidgets('2. Displays Market Breadth with gainers and losers',
        (tester) async {
      final repo = MockStatsRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);
      await marketProvider.loadMarketData();

      await tester.pumpWidget(
        buildTestWidget(marketProvider: marketProvider),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 Gainers'), findsOneWidget);
      expect(find.text('1 Losers'), findsOneWidget);
    });

    testWidgets('3. Leaderboard tab switching works (Gainers, Losers, Volume)',
        (tester) async {
      final repo = MockStatsRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);
      await marketProvider.loadMarketData();

      await tester.pumpWidget(
        buildTestWidget(marketProvider: marketProvider),
      );
      await tester.pumpAndSettle();

      // Initially on Top Gainers: SOL has highest change (+8.2%)
      expect(find.text('SOL'), findsOneWidget);

      // Switch to Top Losers
      await tester.tap(find.text('Top Losers'));
      await tester.pumpAndSettle();

      // ETH has negative change (-2.0%)
      expect(find.text('ETH'), findsOneWidget);

      // Switch to 24h Volume
      await tester.tap(find.text('24h Volume'));
      await tester.pumpAndSettle();

      // BTC has highest volume
      expect(find.text('BTC'), findsOneWidget);
    });

    testWidgets('4. Tapping a leaderboard coin navigates to CoinDetailsScreen',
        (tester) async {
      final repo = MockStatsRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);
      await marketProvider.loadMarketData();

      await tester.pumpWidget(
        buildTestWidget(marketProvider: marketProvider),
      );
      await tester.pumpAndSettle();

      // Tap SOL
      await tester.tap(find.text('SOL'));
      await tester.pumpAndSettle();

      expect(find.byType(CoinDetailsScreen), findsOneWidget);
      expect(find.text('SOL / USDT'), findsOneWidget);
    });

    testWidgets('5. Light and Dark themes render without error',
        (tester) async {
      final repo = MockStatsRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);
      await marketProvider.loadMarketData();

      // Light theme
      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          themeMode: ThemeMode.light,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MarketStatisticsScreen), findsOneWidget);

      // Dark theme
      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MarketStatisticsScreen), findsOneWidget);
    });
  });
}
