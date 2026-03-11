const { admin, db } = require('../config/firebase');

const createUserProfile = async (req, res) => {
  try {
    const uid = req.user?.uid;
    const { name, role } = req.body;

    if (!uid) {
      return res.status(401).json({ error: 'Unauthorized user' });
    }

    if (!name || !role) {
      return res.status(400).json({ error: 'name and role are required' });
    }

    const userRecord = await admin.auth().getUser(uid);

    const userDoc = {
      uid,
      name,
      email: userRecord.email || null,
      role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection('users').doc(uid).set(userDoc, { merge: true });

    return res.status(201).json({ message: 'User profile created', data: userDoc });
  } catch (error) {
    console.error('createUserProfile error:', error.message);
    return res.status(500).json({ error: 'Failed to create user profile' });
  }
};

const getUserProfile = async (req, res) => {
  try {
    const uid = req.user?.uid;

    if (!uid) {
      return res.status(401).json({ error: 'Unauthorized user' });
    }

    const userSnapshot = await db.collection('users').doc(uid).get();

    if (!userSnapshot.exists) {
      return res.status(404).json({ error: 'User profile not found' });
    }

    return res.status(200).json({ data: userSnapshot.data() });
  } catch (error) {
    console.error('getUserProfile error:', error.message);
    return res.status(500).json({ error: 'Failed to fetch user profile' });
  }
};

module.exports = {
  createUserProfile,
  getUserProfile,
};
