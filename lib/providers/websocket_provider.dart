import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/ws_ticker_model.dart';
import '../repositories/crypto_repository.dart';
import '../services/binance_rest_service.dart';
import '../services/binance_websocket_service.dart';

enum WebSocketConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Provider managing WebSocket connections and real-time ticker data.
class WebSocketProvider extends ChangeNotifier {
  WebSocketProvider({
    CryptoRepository? repository,
    BinanceWebSocketService? wsService,
  })  : _repository = repository,
        _wsService =
            wsService ?? repository?.wsService ?? BinanceWebSocketService();

  final CryptoRepository? _repository;
  final BinanceWebSocketService _wsService;

  static int connectionCount = 0;

  WebSocketConnectionStatus _status = WebSocketConnectionStatus.disconnected;
  String? _currentSymbol;
  double? _livePrice;
  WsTickerModel? _latestTicker;
  String? _errorMessage;

  StreamSubscription<WsTickerModel>? _subscription;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  bool _isDisposed = false;

  void Function(double price)? _onPriceUpdate;

  WebSocketConnectionStatus get status => _status;
  String? get currentSymbol => _currentSymbol;
  double? get livePrice => _livePrice;
  WsTickerModel? get latestTicker => _latestTicker;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _status == WebSocketConnectionStatus.connected;
  bool get isConnecting => _status == WebSocketConnectionStatus.connecting;
  bool get isReconnecting => _status == WebSocketConnectionStatus.reconnecting;
  int get reconnectAttempts => _reconnectAttempts;

  void connect(String symbol, {void Function(double price)? onPriceUpdate}) {
    if (_isDisposed) return;

    final sym = symbol.toUpperCase();
    if (_currentSymbol == sym && _status == WebSocketConnectionStatus.connected) {
      if (onPriceUpdate != null) {
        _onPriceUpdate = onPriceUpdate;
        if (_livePrice != null) {
          onPriceUpdate(_livePrice!);
        }
      }
      return;
    }

    connectionCount++;
    if (connectionCount == 1) {
      debugPrint('[WS] connection #1');
    } else {
      debugPrint('[WS] previous connection closed');
      debugPrint('[WS] new connection #$connectionCount');
    }
    BinanceRestService.isLiveStreamActive = true;

    _onPriceUpdate = onPriceUpdate;
    _currentSymbol = sym;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _initiateConnection(sym);
  }

  void _initiateConnection(String symbol) {
    if (_isDisposed || _currentSymbol == null) return;

    _subscription?.cancel();
    _subscription = null;

    _status = _reconnectAttempts > 0
        ? WebSocketConnectionStatus.reconnecting
        : WebSocketConnectionStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      final stream = _repository != null
          ? _repository.subscribeTicker(symbol)
          : _wsService.subscribeTicker(symbol);

      _subscription = stream.listen(
        (ticker) {
          if (_isDisposed) return;
          if (_status != WebSocketConnectionStatus.connected) {
            debugPrint('[WS] state=CONNECTED');
          }
          debugPrint('[PROVIDER] WebSocket live price received');
          debugPrint('[PROVIDER] updateLivePrice=${ticker.currentPrice.toStringAsFixed(2)}');
          debugPrint('[PROVIDER] WebSocketProvider.livePrice=${ticker.currentPrice.toStringAsFixed(2)}');
          _status = WebSocketConnectionStatus.connected;
          _reconnectAttempts = 0;
          _latestTicker = ticker;
          _livePrice = ticker.currentPrice;
          _errorMessage = null;
          notifyListeners();
          _onPriceUpdate?.call(ticker.currentPrice);
        },
        onError: (error) {
          if (_isDisposed) return;
          _status = WebSocketConnectionStatus.error;
          _errorMessage = 'Connection error';
          notifyListeners();
          _scheduleReconnect();
        },
        onDone: () {
          if (_isDisposed) return;
          if (_status != WebSocketConnectionStatus.disconnected &&
              _currentSymbol != null) {
            _scheduleReconnect();
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (_isDisposed) return;
      _status = WebSocketConnectionStatus.error;
      _errorMessage = 'Failed to connect';
      notifyListeners();
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_isDisposed || _currentSymbol == null) return;

    if (_reconnectAttempts >= maxReconnectAttempts) {
      _status = WebSocketConnectionStatus.error;
      _errorMessage = 'Connection lost. Max retries reached.';
      notifyListeners();
      return;
    }

    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: _reconnectAttempts * 2);
    _status = WebSocketConnectionStatus.reconnecting;
    notifyListeners();

    _reconnectTimer = Timer(delay, () {
      if (_isDisposed || _currentSymbol == null) return;
      _initiateConnection(_currentSymbol!);
    });
  }

  void reconnect() {
    if (_isDisposed || _currentSymbol == null) return;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _initiateConnection(_currentSymbol!);
  }

  void disconnect() {
    BinanceRestService.isLiveStreamActive = false;
    debugPrint('[POLLING] ticker/price calls during live stream=${BinanceRestService.liveStreamTickerPriceCalls}');
    debugPrint('[POLLING] ticker/24hr repeated calls during live stream=${BinanceRestService.liveStreamTicker24hrCalls}');
    debugPrint('[POLLING] Timer.periodic price polling=false');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    if (_repository != null) {
      _repository.unsubscribeTicker();
    } else {
      _wsService.disconnect();
    }
    _currentSymbol = null;
    _livePrice = null;
    _latestTicker = null;
    _onPriceUpdate = null;
    _status = WebSocketConnectionStatus.disconnected;
    _errorMessage = null;
    _reconnectAttempts = 0;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    if (_repository != null) {
      _repository.unsubscribeTicker();
    } else {
      _wsService.disconnect();
    }
    super.dispose();
  }
}
