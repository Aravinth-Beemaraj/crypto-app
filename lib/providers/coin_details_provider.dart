import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/helpers.dart';
import '../models/coin_model.dart';
import '../models/kline_model.dart';
import '../repositories/crypto_repository.dart';

class CoinDetailsProvider extends ChangeNotifier {
  CoinDetailsProvider({CryptoRepository? repository})
      : _repository = repository ?? CryptoRepository();

  final CryptoRepository _repository;

  String? _symbol;
  CoinModel? _coin;
  List<KlineModel> _klines = const [];
  String _selectedTimeframe = AppConstants.defaultKlineInterval;

  bool _isLoading = false;
  String? _errorMessage;

  bool _isChartLoading = false;
  String? _chartErrorMessage;

  double? _livePrice;

  String? get symbol => _symbol;
  CoinModel? get coin => _coin;
  List<KlineModel> get klines => _klines;
  String get selectedTimeframe => _selectedTimeframe;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isChartLoading => _isChartLoading;
  String? get chartErrorMessage => _chartErrorMessage;

  double get currentPrice => _livePrice ?? _coin?.price ?? 0.0;

  Future<void> loadCoinDetails(String symbol, {CoinModel? initialCoin}) async {
    _symbol = symbol.toUpperCase();
    if (initialCoin != null) {
      _coin = initialCoin;
      _livePrice = initialCoin.price;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final config = _getTimeframeConfig(_selectedTimeframe);
      final detailsFuture = _repository.getCoinDetails(_symbol!);
      final chartFuture = _repository.getKlines(
        _symbol!,
        interval: config.interval,
        limit: config.limit,
      );

      final results = await Future.wait([detailsFuture, chartFuture]);

      _coin = results[0] as CoinModel;
      _klines = results[1] as List<KlineModel>;
      _livePrice = _coin!.price;
      debugPrint('[DETAILS] initialPrice=${_coin!.price.toStringAsFixed(2)}');
      debugPrint('[DETAILS] klineCount=${_klines.length}');
      _errorMessage = null;
    } catch (e) {
      _errorMessage = Helpers.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setTimeframe(String interval) async {
    if (_selectedTimeframe.toUpperCase() == interval.toUpperCase() ||
        _symbol == null) {
      return;
    }

    _selectedTimeframe = interval;
    _isChartLoading = true;
    _chartErrorMessage = null;
    notifyListeners();

    try {
      final config = _getTimeframeConfig(_selectedTimeframe);
      _klines = await _repository.getKlines(
        _symbol!,
        interval: config.interval,
        limit: config.limit,
      );
      _chartErrorMessage = null;
    } catch (e) {
      _chartErrorMessage = Helpers.getErrorMessage(e);
    } finally {
      _isChartLoading = false;
      notifyListeners();
    }
  }

  void updateLivePrice(double price) {
    if (_livePrice == price) return;
    debugPrint('[PROVIDER] CoinDetailsProvider.updateLivePrice(${price.toStringAsFixed(2)})');
    _livePrice = price;
    if (_coin != null) {
      _coin = _coin!.copyWith(price: price);
    }
    debugPrint('[PROVIDER] notifyListeners()');
    notifyListeners();
  }

  void updateFavorite(bool isFavorite) {
    if (_coin == null) return;
    _coin = _coin!.copyWith(isFavorite: isFavorite);
    notifyListeners();
  }

  static ({String interval, int limit}) _getTimeframeConfig(String tf) {
    switch (tf.toUpperCase()) {
      case '1H':
        return (interval: '1m', limit: 60);
      case '4H':
        return (interval: '15m', limit: 16);
      case '1D':
        return (interval: '1h', limit: 24);
      case '7D':
      case '1W':
        return (interval: '4h', limit: 42);
      default:
        return (interval: tf.toLowerCase(), limit: 50);
    }
  }
}
