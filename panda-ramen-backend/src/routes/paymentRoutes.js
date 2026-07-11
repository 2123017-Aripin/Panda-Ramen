const express = require('express');
const router = express.Router();
const {
  createTransaction,
  handleNotification,
  getTransactionStatus,
} = require('../controllers/paymentController');

router.post('/create-transaction', createTransaction);
router.post('/notification', handleNotification);
router.get('/status/:orderId', getTransactionStatus);

module.exports = router;
