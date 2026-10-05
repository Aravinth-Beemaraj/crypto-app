import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_app/storage/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorage', () {
    late LocalStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'watchlist_symbols': ['BTCUSDT', 'ETHUSDT'],
      });
      storage = LocalStorage();
    });

    test('loadWatchlistSymbols retrieves saved symbols', () async {
      final symbols = await storage.loadWatchlistSymbols();
      expect(symbols, containsAll(['BTCUSDT', 'ETHUSDT']));
    });

    test('addWatchlistSymbol adds new symbol and prevents duplicates', () async {
      await storage.addWatchlistSymbol('solusdt');
      var symbols = await storage.loadWatchlistSymbols();
      expect(symbols, contains('SOLUSDT'));

      // Adding again should not duplicate
      await storage.addWatchlistSymbol('SOLUSDT');
      symbols = await storage.loadWatchlistSymbols();
      expect(symbols.where((s) => s == 'SOLUSDT').length, 1);
    });

    test('removeWatchlistSymbol removes symbol', () async {
      await storage.removeWatchlistSymbol('BTCUSDT');
      final symbols = await storage.loadWatchlistSymbols();
      expect(symbols, isNot(contains('BTCUSDT')));
    });

    test('isFavorite checks membership after init', () async {
      await storage.init();
      expect(storage.isFavorite('BTCUSDT'), isTrue);
      expect(storage.isFavorite('ADAUSDT'), isFalse);
    });

    test('clearWatchlist removes all symbols', () async {
      await storage.clearWatchlist();
      final symbols = await storage.loadWatchlistSymbols();
      expect(symbols, isEmpty);
    });
  });
}
