const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const {
  createCar,
  getAllCars,
  getCarById,
  updateCar,
  deleteCar,
} = require('../controllers/carController');

const router = express.Router();

router.get('/', getAllCars);
router.get('/:id', getCarById);
router.post('/', authMiddleware, roleMiddleware(), createCar);
router.put('/:id', authMiddleware, roleMiddleware(), updateCar);
router.delete('/:id', authMiddleware, roleMiddleware(), deleteCar);

module.exports = router;
