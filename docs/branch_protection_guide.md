# Branch Koruma Rehberi

Önerilen GitHub ayarları (`Settings > Branches > Branch protection rules`):

## 1. main
- Require a pull request before merging: ON
  - Required approvals: 1 (ileride 2 olabilir)
  - Dismiss stale pull request approvals when new commits are pushed: ON
- Require status checks to pass before merging: ON
  - CI workflow: `CI` seçili
- Require branches to be up to date before merging: ON
- Require linear history: ON (opsiyonel)
- Include administrators: ON (disiplin için önerilir)
- Allow force pushes: OFF
- Allow deletions: OFF

## 2. develop (opsiyonel)
- Require PR before merge: ON (daha hafif kurallar)
- Required approvals: 0 veya 1
- Status checks: Analyzer + Tests

## 3. Konvansiyon
- Feature branch isimleri: `feature/<kisa-konu>`
- Hotfix: `hotfix/<problem>` (main'e PR + develop senkron)
- Release: `release/<versiyon>` (tag + CHANGELOG güncellemesi)

## 4. Otomasyon Önerileri (V2)
- Lint & test sonuç yorum botu
- Dependabot security updates (haftalık)
- PR template (kısa: Amaç / Değişiklikler / Testler / İlgili Doküman)

## 5. Manuel Adımlar
Bu rehberi uyguladıktan sonra `sprint0_checklist.md` branch koruma maddesi işaretlenebilir.
