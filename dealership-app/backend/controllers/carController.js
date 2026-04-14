const { admin, db } = require('../config/firebase');

const createCar = async (req, res) => {
  try {
    const { title, brand, year, price, description, imageUrl } = req.body;
    const sellerId = req.user?.uid;

    if (!title || !brand || !year || price === undefined || !description) {
      return res.status(400).json({ error: 'title, brand, year, price, and description are required' });
    }

    const numericYear = Number(year);
    const currentYear = new Date().getFullYear();
    if (!Number.isInteger(numericYear) || numericYear < 1900 || numericYear > currentYear + 1) {
      return res.status(400).json({ error: `year must be a valid 4-digit year between 1900 and ${currentYear + 1}` });
    }

    const numericPrice = Number(price);
    if (!Number.isFinite(numericPrice) || numericPrice < 0) {
      return res.status(400).json({ error: 'price must be a finite non-negative number' });
    }

    const newCar = {
      title,
      brand,
      year: String(numericYear),
      price: numericPrice,
      description,
      imageUrl: imageUrl || null,
      sellerId,
      isSold: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await db.collection('cars').add(newCar);

    return res.status(201).json({ message: 'Car created', id: docRef.id, data: { id: docRef.id, ...newCar } });
  } catch (error) {
    console.error('createCar error:', error.message);
    return res.status(500).json({ error: 'Failed to create car' });
  }
};

const getAllCars = async (req, res) => {
  try {
    const snapshot = await db.collection('cars').get();

    const cars = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

    return res.status(200).json({ data: cars });
  } catch (error) {
    console.error('getAllCars error:', error.message);
    return res.status(500).json({ error: 'Failed to fetch cars' });
  }
};

const getCarById = async (req, res) => {
  try {
    const { id } = req.params;
    const carSnapshot = await db.collection('cars').doc(id).get();

    if (!carSnapshot.exists) {
      return res.status(404).json({ error: 'Car not found' });
    }

    return res.status(200).json({ data: { id: carSnapshot.id, ...carSnapshot.data() } });
  } catch (error) {
    console.error('getCarById error:', error.message);
    return res.status(500).json({ error: 'Failed to fetch car' });
  }
};

const getMyListings = async (req, res) => {
  try {
    const sellerId = req.user?.uid;

    const snapshot = await db.collection('cars').where('sellerId', '==', sellerId).get();
    const cars = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

    return res.status(200).json({ data: cars });
  } catch (error) {
    console.error('getMyListings error:', error.message);
    return res.status(500).json({ error: 'Failed to fetch listings' });
  }
};

const MUTABLE_CAR_FIELDS = ['title', 'brand', 'year', 'price', 'description', 'imageUrl'];

const updateCar = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = {};

    MUTABLE_CAR_FIELDS.forEach((field) => {
      if (req.body[field] !== undefined) {
        updates[field] = field === 'price' ? Number(req.body[field]) : req.body[field];
      }
    });

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ error: 'No valid fields provided for update' });
    }

    const carRef = db.collection('cars').doc(id);
    const carSnapshot = await carRef.get();

    if (!carSnapshot.exists) {
      return res.status(404).json({ error: 'Car not found' });
    }

    const carData = carSnapshot.data();
    if (carData.sellerId !== req.user?.uid) {
      return res.status(403).json({ error: 'Forbidden: You can only update your own listings' });
    }

    await carRef.update(updates);

    const updatedCar = await carRef.get();
    return res.status(200).json({ message: 'Car updated', data: { id: updatedCar.id, ...updatedCar.data() } });
  } catch (error) {
    console.error('updateCar error:', error.message);
    return res.status(500).json({ error: 'Failed to update car' });
  }
};

const deleteCar = async (req, res) => {
  try {
    const { id } = req.params;

    const carRef = db.collection('cars').doc(id);
    const carSnapshot = await carRef.get();

    if (!carSnapshot.exists) {
      return res.status(404).json({ error: 'Car not found' });
    }

    const carData = carSnapshot.data();
    if (carData.sellerId !== req.user?.uid) {
      return res.status(403).json({ error: 'Forbidden: You can only delete your own listings' });
    }

    await carRef.delete();

    return res.status(200).json({ message: 'Car deleted successfully' });
  } catch (error) {
    console.error('deleteCar error:', error.message);
    return res.status(500).json({ error: 'Failed to delete car' });
  }
};

module.exports = {
  createCar,
  getAllCars,
  getCarById,
  getMyListings,
  updateCar,
  deleteCar,
};
