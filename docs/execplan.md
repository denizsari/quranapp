Kuran & Arapça Öğrenme Uygulaması - Proje Yürütme Planı (Execution Plan)
Doküman Amacı: Bu plan, PRD'de tanımlanan hedeflere ulaşmak için gerekli olan teknik adımları, görev dağılımını, zaman çizelgesini, kullanılacak araçları ve metodolojiyi detaylandırmaktadır.

1. Proje Ekibi ve Roller (Varsayımsal)
Proje Yöneticisi/Scrum Master: Proje takibini yapar, engelleri kaldırır, ekibin senkronizasyonunu sağlar.

Flutter Geliştiricisi (Frontend): Kullanıcı arayüzü (UI), kullanıcı deneyimi (UX) ve uygulama içi mantığın Flutter ile geliştirilmesinden sorumlu.

Backend Geliştiricisi: Sunucu, veritabanı, API'ler ve AI servis entegrasyonlarından sorumlu.

UI/UX Tasarımcısı: Uygulamanın ekran tasarımlarını, prototiplerini ve kullanıcı akışlarını Figma gibi araçlarla hazırlar.

AI/ML Mühendisi (Faz 3 için kritik): Telaffuz analizi ve kişiselleştirme algoritmalarının geliştirilmesi veya entegrasyonundan sorumlu.

Dini İçerik ve Pedagoji Danışmanı: Tüm eğitim içeriğinin doğruluğunu, pedagojik uygunluğunu denetler ve onaylar. Bu rol, projenin en kritik paydaşıdır.

1.1. RACI Özet (Seçilmiş Alanlar)
- İçerik Yayınlama: R (İçerik Danışmanı), A (Admin), C (Flutter Dev - entegrasyon), I (PM)
- Firestore Şema Değişikliği: R (Backend), A (Backend Lead), C (Flutter Dev, AI), I (PM)
- AI Model Seçimi: R (AI Müh.), A (AI Müh. Lead / yoksa Backend), C (Backend, İçerik Danışmanı), I (PM)
- Güvenlik & KVKK İncelemesi: R (Backend), A (PM), C (İçerik Danışmanı), I (Tüm ekip)
- Release Onayı: R (PM), A (PM), C (Flutter/Backend), I (Danışman)

2. Kullanılacak Araçlar ve Platformlar
Proje Yönetimi: Jira veya Trello. Görevler (task), hikayeler (user story) ve hatalar (bug) burada takip edilecek.

Versiyon Kontrolü: Git (Depo olarak GitHub veya GitLab kullanılacak).

Tasarım ve Prototip: Figma. Tüm ekran tasarımları ve interaktif prototipler burada oluşturulacak.

İletişim: Slack veya Discord. Ekip içi anlık iletişim için kullanılacak.

Dokümantasyon: Notion veya Confluence. PRD, API dokümantasyonu ve toplantı notları burada tutulacak.

CI/CD (Sürekli Entegrasyon/Dağıtım): Codemagic veya GitHub Actions for Flutter. Kodun otomatik olarak test edilip derlenmesini ve dağıtımını sağlar.

