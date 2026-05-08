class AssetModel {
  final String symbol;
  final String name;
  final String displayName;
  final String yahooSymbol;
  double? currentRSI;
  double? currentPrice;
  List<double> priceHistory;
  DateTime? lastUpdated;
  bool isEnabled;

  AssetModel({
    required this.symbol,
    required this.name,
    required this.displayName,
    required this.yahooSymbol,
    this.currentRSI,
    this.currentPrice,
    this.priceHistory = const [],
    this.lastUpdated,
    this.isEnabled = true,
  });

  static List<AssetModel> defaultAssets() {
    return [
      AssetModel(
        symbol: 'BRENT',
        name: 'Brent Petrol',
        displayName: 'Brent Ham Petrol',
        yahooSymbol: 'BZ=F',
      ),
      AssetModel(
        symbol: 'GOLD',
        name: 'Altın',
        displayName: 'Altın (XAU/USD)',
        yahooSymbol: 'GC=F',
      ),
      AssetModel(
        symbol: 'EURUSD',
        name: 'EUR/USD',
        displayName: 'Euro / Dolar',
        yahooSymbol: 'EURUSD=X',
      ),
    ];
  }

  String get rsiStatus {
    if (currentRSI == null) return 'Yükleniyor...';
    if (currentRSI! <= 15) return '🔴 Aşırı Satım (Kritik)';
    if (currentRSI! <= 20) return '🟠 Aşırı Satım';
    if (currentRSI! <= 25) return '🟡 Satım Bölgesi';
    if (currentRSI! >= 85) return '🔴 Aşırı Alım (Kritik)';
    if (currentRSI! >= 80) return '🟠 Aşırı Alım';
    if (currentRSI! >= 75) return '🟡 Alım Bölgesi';
    return '🟢 Normal';
  }

  Color get rsiColor {
    if (currentRSI == null) return const Color(0xFF9E9E9E);
    if (currentRSI! <= 15 || currentRSI! >= 85) return const Color(0xFFEF5350);
    if (currentRSI! <= 20 || currentRSI! >= 80) return const Color(0xFFFF9800);
    if (currentRSI! <= 25 || currentRSI! >= 75) return const Color(0xFFFFEB3B);
    return const Color(0xFF4CAF50);
  }
}
