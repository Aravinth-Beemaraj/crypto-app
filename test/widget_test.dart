import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crypto_app/main.dart';
import 'package:crypto_app/models/coin_model.dart';
import 'package:crypto_app/repositories/crypto_repository.dart';
import 'package:crypto_app/storage/local_storage.dart';

class MockCryptoRepository extends CryptoRepository {
  @override
  Future<List<CoinModel>> getMarketCoins({String quoteAsset = 'USDT'}) async {
    return [
      const CoinModel(
        symbol: 'BTCUSDT',
        baseAsset: 'BTC',
        quoteAsset: 'USDT',
        price: 90000.0,
        priceChangePercent: 2.5,
        volume: 1000000.0,
      ),
    ];
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches smoke test and navigates from splash to market',
      (WidgetTester tester) async {
    final mockRepo = MockCryptoRepository();
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorage(preferences: prefs);

    await tester.pumpWidget(
      MyApp(
        cryptoRepository: mockRepo,
        localStorage: storage,
        splashDuration: const Duration(milliseconds: 200),
      ),
    );

    // 1. Splash screen logo image
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // 2. Advance time past splash duration
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // 3. Reached Market Screen
    expect(find.text('Track prices and market movements'), findsOneWidget);
    expect(find.text('BTC'), findsOneWidget);

    // 4. Navigate to Watchlist via bottom nav bar
    final bottomNavWatchlist = find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Watchlist'),
    );
    await tester.tap(bottomNavWatchlist);
    await tester.pumpAndSettle();

    // 5. Watchlist renders empty state initially
    expect(find.text('Your Watchlist is Empty'), findsOneWidget);
  });
}
