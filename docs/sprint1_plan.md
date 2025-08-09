# Sprint 1 Plan (Öneri)

## 1. Hedef (Sprint Goal)
İlk öğretim akışını (10 harf) anonim kullanıcıyla tamamlayıp temel ilerleme (XP + streak) ve kayıt yükleme prototipini çalışır hale getirmek.

## 2. Scope (Dahil)
- Harf listesinin Firestore'dan okunması
- Lesson list ekranı: dinamik veri + progress bar
- Kayıt oluşturma UI (dummy / local) + Storage upload stub
- XP kazanımı: basit derse girince +10 (placeholder) → progression servisine uygulama
- Streak güncellemesi günlük 1 derste
- Analytics: lesson_started, lesson_completed event gönderimi
- Feature Flag okuma (systemFlags) caching (memorize + 5dk refresh)

## 3. Hariç
- Gerçek ses analizi (AI)
- Çoklu dil / i18n
- Ödeme / premium
- Push notification

## 4. Backlog Kalemleri
| ID | Başlık | Tip | Kabul Kriterleri |
|----|--------|-----|------------------|
| S1-1 | Lessons koleksiyon provider | feat | Firestore'dan aktif lessons çekilir, boşsa graceful state |
| S1-2 | Lesson list UI dynamic | feat | Liste Firestore verisi ile render |
| S1-3 | User lesson progress write | feat | Derse girişte progress doc %0→%100 simülasyon |
| S1-4 | XP award integration | feat | Derse girişte XP +10; level badge güncellenir |
| S1-5 | Streak update daily | feat | Yeni gün ilk ders açıldığında streak++ |
| S1-6 | Recording upload stub | feat | UI buton → fake wav bytes → Storage path'e yaz (opsiyonel try/catch) |
| S1-7 | Analytics events dispatch | feat | lesson_started/completed log + (future firebase analytics) interface |
| S1-8 | Feature flags fetch | feat | systemFlags koleksiyonu read (cache) |
| S1-9 | Error logging improvements | chore | Crashlytics test durumunda custom log |
| S1-10 | CI coverage badge hazırlığı | chore | Coverage yüzdesi README'ye eklenir |

## 5. Teknik Notlar
- Provider layering: Firestore stream → repository → UI provider
- Error states: simple SnackBar / console log (V1)
- Caching: in-memory map + timestamp for feature flags

## 6. Riskler
- Firestore read maliyeti artışı → limit + index kontrolü
- Progress doc race condition → merge update (set with merge)

## 7. Definition of Done
- Tüm backlog kalemleri PR review + test (varsa) + CI yeşil
- README Sprint 1 sonuç kısmı güncellemesi
- Sign-off notu (review_signoff.md güncellemesi)

## 8. Ölçümler
- İlk 10 harf tamamlanma oranı (dummy) > %70 test akışı
- Crash olmadan 5 ardışık test oturumu

---
Taslak: Rev A
