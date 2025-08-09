# Kuran & Arapça Öğrenme Uygulaması (Doküman Dizini)

Bu repo şu an konsept / planlama ve çekirdek algoritma aşamasındadır. Aşağıda mevcut doküman ve prototip modül bağlantıları yer alır.

## 1. Dokümanlar
- PRD: `prd.md`
- Execution Plan: `execplan.md`
- Veri Modeli: `data_model.md`
- Analitik Event Şeması: `analytics_events.md`
- İlerleme (XP / Level) Modeli: `progression_model.md`
- Security & Privacy: `security_privacy.md`
- AI POC Veri Formu: `ai_poc_data_form.md`
- Lesson Content Örnekleri: `lesson_content_examples.md`
- Sprint 0 Checklist: `sprint0_checklist.md`
- Harf Metadata: `docs/letter_metadata.json`
- Ses Format Rehberi: `docs/audio_format_guidelines.md`
- İçerik Onay Flow: `docs/content_workflow.md`
- 10 Kelime Listesi: `docs/ten_words_list.md`
 - Commit Mesaj Rehberi: `docs/commit_convention.md`
 - Performans Rehberi: `docs/performance_baseline.md`
 - Tasarım Placeholder: `docs/design_figma_placeholder.md`
	- Branch Koruma Rehberi: `docs/branch_protection_guide.md`
		- Sprint 0 Sign-off: `docs/review_signoff.md`
	- Sprint 1 Plan: `docs/sprint1_plan.md`

## 2. Çekirdek Mantık & Flutter İskeleti
Kod klasörü: `lib/` (progression, spaced repetition + temel Flutter scaffold: theme, LessonTile, analytics placeholder).

## 3. Kurulum (Çekirdek + Flutter)
```
dart pub get
dart run build_runner build --delete-conflicting-outputs   # (freezed modelleri eklendiğinde)
flutter test                                                # unit + widget test
flutter test integration_test                               # basit smoke integration
```

## 4. Yol Haritası (Kısa)
### Performans Ölçüm Komutları
Profil modunda çalıştırma:
```
flutter run --profile
```
Çıkan loglardan `[PERF]` etiketli satırları kopyalayıp P01..P04 hesapla ve `docs/performance_baseline.md` tablosuna ekle.

## 4.1 Firebase Kurulum (Özet)
Gerçek değerleri eklemek için:
1. Firebase console'da dev projesi oluştur.
2. `dart pub global activate flutterfire_cli`
3. `flutterfire configure` çalıştır (platformları seç) → `firebase_options.dart` otomatik güncellenir.
4. Rules deploy (emulator veya prod):
```
firebase emulators:start --only firestore
firebase deploy --only firestore:rules   # prod için
```
Not: Şu an `firebase_options.dart` placeholder değer içerir.

## 4.2 Code Generation
## 4.3 Storage Yol Yapısı (Öneri)
`recordings/<letterId>/<userId>/<epoch>.wav`
İleride: anonim analiz için `recordings_anonymized/<letterId>/<hashUser>/<epoch>.wav`

## 4.4 Branch Koruma / Git Akışı
- Ana branch: `main` (sadece release merge)
- Geliştirme: `develop`
- Özellik: `feature/<kisa-ad>`
- Koruma: `main` için required PR + CI yeşil + 1 review.
Commit formatı: `docs/commit_convention.md`

### Sprint 1 Plan (Özet)
İlk 10 harf için dinamik liste, anonim kullanıcı ilerleme güncellemesi, kayıt yükleme taslağı ve temel analytics eventleri. Detay: `docs/sprint1_plan.md`.

Modeller için (freezed/json):
```
dart run build_runner build --delete-conflicting-outputs
```
Watch modu:
```
dart run build_runner watch
```

1. Tasarım Sistemi Kuralları (renk, tipografi, komponent tokenları) – in progress (`theme/app_theme.dart`)
2. Firestore Security Rules implementasyonu (rules dosyası + emulator test)
3. Navigation & gerçek lesson data provider
4. İçerik pipeline scriptleri (ses dönüştürme, JSON doğrulama)
5. Analytics abstraction (Firebase + console fallback)

## 5. Tasarım Kuralları (Çekirdek Placeholder)
Çekirdek kurulan temel:
- Renkler: `AppSemanticColors` (primary, success, warning, error)
- Tipografi: `typography.dart` (heading1, heading2, body, bodySmall, caption)
- Bileşenler: `AppButton`, `AppCard`, `AppProgressBar`, `Badge`
- Spacing (öneri): 4pt grid (4,8,12,16,24,32,40)
Eksikler (ileride): Figma kaynak linki, koyu tema varyantı, durum (hover/pressed) tokenları, ikon seti, erişilebilirlik kontrast testi.

## 6. Lisans / Telif
Henüz lisans seçilmedi. (Öneri: AGPL vs. kapalı kaynak opsiyon analizi). Ses / dini içerik kaynakları için ayrı telif değerlendirmesi.

---
Revizyon: v0.1 (Doküman Index Başlangıç)
