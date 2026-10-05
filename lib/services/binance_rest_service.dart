import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../core/network/network_exceptions.dart';
import '../core/utils/helpers.dart';
import '../models/coin_symbol_info.dart';
import '../models/kline_model.dart';
import '../models/ticker_model.dart';

class BinanceRestService {
  BinanceRestService({http.Client? client})
      : _client = client ?? http.Client(),
        _isInternalClient = client == null;

  final http.Client _client;
  final bool _isInternalClient;
  static const Duration _timeout = Duration(seconds: 15);

  static int liveStreamTickerPriceCalls = 0;
  static int liveStreamTicker24hrCalls = 0;
  static bool isLiveStreamActive = false;

  Future<List<CoinSymbolInfo>> fetchExchangeInfo() async {
    debugPrint('[REST] REQUEST');
    debugPrint('[REST] method=GET');
    debugPrint('[REST] endpoint=/exchangeInfo');
    debugPrint('[REST] exchangeInfo REQUEST');
    final uri = Uri.parse(ApiConstants.exchangeInfo);
    final data = await _getJson(uri);
    debugPrint('[REST] RESPONSE');
    debugPrint('[REST] endpoint=/exchangeInfo');
    debugPrint('[REST] status=200');
    debugPrint('[REST] success=true');
    debugPrint('[REST] exchangeInfo RESPONSE status=200');

    if (data is Map<String, dynamic> && data['symbols'] is List) {
      final list = data['symbols'] as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(CoinSymbolInfo.fromJson)
          .toList();
    }

    return const [];
  }

  Future<double> fetchTickerPrice(String symbol) async {
    if (isLiveStreamActive) liveStreamTickerPriceCalls++;
    debugPrint('[REST] REQUEST');
    debugPrint('[REST] method=GET');
    debugPrint('[REST] endpoint=/ticker/price');
    final uri = Uri.parse(ApiConstants.tickerPrice).replace(
      queryParameters: {'symbol': symbol.toUpperCase()},
    );
    final data = await _getJson(uri);
    debugPrint('[REST] RESPONSE');
    debugPrint('[REST] endpoint=/ticker/price');
    debugPrint('[REST] status=200');
    debugPrint('[REST] success=true');

    if (data is Map<String, dynamic>) {
      return Helpers.parseDouble(data['price']);
    }

    throw const ApiException(message: 'Invalid price response from Binance');
  }

  Future<TickerModel> fetch24hrTicker(String symbol) async {
    if (isLiveStreamActive) liveStreamTicker24hrCalls++;
    debugPrint('[REST] REQUEST');
    debugPrint('[REST] method=GET');
    debugPrint('[REST] endpoint=/ticker/24hr');
    debugPrint('[REST] ticker/24hr REQUEST symbol=${symbol.toUpperCase()}');
    final uri = Uri.parse(ApiConstants.ticker24hr).replace(
      queryParameters: {'symbol': symbol.toUpperCase()},
    );
    final data = await _getJson(uri);

    if (data is Map<String, dynamic>) {
      final ticker = TickerModel.fromJson(data);
      debugPrint('[REST] RESPONSE');
      debugPrint('[REST] endpoint=/ticker/24hr');
      debugPrint('[REST] status=200');
      debugPrint('[REST] success=true');
      debugPrint('[REST] ticker/24hr RESPONSE status=200');
      debugPrint('[REST] ticker/24hr');
      debugPrint('[REST] symbol=${ticker.symbol}');
      debugPrint('[REST] lastPrice=${ticker.lastPrice.toStringAsFixed(2)}');
      debugPrint('[REST] priceChangePercent=${ticker.priceChangePercent.toStringAsFixed(2)}');
      debugPrint('[REST] highPrice=${ticker.highPrice.toStringAsFixed(2)}');
      debugPrint('[REST] lowPrice=${ticker.lowPrice.toStringAsFixed(2)}');
      return ticker;
    }

    throw const ApiException(message: 'Invalid ticker response from Binance');
  }

  Future<List<TickerModel>> fetch24hrTickers() async {
    debugPrint('[REST] REQUEST');
    debugPrint('[REST] method=GET');
    debugPrint('[REST] endpoint=/ticker/24hr');
    debugPrint('[REST] batch ticker REQUEST');
    final uri = Uri.parse(ApiConstants.ticker24hr);
    final data = await _getJson(uri);
    debugPrint('[REST] RESPONSE');
    debugPrint('[REST] endpoint=/ticker/24hr');
    debugPrint('[REST] status=200');
    debugPrint('[REST] success=true');
    debugPrint('[REST] batch ticker RESPONSE status=200');

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(TickerModel.fromJson)
          .toList();
    }

    return const [];
  }

  Future<List<KlineModel>> fetchKlines(
    String symbol, {
    String interval = '1h',
    int limit = 50,
  }) async {
    debugPrint('[REST] REQUEST');
    debugPrint('[REST] method=GET');
    debugPrint('[REST] endpoint=/klines');
    debugPrint('[REST] klines REQUEST symbol=${symbol.toUpperCase()} interval=$interval limit=$limit');
    final uri = Uri.parse(ApiConstants.klines).replace(
      queryParameters: {
        'symbol': symbol.toUpperCase(),
        'interval': interval,
        'limit': limit.toString(),
      },
    );
    final data = await _getJson(uri);
    debugPrint('[REST] RESPONSE');
    debugPrint('[REST] endpoint=/klines');
    debugPrint('[REST] status=200');
    debugPrint('[REST] success=true');
    debugPrint('[REST] klines RESPONSE status=200');

    if (data is List) {
      return data.whereType<List<dynamic>>().map(KlineModel.fromList).toList();
    }

    return const [];
  }

  Future<dynamic> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      String message = 'API request failed';
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson is Map<String, dynamic> && errorJson['msg'] != null) {
          message = errorJson['msg'].toString();
        }
      } catch (_) {
        message = 'HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'Error'}';
      }

      throw ApiException(message: message, statusCode: response.statusCode);
    } on TimeoutException {
      throw const NetworkException(
        message: 'Request timed out. Please check your internet connection.',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        message: 'Network error: ${e.message}. Please check your connection.',
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(message: 'Failed to parse Binance API response.');
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(message: 'Unable to connect to Binance: $e');
    }
  }

  void dispose() {
    if (_isInternalClient) {
      _client.close();
    }
  }
}
