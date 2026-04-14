const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const { purchaseCar, getMyPurchases } = require('../controllers/transactionController');

const router = express.Router();

router.post('/purchase', authMiddleware, purchaseCar);
router.get('/my-purchases', authMiddleware, getMyPurchases);

module.exports = router;
