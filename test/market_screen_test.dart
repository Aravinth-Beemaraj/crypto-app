import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crypto_app/core/network/network_exceptions.dart';
import 'package:crypto_app/core/theme/app_theme.dart';
import 'package:crypto_app/models/coin_model.dart';
import 'package:crypto_app/models/kline_model.dart';
import 'package:crypto_app/providers/coin_details_provider.dart';
import 'package:crypto_app/providers/market_provider.dart';
import 'package:crypto_app/providers/watchlist_provider.dart';
import 'package:crypto_app/repositories/crypto_repository.dart';
import 'package:crypto_app/screens/coin_details/coin_details_screen.dart';
import 'package:crypto_app/screens/market/market_screen.dart';
import 'package:crypto_app/screens/market/widgets/market_header.dart';
import 'package:crypto_app/storage/local_storage.dart';
import 'package:crypto_app/widgets/coin_card.dart';
import 'package:crypto_app/widgets/empty_view.dart';
import 'package:crypto_app/widgets/error_view.dart';
import 'package:crypto_app/widgets/favorite_button.dart';
import 'package:crypto_app/widgets/loading_widgets.dart';

class MockMarketRepository extends CryptoRepository {
  MockMarketRepository({
    this.coins = const [],
    this.shouldThrow = false,
    this.completer,
  });

  final List<CoinModel> coins;
  final bool shouldThrow;
  final Completer<List<CoinModel>>? completer;
  int loadCalls = 0;

