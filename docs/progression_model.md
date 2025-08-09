# XP & Seviye (Progression) Modeli (v1.0)

Bu doküman XP, level, streak, hearts ve rozet kazanım mantığını; pseudo kod ve test planını içerir.

## 1. Bileşenler
- XP: Ders / egzersiz performans puanı.
- Level: Toplam kazanılan XP'ye göre seviye (kaplamsal hız eğrisi).
- Streak: Günlük en az 1 tamamlanan ders ardışıklığı.
- Hearts: Hata/deneme ekonomisi (motivasyon & tempo kontrol).
- Rozetler: Kalıcı başarı göstergeleri.

## 2. Formüller
```
base_xp (egzersiz tipi ağırlığı)
performanceMultiplier =
  accuracy >= 0.95 -> 1.2
  0.80 <= accuracy < 0.95 -> 1.0
  0.60 <= accuracy < 0.80 -> 0.8
  else -> 0.6

earned_xp = round(base_xp * performanceMultiplier)

level_requirement(level) = round(50 * level^1.5)

# Level up koşulu
while current_total_xp >= level_requirement(current_level):
  current_level += 1
  hearts = min(hearts + 1, HEART_CAP)
```

Streak:
```
if (now - lastActive <= 30h) and lesson_completed_today == false:
   streak_current += 1
else if (now - lastActive > 30h):
   streak_current = 1  # yeni başlangıç
lastActive = today_utc
```

Hearts kullanımı (örnek kural):
```
consecutive_incorrect += 1 if incorrect else 0
if incorrect == false: consecutive_incorrect = 0
if consecutive_incorrect >= 3:
   hearts -= 1
   consecutive_incorrect = 0
if hearts == 0: show_heart_refill_gate()
```

Anti-abuse XP azaltma:
```
repeatCountSameLesson += 1
if repeatCountSameLesson > 3:
   earned_xp = floor(earned_xp * 0.5)
if repeatCountSameLesson > 5:
   earned_xp = floor(earned_xp * 0.25)
```

## 3. Pseudo Kod Akışı (Ders Tamamlama)
```
function completeLesson(user, lesson, metrics):
  accuracy = metrics.correct / metrics.total
  base_xp = lesson.baseXP
  performanceMultiplier = deriveMultiplier(accuracy)
  earned_xp = round(base_xp * performanceMultiplier)
  earned_xp = applyRepeatPenalty(user, lesson, earned_xp)
  user.totalXP += earned_xp
  # Level loop
  while user.totalXP >= level_requirement(user.level):
      user.level += 1
      user.hearts = min(user.hearts + 1, HEART_CAP)
  # Streak update
  updateStreak(user)
  persistProgress(user, lesson, accuracy)
  emitEvent('lesson_completed', ...)
  emitEvent('xp_awarded', ...)
  if streakIncremented: emitEvent('streak_increment', ...)
```

## 4. Kenar Durumları
- Midnight farklı zaman dilimi → UTC gün sınırı referans alınır.
- Offline tamamlama → local queue; timestamp server sync.
- Çoklu cihaz race condition → transaction (read-modify-write) veya server function.
- XP overflow (çok büyük int) pratikte yok; 64-bit güvenli.

## 5. Test Planı
| Senaryo | Adımlar | Beklenen |
|---------|---------|----------|
| Yüksek doğruluk XP | accuracy=0.96, base=10 | earned=12 |
| Orta doğruluk XP | accuracy=0.85, base=10 | earned=10 |
| Düşük doğruluk XP | accuracy=0.50, base=10 | earned=6 |
| Level Up | totalXP=49, base=10 acc=1.0 lvlReq=50 | level+1, hearts+1 |
| Level Loop | threshold back-to-back | Döngü tüm seviye atlamaları uygular |
| Streak Artış | lastActive < 30h, bugün ders yok | streak+1 |
| Streak Reset | lastActive > 30h | streak=1 |
| Hearts Düşüş | 3 ardışık yanlış | hearts-1, counter reset |
| Hearts Gate | hearts 0 olur | refill UI tetik |
| Repeat Penalty 4. kez | repeat=4 | xp*0.5 |
| Repeat Penalty 6. kez | repeat=6 | xp*0.25 |
| Offline Queue | flight mode tamamla | senkron sonrası eventler gönderilir |

## 6. Ölçüm / Telemetri Kontrolü
- xp_awarded total_xp == base_xp * multiplier sonrası penalty uygulanmış mı? (event alanları açıkça).
- streak_increment event varlığı streak artışı ile senkron.

## 7. Açık Sorular
- HEART_CAP kesin değer? (öneri 7)
- XP curve ileride logaritmik yumuşatma gerekli mi?

---
Revizyon: v1.0
