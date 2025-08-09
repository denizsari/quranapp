# AI POC Veri Toplama Formu (Telaffuz Analizi) v1.0

Amaç: 10 harf + 10 kelimelik küçük veri seti ile telaffuz değerlendirme POC.

## 1. Katılımcı Bilgisi
| Alan | Değer |
|------|-------|
| Participant Code | |
| Tarih | |
| Yaş Aralığı | 7-9 / 10-13 / 14+ |
| Cinsiyet (opsiyonel) | |
| Ana Dil | |
| İkinci Dil(ler) | |

## 2. Rıza (Consent)
"Bu ses kayıtlarının yalnızca telaffuz analizi POC çalışması için kullanılmasını ve 90 gün içinde silineceğini kabul ediyorum." 
- [ ] Onaylandı
İmza / İşaret (dijital): ___________________

## 3. Kayıt Ortamı
| Alan | Değer |
|------|-------|
| Cihaz Modeli | |
| Mikrofon Türü | Dahili / Harici |
| Ortam Gürültüsü | Düşük / Orta / Yüksek |
| Mesafe (cm) | |

## 4. Harf Listesi (Örnek)
| Harf ID | Kayıt Dosya Adı | Kalite (1-5) | Not |
|---------|-----------------|--------------|-----|
| harf_alif | | | |
| harf_ba | | | |
| harf_ta | | | |
| harf_tha | | | |
| harf_ha | | | |
| harf_kha | | | |
| harf_dal | | | |
| harf_dhal | | | |
| harf_ra | | | |
| harf_zay | | | |

## 5. Kelime Listesi (Örnek)
| Kelime ID | Kayıt Dosya Adı | Kalite (1-5) | Not |
|-----------|-----------------|--------------|-----|
| kelime_bismillah | | | |
| kelime_allahu | | | |
| kelime_rahman | | | |
| kelime_rahim | | | |
| kelime_deen | | | |
| kelime_sirat | | | |
| kelime_iyyaka | | | |
| kelime_nastaeen | | | |
| kelime_amin | | | |
| kelime_kawthar | | | |

## 6. Hata / Not Kategorileri
- Pronunciation unclear
- Background noise
- Cut off / incomplete
- Over-emphasis

## 7. Metadata JSON (Örnek)
```
{
  "participant_code": "P001",
  "device": "Android Pixel 6",
  "environment_noise": "low",
  "records": [
    { "type": "harf", "id": "harf_alif", "file": "P001_harf_alif.wav", "quality": 4 },
    { "type": "kelime", "id": "kelime_bismillah", "file": "P001_kelime_bismillah.wav", "quality": 5 }
  ]
}
```

## 8. Silme Politikası Onayı
- [ ] 90 gün silme politikası bilgilendirmesi yapıldı.

## 9. Geri Bildirim
Katılımcı deneyim yorumu: __________________________

---
Revizyon: v1.0
