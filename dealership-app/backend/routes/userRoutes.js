const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const { createUserProfile, getUserProfile } = require('../controllers/userController');

const router = express.Router();

router.post('/profile', authMiddleware, createUserProfile);
router.get('/me', authMiddleware, getUserProfile);

module.exports = router;
