PRD: Kuran & Arapça Öğrenme Uygulaması
(Flutter ile Geliştirilecek, +7 Yaş İçin, AI Destekli Öğrenme Platformu)

1. Proje Özeti
7 yaş ve üzeri kullanıcıların Kuran’ı Elif-Ba’dan başlayarak öğrenebileceği, Arapça dil bilgisini kavrayabileceği, oyunlaştırılmış ve AI destekli bir mobil uygulama. Kullanıcıların hem Kuran surelerini ve dualarını hem de Arapça harf ve kelimeleri doğru telaffuzla öğrenmesini sağlar. Motivasyon için puanlama, rozetler, ligler ve hatırlatıcılar içerir.

2. Hedef Kitle
7+ yaş çocuklar ve gençler

Ebeveynler (çocuklarının ilerlemesini takip eder)

Başlangıç seviyesinde Kuran ve Arapça öğrenmek isteyenler

2.1. Kullanıcı Rollerinin Tanımı ve Yetkiler
- Çocuk Kullanıcı: Dersleri görür, egzersiz yapar, ses kaydı yükler, sınırlı ayar (tema, ses seviyesi) değiştirir.
- Ebeveyn: Bağlı çocuk(lar)ın ilerlemesini, XP, streak, zayıf alan özetlerini görür. Çocuğun hesap ayarlarını (bildirim, kullanım süresi limiti) düzenleyebilir.
- Yetişkin Tekil Öğrenen (Solo): Çocuk kısıtları olmadan tam öğrenme akışını kullanır.
- Admin (İç Sistem): İçerik yayınlama, düzeltme, moderasyon (ses kayıt inceleme), rozet tanımı, risk işaretli AI sonuçlarını gözden geçirme.

Yetki Özetleri
- İçerik Düzenleme: Sadece Admin
- Kullanıcı Verisini Silme Talebi İşleme: Admin + Otomasyon
- Çocuk Hesabı Oluşturma / Bağlama: Ebeveyn
- AI Geri Bildirim İnceleme (flagged): Admin / İçerik Danışmanı

3. Temel Felsefe ve Pedagojik Yaklaşım
Kısa, odaklı ve günlük tamamlanabilir dersler (5-10 dakika)

Etkileşimli ve çoklu egzersiz tipleri (sesli tekrar, yazma, eşleştirme vb.)

Anında ve nazik geri bildirim sistemi

Aralıklı tekrar (spaced repetition) ile kalıcı öğrenme

Oyunlaştırma ile yüksek motivasyon ve kullanıcı bağlılığı

3.1. Pedagojik İlkeleri Destekleyen Teknik Unsurlar
- Aralıklı Tekrar: Zayıf alanları (yanlış / düşük doğruluk puanlı harf & kelime) algoritmik olarak 1., 3., 7., 14. gün tekrar yüzeyleme.
- Çoklu Modalite: Görsel (harf form varyasyonları), İşitsel (telaffuz), Kinestetik (tracing) birleşimi.
- Mikro Geri Bildirim: Her egzersizde 2 sn içinde görsel + kısa nazik mesaj.
- Erken Motivasyon: İlk 10 derste hata toleransı yüksek (hearts tüketimi sınırlı).

4. Ürün Özellikleri
4.1. Eğitim İçeriği ve Modüller
Modül	İçerik	Egzersizler
Modül 1: Elif-Ba ve Harflerin Tanınması	Harflerin yazılışları (başta, ortada, sonda), mahreç (ağız çıkış yeri) animasyonları	Harf seçme, dinleyip tanıma, parmakla çizim (tracing), sesli tekrar
Modül 2: Tecvid Kuralları	Temel tecvid kuralları basitleştirilmiş isimlerle	Kural tanıma, sesli ve yazılı doğrulama
Modül 3: Kelime Hazinesi	Kur’an’da sık geçen kelimeler, anlamları	Flashcard, eşleştirme, kelime tamamlama
Modül 4: Kısa Sureler & Dualar	Fatiha, İhlas gibi sureler ve günlük dualar	Dinle, oku, ses kaydı ile tekrar, kelime sıralama, eksik tamamlama
Modül 5: Kur’an Okuma & Anlama	Cüz cüz okuma, ayet anlamları, kısa tefsirler	Okuma pratiği, ayet seçimi, anlam tıklama

