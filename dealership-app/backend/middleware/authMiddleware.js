const { admin, db } = require('../config/firebase');

// Simple in-memory role cache to avoid a Firestore read on every authenticated request.
const roleCache = new Map(); // uid -> { role, expiresAt }
const ROLE_CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes

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
    // Use a short-lived in-memory cache to reduce per-request Firestore reads.
    const cached = roleCache.get(decodedToken.uid);
    if (cached && cached.expiresAt > Date.now()) {
      req.user.role = cached.role;
    } else {
      const userDoc = await db.collection('users').doc(decodedToken.uid).get();
      if (userDoc.exists) {
        req.user.role = userDoc.data().role;
        roleCache.set(decodedToken.uid, {
          role: req.user.role,
          expiresAt: Date.now() + ROLE_CACHE_TTL_MS,
        });
      }
    }

    next();
  } catch (error) {
    console.error('Token verification failed:', error.message);
    return res.status(401).json({ error: 'Unauthorized: Token verification failed' });
  }
};

module.exports = authMiddleware;
