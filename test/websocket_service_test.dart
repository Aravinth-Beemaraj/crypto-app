import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:crypto_app/core/constants/api_constants.dart';
import 'package:crypto_app/models/ws_ticker_model.dart';
import 'package:crypto_app/services/binance_websocket_service.dart';

class MockWebSocketSink implements WebSocketSink {
  bool isClosed = false;

  @override
  void add(dynamic data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream stream) async {}

  @override
  Future close([int? closeCode, String? closeReason]) async {
    isClosed = true;
  }

  @override
  Future get done => Future.value();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWebSocketChannel implements WebSocketChannel {
  MockWebSocketChannel({StreamController<dynamic>? controller})
      : _controller = controller ?? StreamController<dynamic>();

  final StreamController<dynamic> _controller;
  final MockWebSocketSink _sink = MockWebSocketSink();

  @override
  Stream get stream => _controller.stream;

  @override
  WebSocketSink get sink => _sink;

  @override
  String? get protocol => null;

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  Future<void> get ready => Future.value();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  void emit(dynamic data) => _controller.add(data);
  void emitError(Object error) => _controller.addError(error);
  void closeChannel() => _controller.close();
}

void main() {
  group('BinanceWebSocketService & ApiConstants Tests', () {
    test('1. WebSocket URL is generated correctly', () {
      final url = ApiConstants.tickerStreamUrl('BTCUSDT');
      expect(url, 'wss://stream.binance.com:9443/ws/btcusdt@ticker');
    });

    test('2. BTCUSDT becomes btcusdt in the URL and works for any symbol', () {
      expect(
        ApiConstants.tickerStreamUrl('BTCUSDT'),
        'wss://stream.binance.com:9443/ws/btcusdt@ticker',
      );
      expect(
        ApiConstants.tickerStreamUrl('ethusdt'),
        'wss://stream.binance.com:9443/ws/ethusdt@ticker',
      );
      expect(
        ApiConstants.tickerStreamUrl('SOLUSDT'),
        'wss://stream.binance.com:9443/ws/solusdt@ticker',
      );
    });

    test('3. Valid Binance ticker JSON is parsed correctly', () async {
      late MockWebSocketChannel mockChannel;
      final service = BinanceWebSocketService(
        channelFactory: (uri) {
          mockChannel = MockWebSocketChannel();
          return mockChannel;
        },
      );

      final stream = service.subscribeTicker('BTCUSDT');
      final expectation = expectLater(
        stream,
        emits(predicate<WsTickerModel>((ticker) {
          return ticker.symbol == 'BTCUSDT' &&
              ticker.currentPrice == 84126.72 &&
              ticker.priceChangePercent == 1.35 &&
              ticker.highPrice == 85000.0 &&
              ticker.lowPrice == 83000.0 &&
              ticker.volume == 15000.0;
        })),
      );

      final sampleMessage = jsonEncode({
        'e': '24hrTicker',
        'E': 1672531199000,
        's': 'BTCUSDT',
        'p': '1120.00',
        'P': '1.350',
        'c': '84126.72000000',
        'h': '85000.00000000',
        'l': '83000.00000000',
        'v': '15000.00',
      });

      mockChannel.emit(sampleMessage);
      await expectation;
      service.disconnect();
    });

    test('4. Current price is extracted safely from "c" even as string or num',
        () {
      final json1 = {'s': 'ETHUSDT', 'c': '3425.50', 'P': '2.10'};
      final ticker1 = WsTickerModel.fromJson(json1);
      expect(ticker1.currentPrice, 3425.50);

      final json2 = {'s': 'SOLUSDT', 'c': 180.25, 'P': -0.45};
      final ticker2 = WsTickerModel.fromJson(json2);
      expect(ticker2.currentPrice, 180.25);
    });

    test('5. Invalid JSON is handled safely without crashing the service',
        () async {
      late MockWebSocketChannel mockChannel;
      final service = BinanceWebSocketService(
        channelFactory: (uri) {
          mockChannel = MockWebSocketChannel();
          return mockChannel;
        },
      );

      final received = <WsTickerModel>[];
      final sub = service.subscribeTicker('BTCUSDT').listen(received.add);

      // Malformed json string
      mockChannel.emit('invalid_json_payload');
      // Unexpected json format
      mockChannel.emit(jsonEncode({'unknown': 123}));
      // Valid message
      mockChannel.emit(jsonEncode({
        's': 'BTCUSDT',
        'c': '85000.00',
      }));

      await Future.delayed(const Duration(milliseconds: 50));
      expect(received.length, 2); // 1 from unexpected map, 1 from valid message
      expect(received.last.currentPrice, 85000.0);

      await sub.cancel();
      service.disconnect();
    });

    test('6. WebSocket errors are handled gracefully through the stream',
        () async {
      late MockWebSocketChannel mockChannel;
      final service = BinanceWebSocketService(
        channelFactory: (uri) {
          mockChannel = MockWebSocketChannel();
          return mockChannel;
        },
      );

      final stream = service.subscribeTicker('BTCUSDT');
      final expectation = expectLater(
        stream,
        emitsError(isA<Exception>()),
      );

      mockChannel.emitError(Exception('Network error'));
      await expectation;
      service.disconnect();
    });

    test('7. Disconnect closes channel sink and stream', () async {
      late MockWebSocketChannel mockChannel;
      final service = BinanceWebSocketService(
        channelFactory: (uri) {
          mockChannel = MockWebSocketChannel();
          return mockChannel;
        },
      );

      final stream = service.subscribeTicker('BTCUSDT');
      expect(service.isConnected, isTrue);

      service.disconnect();
      expect(service.isConnected, isFalse);
      expect(mockChannel._sink.isClosed, isTrue);

      // Stream should be closed
      await expectLater(stream, emitsDone);
    });
  });
}
