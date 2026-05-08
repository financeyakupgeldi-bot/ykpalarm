class RSICalculator {
  /// RSI(14) hesaplama - Wilder's Smoothing Method
  static double? calculate(List<double> prices, {int period = 14}) {
    if (prices.length < period + 1) return null;

    List<double> gains = [];
    List<double> losses = [];

    for (int i = 1; i < prices.length; i++) {
      double change = prices[i] - prices[i - 1];
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? change.abs() : 0);
    }

    // İlk ortalama
    double avgGain = gains.sublist(0, period).reduce((a, b) => a + b) / period;
    double avgLoss = losses.sublist(0, period).reduce((a, b) => a + b) / period;

    // Wilder's smoothing
    for (int i = period; i < gains.length; i++) {
      avgGain = (avgGain * (period - 1) + gains[i]) / period;
      avgLoss = (avgLoss * (period - 1) + losses[i]) / period;
    }

    if (avgLoss == 0) return 100.0;

    double rs = avgGain / avgLoss;
    double rsi = 100 - (100 / (1 + rs));

    return double.parse(rsi.toStringAsFixed(2));
  }

  /// Hangi alarm seviyesi tetiklendi?
  static String? checkAlarmLevel(double rsi) {
    if (rsi <= 15) return 'OVERSOLD_15';
    if (rsi <= 20) return 'OVERSOLD_20';
    if (rsi <= 25) return 'OVERSOLD_25';
    if (rsi >= 85) return 'OVERBOUGHT_85';
    if (rsi >= 80) return 'OVERBOUGHT_80';
    if (rsi >= 75) return 'OVERBOUGHT_75';
    return null;
  }

  static String alarmLevelMessage(String level, String assetName, double rsi) {
    switch (level) {
      case 'OVERSOLD_15':
        return '$assetName RSI KRİTİK DÜŞÜK! RSI: ${rsi.toStringAsFixed(1)} (≤15) - Güçlü alım sinyali!';
      case 'OVERSOLD_20':
        return '$assetName RSI çok düşük! RSI: ${rsi.toStringAsFixed(1)} (≤20) - Aşırı satım bölgesi';
      case 'OVERSOLD_25':
        return '$assetName RSI düşük! RSI: ${rsi.toStringAsFixed(1)} (≤25) - Satım bölgesine girdi';
      case 'OVERBOUGHT_85':
        return '$assetName RSI KRİTİK YÜKSEK! RSI: ${rsi.toStringAsFixed(1)} (≥85) - Güçlü satış sinyali!';
      case 'OVERBOUGHT_80':
        return '$assetName RSI çok yüksek! RSI: ${rsi.toStringAsFixed(1)} (≥80) - Aşırı alım bölgesi';
      case 'OVERBOUGHT_75':
        return '$assetName RSI yüksek! RSI: ${rsi.toStringAsFixed(1)} (≥75) - Alım bölgesine girdi';
      default:
        return '$assetName RSI: ${rsi.toStringAsFixed(1)}';
    }
  }
}
