# Security & Privacy Dokümanı (v1.0 - Sprint 0)

Bu doküman MVP kapsamındaki veri koruma, güvenlik ve gizlilik prensiplerini özetler.

## 1. Kapsam
- Platform: Flutter (iOS/Android) + Firebase (Auth, Firestore, Storage) + gelecekte AI microservice.
- Kullanıcı Rolleri: child, parent, solo, admin.
- Kişisel veri (PII) minimizasyonu odağı.

## 2. Veri Envanteri (MVP)
| Veri Alanı | Kaynak | Tip | PII Sınıfı | Saklama | Not |
|------------|--------|-----|-----------|---------|-----|
| email | Auth | string | Hassas | Hesap süresi | Çocuk hesapta ebeveyn perdesi |
| displayName | User input | string | Orta | Hesap süresi | Takma ad önerilir |
| role | Uygulama | enum | Düşük | Hesap süresi | Yetki kontrolü |
| xp, level, streak | App logic | sayısal | Düşük | Hesap süresi | Analitik |
| recordings (audio) | Kullanıcı | binary | Orta | ≤ 90 gün | AI eğitimi için açık rıza şart |
| weakAreas | App logic | dizi | Düşük | Dinamik | Kişiselleştirme |
| parent-child link | Parent | ilişki | Orta | Hesap süresi | Ebeveyn onayı |

PII Sınıfları: Hassas (email), Orta (ses kayıtları), Düşük (oyunlaştırma metrikleri)

## 3. Hukuki Dayanak (KVKK/GDPR Eşlemesi)
- Sözleşme İfası: Hesap oluşturma, temel öğrenme fonksiyonları.
- Meşru Menfaat: Kullanım analitiği (anonimleştirilmiş / psödonom). 
- Açık Rıza: AI model eğitimi için ses kayıtlarının yeniden kullanımı.

## 4. Kullanıcı Hakları
| Hak | Mekanizma | SLA |
|-----|-----------|-----|
| Erişim | Ayarlar > Veri Talebi (JSON export) | 30 gün |
| Silme | Ayarlar > Hesabı Sil (soft delete + 30 gün purge) | 30 gün |
| Düzeltme | Profil düzenleme | Anında |
| Rıza Geri Alma | Ses yeniden kullanım toggle | 7 gün |

## 5. Veri Saklama Politikası
- Kayıtlı hesap verisi: Hesap silme talebi sonrası 30 gün bekleme (geri alma penceresi).
- Ses kayıtları: Varsayılan ≤ 90 gün, ardından otomatik silme job.
- Log & erişim kayıtları: 30 gün sonra anonimleştirme.

## 6. Güvenlik Kontrolleri
| Katman | Önlem |
|--------|-------|
| İletişim | HTTPS (TLS 1.2+), HSTS |
| Auth | Firebase Auth (email doğrulama), brute force throttle |
| Firestore Kuralları | Principle of least privilege, serverTimestamp doğrulama |
| Storage | Dosya path userId segment kontrolü |
| Gizlilik | Çocuk hesapta gerçek isim zorunlu değil |
| Logging | PII mask (email hash) |
| CI | Secrets .env + build time injeksiyon |

## 7. Tehdit Modeli (Özet)
| Tehdit | Vektör | Etki | Azaltma |
|--------|--------|------|---------|
| Yetkisiz user doc erişimi | Zayıf security rules | Yüksek | Rule test + emulator otomasyon |
| Kötü amaçlı ses paylaşımı | Paylaş link | Orta | Time-limited URL, erişim log |
| API anahtar sızıntısı | Repo commit | Orta | .gitignore + secret scan |
| Brute force login | Otomatik denemeler | Orta | Rate limit + Firebase yerleşik |
| Token çalınması | Kötü niyetli app | Orta | Refresh token rotation (gerekirse) |

## 8. Incident Response Akışı
1. Tespit (monitor / kullanıcı bildirimi)
2. Sınıflandırma (kritiklik, kapsam)
3. İzolasyon (token revoke, kural güncelleme)
4. Bildirim (yasal süreler: 72 saat içinde gerekli otoritelere)
5. Kök Neden Analizi
6. Düzeltici Aksiyon & Dokümantasyon

## 9. AI Spesifik Gizlilik
- Ses anonim ID ile işlenir (userId hash + salt).
- Model eğitimi dataset whitelist (explicit inclusion list).
- Düşük güven skorları log; içerik danışmanı inceleme (flag).

## 10. Açık Sorular
- İç lokasyon ülke/regional hosting gereksinimi? (TR/EU)
- Ek şifreleme (client-side) gerekecek mi?

## 11. Revizyon Yönetimi
- Değişiklik PR'larında security_privacy.md diff review (PM + Backend).

---
Revizyon: v1.0 (Sprint 0)
