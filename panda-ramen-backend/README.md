# Panda Ramen — Backend

REST API server untuk aplikasi Panda Ramen, dibangun dengan Node.js.

## Instalasi

```bash
npm install
cp .env.example .env
```

Isi `.env` dengan credential berikut:
- **Firebase**: dari Firebase Console → Project Settings → Service Accounts
- **Cloudinary**: dari Cloudinary Dashboard → Account Details
- **Midtrans**: dari Midtrans Dashboard → Settings → Access Keys (gunakan Sandbox key untuk development)

## Menjalankan Server

```bash
npm start
```

Untuk development dengan auto-reload (jika `nodemon` terpasang):
```bash
npm run dev
```

## Struktur Folder

```
src/
├── routes/         # Definisi endpoint API
├── controllers/    # Logika bisnis tiap endpoint
├── models/         # Model/skema data
└── index.js        # Entry point server
```

## Endpoint Utama

Lihat dokumentasi lengkap di [`../docs/API.md`](../docs/API.md).

## Catatan Keamanan

- Jangan pernah commit file `.env` atau `serviceAccountKey.json`
- Gunakan Midtrans Sandbox key selama development, ganti ke Production key hanya saat deploy final
