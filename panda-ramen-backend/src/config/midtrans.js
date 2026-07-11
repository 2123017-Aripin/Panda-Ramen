const midtransClient = require('midtrans-client');

const isProduction = process.env.MIDTRANS_IS_PRODUCTION === 'true';

// Snap dipakai untuk membuat transaction & redirect_url pembayaran
const snap = new midtransClient.Snap({
  isProduction,
  serverKey: process.env.MIDTRANS_SERVER_KEY,
  clientKey: process.env.MIDTRANS_CLIENT_KEY,
});

// Core API dipakai untuk cek status transaksi manual (opsional, berguna untuk debugging)
const coreApi = new midtransClient.CoreApi({
  isProduction,
  serverKey: process.env.MIDTRANS_SERVER_KEY,
  clientKey: process.env.MIDTRANS_CLIENT_KEY,
});

module.exports = { snap, coreApi, isProduction };
