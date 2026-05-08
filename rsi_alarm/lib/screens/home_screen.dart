import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asset_model.dart';
import '../services/market_data_service.dart';
import '../services/rsi_calculator.dart';
import '../services/notification_service.dart';
import 'asset_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AssetModel> assets = AssetModel.defaultAssets();
  bool isLoading = false;
  DateTime? lastRefresh;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _refreshAll();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (final asset in assets) {
        asset.isEnabled = prefs.getBool('asset_enabled_${asset.symbol}') ?? true;
      }
    });
  }

  Future<void> _refreshAll() async {
    setState(() => isLoading = true);
    for (final asset in assets) {
      await _fetchAssetData(asset);
    }
    setState(() {
      isLoading = false;
      lastRefresh = DateTime.now();
    });
  }

  Future<void> _fetchAssetData(AssetModel asset) async {
    final data = await MarketDataService.fetchAssetData(asset.yahooSymbol);
    if (data == null) return;

    final prices = List<double>.from(data['prices']);
    final rsi = RSICalculator.calculate(prices);

    setState(() {
      asset.priceHistory = prices;
      asset.currentPrice = data['currentPrice'];
      asset.currentRSI = rsi;
      asset.lastUpdated = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        title: const Row(
          children: [
            Icon(Icons.show_chart, color: Color(0xFF64B5F6), size: 28),
            SizedBox(width: 10),
            Text(
              'RSI Alarm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF64B5F6),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _refreshAll,
              icon: const Icon(Icons.refresh, color: Color(0xFF64B5F6)),
              tooltip: 'Yenile',
            ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings, color: Color(0xFF64B5F6)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshAll,
              color: const Color(0xFF64B5F6),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  return _buildAssetCard(assets[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RSI(14) Takip',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lastRefresh != null
                    ? 'Son güncelleme: ${_formatTime(lastRefresh!)}'
                    : 'Yükleniyor...',
                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
              ),
            ],
          ),
          _buildAlarmLegend(),
        ],
      ),
    );
  }

  Widget _buildAlarmLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _legendItem('🔴', '≤15 / ≥85 Kritik'),
        _legendItem('🟠', '≤20 / ≥80 Uyarı'),
        _legendItem('🟡', '≤25 / ≥75 Dikkat'),
      ],
    );
  }

  Widget _legendItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        '$emoji $text',
        style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 10),
      ),
    );
  }

  Widget _buildAssetCard(AssetModel asset) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AssetDetailScreen(asset: asset),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: asset.currentRSI != null
                ? asset.rsiColor.withOpacity(0.4)
                : const Color(0xFF1E3A5F),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      asset.currentPrice != null
                          ? _formatPrice(asset.symbol, asset.currentPrice!)
                          : 'Fiyat yükleniyor...',
                      style: const TextStyle(
                        color: Color(0xFF64B5F6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: asset.rsiColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: asset.rsiColor.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        asset.currentRSI != null
                            ? 'RSI: ${asset.currentRSI!.toStringAsFixed(1)}'
                            : 'RSI: --',
                        style: TextStyle(
                          color: asset.rsiColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      asset.rsiStatus,
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRSIBar(asset),
          ],
        ),
      ),
    );
  }

  Widget _buildRSIBar(AssetModel asset) {
    final rsi = asset.currentRSI ?? 50.0;
    return Column(
      children: [
        Stack(
          children: [
            // Arka plan
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E1A),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Alarm bölgeleri
            Row(
              children: [
                // Aşırı satım bölgesi (0-25)
                Expanded(
                  flex: 25,
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B5E20),
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(4)),
                    ),
                  ),
                ),
                // Normal bölge (25-75)
                const Expanded(
                  flex: 50,
                  child: SizedBox(height: 8),
                ),
                // Aşırı alım bölgesi (75-100)
                Expanded(
                  flex: 25,
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7F0000),
                      borderRadius:
                          BorderRadius.horizontal(right: Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
            // RSI göstergesi
            FractionallySizedBox(
              widthFactor: rsi / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4CAF50),
                      asset.rsiColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 10)),
            const Text('25', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 10)),
            const Text('50', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 10)),
            const Text('75', style: TextStyle(color: Color(0xFFEF5350), fontSize: 10)),
            const Text('100', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 10)),
          ],
        ),
      ],
    );
  }

  String _formatPrice(String symbol, double price) {
    if (symbol == 'EURUSD') {
      return '\$${price.toStringAsFixed(4)}';
    } else if (symbol == 'GOLD') {
      return '\$${price.toStringAsFixed(2)}/oz';
    } else {
      return '\$${price.toStringAsFixed(2)}/bbl';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131929),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SettingsSheet(
        assets: assets,
        onChanged: (asset, enabled) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('asset_enabled_${asset.symbol}', enabled);
          setState(() => asset.isEnabled = enabled);
        },
      ),
    );
  }
}

class _SettingsSheet extends StatefulWidget {
  final List<AssetModel> assets;
  final Function(AssetModel, bool) onChanged;

  const _SettingsSheet({required this.assets, required this.onChanged});

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚙️ Ayarlar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Alarm bildirimleri aktif varlıklar için çalışır.',
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
          ),
          const SizedBox(height: 20),
          ...widget.assets.map((asset) => SwitchListTile(
                title: Text(
                  asset.displayName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  asset.isEnabled ? 'Alarm aktif' : 'Alarm pasif',
                  style: TextStyle(
                    color: asset.isEnabled
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF9E9E9E),
                  ),
                ),
                value: asset.isEnabled,
                onChanged: (val) {
                  setState(() => asset.isEnabled = val);
                  widget.onChanged(asset, val);
                },
                activeColor: const Color(0xFF64B5F6),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '⏰ Arka planda her 15 dakikada bir RSI kontrolü yapılır. Alarm tetiklendiğinde bildirim gönderilir. Aynı seviye için 4 saatte bir tekrar bildirim gönderilir.',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
