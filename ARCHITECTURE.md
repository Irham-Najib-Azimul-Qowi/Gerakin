# GERAKIN Enterprise Architecture Specification

Dokumen ini mendokumentasikan spesifikasi arsitektur enterprise, prinsip desain, dan alur data untuk aplikasi **GERAKIN**.

---

## 🏗️ Clean Architecture & Layering

Aplikasi GERAKIN mengadopsi pola **Clean Architecture** yang terbagi menjadi 3 lapisan utama di setiap modul fitur (`features/<feature_name>`):

```
lib/features/<feature>/
├── presentation/          # Lapisan Antarmuka (UI Widgets, Riverpod Controllers/Notifiers)
├── domain/                # Lapisan Bisnis Inti (Use Cases, Models, Repository Interfaces)
├── data/                  # Lapisan Akses Data (ObjectBox Local Box, Firestore Data Sources, Repositories Impl)
├── services/              # Engine Spesifik & Business Rule Engines
└── models/                # ObjectBox Entities (@Entity)
```

### Prinsip Utama:
1. **Dependency Inversion Principle (DIP)**: Lapisan UI (`presentation`) dan logika bisnis (`domain`) hanya bergantung pada abstraksi antarmuka repositori (`repository interface`), bukan pada implementasi konkret database atau cloud.
2. **Offline-First Resilience**: Pembacaan dan penulisan data selalu mengeksekusi operasi lokal ke ObjectBox terlebih dahulu. Penulisan ke cloud Firestore diantrekan secara asinkron melalui `SyncEngine`.
3. **Single Responsibility Principle (SRP)**: Setiap engine (misal `XPEngine`, `LevelEngine`, `StreakEngine`, `RetryManager`) memegang satu fokus tugas yang jelas.

---

## 🔄 Offline-First Cloud Synchronization Pipeline

```
[ UI User Action ]
       │
       ▼
[ Local ObjectBox Store ]  ◄── (Instant 0ms Read/Write)
       │
       ▼
[ Local SyncQueue Box ] ──► (State: pending)
       │
       ▼
[ Connectivity Monitor ] ── (Memeriksa Koneksi Internet)
       │
   [ Online? ]
   ├── YES ──► [ SyncEngine ] ──► [ Remote Firestore ]
   │                 │
   │            [ Fail? ] ──► [ RetryManager ] (Exponential Backoff: 1s, 2s, 4s...)
   │                 │
   │            [ Conflict? ] ──► [ ConflictResolver ] (Last Write Wins strategy)
   │
   └── NO  ──► [ Abort Processing & Wait for Reconnection ]
```

---

## 🛡️ Security & ProGuard Compliance

* **Obfuscation**: Konfigurasi `android/app/proguard-rules.pro` melindungi entitas ObjectBox, plugin Flutter, dan SDK Firebase agar tidak dapat di-reverse-engineer.
* **Input Sanitization**: Kelas `SecurityHardening` menyaring karakter khusus dan tag HTML pada seluruh input bidang teks.

---

## 🧪 Strategi Pengujian (Testing Strategy)

* **Unit Testing**: Pengujian mandiri terhadap kalkulasi matematika engine (misal `XPEngine`, `JointAngleCalculator`, `RetryManager`, `StreakEngine`).
* **Mock Repositories**: Pengujian menggunakan representasi repositori in-memory tanpa ketergantungan pada runtime binary ObjectBox native, sehingga tes dapat berjalan super cepat dalam hitungan milidetik.
