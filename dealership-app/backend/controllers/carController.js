const { admin, db } = require('../config/firebase');

const createCar = async (req, res) => {
  try {
    const { title, brand, price } = req.body;
    const dealerId = req.user?.uid;

    if (!title || !brand || price === undefined) {
      return res.status(400).json({ error: 'title, brand, and price are required' });
    }

    const newCar = {
      title,
      brand,
      price: Number(price),
      dealerId,
      isSold: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await db.collection('cars').add(newCar);

    return res.status(201).json({ message: 'Car created', id: docRef.id, data: newCar });
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

const updateCar = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const carRef = db.collection('cars').doc(id);
    const carSnapshot = await carRef.get();

    if (!carSnapshot.exists) {
      return res.status(404).json({ error: 'Car not found' });
    }

    const carData = carSnapshot.data();
    if (carData.dealerId !== req.user?.uid) {
      return res.status(403).json({ error: 'Forbidden: You can only update your own cars' });
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
    if (carData.dealerId !== req.user?.uid) {
      return res.status(403).json({ error: 'Forbidden: You can only delete your own cars' });
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
  updateCar,
  deleteCar,
};
