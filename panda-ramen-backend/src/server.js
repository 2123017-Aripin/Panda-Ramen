require('dotenv').config();
const express = require('express');
const cors = require('cors');
const paymentRoutes = require('./routes/paymentRoutes');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── ROUTES API ──
app.use('/api/payment', paymentRoutes);

// ── HALAMAN CALLBACK (dibuka browser/webview setelah bayar) ──
// WebView di Flutter akan mendeteksi URL ini SEBELUM benar-benar
// selesai loading, jadi halaman ini cuma fallback kalau dibuka manual.
app.get('/payment/finish', (req, res) => {
  res.send(`
    <html>
      <body style="font-family: sans-serif; text-align:center; padding-top: 60px;">
        <h2>✅ Pembayaran Berhasil</h2>
        <p>Silakan kembali ke aplikasi.</p>
      </body>
    </html>
  `);
});

app.get('/payment/error', (req, res) => {
  res.send(`
    <html>
      <body style="font-family: sans-serif; text-align:center; padding-top: 60px;">
        <h2>❌ Pembayaran Gagal</h2>
        <p>Silakan kembali ke aplikasi dan coba lagi.</p>
      </body>
    </html>
  `);
});

app.get('/payment/pending', (req, res) => {
  res.send(`
    <html>
      <body style="font-family: sans-serif; text-align:center; padding-top: 60px;">
        <h2>⏳ Pembayaran Menunggu Konfirmasi</h2>
        <p>Silakan kembali ke aplikasi.</p>
      </body>
    </html>
  `);
});

// Health check
app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Panda Ramen backend berjalan' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🐼 Panda Ramen backend berjalan di port ${PORT}`);
  console.log(`Mode Midtrans: ${process.env.MIDTRANS_IS_PRODUCTION === 'true' ? 'PRODUCTION' : 'SANDBOX'}`);
});
