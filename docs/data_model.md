# Data Model (Firestore + Supporting Storage)

Bu doküman MVP ve Faz 2/3 genişlemelerini öngören ilk veri modelini, isimlendirme kurallarını, indeksleri, güvenlik prensiplerini ve evrim (migration) stratejisini içerir.

## 1. Tasarım İlkeleri
- **Basit Okuma Akışı**: Lesson + lessonContent ayrımı; içerik lokal cache ile minimize read.
- **Kullanıcı Ayrımı**: Çocuk / Ebeveyn / Solo / Admin rolleri `users.role` alanı.
- **Denormalizasyon Minimal**: Sık görüntülenen özet metrikler (xp, level, streak) user doc üstünde tutulur.
- **Audit / Versioning**: İçerik revizyonu `version` + `lessonVersion` alanları.
- **Performans**: Liste sayfalarında sayfalama (limit + startAfter) kullanılır.
- **Gizlilik**: Çocuk kişisel veri minimizasyonu; ses kayıtları sadece ihtiyaç süresince saklanır.

## 2. Koleksiyonlar
### 2.1 users
```
/users/{userId} {
  displayName: string,
  role: 'child' | 'parent' | 'solo' | 'admin',
  xp: number,
  level: number,
  streak: { current: number, lastActiveDate: string (ISO) },
  hearts: number,
  settings: { locale: 'tr' | 'ar' | 'en'?, notifications: boolean },
  weakAreas: string[],            // harfId veya kelimeId referansları
  createdAt: Timestamp,
  updatedAt: Timestamp,
  parentApprovedAt?: Timestamp,   // çocuk hesabı onay tarihi
  premium?: { tier: string, expiresAt: Timestamp }
}
```
Indeks: (role) opsiyonel admin listesi; (premium.expiresAt) süresi yaklaşan abonelik taraması için.

### 2.2 parentLinks
```
/parentLinks/{linkId} {
  parentId: string,
  childUserId: string,
  status: 'pending' | 'active' | 'revoked',
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```
Sorgu: parentId == currentUser OR childUserId == currentUser. Indeks: composite (parentId, status).

### 2.3 lessons
```
/lessons/{lessonId} {
  moduleId: string,               // m1, m2...
  type: 'harf' | 'sure' | 'kelime' | 'egzersiz' | 'tecvid',
  order: number,
  prereqIds: string[],
  version: number,
  difficulty: 1|2|3,              // XP çarpanı veya base hesap için
  active: boolean,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```
Indeks: moduleId+order (listeleme), type+active.

### 2.4 lessonContent
Metinsel ve medya segmentleri. Büyük blob yerine segment array.
```
/lessonContent/{docId} {
  lessonId: string,
  locale: 'tr' | 'ar' | 'en',
  segments: [
    { type: 'text', text: string, style?: 'title'|'body' },
    { type: 'audio', ref: 'gs://.../audio/alfba_ha_v1.wav', durationMs?: number },
    { type: 'trace', svgPath: string, strokeCount: number },
    { type: 'quiz', quizType: 'select'|'order'|'fill', payload: { ... } }
  ],
  lessonVersion: number,
  approved: boolean,
  approvedBy?: string,
  approvedAt?: Timestamp
}
```
Indeks: lessonId+locale.

### 2.5 userLessonProgress
```
/userLessonProgress/{ulpId} {
  userId: string,
  lessonId: string,
  status: 'not_started' | 'in_progress' | 'completed',
  accuracy: number,                // 0..1 son oturum
  attempts: number,
  bestAccuracy: number,
  lastAnsweredAt: Timestamp,
  updatedAt: Timestamp
}
```
Composite indeks: userId+lessonId (unique), userId+status (filtre), userId+updatedAt (son aktiviteler).

### 2.6 recordings
```
/recordings/{recordingId} {
  userId: string,
  lessonId: string,
  unitId: string,                  // harf veya kelime ID
  storagePath: string,             // cloud storage tam yol
  durationMs: number,
  aiScore?: number,                // 0..1
  aiConfidence?: number,
  flagged?: boolean,
  createdAt: Timestamp
}
```
Indeks: userId+createdAt desc. Lifecycle: 90 gün sonra otomatik sil (Cloud Storage rule + scheduled function).

