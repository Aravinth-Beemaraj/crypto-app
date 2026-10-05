import 'package:flutter/foundation.dart';

import '../storage/local_storage.dart';

class WatchlistProvider extends ChangeNotifier {
  WatchlistProvider({LocalStorage? storage})
      : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;
  final Set<String> _favoriteSymbols = {};
  bool _isInitialized = false;

  Set<String> get favoriteSymbols => Set.unmodifiable(_favoriteSymbols);
  List<String> get symbolsList => _favoriteSymbols.toList();
  bool get isInitialized => _isInitialized;

  bool isFavorite(String symbol) {
    return _favoriteSymbols.contains(symbol.toUpperCase());
  }

  Future<void> loadFavorites() async {
    final list = await _storage.loadWatchlistSymbols();
    _favoriteSymbols
      ..clear()
      ..addAll(list.map((s) => s.toUpperCase()));
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> addFavorite(String symbol) async {
    final sym = symbol.toUpperCase();
    if (_favoriteSymbols.add(sym)) {
      notifyListeners();
      return _storage.addWatchlistSymbol(sym);
    }
    return true;
  }

  Future<bool> removeFavorite(String symbol) async {
    final sym = symbol.toUpperCase();
    if (_favoriteSymbols.remove(sym)) {
      notifyListeners();
      return _storage.removeWatchlistSymbol(sym);
    }
    return true;
  }

  Future<bool> toggleFavorite(String symbol) async {
    if (isFavorite(symbol)) {
      return removeFavorite(symbol);
    } else {
      return addFavorite(symbol);
    }
  }

  Future<void> clearAll() async {
    _favoriteSymbols.clear();
    notifyListeners();
    await _storage.clearWatchlist();
  }
}
