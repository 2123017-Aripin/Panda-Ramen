const { snap, coreApi } = require('../config/midtrans');
const { saveOrder, getOrder, updateOrderStatus } = require('../store/orderStore');

// POST /api/payment/create-transaction
// Body: { orderId, customerName, tableNumber, grossAmount, items: [{ id, name, quantity, price }] }
async function createTransaction(req, res) {
  try {
    const { orderId, customerName, tableNumber, grossAmount, items } = req.body;

    if (!orderId || !grossAmount || !items || !Array.isArray(items)) {
      return res.status(400).json({
        error: 'Data tidak lengkap. Wajib ada: orderId, grossAmount, items[]',
      });
    }

    // Validasi: total item_details harus sama persis dengan grossAmount
    const itemsTotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    if (itemsTotal !== grossAmount) {
      return res.status(400).json({
        error: `Total item (${itemsTotal}) tidak cocok dengan grossAmount (${grossAmount})`,
      });
    }

    const baseUrl = process.env.BASE_URL || 'http://localhost:3000';

    const parameter = {
      transaction_details: {
        order_id: orderId,
        gross_amount: grossAmount,
      },
      item_details: items.map((item) => ({
        id: item.id,
        name: item.name.substring(0, 50), // Midtrans membatasi max 50 karakter
        quantity: item.quantity,
        price: item.price,
      })),
      customer_details: {
        first_name: customerName || 'Customer',
      },
      callbacks: {
        finish: `${baseUrl}/payment/finish`,
        error: `${baseUrl}/payment/error`,
        pending: `${baseUrl}/payment/pending`,
      },
    };

    const transaction = await snap.createTransaction(parameter);

    // Simpan order di memori untuk tracking status
    saveOrder(orderId, {
      customerName,
      tableNumber,
      grossAmount,
      items,
      snapToken: transaction.token,
      redirectUrl: transaction.redirect_url,
    });

    return res.status(200).json({
      token: transaction.token,
      redirect_url: transaction.redirect_url,
      order_id: orderId,
    });
  } catch (error) {
    console.error('Error createTransaction:', error.message);
    return res.status(500).json({
      error: 'Gagal membuat transaksi Midtrans',
      detail: error.message,
    });
  }
}

// POST /api/payment/notification (webhook dari Midtrans)
// Ini dipanggil OTOMATIS oleh server Midtrans, bukan dari app Flutter.
// Wajib didaftarkan di dashboard Midtrans: Settings > Configuration > Payment Notification URL
async function handleNotification(req, res) {
  try {
    const notificationJson = req.body;
    const statusResponse = await coreApi.transaction.notification(notificationJson);

    const orderId = statusResponse.order_id;
    const transactionStatus = statusResponse.transaction_status;
    const fraudStatus = statusResponse.fraud_status;

    console.log(`Notifikasi masuk. Order ID: ${orderId}. Status: ${transactionStatus}. Fraud: ${fraudStatus}`);

    let finalStatus = 'pending';

    if (transactionStatus === 'capture') {
      finalStatus = fraudStatus === 'accept' ? 'success' : 'pending';
    } else if (transactionStatus === 'settlement') {
      finalStatus = 'success';
    } else if (transactionStatus === 'deny' || transactionStatus === 'cancel') {
      finalStatus = 'failed';
    } else if (transactionStatus === 'expire') {
      finalStatus = 'expired';
    } else if (transactionStatus === 'pending') {
      finalStatus = 'pending';
    }

    updateOrderStatus(orderId, finalStatus);

    return res.status(200).json({ message: 'Notifikasi diterima' });
  } catch (error) {
    console.error('Error handleNotification:', error.message);
    return res.status(500).json({ error: 'Gagal memproses notifikasi' });
  }
}

// GET /api/payment/status/:orderId
// Dipakai Flutter app untuk polling/cek status order (misalnya di halaman order summary)
async function getTransactionStatus(req, res) {
  try {
    const { orderId } = req.params;
    const order = getOrder(orderId);

    if (!order) {
      return res.status(404).json({ error: 'Order tidak ditemukan' });
    }

    // Fallback: kalau status di store lokal masih 'pending',
    // cek langsung ke Midtrans (jaga-jaga webhook belum/tidak sampai, misal saat dev di localhost)
    if (order.status === 'pending') {
      try {
        const statusResponse = await coreApi.transaction.status(orderId);
        const transactionStatus = statusResponse.transaction_status;
        const fraudStatus = statusResponse.fraud_status;

        let finalStatus = 'pending';
        if (transactionStatus === 'capture') {
          finalStatus = fraudStatus === 'accept' ? 'success' : 'pending';
        } else if (transactionStatus === 'settlement') {
          finalStatus = 'success';
        } else if (transactionStatus === 'deny' || transactionStatus === 'cancel') {
          finalStatus = 'failed';
        } else if (transactionStatus === 'expire') {
          finalStatus = 'expired';
        }

        if (finalStatus !== order.status) {
          updateOrderStatus(orderId, finalStatus);
          order.status = finalStatus;
        }
      } catch (checkError) {
        console.log(`Cek status Midtrans untuk ${orderId}: ${checkError.message}`);
      }
    }

    return res.status(200).json({
      order_id: orderId,
      status: order.status,
      customerName: order.customerName,
      tableNumber: order.tableNumber,
      grossAmount: order.grossAmount,
    });
  } catch (error) {
    console.error('Error getTransactionStatus:', error.message);
    return res.status(500).json({ error: 'Gagal mengambil status order' });
  }
}
module.exports = { createTransaction, handleNotification, getTransactionStatus };