### 2.7 achievements & userAchievements
```
/achievements/{code} {
  title: string,
  description: string,
  category: 'progress'|'consistency'|'mastery'|'exploration'|'social',
  criteria: { type: string, params: object }, // örn { type: 'streak', params:{days:7} }
  active: boolean
}

/userAchievements/{uaId} {
  userId: string,
  achievementCode: string,
  earnedAt: Timestamp
}
```
Indeks: userId+achievementCode (unique), achievementCode+active.

### 2.8 weeklyLeaderboards
```
/weeklyLeaderboards/{weekISO} {
  weekISO: string,                 // 2025-W32
  generatedAt: Timestamp,
  entries: [ { userId: string, xp: number, level?: number } ] // max 500? segmentle
}
```
Alternatif: entries alt koleksiyonu ile sayfalama.

### 2.9 systemFlags (opsiyonel)
Feature flag / rollout.
```
/systemFlags/{flagName} {
  enabled: boolean,
  rolloutPercent?: number,
  updatedAt: Timestamp
}
```

## 3. Storage Yapısı
```
audio/
  letters/
    <harfId>_v<version>.wav
  words/
    <wordId>_v<version>.wav
recordings/
  <userId>/<YYYY>/<MM>/<recordingId>.wav
```
- Format: 16kHz mono PCM WAV → (opsiyonel) AAC dönüştürme client tarafında.

## 4. İsimlendirme Kuralları
- lessonId: m<moduleNumber>_<slug> (örn. m1_alif)
- harfId: harf_<arabicLetterNameLatin>
- kelimeId: kelime_<short_slug>
- achievement code: ACH_<CATEGORY>_<SLUG> (ACH_CONSISTENCY_7DAY)
- feature flag: FEATURE_<NAME>

## 5. İndeks Tablosu (Özet)
| Koleksiyon | Alanlar | Amaç |
|------------|---------|------|
| userLessonProgress | userId, lessonId | Doğrudan erişim / upsert |
| userLessonProgress | userId, updatedAt | Son aktiviteler listesi |
| recordings | userId, createdAt | Kayıt geçmişi |
| lessons | moduleId, order | Modül sırası |
| lessonContent | lessonId, locale | İçerik fetch |
| weeklyLeaderboards | weekISO | Haftalık tablo |

## 6. Güvenlik Kuralları Özet
- users: read/write only self (admin istisnası).
- parentLinks: parent veya child tarafı sınırlandırılmış listeler.
- lessonContent & lessons: read public (active==true), write only admin.
- recordings: create self, read self, AI servis hesabı read.
- achievements: read public, write admin.
- userAchievements: read self, write Cloud Function (server timestamp). 

## 7. Veri Tutarlılığı
- XP / Level güncellemesi atomic transaction (user doc + progress). 
- Streak update: serverTimestamp + timezone normalization (UTC gün sınırı + 30h grace logic). 
- Leaderboard: Haftalık cron (Cloud Function) → snapshot write. 

## 8. Migration Stratejisi
| Durum | Yaklaşım |
|-------|----------|
| Şema alan ekleme | Non-breaking: default yoksa read-time fallback |
| Alan kaldırma | Önce yazımları durdur → arka plan temizleme → koddan kaldır |
| Büyük refactor | Yeni koleksiyon paralel → sync script → switch over |

## 9. Ölçüm & Telemetri Referansı
- `userLessonProgress` değişimlerinde event tetikleme (analytics_events.md referans). 

## 10. Açık Sorular
- Hearts üst limit kesin mi? Varsayılan 7 öneri. 
- weeklyLeaderboards entries boyutu limit? (500 → segment?)

## 11. Gelecek Faz Eklemeleri
- Tecvid kural zorluk derecesi: `rules` koleksiyonu.
- Tefsir içerikleri ayrı koleksiyon: `verses` + `verseExplanations`.

---
Revizyon: v1.0 (Sprint 0 çıkışı)
