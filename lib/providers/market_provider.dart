import 'package:flutter/foundation.dart';

import '../core/utils/helpers.dart';
import '../models/coin_model.dart';
import '../repositories/crypto_repository.dart';

enum MarketStatus { initial, loading, success, error, empty }

enum MarketSortOption {
  volumeDesc,
  priceAsc,
  priceDesc,
  changeAsc,
  changeDesc,
  defaultSort,
}

class MarketProvider extends ChangeNotifier {
  MarketProvider({CryptoRepository? repository})
      : _repository = repository ?? CryptoRepository();

  final CryptoRepository _repository;

  MarketStatus _status = MarketStatus.initial;
  List<CoinModel> _allCoins = const [];
  List<CoinModel> _displayedCoins = const [];

  String _searchQuery = '';
  String _selectedQuoteAsset = 'USDT';
  MarketSortOption _sortOption = MarketSortOption.volumeDesc;
  bool _favoritesOnly = false;
  String? _errorMessage;

  MarketStatus get status => _status;
  bool get isLoading => _status == MarketStatus.loading;
  bool get isSuccess => _status == MarketStatus.success;
  bool get isError => _status == MarketStatus.error;
  bool get isEmpty => _status == MarketStatus.empty;

  List<CoinModel> get coins => _displayedCoins;
  List<CoinModel> get allCoins => _allCoins;
  String get searchQuery => _searchQuery;
  String get selectedQuoteAsset => _selectedQuoteAsset;
  MarketSortOption get sortOption => _sortOption;
  bool get favoritesOnly => _favoritesOnly;
  String? get errorMessage => _errorMessage;

  Future<void> loadMarketData({bool isRefresh = false}) async {
    if (!isRefresh) {
      _status = MarketStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final coins = await _repository.getMarketCoins(
        quoteAsset: _selectedQuoteAsset,
      );

      _allCoins = coins;
      _errorMessage = null;

      if (_allCoins.isEmpty) {
        _status = MarketStatus.empty;
        _displayedCoins = const [];
      } else {
        _status = MarketStatus.success;
        _applyLocalFilterAndSort();
      }
    } catch (e) {
      _errorMessage = Helpers.getErrorMessage(e);
      _status = MarketStatus.error;
    }

    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyLocalFilterAndSort();
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    _applyLocalFilterAndSort();
    notifyListeners();
  }

  void setSort(MarketSortOption option) {
    if (_sortOption == option) return;
    _sortOption = option;
    _applyLocalFilterAndSort();
    notifyListeners();
  }

  void setQuoteAsset(String quoteAsset) {
    if (_selectedQuoteAsset.toUpperCase() == quoteAsset.toUpperCase()) return;
    _selectedQuoteAsset = quoteAsset.toUpperCase();
    loadMarketData();
  }

  void setFavoritesOnly(bool value) {
    if (_favoritesOnly == value) return;
    _favoritesOnly = value;
    _applyLocalFilterAndSort();
    notifyListeners();
  }

  void updateFavoriteStatus(String symbol, bool isFavorite) {
    final sym = symbol.toUpperCase();
    _allCoins = _allCoins.map((coin) {
      if (coin.symbol.toUpperCase() == sym) {
        return coin.copyWith(isFavorite: isFavorite);
      }
      return coin;
    }).toList();

    _displayedCoins = _displayedCoins.map((coin) {
      if (coin.symbol.toUpperCase() == sym) {
        return coin.copyWith(isFavorite: isFavorite);
      }
      return coin;
    }).toList();

    notifyListeners();
  }

  void _applyLocalFilterAndSort() {
    var result = List<CoinModel>.from(_allCoins);

    if (_favoritesOnly) {
      result = result.where((c) => c.isFavorite).toList();
    }

    final trimmedQuery = _searchQuery.trim().toUpperCase();
    if (trimmedQuery.isNotEmpty) {
      result = result.where((c) {
        return c.symbol.toUpperCase().contains(trimmedQuery) ||
            c.baseAsset.toUpperCase().contains(trimmedQuery);
      }).toList();
    }

    switch (_sortOption) {
      case MarketSortOption.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
      case MarketSortOption.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
      case MarketSortOption.changeAsc:
        result.sort(
          (a, b) => a.priceChangePercent.compareTo(b.priceChangePercent),
        );
      case MarketSortOption.changeDesc:
        result.sort(
          (a, b) => b.priceChangePercent.compareTo(a.priceChangePercent),
        );
      case MarketSortOption.volumeDesc:
        result.sort((a, b) => b.quoteVolume.compareTo(a.quoteVolume));
      case MarketSortOption.defaultSort:
        break;
    }

    _displayedCoins = result;

    if (_allCoins.isNotEmpty && _displayedCoins.isEmpty) {
      _status = MarketStatus.empty;
    } else if (_allCoins.isNotEmpty) {
      _status = MarketStatus.success;
    }
  }
}
