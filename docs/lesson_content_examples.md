# Lesson Content JSON Örnekleri (v1.0)

Bu dosya `lessonContent` koleksiyonundaki `segments` alanı için örnek şemaları içerir.

## 1. Harf Dersi (Alif) Örneği (TR)
```
{
  "lessonId": "m1_alif",
  "locale": "tr",
  "lessonVersion": 1,
  "segments": [
    { "type": "text", "text": "Alif Harfi", "style": "title" },
    { "type": "audio", "ref": "gs://bucket/audio/letters/alif_v1.wav", "durationMs": 1200 },
    { "type": "text", "text": "Alif sessizdir, çoğunlukla uzun ünlü taşıyıcıdır." },
    { "type": "trace", "svgPath": "M10 10 L10 90", "strokeCount": 1 },
    { "type": "quiz", "quizType": "select", "payload": { "question": "Bu hangi harf?", "options": ["Alif","Ba","Ta"], "answerIndex": 0 } }
  ]
}
```

## 2. Kısa Sure (İhlas) Parçası (TR)
```
{
  "lessonId": "m4_ikhlas",
  "locale": "tr",
  "lessonVersion": 1,
  "segments": [
    { "type": "text", "text": "Kul huvallahu ehad", "style": "body" },
    { "type": "audio", "ref": "gs://bucket/audio/sure/ikhlas_ayah1_v1.wav", "durationMs": 2500 },
    { "type": "quiz", "quizType": "order", "payload": { "instruction": "Kelimeleri doğru sıraya diz", "tokens": ["Kul","huwallahu","ehad"] } }
  ]
}
```

## 3. Tracing Egzersizi (Ha Harfi)
```
{
  "lessonId": "m1_ha_trace",
  "locale": "tr",
  "lessonVersion": 1,
  "segments": [
    { "type": "text", "text": "Ha harfini çiz." },
    { "type": "trace", "svgPath": "M5 20 C20 5, 40 5, 55 20 C70 35, 70 55, 55 70 C40 85, 20 85, 5 70 Z", "strokeCount": 2 }
  ]
}
```

## 4. Çoklu Locale Örneği (EN)
```
{
  "lessonId": "m1_alif",
  "locale": "en",
  "lessonVersion": 1,
  "segments": [
    { "type": "text", "text": "Letter Alif", "style": "title" },
    { "type": "text", "text": "Alif often acts as a carrier for the long vowel 'aa'." }
  ]
}
```

## 5. Gelişmiş Quiz (Kelime Eşleştirme)
```
{
  "lessonId": "m3_vocab_basic1",
  "locale": "tr",
  "lessonVersion": 1,
  "segments": [
    { "type": "quiz", "quizType": "match", "payload": {
        "pairs": [
          { "left": "Allah", "right": "God" },
          { "left": "Rahman", "right": "Most Merciful" }
        ]
    } }
  ]
}
```

## 6. Segment Tipleri Özet Şema (JSON Şablon)
```
Segment =
  { "type":"text", "text": string, "style?": "title"|"body" } |
  { "type":"audio", "ref": string, "durationMs?": number } |
  { "type":"trace", "svgPath": string, "strokeCount": number } |
  { "type":"quiz", "quizType": "select"|"order"|"fill"|"match", "payload": object }
```

## 7. Validasyon Notları
- Maximum segments: 20 (UI performansı).
- Quiz payload schema varyant bazında tip kontrol (client side assert).
- Büyük medyalar progressive preload edilmez; kullanıcı etkileşiminde fetch.

---
Revizyon: v1.0
