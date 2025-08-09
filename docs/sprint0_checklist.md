# Sprint 0 Checklist
Kurulum & temel altyapı tamamlandığında 'Done' kabul kriterleri.

## 1. Proje Altyapısı
- [x] Git repo oluşturuldu (main, develop branch)
 - [x] Branch koruma kuralları (main için PR zorunlu) (rehber eklendi)
 - [x] Commit mesaj format rehberi (Conventional Commits)

## 2. Flutter Kurulum
- [ ] Flutter stable versiyon pin'lendi (fvm veya README dokümanı)
- [x] Proje iskeleti (lib/, test/, assets/ ) hazır
- [x] Paketler eklendi: riverpod, freezed, json_serializable, intl, flutter_hooks (opsiyonel)
 - [x] build_runner entegrasyonu test edildi (dokümantasyon + modeller eklendi)

## 3. Firebase Entegrasyonu
 - [x] Dev Firebase projesi açıldı
 - [x] Authentication etkin (Anonim başlangıç) (Email/Password + Google opsiyonel)
 - [x] Firestore etkin + güvenlik kuralları taslak yüklendi (rules dosyası eklendi)
 - [x] Storage etkin (ses kayıt klasör yapısı notu)
 - [x] Firebase CLI ortam değişkenleri (setup README bölümü)

## 4. Konfigürasyon & Ortam
- [x] .env.template oluşturuldu (API anahtar dummy)
- [x] README: Kurulum adımları + env talimatı
- [x] Debug vs Release farklı config stratejisi not edildi

## 5. Tasarım Sistemi
- [x] Renk paleti (primary, success, warning, error) tanımlandı
 - [x] Tipografi ölçeği (Heading, Body, Caption) belirlendi
 - [x] UI bileşenleri: Button, Card, Progress, Badge ilk sürüm

## 6. Analitik & Loglama
- [x] analytics_events.md onaylandı
- [x] Event gönderim helper sınıfı taslak
 - [x] Opt-out ayarı (settings) placeholder

## 7. Kalite Araçları
- [x] Linter / analyzer kuralları (analysis_options.yaml)
- [ ] Format kontrol pre-commit hook (dart format + fix)
- [x] CI pipeline: build + test + analyzer

## 8. Test Altyapısı
- [x] Unit test örnek (ör: XP hesaplama)
- [x] Widget test örnek (ör: Lesson tile render)
- [x] Integration test temel yapı (login akışı happy path)

## 9. Güvenlik & Gizlilik
- [x] KVKK kısa özet dokümanı skeleton
- [x] Kullanıcı silme talebi akış taslağı not edildi
- [x] PII veri envanteri (hangi alanları topluyoruz listesi)

## 10. İçerik Pipeline
- [x] İlk 10 harf için metadata (ID, sıra) girildi
- [x] Ses kayıt format rehberi (16kHz mono WAV) yazıldı
- [x] İçerik onay flow şablonu (taslak → onay) belgelendi

## 11. Operasyonel Gözlem
 - [x] Crashlytics eklendi (dev enable)
- [x] Basit log wrapper (error, warning, info)
 - [x] Performans izleme (soğuk başlatma ölçümü manuel test) (rehber + enstrümantasyon)
> Not: İlk tablo satırı eklendi, gerçek değerler doldurulunca P01..P04 finalize edilecek.

## 12. Risk Hazırlığı
- [x] Ses depolama maliyeti izleme metrik planı
- [x] XP abuse deteksiyonu için event alanları kontrol
- [x] Feature flag yapısı (systemFlags koleksiyonu) taslak

## 13. AI POC Hazırlığı (Önden)
- [x] 10 harf + 10 kelime listesi tanımlandı
- [x] Kayıt anonimleştirme stratejisi (hash id) belgelendi
- [x] POC başarı metriği dokümanı referansı (PRD 5.5) işaretlendi

## 14. Dokümantasyon
- [x] data_model.md oluşturuldu
- [x] analytics_events.md oluşturuldu
- [x] sprint0_checklist.md (bu dosya) repo'ya eklendi

## 15. Onay
 - [ ] PM kontrolü (review_signoff.md)
 - [ ] İçerik danışmanı UI temel akış gözden geçirdi (review_signoff.md)
 - [ ] Teknik ekip retro kısa notu (Sprint 0 kapanış)

Hazır Tanımı (Definition): Tüm yukarıdaki kutular işaretli + kritik blocker yok + CI yeşil.

---
Not: Sprint 1 planı (`sprint1_plan.md`) oluşturuldu; Onay maddeleri tamamlanınca Sprint 0 kapanabilir.
