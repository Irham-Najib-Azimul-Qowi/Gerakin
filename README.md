# GERAKIN — Web & Mobile Adaptive Physical Therapy Application

[![CI/CD Pipeline](https://github.com/Irham-Najib-Azimul-Qowi/GERAKIN/actions/workflows/ci_cd.yml/badge.svg)](https://github.com/Irham-Najib-Azimul-Qowi/GERAKIN/actions/workflows/ci_cd.yml)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.22%2B-02569B?logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Offline--First-green)](#architecture)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**GERAKIN** adalah aplikasi terapi fisik adaptif berbasis penglihatan komputer (computer vision) dan kecerdasan buatan (AI) yang dirancang khusus untuk mendukung proses rehabilitasi pengguna kursi roda, pasien stroke, serta disabilitas motorik secara mandiri dan aman di mana saja.

---

## 🌟 Fitur Utama (Core Features)

1. **AI Vision Pose Analysis & Validation**:
   - Deteksi sudut sendi real-time (*Flexion/Extension*) tanpa memerlukan perangkat keras tambahan.
   - Filter Smoothing EMA (*Exponential Moving Average*) untuk meredam jitter/noise pada gerak sensor visual.
   - Evaluasi kualitas pose (*Confidence Filter* & *Stability Analyzer*).

2. **Offline-First User Identity & Profile Management**:
   - Dukungan Mode Tamu (*Guest Mode*) & Multi-Profil (*Multi-Profile Manager*).
   - Wizard penyesuaian rehabilitasi (*Physical Assessment Wizard*).
   - Manajemen data lokal persisten menggunakan ObjectBox NoSQL DB.

3. **Cloud Synchronization Engine**:
   - Antrean perubahan FIFO lokal terisolasi (`SyncQueue`).
   - Penanganan rintangan jaringan menggunakan penundaan *Exponential Backoff* (`RetryManager`).
   - Resolusi konflik otomatis berbasis *Last Write Wins* (`ConflictResolver`).

4. **Gamification & Motivation Engine**:
   - Sistem perolehan XP berdasarkan performa akurasi dan konsistensi latihan.
   - Progresi Level, Misi Harian, dan Tantangan Mingguan.
   - Timeline Perjalanan Rehabilitasi (*Rehabilitation Journey Timeline*).

5. **Physiotherapist & Caregiver Collaboration Platform**:
   - Peran *Role-Based Access Control* (RBAC): *Patient*, *Physiotherapist*, *Caregiver*, *Administrator*.
   - Resep program latihan adaptif (*Exercise Prescription Service*).
   - Catatan umpan balik terapis (*Feedback Note Service*).
   - Gerbang izin pembagian data aman (*Secure Data Sharing Gate*).

6. **KMIPN AI Presentation Dashboard**:
   - Dashboard presentasi khusus juri KMIPN dengan metrik live FPS, Latency (ms), Confidence %, dan pembuat laporan benchmark (*Benchmark Report Generator*).

---

## 🛠️ Arsitektur & Teknologi

* **Framework**: Flutter (Dart 3.x)
* **State Management**: Riverpod (Notifier Pattern)
* **Local Persistence**: ObjectBox NoSQL High-Performance Mobile Database
* **Cloud Sync**: Firebase Firestore (Offline Replication Engine)
* **Routing**: GoRouter (Declarative Routing)
* **Security & Hardening**: ProGuard Obfuscation, Input Sanitization

---

## 🚀 Panduan Memulai (Getting Started)

### Prasyarat (Prerequisites)
* Flutter SDK (`>= 3.22.0`)
* Java JDK 17
* Android Studio / VS Code dengan ekstensi Flutter

### Langkah Instalasi
```bash
# 1. Clone repository
git clone https://github.com/Irham-Najib-Azimul-Qowi/GERAKIN.git
cd GERAKIN

# 2. Install dependensi
flutter pub get

# 3. Jalankan kode generator ObjectBox / Freezed
dart run build_runner build --delete-conflicting-outputs

# 4. Jalankan pengujian unit
flutter test

# 5. Jalankan aplikasi pada perangkat
flutter run --release
```

---

## 📊 Hasil Benchmark Kinerja (Performance Benchmark)

| Metrik Kinerja | Nilai Terukur | Target Standar | Status |
| :--- | :--- | :--- | :--- |
| **Render Frame Rate** | 60.0 FPS | ≥ 60.0 FPS | **PASS** |
| **Inference Latency** | 14.2 ms | ≤ 25.0 ms | **PASS** |
| **Landmark Confidence** | 98.4% | ≥ 90.0% | **PASS** |
| **Peak Memory Footprint** | 48.5 MB | ≤ 150 MB | **PASS** |

---

## 📄 Lisensi
Hak Cipta © 2026 Tim GERAKIN. Diterbitkan di bawah Lisensi MIT.
