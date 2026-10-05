import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crypto_app/core/network/network_exceptions.dart';
import 'package:crypto_app/core/theme/app_theme.dart';
import 'package:crypto_app/models/coin_model.dart';
import 'package:crypto_app/models/kline_model.dart';
import 'package:crypto_app/providers/coin_details_provider.dart';
import 'package:crypto_app/providers/watchlist_provider.dart';
import 'package:crypto_app/repositories/crypto_repository.dart';
import 'package:crypto_app/screens/coin_details/coin_details_screen.dart';
import 'package:crypto_app/screens/coin_details/widgets/coin_chart.dart';
import 'package:crypto_app/screens/coin_details/widgets/coin_header.dart';
import 'package:crypto_app/screens/coin_details/widgets/market_stats_grid.dart';
import 'package:crypto_app/screens/coin_details/widgets/price_section.dart';
import 'package:crypto_app/screens/coin_details/widgets/timeframe_selector.dart';
import 'package:crypto_app/storage/local_storage.dart';
import 'package:crypto_app/widgets/error_view.dart';
import 'package:crypto_app/widgets/favorite_button.dart';

class MockDetailsRepo extends CryptoRepository {
  MockDetailsRepo({
    this.coin,
    this.klines = const [],
    this.shouldThrow = false,
    this.completer,
  });

  final CoinModel? coin;
  final List<KlineModel> klines;
  final bool shouldThrow;
  final Completer<CoinModel>? completer;
  int klineCalls = 0;

  @override
  Future<CoinModel> getCoinDetails(String symbol) async {
    if (completer != null) return completer!.future;
    if (shouldThrow) {
      throw const NetworkException(message: 'Failed to fetch coin details');
    }
    return coin ??
        CoinModel(
          symbol: symbol,
          baseAsset: 'BTC',
          quoteAsset: 'USDT',
          price: 84126.72,
          priceChangePercent: 1.35,
          high24h: 85200.0,
          low24h: 82800.0,
          volume: 15200.0,
          quoteVolume: 1280000000.0,
        );
  }

  @override
  Future<List<KlineModel>> getKlines(
    String symbol, {
    String interval = '1h',
    int limit = 50,
  }) async {
    klineCalls++;
    return klines;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleKlines = List.generate(
    10,
    (i) => KlineModel(
      openTime: 1700000000000 + i * 3600000,
      open: 83000.0 + i * 100,
      high: 83500.0 + i * 100,
      low: 82500.0 + i * 100,
      close: 83200.0 + i * 100,
      volume: 500.0,
      closeTime: 1700000000000 + (i + 1) * 3600000,
    ),
  );

  const sampleCoin = CoinModel(
    symbol: 'BTCUSDT',
    baseAsset: 'BTC',
    quoteAsset: 'USDT',
    price: 84126.72,
    priceChangePercent: 1.35,
    high24h: 85200.0,
    low24h: 82800.0,
    volume: 15200.0,
    quoteVolume: 1280000000.0,
  );

  Widget buildDetailsTestWidget({
    required CoinDetailsProvider detailsProvider,
    required WatchlistProvider watchlistProvider,
    ThemeMode themeMode = ThemeMode.dark,
    String symbol = 'BTCUSDT',
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CoinDetailsProvider>.value(value: detailsProvider),
        ChangeNotifierProvider<WatchlistProvider>.value(value: watchlistProvider),
      ],
      child: MaterialApp(
        themeMode: themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: CoinDetailsScreen(symbol: symbol),
      ),
    );
  }

  group('CoinDetailsScreen Tests', () {
    late LocalStorage storage;
    late WatchlistProvider watchlistProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorage();
      watchlistProvider = WatchlistProvider(storage: storage);
    });

    testWidgets('1. Coin Details screen renders', (tester) async {
      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CoinDetailsScreen), findsOneWidget);
      expect(find.byType(CoinHeader), findsOneWidget);
      expect(find.byType(PriceSection), findsOneWidget);
      expect(find.byType(TimeframeSelector), findsOneWidget);
      expect(find.byType(CoinChart), findsOneWidget);
      expect(find.byType(MarketStatsGrid), findsOneWidget);
    });

    testWidgets('2. Correct symbol and pair are displayed', (tester) async {
      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BTC'), findsOneWidget);
      expect(find.text('BTC / USDT'), findsOneWidget);
    });

    testWidgets('3. Current price is displayed', (tester) async {
      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('\$84,126.72'), findsOneWidget);
    });

    testWidgets('4. 24h market statistics are displayed', (tester) async {
      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('24h High'), findsOneWidget);
      expect(find.text('\$85,200.00'), findsOneWidget);
      expect(find.text('24h Low'), findsOneWidget);
      expect(find.text('\$82,800.00'), findsOneWidget);
      expect(find.text('24h Volume'), findsOneWidget);
      expect(find.text('Quote Volume'), findsOneWidget);
    });

    testWidgets('5. Loading state displays indicator', (tester) async {
      final completer = Completer<CoinModel>();
      final repo = MockDetailsRepo(completer: completer, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(sampleCoin);
      await tester.pumpAndSettle();
    });

    testWidgets('6. Error state displays ErrorView with retry', (tester) async {
      final repo = MockDetailsRepo(shouldThrow: true);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Failed to load BTCUSDT'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('7. Chart renders LineChart when data is available', (tester) async {
      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('8. Timeframe selection triggers klines reload', (tester) async {
      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      final initialKlineCalls = repo.klineCalls;

      // Tap 4H timeframe
      await tester.tap(find.text('4H'));
      await tester.pumpAndSettle();

      expect(repo.klineCalls, greaterThan(initialKlineCalls));
      expect(provider.selectedTimeframe, '4H');
    });

    testWidgets('9. Favorite button updates watchlist state', (tester) async {
      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(watchlistProvider.isFavorite('BTCUSDT'), isFalse);

      await tester.tap(find.byType(FavoriteButton));
      await tester.pumpAndSettle();

      expect(watchlistProvider.isFavorite('BTCUSDT'), isTrue);
    });

    testWidgets('10. Light theme renders without error', (tester) async {
      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
          themeMode: ThemeMode.light,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CoinDetailsScreen), findsOneWidget);
    });

    testWidgets('11. Dark theme renders without error', (tester) async {
      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CoinDetailsScreen), findsOneWidget);
    });

    testWidgets('12. Responsive layout renders on small phone screen', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CoinDetailsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('13. Responsive layout renders on tablet screen', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildDetailsTestWidget(
          detailsProvider: provider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CoinDetailsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('14. Back button pops navigator', (tester) async {
      final repo = MockDetailsRepo(coin: sampleCoin, klines: sampleKlines);
      final provider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider<CoinDetailsProvider>.value(
                            value: provider,
                          ),
                          ChangeNotifierProvider<WatchlistProvider>.value(
                            value: watchlistProvider,
                          ),
                        ],
                        child: const CoinDetailsScreen(symbol: 'BTCUSDT'),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CoinDetailsScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(CoinDetailsScreen), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  });
}