4.1.1. İçerik Genişleme Stratejisi
- MVP Sonrası Öncelik: Namaz sureleri → Günlük dualar → Tecvid temel kuralları → Kelime hazinesi (frekans bazlı) → Cüz bazlı okuma.
- İçerik Sürümleme: lessonVersion alanı ile revizyon izleme.
- Onay Süreci: Taslak → Pedagoji İnceleme → Dini Doğrulama → Ses Kayıt → QA → Yayın.

4.2. Oyunlaştırma (Gamification)
XP (Deneyim Puanı): Ders ve egzersiz tamamlama bazlı

Seviye Atlama: XP’ye göre kullanıcı seviyeleri

Seri (Streak): Günlük aktif kullanım ödüllendirmesi

Ligler: Haftalık XP sıralamasıyla Bronz/Gümüş/Altın ligleri

Başarımlar: Rozetler, madalyalar (örneğin: “İlk Sure Ezberlendi”)

Can Sistemi: Yanlışlar can kaybına sebep olur, can bittiğinde bekleme veya satın alma

Sanal Para: Derslerden kazanılır, mağazada kozmetik veya güçlendirme alınır

4.2.1. Gamification Mekanik Detayları
- XP: baseXP * performanceMultiplier. baseXP örnekleri: Harf Tanıma 8, Tracing 10, Sure Tekrar 15.
- performanceMultiplier: >=95% 1.2, 80-95% 1.0, 60-80% 0.8, <60% 0.6.
- Level XP Gereksinimi: round(50 * level^1.5). Level up → +1 heart (üst limit tartışılacak) + animasyon.
- Streak: Günlük ≥1 ders tamamla → +1. Grace: 30 saat.
- Hearts: Başlangıç 5; kritik ardışık yanlış seti → -1. Hearts=0 → bekleme / reklam / premium.
- Rozet Kategorileri: Progress, Consistency, Mastery, Exploration, Social.
- Lig (Faz 2): İlk etapta haftalık XP listesi (light). Tam lig: kullanıcı tabanı eşiği aşıldığında.
- Sanal Para: XP/10 (floor). Mağaza Faz 2 sonu.

4.2.2. Anti-Abuse Önlemleri
- Aynı dersi 3 ardışık tekrar → azalan XP (0.5 sonra 0.25 multiplier).
- Hızlı spam yanlış (cevap <1sn seri) → geçici rate limit.

4.3. Kullanıcı Yönetimi
E-posta ve sosyal medya ile kayıt/giriş

Profil ve ilerleme sayfası

Ebeveyn kontrol paneli (çocuk takibi, ilerleme raporu)

4.3.1. Ebeveyn Onay Akışı
1. Ebeveyn e-posta doğrulama
2. Çocuk profili oluşturma (doğum yılı, takma ad)
3. Gizlilik bilgilendirme onayı
4. Silme Talebi: Uygulama içi form → 30 gün içinde kalıcı silme (soft delete + purge kuyruğu)

4.4. Bildirimler
Günlük ders hatırlatmaları

Özel günlerde dua önerileri ve motivasyon mesajları

4.4.1. Bildirim Mantığı
- Günlük Hedef: Lokal saat 18:00 (kullanıcı etkileşimi yoksa).
- Streak Kurtarma: Streak bitimine 4 saat kala.
- AI Geri Bildirim (Faz 3): "Telaffuz analizin hazır" (opt-in).

5. AI Entegrasyonu ve Yapay Zeka Kullanım Alanları
5.1. Sesli Telaffuz Analizi
Kullanıcının okuduğu harf, kelime ve sureleri ses kaydı ile analiz eder.

Google Cloud Speech-to-Text, Azure Speech Services veya open-source modellerle doğru telaffuz değerlendirmesi yapılır.

Anlık geri bildirim: Hangi harfi doğru/yanlış okuduğunu nazikçe bildirir.

İleri aşamalarda derin öğrenme tabanlı telaffuz düzeltme ve hata analizi.

5.2. Yazma ve Okuma Hatası Tespiti
Kullanıcının yazdığı metindeki hataları yapay zeka destekli dil modeliyle tespit eder.

Kur’an yazımı ve Arapça harf doğruluğu için özel kurallar ve ML destekli öneriler.

