const admin = require('firebase-admin');
const serviceAccount = require('./dealership-app-f5cdc-firebase-adminsdk-fbsvc-93d856e2c2.json');

// Prevent re-initialization during hot reloads in development.
if (!admin.apps.length) {
	admin.initializeApp({
		credential: admin.credential.cert(serviceAccount),
	});
}

const db = admin.firestore();

module.exports = {
	admin,
	db,
};