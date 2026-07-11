// Penyimpanan order sederhana di memori.
// Catatan: data akan hilang setiap kali server di-restart.
// Untuk produksi sungguhan, ganti ini dengan database (MongoDB, PostgreSQL, dll).

const orders = new Map();

function saveOrder(orderId, data) {
  orders.set(orderId, {
    ...data,
    status: data.status || 'pending',
    createdAt: new Date().toISOString(),
  });
}

function getOrder(orderId) {
  return orders.get(orderId);
}

function updateOrderStatus(orderId, status) {
  const order = orders.get(orderId);
  if (order) {
    order.status = status;
    order.updatedAt = new Date().toISOString();
    orders.set(orderId, order);
  }
  return order;
}

function getAllOrders() {
  return Array.from(orders.values());
}

module.exports = { saveOrder, getOrder, updateOrderStatus, getAllOrders };
