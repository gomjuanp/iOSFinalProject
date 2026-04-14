const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const {
  createCar,
  getAllCars,
  getCarById,
  getMyListings,
  updateCar,
  deleteCar,
} = require('../controllers/carController');

const router = express.Router();

router.get('/', getAllCars);
// /my-listings must be declared before /:id so it is not treated as a car id.
router.get('/my-listings', authMiddleware, roleMiddleware(['seller']), getMyListings);
router.get('/:id', getCarById);
router.post('/', authMiddleware, roleMiddleware(['seller']), createCar);
router.put('/:id', authMiddleware, roleMiddleware(['seller']), updateCar);
router.delete('/:id', authMiddleware, roleMiddleware(['seller']), deleteCar);

module.exports = router;
