const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const { purchaseCar } = require('../controllers/transactionController');

const router = express.Router();

router.post('/purchase', authMiddleware, purchaseCar);

module.exports = router;
