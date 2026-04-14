const { admin, db } = require('../config/firebase');

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || '';

    if (!authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Unauthorized: Missing Bearer token' });
    }

    const idToken = authHeader.split(' ')[1];

    if (!idToken) {
      return res.status(401).json({ error: 'Unauthorized: Invalid token format' });
    }

    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken;

    // Enrich req.user with the role stored in Firestore so roleMiddleware works correctly.
    const userDoc = await db.collection('users').doc(decodedToken.uid).get();
    if (userDoc.exists) {
      req.user.role = userDoc.data().role;
    }

    next();
  } catch (error) {
    console.error('Token verification failed:', error.message);
    return res.status(401).json({ error: 'Unauthorized: Token verification failed' });
  }
};

module.exports = authMiddleware;
