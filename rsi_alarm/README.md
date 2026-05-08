# 📊 RSI Alarm - Flutter Uygulaması

## Özellikler
- **Takip edilen varlıklar:** Brent Petrol (BZ=F), Altın (GC=F), EUR/USD
- **RSI(14)** hesaplama - Wilder's Smoothing yöntemi
- **Alarm seviyeleri:**
  - 🟡 RSI ≤ 25 / ≥ 75 — Dikkat
  - 🟠 RSI ≤ 20 / ≥ 80 — Uyarı
  - 🔴 RSI ≤ 15 / ≥ 85 — Kritik
- Arka planda **15 dakikada bir** otomatik kontrol
- Aynı seviye için **4 saatte bir** tekrar bildirim (spam önleme)
- RSI geçmişi grafiği
- Varlık bazında alarm açma/kapama

---

## Kurulum

### Gereksinimler
- Flutter SDK 3.0+
- Android Studio veya VS Code
- Android cihaz veya emülatör (API 21+)

### Adımlar

```bash
# 1. Projeyi klonla / indir
cd rsi_alarm

# 2. Bağımlılıkları yükle
flutter pub get

# 3. Android'e kur ve çalıştır
flutter run
```

### APK Oluşturma
```bash
flutter build apk --release
# APK konumu: build/app/outputs/flutter-apk/app-release.apk
```

---

## Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── models/
│   └── asset_model.dart         # Varlık veri modeli
├── services/
│   ├── rsi_calculator.dart      # RSI hesaplama motoru
│   ├── market_data_service.dart # Yahoo Finance API
│   ├── notification_service.dart# Bildirim yönetimi
│   └── background_service.dart  # Arka plan görevleri
└── screens/
    ├── home_screen.dart          # Ana ekran
    └── asset_detail_screen.dart  # Detay ekranı + grafik
```

---

## Veri Kaynağı
Yahoo Finance API (ücretsiz, kayıt gerektirmez):
- `BZ=F` → Brent Ham Petrol
- `GC=F` → Altın (spot)
- `EURUSD=X` → EUR/USD paritesi

---

## Yeni Varlık Ekleme
`lib/models/asset_model.dart` dosyasında `defaultAssets()` listesine ekle:

```dart
AssetModel(
  symbol: 'SILVER',
  name: 'Gümüş',
  displayName: 'Gümüş (XAG/USD)',
  yahooSymbol: 'SI=F',
),
```

Yahoo Finance sembollerini [finance.yahoo.com](https://finance.yahoo.com) adresinden bulabilirsiniz.

---

## Bildirim Ayarları (Android)
- Uygulama ilk açıldığında bildirim izni istenir
- Android 13+ için `POST_NOTIFICATIONS` izni gereklidir
- Pil optimizasyonundan muaf tutmak için: **Ayarlar → Uygulamalar → RSI Alarm → Pil → Kısıtlanmamış**

---

## Notlar
- Arka plan çalışması cihaz modeline ve Android sürümüne göre değişebilir
- Huawei/Xiaomi cihazlarda arka plan kısıtlamaları nedeniyle ek ayar gerekebilir
- Uygulama, veriye erişim için internet bağlantısı gerektirir