5.3. Kişiselleştirilmiş Öğrenme Önerileri
Kullanıcının performansını analiz eden makine öğrenimi algoritmaları ile zayıf noktaları belirler.

Buna göre ders ve egzersiz önerileri sunar.

Spaced repetition algoritması ile tekrar zamanlamasını optimize eder.

5.4. AI Entegrasyon Teknikleri
Bulut AI API’leri: Google Cloud, Azure, IBM Watson (ses, NLP)

Mobilde AI: TensorFlow Lite ile offline ses/ses analizi modelleri

Backend ML: Performans takibi ve öneri sistemi için TensorFlow, PyTorch tabanlı modeller

5.5. AI POC Başarı Kriterleri
- Kapsam: 10 harf + 10 temel kelime.
- Metrikler: Accuracy ≥ %85, False Positive ≤ %10, Ortalama latency <1500ms.
- Geri Bildirim Formatı: Harf bazlı renk + ≤90 karakter öneri.
- Veri Saklama: İşlenmiş ses ≤90 gün (silme politikası uyumlu).

5.6. Kişiselleştirilmiş Öğrenme (İlk Taslak)
- WeakAreaScore = Σ (attemptWeight * (1 - accuracy)).
- Spaced intervals: 1d, 3d, 7d, 14d, 30d (başarılı → interval artar, başarısız → reset).

6. Teknik Mimari
6.1. Frontend
Flutter ile iOS ve Android için tek kod tabanı

UI/UX: Çocuk dostu, renkli, erişilebilir ve İslami motiflerle modern tasarım

State Management: Riverpod veya Provider

6.1.1. Teknik Karar Notları (MVP)
- State: Riverpod
- Kod Üretim: freezed + json_serializable
- Arka Plan Kuyruk: Ses yükleme retry queue

6.2. Backend
Firebase Authentication ve Firestore (hızlı MVP için)

Node.js veya Python Django REST API (gerektiğinde AI modeller ve gelişmiş backend)

Bulut dosya depolama: AWS S3 veya Firebase Storage (ses, video, ders içerikleri)

Bildirimler: Firebase Cloud Messaging (FCM)

6.2.1. Firestore Veri Modeli Taslak
- users { displayName, role, xp, level, streak {current,lastActiveDate}, hearts, settings {locale, notifications}, weakAreas[], createdAt }
- parentLinks { parentId, childUserId, status }
- lessons { moduleId, type, order, prereqIds[], version }
- lessonContent { lessonId, locale, segments[ {type, payload} ] }
- userLessonProgress { userId, lessonId, status, accuracy, attempts, lastAnsweredAt }
- recordings { userId, lessonId, unitId, storagePath, durationMs, aiScore?, createdAt }
- achievements { code, title, criteriaJson }
- userAchievements { userId, achievementCode, earnedAt }
- weeklyLeaderboards { weekISO, entries[ {userId, xp} ], generatedAt }
İndeks: userLessonProgress (userId+lessonId), recordings (userId+createdAt), weeklyLeaderboards (weekISO)

6.2.2. Güvenlik İlkeleri
- Kullanıcı sadece kendi user & progress kayıtlarını okur/yazar.
- parentLinks yalnızca parentId/childUserId üzerinden sorgulanabilir.
- recordings AI servis hesabı read; kullanıcı sadece kendi kayıtlarını listeler.

6.3.1. AI Veri Pipeline
- Normalize: 16kHz mono PCM WAV
- Gürültü azaltma + trim
- Log: processingLatencyMs, aiConfidenceScore, userAcceptedFeedback, modelVersion

6.3. AI Katmanı
AI API entegrasyonu için backend microservice yapısı

TensorFlow Serving veya serverless fonksiyonlar (Google Cloud Functions, AWS Lambda)

7. Güvenlik ve Uyumluluk
GDPR ve KVKK uyumu (özellikle çocuk veri koruması)

Şifrelenmiş veri saklama ve güvenli iletişim (HTTPS, JWT)

Ebeveyn onayı ve çocuk profili kısıtlamaları

İçerik ve dini doğruluk onayı: Alanında uzman ilahiyatçılar ve hafızlar

