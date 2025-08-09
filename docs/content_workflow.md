# İçerik Onay Flowu

## 1. Durumlar
`draft -> in_review -> approved -> deprecated`

## 2. Roller
- Content Author: Draft oluşturur / günceller
- Reviewer (Pedagojik): Doğruluk & sıralama
- QA: Uygulamada render testi

## 3. Firestore Alanları (lessonContent)
| Alan | Açıklama |
|------|----------|
| status | `draft|in_review|approved|deprecated` |
| version | Otomatik artan integer |
| updatedAt | server timestamp |
| updatedBy | user ref |
| reviewNotes | kısa text |
| pedagogyRating | 1-5 (opsiyonel) |

## 4. Geçiş Kuralları
- draft -> in_review: Author dışında değiştirilemez; boş alan kontrolü (metin + tip + ses placeholder)
- in_review -> approved: Reviewer gerekli; `reviewNotes` zorunlu
- approved -> deprecated: Sadece Admin/Reviewer; migration planı not edilir

## 5. Otomasyon (V2)
- Firestore trigger: approved olduğunda search index queue'ya yaz
- Analytics: `content_status_transition` event gönder

## 6. Checklist (İlk 10 Harf)
- [x] Draft yaratıldı
- [x] İnceleme not formatı belirlendi
- [ ] Reviewer ataması yapıldı
- [ ] Onay sonrası QA test scripti yazıldı

## 7. Riskler
- Tutarsız sürümleme → Çözüm: Atomic update + transaction
- Eski sürüm cache problemi → Çözüm: `version` bazlı local invalidation

Bu doküman Sprint 0 içerik pipeline maddelerini destekler.
