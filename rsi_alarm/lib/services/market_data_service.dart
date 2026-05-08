import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketDataService {
  static const String _baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart';

  /// Yahoo Finance'den son 30 günlük günlük kapanış fiyatlarını çek
  static Future<List<double>?> fetchDailyPrices(String symbol) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/$symbol?interval=1d&range=60d',
      );

      final response = await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final result = data['chart']['result'];
      if (result == null || result.isEmpty) return null;

      final closes = result[0]['indicators']['quote'][0]['close'] as List;
      final prices = closes
          .where((p) => p != null)
          .map<double>((p) => (p as num).toDouble())
          .toList();

      return prices.length >= 15 ? prices : null;
    } catch (e) {
      return null;
    }
  }

  /// Güncel fiyatı çek
  static Future<double?> fetchCurrentPrice(String symbol) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/$symbol?interval=1d&range=1d',
      );

      final response = await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final result = data['chart']['result'];
      if (result == null || result.isEmpty) return null;

      final meta = result[0]['meta'];
      final price = meta['regularMarketPrice'];
      return price != null ? (price as num).toDouble() : null;
    } catch (e) {
      return null;
    }
  }

  /// Hem fiyatları hem de güncel fiyatı döndür
  static Future<Map<String, dynamic>?> fetchAssetData(String symbol) async {
    final prices = await fetchDailyPrices(symbol);
    if (prices == null) return null;

    return {
      'prices': prices,
      'currentPrice': prices.last,
    };
  }
}