7.1. KVKK/GDPR Uyum Maddeleri
- Veri Minimizasyonu (gerçek isim zorunlu değil)
- Silme Hakkı: 30 gün süreç, soft delete + purge kuyruğu
- Erişim log anonimleştirme 30 gün sonra
- AI ses yeniden kullanım açık rıza (varsayılan kapalı)

7.2. İçerik Onay Kayıtları
- revisionId, approvedBy, approvedAt saklanır.

8. Geliştirme Yol Haritası
Faz	Hedefler	Süre
Faz 1 (MVP)	- Kullanıcı yönetimi, Elif-Ba modülü (harf tanıma, yazma)
- Fatiha, İhlas sureleri
- XP, seri ve puanlama sistemi
- Basit ses kaydı ve dinleme	6 hafta
Faz 2	- Tüm namaz sureleri ve dualar
- Ligler, rozetler, başarımlar
- Kelime hazinesi
- Ebeveyn kontrol paneli
- Bildirim sistemi	6 hafta
Faz 3	- AI destekli telaffuz analizi
- Yazma/okuma hatası tespiti
- Kişiselleştirilmiş tekrar ve öğrenme önerileri
- Cüz cüz Kur’an okuma ve tefsir modülü	8 hafta

8.1. MVP Kapsam Daraltma Notu
- Dahil: Elif-Ba temel egzersiz, 2 kısa sure, XP + streak, ses kaydı (dinle, analiz yok).
- Hariç: Lig, mağaza, gelişmiş rozetler, AI telaffuz, tefsir.

8.2. MVP Çıkış Kriterleri
- Crash-free session ≥ %95
- İlk 10 ders tamamlanabilir
- Streak & XP test senaryoları yeşil
- Firestore güvenlik negatif testleri geçer

9. Monetizasyon Modeli
Freemium: Temel dersler ücretsiz, premium abonelik ile reklam kaldırma, sınırsız can, offline dersler, ekstra içeriklere erişim

Sanal Mağaza: Oyun içi para ile kozmetik ve güçlendirmeler satın alma

Bağış & Destek: Uygulama içi bağış seçenekleri, hayır amaçlı kampanyalar

9.1. Premium Paket Taslakları
- Premium A: Reklamsız + Sınırsız Hearts + Offline Ders.
- Premium B: A + Genişletilmiş içerik + Erken AI beta.
- Eventler: trial_started, trial_converted, premium_canceled.

10. Önemli Notlar ve Riskler
İçerik Doğruluğu: Dini metin ve eğitim materyalleri mutlaka uzmanlarca onaylanmalı.

AI Modellerinin Hassasiyeti: Telaffuz ve yazım analizi hassas ve kültürel açıdan doğru olmalı.

Çocuk Güvenliği: Veri gizliliği ve ebeveyn kontrol mekanizmaları özenle planlanmalı.

Teknik Ölçeklenebilirlik: Kullanıcı arttıkça altyapı ölçeklenebilir olmalı.

10.1. Ek Riskler ve Azaltımlar
- Ses Depolama Maliyeti: Eski (≥30gün) düşük aiScore kayıtları lifecycle ile sil.
- XP Abuse: Günlük XP soft cap + anomali tespiti.
- Performans: LessonContent local cache.
- AI Yanlılık: Düşük güven flag manual review.
- Premium Paylaşım: Feature flag sunucu doğrulaması.

11. Analitik & KPI
- Activation (İlk 24h ≥1 ders)
- D1/D7/D30 Retention
- DAU/MAU
- Avg Session Length, Sessions/User/Week
- Lesson Completion Rate
- Error Rate (app + AI failure %)
- Streak Median
- Weak Area Closure Time
- Premium dönüşüm (trial→paid %)

12. Açık Sorular
- Hearts üst limit? (öneri 7)
- Lig başlama eşiği? (öneri 5k MAU)
- AI sağlayıcı öncelik sırası? (Google STT vs open-source)

13. Sonraki Adımlar
- data_model.md
- analytics_events.md
- sprint0_checklist.md

Sonuç
Bu PRD, projenin pedagojik, teknik, AI ve iş modeli detaylarını kapsayarak, uygulamanın başarılı, etkili ve sürdürülebilir şekilde geliştirilmesine zemin hazırlar. İstersen bu PRD üzerinden özel olarak frontend ekran tasarımları, backend API şemaları veya AI modülleri için detaylara geçebiliriz.