  @override
  Future<List<CoinModel>> getMarketCoins({String quoteAsset = 'USDT'}) async {
    loadCalls++;
    if (completer != null) {
      return completer!.future;
    }
    if (shouldThrow) {
      throw const NetworkException(message: 'Network connection failed');
    }
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
        price: 84126.72,
      ),
    );
  }

  @override
  Future<List<KlineModel>> getKlines(
    String symbol, {
    String interval = '1h',
    int limit = 50,
  }) async {
    return const [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleCoins = [
    const CoinModel(
      symbol: 'BTCUSDT',
      baseAsset: 'BTC',
      quoteAsset: 'USDT',
      price: 84126.72,
      priceChangePercent: 1.35,
      volume: 12000.0,
      quoteVolume: 1000000000.0,
    ),
    const CoinModel(
      symbol: 'ETHUSDT',
      baseAsset: 'ETH',
      quoteAsset: 'USDT',
      price: 3450.25,
      priceChangePercent: -2.10,
      volume: 45000.0,
      quoteVolume: 155000000.0,
    ),
  ];

  Widget buildTestWidget({
    required MarketProvider marketProvider,
    required WatchlistProvider watchlistProvider,
    CoinDetailsProvider? coinDetailsProvider,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MarketProvider>.value(value: marketProvider),
        ChangeNotifierProvider<WatchlistProvider>.value(value: watchlistProvider),
        ChangeNotifierProvider<CoinDetailsProvider>(
          create: (_) => coinDetailsProvider ?? CoinDetailsProvider(),
        ),
      ],
      child: MaterialApp(
        themeMode: themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const MarketScreen(),
      ),
    );
  }

  group('MarketScreen UI Tests', () {
    late LocalStorage storage;
    late WatchlistProvider watchlistProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorage();
      watchlistProvider = WatchlistProvider(storage: storage);
    });

    testWidgets('1. Market screen renders header, sort button, and structure', (tester) async {
      final repo = MockMarketRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MarketScreen), findsOneWidget);
      expect(find.text('Crypto Market'), findsOneWidget);
      expect(find.text('Track prices and market movements'), findsOneWidget);
      expect(find.text('Sort'), findsOneWidget);
      expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      // Filter chips removed from market screen
      expect(find.text('All USDT'), findsNothing);
    });

    testWidgets('2. Loading state renders skeleton LoadingWidgets', (tester) async {
      final completer = Completer<List<CoinModel>>();
      final repo = MockMarketRepository(completer: completer);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
        ),
      );
      // Pump one frame to trigger initState post-frame callback
      await tester.pump();

      expect(find.byType(LoadingWidgets), findsOneWidget);

      // Complete to finish gracefully
      completer.complete(sampleCoins);
      await tester.pumpAndSettle();
    });

    testWidgets('3. Coin list renders with provider data', (tester) async {
      final repo = MockMarketRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CoinCard), findsNWidgets(2));
      expect(find.text('BTC'), findsOneWidget);
      expect(find.text('ETH'), findsOneWidget);
      expect(find.text('\$84,126.72'), findsOneWidget);
      expect(find.text('+1.35%'), findsOneWidget);
    });

    testWidgets('4. Search filters coins locally', (tester) async {
      final repo = MockMarketRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'btc');
      await tester.pumpAndSettle();

      expect(find.text('BTC'), findsOneWidget);
      expect(find.text('ETH'), findsNothing);
    });

    testWidgets('5. Empty search result displays EmptyView', (tester) async {
      final repo = MockMarketRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'NONEXISTENT');
      await tester.pumpAndSettle();

      expect(find.byType(EmptyView), findsOneWidget);
      expect(find.text('No coins found'), findsOneWidget);
    });

    testWidgets('6. Error state displays ErrorView', (tester) async {
      final repo = MockMarketRepository(shouldThrow: true);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('7. Retry button triggers reload', (tester) async {
      final repo = MockMarketRepository(shouldThrow: true);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      final initialCalls = repo.loadCalls;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(repo.loadCalls, greaterThan(initialCalls));
    });

    testWidgets('8. Favorite button toggles watchlist state', (tester) async {
      final repo = MockMarketRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(watchlistProvider.isFavorite('BTCUSDT'), isFalse);

      final firstFavBtn = find.byType(FavoriteButton).first;
      await tester.tap(firstFavBtn);
      await tester.pumpAndSettle();

      expect(watchlistProvider.isFavorite('BTCUSDT'), isTrue);
      expect(find.text('BTC added to Watchlist'), findsOneWidget);
    });

    testWidgets('9. Coin card tap navigates to CoinDetailsScreen', (tester) async {
      final repo = MockMarketRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);
      final detailsProvider = CoinDetailsProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
          coinDetailsProvider: detailsProvider,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('BTC'));
      await tester.pumpAndSettle();

      expect(find.byType(CoinDetailsScreen), findsOneWidget);
      expect(find.text('BTC / USDT'), findsOneWidget);
    });

    testWidgets('10. Light theme renders without error', (tester) async {
      final repo = MockMarketRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
          themeMode: ThemeMode.light,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MarketScreen), findsOneWidget);
    });

    testWidgets('11. Dark theme renders without error', (tester) async {
      final repo = MockMarketRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MarketScreen), findsOneWidget);
    });

    testWidgets('12. Tapping Statistics bottom navigation tab displays MarketStatisticsScreen', (tester) async {
      final repo = MockMarketRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      final bottomNavStats = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Statistics'),
      );
      await tester.tap(bottomNavStats);
      await tester.pumpAndSettle();

      expect(find.text('Market Statistics'), findsOneWidget);
      expect(find.text('24h Total Volume'), findsOneWidget);
    });

    testWidgets('13. Tapping Watchlist bottom navigation tab displays WatchlistScreen', (tester) async {
      final repo = MockMarketRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      final bottomNavWatchlist = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Watchlist'),
      );
      await tester.tap(bottomNavWatchlist);
      await tester.pumpAndSettle();

      expect(find.text('Your Watchlist is Empty'), findsOneWidget);
    });

    testWidgets('14. Tapping Sort in AppBar opens MarketSortSheet and selecting option sorts list', (tester) async {
      final repo = MockMarketRepository(coins: sampleCoins);
      final marketProvider = MarketProvider(repository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          marketProvider: marketProvider,
          watchlistProvider: watchlistProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Sort in AppBar
      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      // Verify Sort sheet opened
      expect(find.text('Sort Markets'), findsOneWidget);
      expect(find.text('Price: High to Low'), findsOneWidget);
      expect(find.text('Price: Low to High'), findsOneWidget);
      expect(find.text('Top Gainers (24h Change)'), findsOneWidget);
      expect(find.text('Top Losers (24h Change)'), findsOneWidget);

      // Select Price: Low to High
      await tester.tap(find.text('Price: Low to High'));
      await tester.pumpAndSettle();

      expect(marketProvider.sortOption, MarketSortOption.priceAsc);
    });

    testWidgets('15. MarketHeader responsive layout renders without overflow on small screen', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: MarketHeader(
              title: 'Crypto Market',
              onRefresh: () {},
              onSort: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Crypto Market'), findsOneWidget);
      expect(find.text('Sort'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });
  });
}
