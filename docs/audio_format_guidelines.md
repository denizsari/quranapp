# Ses Kayıt Format Rehberi

Bu rehber, AI telaffuz POC ve üretim kalite pipeline'ı için standart ses kayıt parametrelerini tanımlar.

## 1. Format
- Container: WAV (RIFF)
- Codec: PCM (Linear PCM - sıkıştırmasız)
- Örnekleme Hızı: 16 kHz (16000 Hz)
- Kanal: Mono
- Bit Derinliği: 16-bit
- Byte Order: Little Endian (standart WAV)

## 2. Dosya Boyutu Örneği
Yaklaşık hesap: 16000 (örnek/sn) * 2 byte * 1 kanal = ~32 KB/s. 5 saniyelik kayıt ≈ 160 KB.

## 3. İsimlendirme Konvansiyonu
`<letterId>_<randomBase36 6 chars>_<epochMs>.wav`
Örnek: `alif_k9az3p_1717355523123.wav`

## 4. Metadata Alanları (Firestore recording doc)
| Alan | Tip | Açıklama |
|------|-----|----------|
| letterId | string | Hedef harf ID (`letter_metadata.json` referansı) |
| userRef | reference | Kullanıcı dokümanı referansı |
| createdAt | timestamp | Yüklenme zamanı (server timestamp) |
| durationMs | number | Tahmini süre (ms) |
| sizeBytes | number | Dosya boyutu |
| format | map | `{codec: "pcm_s16le", sampleRate:16000, channels:1}` |
| anonymizedUserId | string | Hashlenmiş kullanıcı ID (POC analizinde) |
| storagePath | string | Storage konumu |
| reviewStatus | string | `pending|accepted|rejected` |
| rejectedReason | string? | Opsiyonel açıklama |

## 5. Kayıt Kalite Kuralları
- Arka plan gürültüsü: < -40 dB RMS hedef.
- Peak clipping: %0 (normalize öncesi kontrol edin).
- Sessizlik trimming: Baş/son > 300ms sessizlik kesilir.
- VUV (voiced/unvoiced) segment sayısı < 5 ise yeniden kayıt öner.

## 6. İstemci Tarafı Kontrolleri
- Tarayıcı / cihaz mikrofon izni kontrolü.
- 10 sn üstü kayıt otomatik durdur.
- Boyut > 400 KB ise uyarı (yeniden kayıt veya sıkıştırma yok — süre kısalt).

## 7. Gizlilik
- Ham kayıt kullanıcıya tekrar dinletilebilir; paylaşım yok.
- Analiz için kullanılan `anonymizedUserId = SHA256(userId + salt)`; salt uygulama build içinde değil, backend config (env) ile gelir.

## 8. Gelecek (V2) Opsiyonlar
- 24 kHz destek (model doğruluk artışı).
- Noise profile adaptif filtre.
- Loudness normalization (EBU R128 yaklaşımı hafifletilmiş).

## 9. Test Checklist
- [ ] 16 kHz doğrulama
- [ ] Mono doğrulama
- [ ] Süre < 10s
- [ ] Boyut hesaplaması doğru
- [ ] Hash üretildi
- [ ] Metadata Firestore'a yazıldı

---
Bu doküman `sprint0_checklist.md` 10. bölüm maddeleri için kanıt sağlar.
