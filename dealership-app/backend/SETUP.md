We are using:

* Node.js
* Express
* Firebase Firestore
* Firebase Authentication (Option A)
* VS Code
* Single repo with `/backend`

---

# ✅ Install Everything You Need

---

## Install Node.js

1. Go to: [https://nodejs.org](https://nodejs.org)
2. Download **LTS version**
3. Install with default settings

After installation, open terminal and run:

```bash
node -v
npm -v
```

If both show versions → success.

---

## Install Postman

For API testing:

[https://www.postman.com/downloads/](https://www.postman.com/downloads/)

Install it.

---

# ✅ PHASE 2 — Create Backend Project

---

## STEP 4 — Create Folder Structure

Inside your repo:

```bash
mkdir dealership-app
cd dealership-app
mkdir backend
mkdir frontend
```

Now go inside backend:

```bash
cd backend
```

---

## STEP 5 — Initialize Node Project

Run:

```bash
npm init -y
```

This creates `package.json`.

---

## STEP 6 — Install Required Dependencies

Run:

```bash
npm install express cors dotenv firebase-admin
```

Install development dependency:

```bash
npm install nodemon --save-dev
```

---

## STEP 7 — Configure package.json Scripts

Open `package.json`.

Find `"scripts"` and change to:

```json
"scripts": {
  "start": "node server.js",
  "dev": "nodemon server.js"
}
```

---

# ✅ PHASE 3 — Setup Firebase

---

## STEP 8 — Create Firebase Project

1. Go to [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click **Create Project**
3. Name it: `dealership-app`
4. Disable Google Analytics (optional)
5. Create project

---

## STEP 9 — Enable Firestore

Inside Firebase:

* Click **Firestore Database**
* Click **Create Database**
* Start in **Test Mode**
* Choose region

---

## STEP 10 — Enable Authentication

Inside Firebase:

* Click **Authentication**
* Click **Get Started**
* Go to **Sign-in Method**
* Enable **Email/Password**

---

## STEP 11 — Generate Admin SDK Key

Inside Firebase:

* Project Settings (gear icon)
* Service Accounts
* Click **Generate New Private Key**
* Download JSON file

Move this file into:

```
backend/config/firebaseServiceKey.json
```

---

# ✅ PHASE 4 — Create Backend Structure

Inside `/backend`, create:

```
/config
/controllers
/routes
/middleware
/services
```

Create files:

```
server.js
.env
```

---

# ✅ PHASE 5 — Configure Firebase Admin

Create file:

```
/config/firebase.js
```

Inside it:

* Import firebase-admin
* Import service key JSON
* Initialize admin SDK
* Export admin and Firestore instance

This file connects your backend to Firebase.

---

# ✅ PHASE 6 — Build Express Server

Open `server.js`.

Initialize:

* express
* cors
* dotenv
* JSON middleware

Connect route files.

Set port:

```
const PORT = process.env.PORT || 5000;
```

Start server:

```bash
npm run dev
```

Visit:

```
http://localhost:5000
```

You should see a test message.

---

# ✅ PHASE 7 — Authentication Middleware (CRITICAL)

Create:

```
/middleware/authMiddleware.js
```

This middleware must:

1. Read `Authorization` header
2. Extract Bearer token
3. Verify token using `admin.auth().verifyIdToken()`
4. Attach decoded user to `req.user`
5. Call `next()`

If token invalid → return 401 Unauthorized.

This protects routes.

---

# ✅ PHASE 8 — Role Middleware

Create:

```
/middleware/roleMiddleware.js
```

Function:

* Check `req.user.role`
* Allow only:

  * dealer_individual
  * dealer_company

Used for:

* Creating cars
* Editing cars
* Deleting cars

---

# ✅ PHASE 9 — Build Controllers

---

## User Controller

File:

```
/controllers/userController.js
```

Functions:

* createUserProfile
* getUserProfile

When user registers via Firebase Auth:

* iOS sends token
* Backend verifies
* Backend creates Firestore document in `users` collection

---

## Car Controller

File:

```
/controllers/carController.js
```

Functions:

* createCar
* getAllCars
* getCarById
* updateCar
* deleteCar

Rules:

* Only dealers can create/update/delete
* Customers can only view

---

## Transaction Controller

File:

```
/controllers/transactionController.js
```

Function:

* purchaseCar

Logic:

1. Verify car exists
2. Check `isSold == false`
3. Update car → `isSold = true`
4. Create transaction record
5. Return success JSON

---

# ✅ PHASE 10 — Create Routes

---

## userRoutes.js

Routes:

* POST /api/users/profile
* GET /api/users/me

Protected with authMiddleware.

---

## carRoutes.js

Routes:

* GET /api/cars
* GET /api/cars/:id
* POST /api/cars
* PUT /api/cars/:id
* DELETE /api/cars/:id

Protect POST/PUT/DELETE with:

* authMiddleware
* roleMiddleware

---

## transactionRoutes.js

Route:

* POST /api/purchase

Protected with:

* authMiddleware

---

Then import all routes into `server.js`.

---

# ✅ PHASE 11 — Firestore Collections

In Firebase Console create:

---

### users

Fields:

* uid (string)
* name (string)
* email (string)
* role (string)
* createdAt (timestamp)

---

### cars

Fields:

* title
* brand
* price
* dealerId
* isSold (boolean)
* createdAt

---

### transactions

Fields:

* carId
* buyerId
* amount
* status
* createdAt

---

# ✅ PHASE 12 — Testing With Postman

---

## 1️⃣ Register User

Use Firebase console or frontend to create user.

---

## 2️⃣ Get ID Token

From frontend:
Call:

```
firebase.auth().currentUser.getIdToken()
```

Copy token.

---

## 3️⃣ Test Protected Route

In Postman:

Add header:

```
Authorization: Bearer YOUR_TOKEN
```

Test:

* Create car
* Get cars
* Purchase car

---

# ✅ PHASE 13 — Final Folder Structure

Your backend must now look like:

```
backend/
  config/
    firebase.js
    firebaseServiceKey.json
  controllers/
    userController.js
    carController.js
    transactionController.js
  middleware/
    authMiddleware.js
    roleMiddleware.js
  routes/
    userRoutes.js
    carRoutes.js
    transactionRoutes.js
  services/
  server.js
  package.json
  .env
```

---

# ✅ PHASE 14 — Optional Improvements

After full functionality works:

* Add error handling middleware
* Add input validation
* Add pagination for cars
* Add filtering
* Add logging

---
