import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/asset_model.dart';
import '../services/rsi_calculator.dart';

class AssetDetailScreen extends StatelessWidget {
  final AssetModel asset;

  const AssetDetailScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final rsiHistory = _calculateRSIHistory(asset.priceHistory);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          asset.displayName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentStats(),
            const SizedBox(height: 20),
            _buildAlarmLevels(),
            const SizedBox(height: 20),
            if (rsiHistory.isNotEmpty) ...[
              const Text(
                'RSI(14) Geçmişi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildRSIChart(rsiHistory),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: asset.rsiColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(
                'Güncel RSI',
                asset.currentRSI != null
                    ? asset.currentRSI!.toStringAsFixed(2)
                    : '--',
                asset.rsiColor,
              ),
              Container(
                  width: 1, height: 60, color: const Color(0xFF1E3A5F)),
              _statItem(
                'Fiyat',
                asset.currentPrice != null
                    ? asset.currentPrice!.toStringAsFixed(
                        asset.symbol == 'EURUSD' ? 4 : 2)
                    : '--',
                const Color(0xFF64B5F6),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: asset.rsiColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: asset.rsiColor.withOpacity(0.3)),
            ),
            child: Text(
              asset.rsiStatus,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: asset.rsiColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmLevels() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alarm Seviyeleri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('📉 Aşırı Satım',
                        style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _alarmLevel('RSI ≤ 25', '🟡 Dikkat',
                        const Color(0xFFFFEB3B), asset.currentRSI != null && asset.currentRSI! <= 25),
                    _alarmLevel('RSI ≤ 20', '🟠 Uyarı',
                        const Color(0xFFFF9800), asset.currentRSI != null && asset.currentRSI! <= 20),
                    _alarmLevel('RSI ≤ 15', '🔴 Kritik',
                        const Color(0xFFEF5350), asset.currentRSI != null && asset.currentRSI! <= 15),
                  ],
                ),
              ),
              Container(
                  width: 1, height: 100, color: const Color(0xFF1E3A5F)),
              Expanded(
                child: Column(
                  children: [
                    const Text('📈 Aşırı Alım',
                        style: TextStyle(
                            color: Color(0xFFEF5350),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _alarmLevel('RSI ≥ 75', '🟡 Dikkat',
                        const Color(0xFFFFEB3B), asset.currentRSI != null && asset.currentRSI! >= 75),
                    _alarmLevel('RSI ≥ 80', '🟠 Uyarı',
                        const Color(0xFFFF9800), asset.currentRSI != null && asset.currentRSI! >= 80),
                    _alarmLevel('RSI ≥ 85', '🔴 Kritik',
                        const Color(0xFFEF5350), asset.currentRSI != null && asset.currentRSI! >= 85),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alarmLevel(String level, String status, Color color, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isActive
            ? Border.all(color: color.withOpacity(0.5))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(level,
              style: TextStyle(
                  color: isActive ? color : const Color(0xFF9E9E9E),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          Text(status,
              style: TextStyle(
                  color: isActive ? color : const Color(0xFF9E9E9E),
                  fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRSIChart(List<double> rsiHistory) {
    final spots = rsiHistory
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: value == 25 || value == 75
                  ? const Color(0xFF1E3A5F)
                  : Colors.transparent,
              strokeWidth: value == 25 || value == 75 ? 1 : 0,
              dashArray: [5, 5],
            ),
            getDrawingVerticalLine: (_) =>
                const FlLine(color: Colors.transparent),
          ),
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (val, meta) {
                  if ([0, 25, 50, 75, 100].contains(val.toInt())) {
                    return Text(val.toInt().toString(),
                        style: const TextStyle(
                            color: Color(0xFF9E9E9E), fontSize: 10));
                  }
                  return const SizedBox();
                },
              ),
            ),
            bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                  y: 25,
                  color: const Color(0xFF4CAF50).withOpacity(0.5),
                  strokeWidth: 1,
                  dashArray: [5, 5]),
              HorizontalLine(
                  y: 75,
                  color: const Color(0xFFEF5350).withOpacity(0.5),
                  strokeWidth: 1,
                  dashArray: [5, 5]),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF64B5F6),
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF64B5F6).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _calculateRSIHistory(List<double> prices) {
    if (prices.length < 15) return [];
    final result = <double>[];
    for (int i = 14; i < prices.length; i++) {
      final rsi = RSICalculator.calculate(prices.sublist(0, i + 1));
      if (rsi != null) result.add(rsi);
    }
    return result;
  }
}
