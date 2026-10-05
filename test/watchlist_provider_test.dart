import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_app/providers/watchlist_provider.dart';
import 'package:crypto_app/storage/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WatchlistProvider', () {
    late LocalStorage storage;
    late WatchlistProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'watchlist_symbols': ['BTCUSDT', 'ETHUSDT'],
      });
      storage = LocalStorage();
      provider = WatchlistProvider(storage: storage);
    });

    test('loadFavorites loads symbols into memory', () async {
      await provider.loadFavorites();

      expect(provider.isInitialized, isTrue);
      expect(provider.favoriteSymbols.length, 2);
      expect(provider.isFavorite('BTCUSDT'), isTrue);
      expect(provider.isFavorite('ETHUSDT'), isTrue);
      expect(provider.isFavorite('SOLUSDT'), isFalse);
    });

    test('addFavorite adds uppercase symbol and persists', () async {
      await provider.loadFavorites();

      await provider.addFavorite('solusdt');

      expect(provider.isFavorite('SOLUSDT'), isTrue);
      expect(provider.favoriteSymbols.contains('SOLUSDT'), isTrue);

      final persisted = await storage.loadWatchlistSymbols();
      expect(persisted, contains('SOLUSDT'));
    });

    test('addFavorite prevents duplicates', () async {
      await provider.loadFavorites();

      await provider.addFavorite('BTCUSDT');
      expect(provider.favoriteSymbols.length, 2);
    });

    test('removeFavorite removes symbol and updates storage', () async {
      await provider.loadFavorites();

      await provider.removeFavorite('BTCUSDT');

      expect(provider.isFavorite('BTCUSDT'), isFalse);
      expect(provider.favoriteSymbols.length, 1);

      final persisted = await storage.loadWatchlistSymbols();
      expect(persisted, isNot(contains('BTCUSDT')));
    });

    test('toggleFavorite adds then removes', () async {
      await provider.loadFavorites();

      // Currently not favorite
      expect(provider.isFavorite('ADAUSDT'), isFalse);

      // Toggle ON
      await provider.toggleFavorite('ADAUSDT');
      expect(provider.isFavorite('ADAUSDT'), isTrue);

      // Toggle OFF
      await provider.toggleFavorite('ADAUSDT');
      expect(provider.isFavorite('ADAUSDT'), isFalse);
    });
  });
}
