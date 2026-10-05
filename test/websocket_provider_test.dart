import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:crypto_app/models/coin_model.dart';
import 'package:crypto_app/models/ws_ticker_model.dart';
import 'package:crypto_app/providers/coin_details_provider.dart';
import 'package:crypto_app/providers/websocket_provider.dart';
import 'package:crypto_app/screens/coin_details/widgets/price_section.dart';
import 'package:crypto_app/services/binance_websocket_service.dart';

class FakeWebSocketService extends BinanceWebSocketService {
  StreamController<WsTickerModel> controller =
      StreamController<WsTickerModel>.broadcast();
  int subscribeCount = 0;
  int disconnectCount = 0;

  @override
  Stream<WsTickerModel> subscribeTicker(String symbol) {
    subscribeCount++;
    return controller.stream;
  }

  @override
  void disconnect() {
    disconnectCount++;
  }

  void emitTicker(WsTickerModel ticker) {
    controller.add(ticker);
  }

  void emitError(Object error) {
    controller.addError(error);
  }
}

void main() {
  group('WebSocketProvider & Integration Tests', () {
    late FakeWebSocketService fakeService;
    late WebSocketProvider wsProvider;

    setUp(() {
      fakeService = FakeWebSocketService();
      wsProvider = WebSocketProvider(wsService: fakeService);
    });

    tearDown(() {
      try {
        wsProvider.dispose();
      } catch (_) {}
      fakeService.controller.close();
    });

    test('1. Initial status is disconnected and values are null', () {
      expect(wsProvider.status, WebSocketConnectionStatus.disconnected);
      expect(wsProvider.currentSymbol, isNull);
      expect(wsProvider.livePrice, isNull);
      expect(wsProvider.isConnected, isFalse);
    });

    test('2. Status transitions: disconnected -> connecting -> connected',
        () async {
      final statuses = <WebSocketConnectionStatus>[];
      wsProvider.addListener(() {
        statuses.add(wsProvider.status);
      });

      wsProvider.connect('BTCUSDT');
      expect(wsProvider.status, WebSocketConnectionStatus.connecting);
      expect(wsProvider.currentSymbol, 'BTCUSDT');

      // Emit live ticker and allow microtasks to deliver
      fakeService.emitTicker(
        const WsTickerModel(
          symbol: 'BTCUSDT',
          currentPrice: 84126.72,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(wsProvider.status, WebSocketConnectionStatus.connected);
      expect(wsProvider.isConnected, isTrue);
      expect(wsProvider.livePrice, 84126.72);
      expect(statuses, contains(WebSocketConnectionStatus.connecting));
      expect(statuses, contains(WebSocketConnectionStatus.connected));
    });

    test('3. Live price reaches CoinDetailsProvider', () async {
      final detailsProvider = CoinDetailsProvider();
      const initialCoin = CoinModel(
        symbol: 'BTCUSDT',
        baseAsset: 'BTC',
        quoteAsset: 'USDT',
        price: 80000.0,
      );

      // Load initial coin
      detailsProvider.loadCoinDetails('BTCUSDT', initialCoin: initialCoin);
      expect(detailsProvider.currentPrice, 80000.0);

      // Connect WebSocket with callback to detailsProvider
      wsProvider.connect(
        'BTCUSDT',
        onPriceUpdate: (price) => detailsProvider.updateLivePrice(price),
      );

      // Emit new real-time price and wait for stream delivery
      fakeService.emitTicker(
        const WsTickerModel(
          symbol: 'BTCUSDT',
          currentPrice: 84128.40,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(wsProvider.livePrice, 84128.40);
      expect(detailsProvider.currentPrice, 84128.40);
      expect(detailsProvider.coin?.price, 84128.40);
    });

    testWidgets('4. UI reflects the updated live price and connection status',
        (tester) async {
      const coin = CoinModel(
        symbol: 'BTCUSDT',
        baseAsset: 'BTC',
        quoteAsset: 'USDT',
        price: 84000.0,
        priceChangePercent: 2.5,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WebSocketProvider>.value(value: wsProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PriceSection(
                coin: coin,
                currentPrice: 84000.0,
                connectionStatus: WebSocketConnectionStatus.connected,
              ),
            ),
          ),
        ),
      );

      expect(find.text('\$84,000.00'), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);

      // Re-pump with updated live price
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WebSocketProvider>.value(value: wsProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PriceSection(
                coin: coin,
                currentPrice: 84135.20,
                connectionStatus: WebSocketConnectionStatus.connected,
              ),
            ),
          ),
        ),
      );

      expect(find.text('\$84,135.20'), findsOneWidget);
    });

    test('5. Disconnect resets status and cancels streams', () async {
      wsProvider.connect('BTCUSDT');
      fakeService.emitTicker(
        const WsTickerModel(symbol: 'BTCUSDT', currentPrice: 84000.0),
      );
      await Future<void>.delayed(Duration.zero);
      expect(wsProvider.isConnected, isTrue);

      wsProvider.disconnect();
      expect(wsProvider.status, WebSocketConnectionStatus.disconnected);
      expect(wsProvider.currentSymbol, isNull);
      expect(wsProvider.livePrice, isNull);
      expect(fakeService.disconnectCount, greaterThanOrEqualTo(1));
    });

    test('6. Reconnection does not create duplicate connections', () async {
      wsProvider.connect('BTCUSDT');
      expect(fakeService.subscribeCount, 1);

      fakeService.emitTicker(
        const WsTickerModel(symbol: 'BTCUSDT', currentPrice: 84000.0),
      );
      await Future<void>.delayed(Duration.zero);

      // Calling connect for the same already-connected symbol does not re-subscribe
      wsProvider.connect('BTCUSDT');
      expect(fakeService.subscribeCount, 1);

      // Calling for a different symbol disconnects and subscribes once
      wsProvider.connect('ETHUSDT');
      expect(fakeService.subscribeCount, 2);
    });

    test('7. Provider dispose cleans up completely', () {
      final localProvider = WebSocketProvider(wsService: fakeService);
      localProvider.connect('BTCUSDT');
      expect(fakeService.subscribeCount, 1);

      localProvider.dispose();
      expect(fakeService.disconnectCount, greaterThanOrEqualTo(1));
    });
  });
}