2.1. Branch Stratejisi
- main: Üretim (tag'li release) branch.
- develop: Entegre edilmiş test edilen özellikler.
- feature/<kısa-isim>: Tekil user story veya düzeltme.
- release/x.y.z: (Opsiyonel) Stabilizasyon süreci.

2.2. Ortamlar
- Dev: Firebase dev project (dev prefix), crashlytics dev.
- Staging: Pre-prod veri maskelenmiş, load test.
- Prod: Sıkı güvenlik kuralları, sadece CI deploy.

2.3. Otomasyon Araçları (Öneri)
- commit hook: dart format + analyzer.
- script: tools/bump_version.dart (semantic version + CHANGELOG append).

3. Geliştirme Metodolojisi: Agile (Scrum)
PRD'deki fazlı yapı, sprint'lere bölünerek yönetilecektir.

Sprint Süresi: 2 Hafta.

Toplantılar:

Sprint Planlama: Her sprint başında o sprint'te yapılacak işler seçilir ve planlanır.

Günlük Stand-up: Her gün 15 dakikalık kısa toplantılarla "dün ne yaptım, bugün ne yapacağım, bir engelim var mı?" soruları cevaplanır.

Sprint Değerlendirme (Review): Sprint sonunda yapılan işler paydaşlara (özellikle İçerik Danışmanına) sunulur ve geri bildirim alınır.

Sprint Retrospektifi: Ekip kendi içinde süreci değerlendirir, nelerin iyi gittiğini ve nelerin iyileştirilebileceğini konuşur.

3.1. Definition of Ready (DoR) Kriterleri
- User Story tanımı INVEST uyumlu.
- Kabul kriterleri Gherkin veya madde listesi.
- Tasarım linki (Figma frame) eklendi.
- Veri alanı / API değişiklikleri not edildi.
- Güvenlik veya KVKK etkisi değerlendirildi.

3.2. Definition of Done (DoD) Kriterleri
- Tüm acceptance test senaryoları geçti.
- Analyzer & format temiz.
- Crashlytics yeni hata eklemedi (staging smoke test).
- İlgili dokümantasyon (README veya md) güncellendi.
- Telemetri event’leri eklendi ve test modunda gözlendi.

4. Detaylı Eylem Planı ve Zaman Çizelgesi
PRD'deki yol haritasını sprint'lere bölerek somutlaştırıyoruz.

Sprint 0: Kurulum ve Hazırlık (1 Hafta)
Görevler:

Jira/Trello panosunun oluşturulması ve ilk backlog'un girilmesi.

GitHub reposunun oluşturulması ve branch (main, develop) stratejisinin belirlenmesi.

Flutter projesinin temel kurulumu (klasör yapısı, temel paketler).

Firebase projesinin oluşturulması (Authentication, Firestore, Storage).

Figma'da tasarım sisteminin (renkler, fontlar, bileşenler) hazırlanması.

CI/CD altyapısının temel konfigürasyonu.

Sprint 0 Çıktıları (Artifacts)
- Flutter proje iskeleti + paketler (riverpod, freezed, json_serializable, intl).
- .env.template + README quick start.
- Firebase dev config entegre.
- CI pipeline: build, test, analyze.
- Firestore güvenlik kuralları taslak.
- data_model.md ve analytics_events.md iskelet.

Faz 1: MVP (Minimum Uygulanabilir Ürün) - 6 Hafta
Sprint 1 (2 Hafta): Kullanıcı Yönetimi ve Ana Yapı

Frontend:

Giriş (Login), Kayıt (Register), Şifremi Unuttum ekranlarının tasarıma uygun geliştirilmesi.

Ana sayfa (ders ağacının görüneceği yer) ve profil sayfası iskeletinin oluşturulması.

State management (Riverpod/Provider) yapısının kurulması.

Backend:

Firebase Authentication ile e-posta/şifre ve sosyal medya giriş altyapısının tamamlanması.

Firestore'da users koleksiyonu şemasının oluşturulması (xp, level, streak, can vb.).

Tasarım/İçerik: Elif-Ba modülünün ders yapısının ve içeriğinin metin olarak hazırlanması.

Sprint 1 Kalite/Kontrol Noktaları
- Auth happy path E2E (manual + otomasyon).
- users koleksiyonu güvenlik test: pozitif/negatif örnekler.
- Performans: İlk açılış süresi < 3s hedef.

Sprint 2 (2 Hafta): Elif-Ba ve İlk Ders Modülü

Frontend:

Elif-Ba dersleri için UI'ın geliştirilmesi (Harf gösterme, dinleme butonu, çizim alanı).

"Harf Seçme", "Dinleyip Tanıma", "Parmakla Çizme" egzersizlerinin geliştirilmesi.

Backend:

Ders ve egzersiz verilerinin (sorular, cevaplar, ses dosyaları) Firestore'a eklenecek yapının oluşturulması.

Kullanıcının ders tamamlama ve cevap doğruluğu verilerinin kaydedilmesi.

İçerik: Elif-Ba ses kayıtlarının profesyonel olarak yapılması ve sisteme yüklenmesi.

Sprint 2 Kalite/Kontrol Noktaları
- Ders progression local cache çalışıyor.
- Çizim egzersizi dokunma latency < 50ms.
- Ses dosyaları boyut ortalama < 200KB (mobil veri optimizasyonu).

Sprint 3 (2 Hafta): Temel Oyunlaştırma ve İlk Sure

Frontend:

XP ve Seri (streak) mekanizmasının UI'da gösterilmesi.

Fatiha suresi ezber modülünün UI'ının geliştirilmesi (Dinle, Oku, Kaydet arayüzü).

Backend:

Ders tamamlandığında XP ve seri verilerinin güncellenmesi logiği.

Kullanıcının ses kaydını Firebase Storage'a yükleme ve dinleme fonksiyonu.

QA & Test: MVP'nin ilk kapsamlı testlerinin yapılması ve hataların giderilmesi.

Sprint 3 Kalite/Kontrol Noktaları
- XP hesaplama unit test coverage ≥ %90 ilgili modül.
- Streak edge case (hafta sonu + saat farkı) testi.
- Crash free seviye ≥ %95 (staging).

Faz 2: Gelişmiş Özellikler - 6 Hafta
Sprint 4 (2 Hafta): Oyunlaştırma ve İçerik Genişletme

Frontend/Backend:

Lig sisteminin (Bronz, Gümüş, Altın) geliştirilmesi. Haftalık olarak kullanıcıları XP'ye göre sıralayan ve terfi/tenzil ettiren bir backend script'i yazılması.

Başarımlar (rozetler) sistemi ve UI'ı.

Tüm namaz sureleri ve günlük duaların içerik ve ses kayıtlarının eklenmesi.

Sprint 4 Kalite/Kontrol Noktaları
- Leaderboard firestore read maliyeti ölçümü ( hedef < 1 read/user/week ).
- Rozet kazanma event telemetri doğrulama.

Sprint 5 (2 Hafta): Ebeveyn Paneli ve Kelime Hazinesi

Frontend/Backend:

Ebeveynlerin çocuklarını ekleyebileceği ve ilerlemelerini (tamamlanan ders, kazanılan XP) görebileceği bir panel geliştirilmesi.

Kelime Hazinesi modülü (Flashcard, eşleştirme) geliştirilmesi.

Sprint 5 Kalite/Kontrol Noktaları
- Parent-child link güvenlik testi.
- Kelime flashcard offline cache (min 10 kelime) doğrulandı.

Sprint 6 (2 Hafta): Bildirimler ve Optimizasyon

Frontend/Backend:

Firebase Cloud Messaging (FCM) entegrasyonu.

"Haydi ders zamanı!", "Serini kaybetme!" gibi günlük hatırlatıcıların planlanması.

Uygulama genelinde performans optimizasyonu ve kullanıcı geri bildirimlerine göre iyileştirmeler.

Sprint 6 Kalite/Kontrol Noktaları
- Notification opt-in rate ölçümü (event).
- Soğuk başlatma süresi artmadı (regression check).

Faz 3: AI Entegrasyonu ve Kur'an Okuma - 8 Hafta
Sprint 7 (2 Hafta): AI Servis Araştırma ve POC (Kavram Kanıtlama)

AI/Backend: Google/Azure/Open Source ses analiz servislerinin araştırılması. Birkaç harf ve kelime ile telaffuz doğruluğunu test eden bir Proof of Concept geliştirilmesi.

Frontend: Telaffuz sonrası geri bildirim (doğru/yanlış/yakın) için UI tasarımı.

Sprint 7 Başarı Kriterleri
- 10 harf + 10 kelime seti.
- Accuracy ≥ %80 POC.
- Latency ortalama < 2000ms.

Sprint 8 (2 Hafta): Telaffuz Analizi Entegrasyonu

Frontend/Backend: Seçilen AI servisinin API'sinin backend'e entegre edilmesi. Flutter uygulamasından gönderilen sesin bu servise iletilip sonucun geri alınması akışının tamamlanması.

Sprint 9 (2 Hafta): Kişiselleştirilmiş Tekrar ve Kur'an Okuma Modülü

Backend: Kullanıcının yanlış yaptığı harf/kelimeleri kaydeden ve "Aralıklı Tekrar" algoritmasına göre bunları tekrar önüne getiren sistemin geliştirilmesi.

Frontend: Cüz cüz Kur'an okuma modülünün UI'ı. Ayetlerin üzerine tıklayınca meal gösterilmesi.

Sprint 9 Kalite/Kontrol Noktaları
- Spaced repetition scheduling doğruluk testleri (mock time ileri sarma).
- Meal gösterimi locale fallback testi.

Sprint 10 (2 Hafta): AI İyileştirmeleri ve Beta Test

AI/Backend: Telaffuz analizinin hassasiyetinin artırılması.

QA: AI özelliklerinin geniş bir kullanıcı kitlesiyle (beta testerlar) test edilmesi ve geri bildirim toplanması.

Sprint 10 Çıktıları
- Model versiyon dokümanı (model_versioning.md).
- Beta feedback sınıflandırma raporu.

Tüm Fazlar: Güvenlik (KVKK/GDPR) ve veri gizliliği kontrollerinin yapılması.

5. Risk Yönetimi ve Önlemler
Risk	Olasılık	Etki	Önlem / Azaltma Stratejisi
Dini İçerik Hatası	Düşük	Yüksek	Proje başından itibaren Dini İçerik Danışmanı ile çalışmak. Her içerik (metin, ses, tecvid kuralı) yayınlanmadan önce yazılı onay (sign-off) alınacak.
AI Telaffuz Analizi Zayıf	Orta	Yüksek	Faz 3'te POC ile başlamak. En iyi API'yi seçmek ve gerekirse basit hatalara (örneğin sadece harf mahrecine) odaklanmak. Kullanıcıya "Bu bir yardımcıdır" mesajı vermek.
Çocuk Güvenliği İhlali	Düşük	Yüksek	KVKK/GDPR danışmanlığı almak. Ebeveyn onayı mekanizmasını en başta kurmak. Mümkün olan en az kişisel veriyi toplamak.
Proje Gecikmesi	Orta	Orta	Agile/Scrum metodolojisini sıkı takip etmek. Riskleri ve engelleri günlük toplantılarda erkenden tespit edip çözmek. MVP kapsamını net tutmak.

6. Operasyonel İzleme & Metrikler
- Crash Rate (Crashlytics) hedef < %2 oturum.
- P75 Launch Time.
- API Error Rate %.
- Recording Upload Success Rate.
- Daily Active Users, Activation Rate.

7. Kalite Güvencesi Stratejisi
- Test Piramidi: Unit (logic) > Widget (Flutter) > Entegre E2E (integration_test / Maestro).
- Minimum Coverage: %70 global, kritik modüller (XP, streak) %90.
- Güvenlik Testleri: Firestore rules emulator otomasyon pipeline.

8. Güvenlik & KVKK Uygulama Planı
- Sprint 1: Minimum veri (email + displayName/takma ad) - PII audit.
- Sprint 3: Silme talebi endpoint taslağı.
- Sprint 5: Parent-child bağ onay kayıtları.
- Sprint 7: AI pipeline'da anonim ID.

9. AI POC Planı (Detay)
Adımlar: Veri toplama → Annotation → Model/Servis kıyas (Accuracy, Latency, Cost) → Basit geri bildirim UI test → Karar raporu.
Çıktılar: ai_poc_report.md, model_selection_matrix.xlsx (örn. cost/accuracy skorlaması).

10. Bağımlılık ve Versiyon Stratejisi
- Lockfile commit zorunlu.
- Dependabot (haftalık) / Flutter pub upgrade script.
- SemVer: MAJOR (breaking UI/şema), MINOR (özellik), PATCH (bug).

11. Çevresel Gereksinimler
- Desteklenen Minimum OS: iOS 14, Android 7 (API 24).
- Ekran Uyumu: 16:9, 19.5:9, tablet layout check (≥600dp breakpoint).

12. Risk Genişletme (Ek)
- Ses Depolama Maliyeti: Orta/Orta → Lifecycle policy + sıkıştırma.
- Leaderboard Okuma Maliyeti: Orta/Düşük → Haftalık precompute Cloud Function.
- Model Yanlış Geri Bildirim: Orta/Yüksek → Confidence threshold + fallback "Tekrar dene" mesajı.
- Performans Degradasyonu (AI entegrasyon): Orta/Orta → Lazy init + arka plan prefetch.

13. Dokümantasyon Yapısı (Önerilen)
- README.md (yükleme, çalıştırma, mimari özet)
- docs/data_model.md
- docs/analytics_events.md
- docs/security_privacy.md
- docs/ai/ poc_report.md (ileride)

14. Sonraki Adımlar (Hızlı)
- data_model.md ve analytics_events.md oluştur (Sprint 0).
- CI pipeline'a Firestore rules test ekle.
- AI POC veri toplama onay formu taslağı.