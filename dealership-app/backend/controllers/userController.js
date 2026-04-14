const { admin, db } = require('../config/firebase');

const VALID_ROLES = ['buyer', 'seller'];

const createUserProfile = async (req, res) => {
  try {
    const uid = req.user?.uid;
    const { username, role } = req.body;

    if (!uid) {
      return res.status(401).json({ error: 'Unauthorized user' });
    }

    if (!username) {
      return res.status(400).json({ error: 'username is required' });
    }

    if (!role || !VALID_ROLES.includes(role)) {
      return res.status(400).json({ error: `role must be one of: ${VALID_ROLES.join(', ')}` });
    }

    // Prevent overwriting an existing profile (role cannot be changed after creation).
    const existingDoc = await db.collection('users').doc(uid).get();
    if (existingDoc.exists) {
      return res.status(409).json({ error: 'User profile already exists' });
    }

    const userRecord = await admin.auth().getUser(uid);

    const userDoc = {
      uid,
      username,
      email: userRecord.email || null,
      role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection('users').doc(uid).set(userDoc);

    const savedDoc = await db.collection('users').doc(uid).get();
    return res.status(201).json({ message: 'User profile created', data: savedDoc.data() });
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

const MUTABLE_USER_FIELDS = ['username'];

const updateUserProfile = async (req, res) => {
  try {
    const uid = req.user?.uid;

    if (!uid) {
      return res.status(401).json({ error: 'Unauthorized user' });
    }

    if (req.body.role !== undefined) {
      return res.status(400).json({ error: 'Role cannot be changed after account creation' });
    }

    const updates = {};
    MUTABLE_USER_FIELDS.forEach((field) => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ error: 'No valid fields provided for update' });
    }

    const userRef = db.collection('users').doc(uid);
    const userSnapshot = await userRef.get();

    if (!userSnapshot.exists) {
      return res.status(404).json({ error: 'User profile not found' });
    }

    await userRef.update(updates);

    const updatedUser = await userRef.get();
    return res.status(200).json({ message: 'User profile updated', data: updatedUser.data() });
  } catch (error) {
    console.error('updateUserProfile error:', error.message);
    return res.status(500).json({ error: 'Failed to update user profile' });
  }
};

module.exports = {
  createUserProfile,
  getUserProfile,
  updateUserProfile,
};
