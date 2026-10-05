import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/constants/api_constants.dart';
import '../models/ws_ticker_model.dart';

typedef WebSocketChannelFactory = WebSocketChannel Function(Uri uri);

/// Binance WebSocket service.
///
/// Responsible ONLY for managing WebSocket connections to Binance.
/// Builds stream URLs, manages sockets, decodes ticker messages,
/// and handles connection teardown.
class BinanceWebSocketService {
  BinanceWebSocketService({this.channelFactory});

  final WebSocketChannelFactory? channelFactory;

  WebSocketChannel? _channel;
  StreamSubscription? _rawSubscription;
  StreamController<WsTickerModel>? _tickerController;
  String? _activeSymbol;

  String? get activeSymbol => _activeSymbol;
  bool get isConnected => _channel != null;

  Stream<WsTickerModel> subscribeTicker(String symbol) {
    disconnect();

    _activeSymbol = symbol.toUpperCase();
    _tickerController = StreamController<WsTickerModel>.broadcast();

    debugPrint('[WS] connect requested');
    debugPrint('[WS] symbol=$_activeSymbol');

    final url = ApiConstants.tickerStreamUrl(symbol);
    debugPrint('[WS] url=$url');
    debugPrint('[WS] state=CONNECTING');

    final uri = Uri.parse(url);

    try {
      final channel = channelFactory != null
          ? channelFactory!(uri)
          : WebSocketChannel.connect(uri);
      _channel = channel;

      _rawSubscription = channel.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data as String);
            if (decoded is Map<String, dynamic>) {
              final ticker = WsTickerModel.fromJson(decoded);
              debugPrint('[WS] MESSAGE');
              debugPrint('[WS] symbol=${ticker.symbol}');
              debugPrint('[WS] event=24hrTicker');
              debugPrint('[WS] currentPrice(c)=${ticker.currentPrice.toStringAsFixed(2)}');
              debugPrint('[WS] ticker received | symbol=${ticker.symbol} | c=${ticker.currentPrice.toStringAsFixed(2)}');
              debugPrint('[WS] symbol=${ticker.symbol} | c=${ticker.currentPrice.toStringAsFixed(2)}');
              if (_tickerController != null && !_tickerController!.isClosed) {
                _tickerController!.add(ticker);
              }
            }
          } catch (_) {
            // Safely ignore unparseable messages
          }
        },
        onError: (error) {
          debugPrint('[WS] state=ERROR');
          debugPrint('[WS] error=$error');
          if (_tickerController != null && !_tickerController!.isClosed) {
            _tickerController!.addError(error);
          }
        },
        onDone: () {
          if (_tickerController != null && !_tickerController!.isClosed) {
            _tickerController!.close();
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[WS] state=ERROR');
      debugPrint('[WS] error=$e');
      if (_tickerController != null && !_tickerController!.isClosed) {
        _tickerController!.addError(e);
      }
    }

    return _tickerController!.stream;
  }

  void disconnect() {
    debugPrint('[WS] subscription cancelled');
    _activeSymbol = null;
    _rawSubscription?.cancel();
    _rawSubscription = null;
    try {
      _channel?.sink.close();
      debugPrint('[WS] channel closed');
    } catch (_) {}
    _channel = null;
    debugPrint('[WS] state=DISCONNECTED');
    if (_tickerController != null && !_tickerController!.isClosed) {
      _tickerController!.close();
    }
    _tickerController = null;
  }

  void dispose() {
    disconnect();
  }
}
