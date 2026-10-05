import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/watchlist_provider.dart';
import '../market/market_screen.dart';

/// Application splash screen.
///
/// Displays branding while initializing required state, then
/// smoothly navigates to the main Market screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.duration = const Duration(seconds: 2),
  });

  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startStartupFlow();
  }

  Future<void> _startStartupFlow() async {
    try {
      final watchlistProvider = context.read<WatchlistProvider>();
      if (!watchlistProvider.isInitialized) {
        await watchlistProvider.loadFavorites();
      }
    } catch (_) {}

    if (widget.duration > Duration.zero) {
      await Future.delayed(widget.duration);
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const MarketScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    // Responsive logo sizing respecting screen bounds
    final logoWidth = (size.width * 0.68).clamp(200.0, 360.0);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: logoWidth,
                maxHeight: size.height * 0.45,
              ),
              child: Image.asset(
                'assets/images/indiaditss_splash.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

