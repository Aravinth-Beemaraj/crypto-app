import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/coin_details_provider.dart';
import 'providers/market_provider.dart';
import 'providers/watchlist_provider.dart';
import 'providers/websocket_provider.dart';
import 'repositories/crypto_repository.dart';
import 'screens/splash/splash_screen.dart';
import 'storage/local_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.cryptoRepository,
    this.localStorage,
    this.splashDuration = const Duration(seconds: 2),
  });

  final CryptoRepository? cryptoRepository;
  final LocalStorage? localStorage;
  final Duration splashDuration;

  @override
  Widget build(BuildContext context) {
    final repo = cryptoRepository ?? CryptoRepository();
    final storage = localStorage ?? LocalStorage();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MarketProvider(repository: repo),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchlistProvider(storage: storage),
        ),
        ChangeNotifierProvider(
          create: (_) => CoinDetailsProvider(repository: repo),
        ),
        ChangeNotifierProvider(
          create: (_) => WebSocketProvider(repository: repo),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: SplashScreen(duration: splashDuration),
      ),
    );
  }
}
