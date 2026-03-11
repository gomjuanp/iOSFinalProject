const { admin, db } = require('../config/firebase');

const purchaseCar = async (req, res) => {
  try {
    const buyerId = req.user?.uid;
    const { carId } = req.body;

    if (!buyerId) {
      return res.status(401).json({ error: 'Unauthorized user' });
    }

    if (!carId) {
      return res.status(400).json({ error: 'carId is required' });
    }

    const result = await db.runTransaction(async (transaction) => {
      const carRef = db.collection('cars').doc(carId);
      const carSnapshot = await transaction.get(carRef);

      if (!carSnapshot.exists) {
        throw new Error('CAR_NOT_FOUND');
      }

      const car = carSnapshot.data();
      if (car.isSold) {
        throw new Error('CAR_ALREADY_SOLD');
      }

      transaction.update(carRef, { isSold: true });

      const transactionRef = db.collection('transactions').doc();
      const transactionData = {
        carId,
        buyerId,
        amount: car.price,
        status: 'completed',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      transaction.set(transactionRef, transactionData);

      return { transactionId: transactionRef.id, transactionData };
    });

    return res.status(200).json({ message: 'Car purchased successfully', data: result });
  } catch (error) {
    if (error.message === 'CAR_NOT_FOUND') {
      return res.status(404).json({ error: 'Car not found' });
    }

    if (error.message === 'CAR_ALREADY_SOLD') {
      return res.status(400).json({ error: 'Car is already sold' });
    }

    return res.status(500).json({ error: 'Failed to purchase car' });
  }
};

module.exports = {
  purchaseCar,
};
