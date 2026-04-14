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
        carTitle: car.title || null,
        carBrand: car.brand || null,
        carYear: car.year || null,
        carImageUrl: car.imageUrl || null,
        amount: car.price,
        status: 'completed',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      transaction.set(transactionRef, transactionData);

      return { transactionId: transactionRef.id };
    });

    const savedTx = await db.collection('transactions').doc(result.transactionId).get();
    return res.status(200).json({ message: 'Car purchased successfully', data: { transactionId: result.transactionId, ...savedTx.data() } });
  } catch (error) {
    console.error('purchaseCar error:', error.message);
    if (error.message === 'CAR_NOT_FOUND') {
      return res.status(404).json({ error: 'Car not found' });
    }

    if (error.message === 'CAR_ALREADY_SOLD') {
      return res.status(400).json({ error: 'Car is already sold' });
    }

    return res.status(500).json({ error: 'Failed to purchase car' });
  }
};

const getMyPurchases = async (req, res) => {
  try {
    const buyerId = req.user?.uid;

    if (!buyerId) {
      return res.status(401).json({ error: 'Unauthorized user' });
    }

    const snapshot = await db
      .collection('transactions')
      .where('buyerId', '==', buyerId)
      .orderBy('createdAt', 'desc')
      .get();

    const purchases = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

    return res.status(200).json({ data: purchases });
  } catch (error) {
    console.error('getMyPurchases error:', error.message);
    return res.status(500).json({ error: 'Failed to fetch purchases' });
  }
};

module.exports = {
  purchaseCar,
  getMyPurchases,
};
