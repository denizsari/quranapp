# Analytics Events Şeması
Bu doküman ürün KPI'larını besleyen temel event'lerin tanımını ve payload alanlarını içerir.

## 1. Tasarım İlkeleri
- Gizlilik: Kişisel veri (PII) gönderilmez; userId hashed (platform sağlayıcısına göre). 
- Tutarlılık: snake_case event adları.
- Versiyonlama: Event şema değişimi major alan eklemesi gerektirirse `schema_version` alanı artırılır.
- Performans: Gereksiz büyük payload yok; limit < 2KB/event.

## 2. Event Listesi (MVP)
| Event | Trigger | Zaman | Kritik KPI Bağı |
|-------|---------|-------|-----------------|
| app_launch | App açıldığında (cold) | Uygulama başlangıcı | DAU/MAU |
| activation_started | Kullanıcı ilk dersi açtığında | İlk ders girişi | Activation Rate |
| lesson_started | Ders UI render sonrası | Her ders başlangıcı | Completion Funnel |
| lesson_completed | Başarılı tamamlama | Ders bitişi | Completion Rate, XP |
| level_up | Level artışı | XP artışı sonrası | Progression Pace |
| exercise_attempt | Egzersiz cevap denemesi | Cevap submit | Doğruluk analizi |
| exercise_feedback_shown | Geri bildirim UI gösterildi | Feedback anı | Latency ölçümü |
| streak_increment | Streak artışı | Streak güncelleme | Retention Proxy |
| xp_awarded | XP hesaplandı | Ders bitişi | Progression Pace |
  schema_version: 2,
  timestamp: ISO8601
| notification_sent | Push planlandı/gönderildi | FCM dispatch | Notification Etkinliği |
| notification_opened | Push açıldı | Kullanıcı açma | CTR |
| weak_item_scheduled | Spaced repetition item surfaced | Öğrenme ekranı | Personalization Etkinliği |
| premium_trial_started | Trial aktivasyonu | Trial onayı | Dönüşüm Hunisi |
| premium_trial_converted | Trial → ödeme | Ödeme onayı | Dönüşüm |
| premium_canceled | Abonelik iptali | İptal aksiyonu | Churn |

## 3. Event Şema Detayları
### 3.1 lesson_started
```
{
  event: 'lesson_started',
  user_id: '<uid>',
  lesson_id: 'm1_alif',
  module_id: 'm1',
  type: 'harf',
  attempt_seq: 1,            // aynı ders içinde kaçıncı tekrar
  timestamp: ISO8601
}
```

### 3.2 lesson_completed
```
{
  event: 'lesson_completed',
  user_id: '<uid>',
  lesson_id: 'm1_alif',
  time_spent_ms: 42000,
  accuracy: 0.92,
  xp_earned: 12,
  hearts_used: 1,
  streak_after: 5,
  timestamp: ISO8601
}
```

### 3.3 level_up
```
{
  event: 'level_up',
  user_id: '<uid>',
  from: 3,
  to: 4,
  xp: 520,
  timestamp: ISO8601
}
```

### 3.4 exercise_attempt
```
{
  event: 'exercise_attempt',
  user_id: '<uid>',
  lesson_id: 'm1_alif',
  exercise_id: 'm1_alif_q1',
  exercise_type: 'select'|'trace'|'record'|'order'|'fill',
  attempt_index: 2,
  correct: true,
  latency_ms: 1800,
  timestamp: ISO8601
}
```

### 3.5 xp_awarded
```
{
  event: 'xp_awarded',
  user_id: '<uid>',
  lesson_id: 'm1_alif',
  base_xp: 10,
  accuracy: 0.92,
  multiplier: 1.2,
  earned_xp: 12,
  xp_before: 110,
  xp_after: 122,
  level_before: 3,
  level_after: 3,
  attempt_count: 7,
  lat_p50_ms: 480,
  lat_p95_ms: 1400,
  current_streak: 5,
  lat_outlier_ratio: 0.15,
  timestamp: ISO8601
}
```

### 3.6 streak_increment
```
{
  event: 'streak_increment',
  user_id: '<uid>',
  streak_before: 4,
  streak_after: 5,
  grace_used: false,
  timestamp: ISO8601
}
```

