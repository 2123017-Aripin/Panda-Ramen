# API Documentation — Panda Ramen Backend

Backend ini hanya menangani proses **pembayaran (Midtrans)**. Fitur menu, cart, dan order lainnya diakses langsung oleh aplikasi Flutter ke Firestore.

Base URL (development): `http://localhost:3000`

Semua endpoint berada di bawah prefix `/api/payment` (sesuaikan dengan cara route ini didaftarkan di `server.js`).

---

## 1. Buat Transaksi Pembayaran

Membuat transaksi baru di Midtrans dan mengembalikan Snap Token untuk ditampilkan di halaman pembayaran pada app.

**Endpoint**
```
POST /api/payment/create-transaction
```

**Request Body**

| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `orderId` | string | ✅ | ID unik untuk order ini |
| `customerName` | string | ❌ | Nama pelanggan (default: "Customer") |
| `tableNumber` | string/number | ❌ | Nomor meja |
| `grossAmount` | number | ✅ | Total harga keseluruhan, harus sama persis dengan total `items` |
| `items` | array | ✅ | Daftar item pesanan |
| `items[].id` | string | ✅ | ID item |
| `items[].name` | string | ✅ | Nama item (otomatis dipotong maks. 50 karakter) |
| `items[].quantity` | number | ✅ | Jumlah item |
| `items[].price` | number | ✅ | Harga satuan |

Contoh body:
```json
{
  "orderId": "ORDER-001",
  "customerName": "Budi",
  "tableNumber": "5",
  "grossAmount": 45000,
  "items": [
    { "id": "menu-01", "name": "Ramen Spicy", "quantity": 1, "price": 35000 },
    { "id": "menu-02", "name": "Es Teh", "quantity": 1, "price": 10000 }
  ]
}
```

**Response Sukses (200)**
```json
{
  "token": "snap-token-dari-midtrans",
  "redirect_url": "https://app.sandbox.midtrans.com/snap/v...",
  "order_id": "ORDER-001"
}
```

**Response Gagal**

| Status | Kondisi |
|---|---|
| 400 | Field wajib tidak lengkap, atau total `items` tidak sama dengan `grossAmount` |
| 500 | Gagal membuat transaksi di Midtrans |

---

## 2. Webhook Notifikasi Midtrans

Endpoint ini **dipanggil otomatis oleh server Midtrans** ketika status pembayaran berubah — bukan dipanggil dari app Flutter. Harus didaftarkan di dashboard Midtrans pada **Settings → Configuration → Payment Notification URL**.

**Endpoint**
```
POST /api/payment/notification
```

**Request Body**
Dikirim otomatis oleh Midtrans sesuai format standar notifikasi mereka.

**Efek**
Status order akan diperbarui menjadi salah satu dari:

| Status Midtrans | Status Disimpan |
|---|---|
| `capture` + fraud `accept` | `success` |
| `capture` + fraud lainnya | `pending` |
| `settlement` | `success` |
| `deny` / `cancel` | `failed` |
| `expire` | `expired` |
| `pending` | `pending` |

**Response (200)**
```json
{ "message": "Notifikasi diterima" }
```

---

## 3. Cek Status Transaksi

Dipakai oleh app Flutter untuk polling/cek status pembayaran, misalnya di halaman ringkasan order atau halaman menunggu pembayaran.

**Endpoint**
```
GET /api/payment/status/:orderId
```

**Path Parameter**

| Parameter | Keterangan |
|---|---|
| `orderId` | ID order yang ingin dicek |

**Response Sukses (200)**
```json
{
  "order_id": "ORDER-001",
  "status": "success",
  "customerName": "Budi",
  "tableNumber": "5",
  "grossAmount": 45000
}
```

Catatan: jika status masih `pending`, server akan mencoba mengecek langsung ke Midtrans sebagai fallback (berguna saat development lokal di mana webhook notifikasi belum bisa diterima).

**Response Gagal (404)**
```json
{ "error": "Order tidak ditemukan" }
```

---

## Catatan Keamanan

- `MIDTRANS_SERVER_KEY` hanya boleh berada di backend (`.env`), **tidak pernah** dikirim ke app Flutter.
- `MIDTRANS_CLIENT_KEY` boleh digunakan di sisi Flutter (jika diperlukan untuk Snap SDK), karena memang didesain untuk publik.
- Pastikan environment Sandbox vs Production di dashboard Midtrans sesuai dengan key yang dipakai di `.env`.
