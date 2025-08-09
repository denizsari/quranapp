# Commit Mesaj Format Rehberi (Conventional Commits)

Format:
```
<tip>(scope)!: kisa aciklama

<Istege bagli detayli aciklama>

BREAKING CHANGE: ... (varsa)
Refs: #issue-id
```

Desteklenen tipler:
- feat: Yeni ozellik
- fix: Hata duzeltme
- docs: Dokumantasyon degisimi
- style: Format / stil (islev yok)
- refactor: Davranisi degistirmeden kod iyilestirme
- perf: Performans iyilestirmesi
- test: Test ekleme / duzeltme
- build: Derleme araci / bagimlilik degisimi
- ci: CI config degisikligi
- chore: Kucuk bakim (kod disi)

Ornekler:
- `feat(auth): email login akisi eklendi`
- `fix(progress): level hesaplama integer truncation` 
- `docs(readme): kurulum adimi` 
- `refactor(lesson): provider yapisi sade` 

Kurallar:
1. Ilk satir 72 karakteri asmamali.
2. Imperative kip kullan ("add", "fix").
3. Scope opsiyonel; modul klasor adi veya domain (auth, ui, core).
4. Breaking degisiklik icin `!` veya en alta `BREAKING CHANGE:` blogu.
5. Bir issue bagliysa `Refs: #ID` satiri.

PR Basligi = Ana commit mesaji (squash stratejisi onerilir).