### 3.6.1 attempt_batch_flush (İç Telemetry)
```
{
  event: 'attempt_batch_flush',
  count: 15,
  batch_age_ms: 3200,
  first_attempt_id: 'L1_1',
  correct_count: 12,
  accuracy: 0.8,
  timestamp: ISO8601
}
```

### 3.6.2 adjudicator_submit_ok / adjudicator_submit_fail
```
// success
{
  event: 'adjudicator_submit_ok',
  lesson_id: 'm1_alif',
  attempts: 1,
  timestamp: ISO8601
}
// fail
{
  event: 'adjudicator_submit_fail',
  lesson_id: 'm1_alif',
  retry_count: 3,
  last_status_code: 500,
  timestamp: ISO8601
}
```

### 3.7 recording_uploaded
```
{
  event: 'recording_uploaded',
  user_id: '<uid>',
  recording_id: '<rid>',
  lesson_id: 'm1_alif',
  unit_id: 'harf_alif',
  duration_ms: 3000,
  file_size_kb: 150,
  network_type: 'wifi'|'cellular',
  timestamp: ISO8601
}
```

### 3.8 weak_item_scheduled
```
{
  event: 'weak_item_scheduled',
  user_id: '<uid>',
  item_id: 'harf_ha',
  item_type: 'harf'|'kelime',
  due_interval_days: 3,
  schedule_source: 'spaced_repetition',
  timestamp: ISO8601
}
```

### 3.9 notification_sent / notification_opened
```
// notification_sent
{
  event: 'notification_sent',
  user_id: '<uid>',
  notif_type: 'daily_goal'|'streak_save'|'ai_feedback',
  send_time: ISO8601
}
// notification_opened
{
  event: 'notification_opened',
  user_id: '<uid>',
  notif_type: 'daily_goal',
  delivered_to_open_latency_ms: 62000,
  timestamp: ISO8601
}
```

### 3.10 premium_trial_started / premium_trial_converted / premium_canceled
```
{
  event: 'premium_trial_started',
  user_id: '<uid>',
  plan: 'premium_a',
  timestamp: ISO8601
}
{
  event: 'premium_trial_converted',
  user_id: '<uid>',
  plan: 'premium_a',
  days_since_trial_start: 7,
  timestamp: ISO8601
}
{
  event: 'premium_canceled',
  user_id: '<uid>',
  plan: 'premium_a',
  days_remaining: 12,
  reason?: 'price'|'usage_low'|'other',
  timestamp: ISO8601
}
```

## 4. Event Akış Diyagramı (Metinsel)
1. Kullanıcı app'i açar → app_launch.
2. İlk ders tıklanır → activation_started + lesson_started.
3. Egzersizler boyunca her cevap → exercise_attempt.
4. Ders bitince → lesson_completed, xp_awarded, gerekirse streak_increment.
5. Zayıf alan hesaplanırsa → weak_item_scheduled.
6. Kullanıcı ses kaydı yaparsa → recording_uploaded.

## 5. Telemetri Kalite Kontrolleri
- Boş veya 0 accuracy içeren lesson_completed olmamalı.
- exercise_attempt latency_ms < 120000 (outlier filtre).
- xp_awarded total_xp == base_xp * performance_multiplier (float tolerans ±1).

## 6. Gizlilik ve Opt-Out
- Kullanıcı ayarlarından analytics kapatırsa yalnızca zorunlu (operasyonel) eventler (app_launch minimal) gönderilir.
- Tüm event payloadları PII içermez.

## 7. Gelecek Faz Event Önerileri
- ai_pronunciation_scored (Faz 3)
- ai_feedback_shown
- leaderboard_position_changed
- achievement_unlocked

## 8. Performans Telemetri Eventleri
- perf_cold_start: { ms_since_process_start, ms_since_binding, firebase_init_ms }
- perf_lesson_complete_ms: { lesson_id, duration_ms }

## 9. Ek Telemetry (Sprint 4)
- ai_scorer_slow: { lesson_id, exercise_id, latency_ms, slow_ms_cfg }
- leaderboard_fetched: { count }
- daily_goal_set: { goal_xp }
- daily_goal_reached: { goal_xp, earned_xp }
 - adjudicator_outbox_submit_error: { lesson_id }
 - ai_scorer_error: { lesson_id, exercise_id, error }

---
Revizyon: v1.2 (Sprint 5 - adjudicator_outbox_submit_error & ai_scorer_error eklendi)
