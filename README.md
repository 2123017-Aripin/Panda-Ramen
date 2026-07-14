<p align="center">
  <i>Dibangun dengan ❤️ dan ☕</i>
</p>

# 🍜 Panda Ramen

Aplikasi pemesanan makanan berbasis Flutter dengan backend Node.js, menggunakan Firebase, Cloudinary, dan Midtrans sebagai payment gateway.

## 📁 Struktur Project

```
panda-ramen/
├── Panda_Ramen/             # Aplikasi Flutter (mobile & web)
├── panda-ramen-backend/     # REST API server
└── docs/                    # Dokumentasi tambahan (ERD, API docs, screenshot)
```

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Node.js + Express
- **Database & Auth:** Firebase (Firestore, Authentication)
- **Image Hosting:** Cloudinary
- **Payment Gateway:** Midtrans

---

## 🚀 Cara Menjalankan Project di Komputer Lain

Panduan ini untuk siapa saja yang ingin men-download project ini dari GitHub dan menjalankannya dari nol.

### 0. Prasyarat (Install Dulu Sebelum Mulai)

Pastikan sudah ter-install di komputer:

| Software | Untuk apa | Link download |
|---|---|---|
| **Git** | Meng-clone repository | https://git-scm.com/downloads |
| **Node.js** (versi 18 ke atas) | Menjalankan backend | https://nodejs.org |
| **Flutter SDK** | Menjalankan aplikasi | https://docs.flutter.dev/get-started/install |
| **Android Studio** atau **VS Code** | Editor + emulator Android | https://developer.android.com/studio |

Cek instalasi sudah benar dengan:
```bash
git --version
node --version
flutter doctor
```

### 1. Clone Repository

Buka terminal (PowerShell/CMD/Terminal), lalu jalankan:
```bash
git clone https://github.com/2123017-Aripin/Panda-Ramen.git
cd Panda-Ramen
```

### 2. Jalankan Backend (Server)

```bash
cd panda-ramen-backend
npm install
```

Buat file `.env` dari template yang sudah disediakan:
```bash
cp .env.example .env
```
> Di Windows PowerShell, kalau `cp` tidak dikenali, gunakan: `copy .env.example .env`

Buka file `.env` yang baru dibuat, lalu isi dengan credential asli:
```dotenv
PORT=3000
MIDTRANS_SERVER_KEY=...        # dari dashboard.midtrans.com
MIDTRANS_CLIENT_KEY=...
MIDTRANS_IS_PRODUCTION=false
BASE_URL=http://localhost:3000
```

Jalankan server:
```bash
npm start
```
Kalau berhasil, server akan berjalan di `http://localhost:3000`.

### 3. Jalankan Aplikasi Flutter

Buka terminal **baru** (biarkan terminal backend tetap berjalan), lalu:
```bash
cd Panda_Ramen
flutter pub get
```

**Konfigurasi Firebase** — file `firebase_options.dart` dan `google-services.json` tidak ikut ter-upload ke GitHub (untuk keamanan). Ada 2 cara mendapatkannya:

- **Cara A (disarankan):** minta file `google-services.json` dan `firebase_options.dart` langsung dari pemilik project (Aripin), lalu taruh di:
  - `android/app/google-services.json`
  - `lib/firebase_options.dart`

- **Cara B:** generate ulang sendiri (butuh akses ke project Firebase yang sama):
  ```bash
  dart pub global activate flutterfire_cli
  flutterfire configure
  ```

Setelah konfigurasi Firebase siap, jalankan aplikasinya:
```bash
flutter run
```

Pilih device/emulator saat diminta. Untuk menjalankan di web browser:
```bash
flutter run -d chrome
```

> **Catatan koneksi ke backend:** jika menjalankan app di **emulator Android**, ganti `baseUrl` di `order_summary_page.dart` dari `http://localhost:3000` menjadi `http://10.0.2.2:3000` (emulator Android tidak bisa akses `localhost` milik komputer host secara langsung).

### 4. Selesai 🎉

Backend berjalan di terminal pertama, aplikasi Flutter berjalan di terminal kedua — keduanya harus tetap aktif bersamaan agar fitur pembayaran online berfungsi.

---

## 📸 Screenshot

<p align="center">
  <img src="docs/screenshots/1.tampilan-awal.png" width="200"/>
  <img src="docs/screenshots/2.login-admin.png" width="200"/>
  <img src="docs/screenshots/3.edit-menu.png" width="200"/>
  <img src="docs/screenshots/4.edit-menu2.png" width="200"/>
  <img src="docs/screenshots/5.tambah-menu-baru.png" width="200"/>
  <img src="docs/screenshots/6.menu-page.png" width="200"/>
  <img src="docs/screenshots/7.menu-page2.png" width="200"/>
  <img src="docs/screenshots/8.keranjang.png" width="200"/>
  <img src="docs/screenshots/chekout-page.png" width="200"/>
  <img src="docs/screenshots/payment-dikasir.png" width="200"/>
  <img src="docs/screenshots/payment-online.png" width="200"/>
  <img src="docs/screenshots/payment-midtrans.png" width="200"/>
  <img src="docs/screenshots/payment-sukses.png" width="200"/>
</p>

## 📄 Dokumentasi Tambahan

- [Dokumentasi API](./docs/API.md)
- [Diagram Hubungan Entitas](./docs/ERD.png)

## 👤 Author

**Aripin** **&** **kory** — Universitas Islam Mulia (UIM Yogya)

## 📝 License

Project ini dibuat untuk keperluan tugas akademik.
