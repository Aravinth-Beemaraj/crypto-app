import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

class LocalStorage {
  LocalStorage({SharedPreferences? preferences}) : _prefs = preferences;

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  List<String> getWatchlistSymbols() {
    if (_prefs == null) return const [];
    return _prefs!.getStringList(AppConstants.watchlistKey) ?? const [];
  }

  Future<List<String>> loadWatchlistSymbols() async {
    final prefs = await _instance;
    return prefs.getStringList(AppConstants.watchlistKey) ?? const [];
  }

  Future<bool> saveWatchlistSymbols(List<String> symbols) async {
    final prefs = await _instance;
    return prefs.setStringList(AppConstants.watchlistKey, symbols.toSet().toList());
  }

  Future<bool> addWatchlistSymbol(String symbol) async {
    final current = (await loadWatchlistSymbols()).toSet();
    if (current.add(symbol.toUpperCase())) {
      return saveWatchlistSymbols(current.toList());
    }
    return true;
  }

  Future<bool> removeWatchlistSymbol(String symbol) async {
    final current = (await loadWatchlistSymbols()).toSet();
    if (current.remove(symbol.toUpperCase())) {
      return saveWatchlistSymbols(current.toList());
    }
    return true;
  }

  bool isFavorite(String symbol) {
    final list = getWatchlistSymbols();
    return list.contains(symbol.toUpperCase());
  }

  Future<bool> clearWatchlist() async {
    final prefs = await _instance;
    return prefs.remove(AppConstants.watchlistKey);
  }
}
