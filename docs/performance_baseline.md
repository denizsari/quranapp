# Performans Ölçüm Rehberi (Sprint 0)

Amaç: Erken dönemde soğuk başlatma ve temel etkileşim süreleri için ölçüm metodolojisini sabitlemek.

## 1. Metrikler
| Kod | Metrik | Tanım | Hedef (Ön) |
|-----|--------|-------|------------|
| P01 | Soğuk Başlatma Süresi | Splash -> ilk frame stable | < 1200ms (mid tier cihaz) |
| P02 | Firebase Init Süresi | `WidgetsBinding` sonrası -> `firebaseInitializedProvider` done | < 400ms |
| P03 | İlk Etkileşim | Uygulama açıldı -> anonim login buton tıklanabilir | < 1300ms |
| P04 | Anonim Login Round-trip | Tap -> user profile snapshot alındı | < 500ms (emulator) |

## 2. Ölçüm Yöntemi
- Release profile build (profiling build) tercih edilir: `flutter run --profile`.
- Timeline olayları: `dart:developer` mark (TODO: instrumentation v1).
- Manuel kronometre + Debug Console log backup.

## 3. Geçici Enstrümantasyon (V1)
Uygulama bootstrap noktalarına log satırları eklenecek:
- T0: `main()` başı
- T1: Firebase init start
- T2: Firebase init complete
- T3: First frame (addPostFrameCallback)
- T4: Auth anon sign-in start / done

Farklar üzerinden P01..P04 hesaplanır.

## 4. Raporlama Formatı
```
Tarih | Cihaz | P01 | P02 | P03 | P04 | Not
2025-08-09 | Pixel 4a | 1050 | 320 | 1180 | 410 | İlk ölçüm
2025-08-09 | Emulator (Android 14) | TBD | TBD | TBD | TBD | Ölçüm bekleniyor
```

## 5. Aksiyon Eşikleri
- P01 > 1500ms: Ağır bağımlılık (Firebase) lazy init stratejisi düşün.
- P02 > 600ms: Ağ servis latency veya config; offline cache doğrula.
- P04 > 800ms: Auth provider fallback stratejisi / retry.

## 6. Sonraki (V2)
- Flutter DevTools timeline export otomasyon scripti.
- Frame build zamanı (jank) ölçümü.
- Memory snapshot (ilk 5 sn, 30 sn).

---
Bu doküman sprint maddesi: Performans izleme (soğuk başlatma ölçümü) için temel kabul kriteri sağlar.
