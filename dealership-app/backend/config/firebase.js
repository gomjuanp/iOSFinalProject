const path = require('path');
const admin = require('firebase-admin');

const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
const firebaseCredential = credentialsPath
	? admin.credential.cert(require(path.resolve(credentialsPath)))
	: admin.credential.applicationDefault();

// Prevent re-initialization during hot reloads in development.
if (!admin.apps.length) {
	admin.initializeApp({
		credential: firebaseCredential,
	});
}

const db = admin.firestore();

module.exports = {
	admin,
	db,
};