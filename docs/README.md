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

## 2. Çekirdek Mantık (Dart Prototip)
Kod klasörü: `lib/` (şu an sadece çekirdek XP ve spaced repetition hesaplamaları). Bu yapı daha sonra Flutter ana uygulamasına entegre edilecektir.

## 3. Kurulum (Çekirdek Paket)
```
# Dart SDK kurulu varsayılır.
dart pub get
dart test
```

## 4. Yol Haritası (Kısa)
1. Tasarım Sistemi Kuralları (renk, tipografi, komponent tokenları) -> forthcoming
2. Firestore Security Rules implementasyonu (rules dosyası + emulator test)
3. Flutter app iskeleti (module navigation + provider setup)
4. İçerik pipeline scriptleri (ses dönüştürme, JSON doğrulama)

## 5. Tasarım Kuralları (Çekirdek Placeholder)
Bu bölüm daha sonra oluşturulacak tasarım sistemine referans tutacaktır (renk palette, spacing scale 4/8pt, typography scale, icon set, accessibility kontrast gereksinimleri).

## 6. Lisans / Telif
Henüz lisans seçilmedi. (Öneri: AGPL vs. kapalı kaynak opsiyon analizi). Ses / dini içerik kaynakları için ayrı telif değerlendirmesi.

---
Revizyon: v0.1 (Doküman Index Başlangıç)
