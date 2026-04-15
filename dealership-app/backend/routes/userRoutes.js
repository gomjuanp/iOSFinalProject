const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const { createUserProfile, getUserProfile, updateUserProfile } = require('../controllers/userController');

const router = express.Router();

router.post('/profile', authMiddleware, createUserProfile);
router.get('/me', authMiddleware, getUserProfile);
router.put('/me', authMiddleware, updateUserProfile);

module.exports = router;
