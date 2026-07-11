# 🍜 Panda Ramen

Aplikasi pemesanan makanan berbasis Flutter dengan backend Node.js, menggunakan Firebase, Cloudinary, dan Midtrans sebagai payment gateway.

## 📁 Struktur Project

```
panda-ramen/
├── panda_ramen/            # Aplikasi Flutter (mobile & web)
├── panda-ramen-backend/    # REST API server
└── docs/                   # Dokumentasi tambahan (ERD, API docs, screenshot)
```

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Node.js + Express
- **Database & Auth:** Firebase (Firestore, Authentication)
- **Image Hosting:** Cloudinary
- **Payment Gateway:** Midtrans

## 🚀 Cara Menjalankan

### 1. Backend

```bash
cd panda-ramen-backend
npm install
cp .env.example .env
# isi .env dengan credential Firebase, Cloudinary, dan Midtrans kamu
npm start
```

Server akan berjalan di `http://localhost:3000` (sesuaikan dengan PORT di `.env`).

### 2. Flutter App

```bash
cd panda_ramen
flutter pub get
flutter run
```

Pastikan file konfigurasi Firebase (`google-services.json` untuk Android dan/atau `firebase_options.dart`) sudah ditambahkan sebelum menjalankan app. Lihat `panda_ramen/README.md` untuk detail.

## 📸 Screenshot

<p align="center">
  <img src="docs/screenshots/1.tampilan-awal.png" width="200"/>
  <img src="docs/screenshots/2.login-admin.png" width="200"/>
  <img src="docs/screenshots/3.edit-menu.png" width="200"/>
  <img src="docs/screenshots/4.edit-menu2.png" width="200"/>
  <img src="docs/screenshots/5.tambah-menu-baru.png" width="200"/>
  <img src="docs/screenshots/6.menu-page.png" width="200"s/>
  <img src="docs/screenshots/7.menu-page2.png" width="200"/>
  <img src="docs/screenshots/8.keranjang.png" width="200"/>
  <img src="docs/screenshots/chekout-page.png" width="200"/>
  <img src="docs/screenshots/payment-dikasir.png" width="200"/>
  <img src="docs/screenshots/payment-online.png" width="200"/>
  <img src="docs/screenshots/payment-online2.png" width="200"/>
  <img src="docs/screenshots/payment-midtrans.png" width="200"/>
  <img src="docs/screenshots/payment-sukses.png" width="200"/>
</p>

## 📄 Dokumentasi Tambahan

- [API Documentation](./docs/API.md)
- [Entity Relationship Diagram](./docs/ERD.png)

## 👤 Author

**Aripin** — Universitas Islam Mulia (UIM Yogya)

## 📝 License

Project ini dibuat untuk keperluan tugas akademik.
