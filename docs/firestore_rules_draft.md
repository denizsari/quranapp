# Firestore Security Rules Taslak (v0.1)

Bu taslak; production öncesi refine edilmesi gereken ilk kural setidir.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() { return request.auth != null; }
    function uid() { return request.auth.uid; }
    function isAdmin() { return isSignedIn() && exists(/databases/$(database)/documents/users/$(uid())) &&
      get(/databases/$(database)/documents/users/$(uid())).data.role == 'admin'; }

    match /users/{userId} {
      allow read, update: if isSignedIn() && userId == uid();
      allow create: if isSignedIn() && userId == uid();
      allow delete: if false; // Silme talepleri server-side queue
      allow list: if false; // Toplu listeleme engeli (privacy)
      // Admin override (minimum):
      allow get: if isAdmin();
      allow update: if isAdmin();
    }

    match /parentLinks/{linkId} {
      allow create: if isSignedIn();
      allow get: if isSignedIn() && (resource.data.parentId == uid() || resource.data.childUserId == uid());
      allow update: if isSignedIn() && (resource.data.parentId == uid());
      allow delete: if isAdmin();
      allow list: if false; // Query param gerekecek
    }

    match /lessons/{lessonId} {
      allow read: if true; // Sadece active false ise filtre client tarafı (alternatif: rule check)
      allow write: if isAdmin();
    }

    match /lessonContent/{docId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /userLessonProgress/{docId} {
      allow read, write: if isSignedIn() && request.resource.data.userId == uid();
      allow list: if isSignedIn(); // Firestore sınırları; userId ile query edilmesi gerekiyor
    }

    match /recordings/{recId} {
      allow create: if isSignedIn() && request.resource.data.userId == uid();
      allow get: if isSignedIn() && resource.data.userId == uid();
      allow update: if false; // Değişmez; yeni versiyon create
      allow delete: if isSignedIn() && resource.data.userId == uid();
      allow list: if false; // query userId equality condition enforced from client
    }

    match /achievements/{code} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /userAchievements/{docId} {
      allow create: if isSignedIn() && request.resource.data.userId == uid();
      allow read: if isSignedIn() && resource.data.userId == uid();
      allow list: if false;
      allow update, delete: if false; // immutable
    }

    match /weeklyLeaderboards/{week} {
      allow read: if true;
      allow write: if isAdmin(); // Veya Cloud Function servis hesabı
    }

    match /systemFlags/{flag} {
      allow read: if true; // feature flag public safe subset
      allow write: if isAdmin();
    }
  }
}
```

## Notlar / Açık Sorular
- lessons active alanı rule içinde kontrol edilmeli mi? (Performans vs esneklik)
- Silme talepleri için ayrı queue koleksiyonu gerekebilir.
- AI servis hesabı için özel token tabanlı erişim mi yoksa admin role mu?

## Test Planı (Emulator)
| Test | Senaryo | Beklenen |
|------|---------|----------|
| USER_READ_SELF | user okur kendi belgesini | 200 |
| USER_READ_OTHER | user başka user doc okur | 403 |
| ADMIN_WRITE_LESSON | admin lesson yazar | 200 |
| CHILD_CREATE_RECORDING | user recordings create | 200 |
| CHILD_READ_OTHER_RECORDING | user farklı recording id | 403 |
| MUTATE_ACHIEVEMENT_USER | user achievements doc update | 403 |

---
Revizyon: v0.1
