# Backend Setup Guide – Dealership App

This document explains exactly how to set up and run the backend locally after cloning the repository.

Follow every step carefully.

---

# 1. Requirements

Before starting, make sure you install:

## 1.1 Install Node.js

Go to:

[https://nodejs.org](https://nodejs.org)

Download the **LTS version**.

After installation, open a terminal and verify:

```bash
node -v
npm -v
```

Both commands must return a version number.

---

## 1.2 Install Postman (For API Testing)

[https://www.postman.com/downloads/](https://www.postman.com/downloads/)

---

# 2. Clone The Repository

Open terminal and run:

```bash
git clone <repository-url>
cd dealership-app/backend
```

Make sure you are inside the `backend` folder.

---

# 3. Install Project Dependencies

Inside the backend folder, run:

```bash
npm install
```

This installs:

* express
* cors
* dotenv
* firebase-admin
* nodemon

You should now see a `node_modules` folder created automatically.

---

# 4. Setup Firebase Admin Key (IMPORTANT)

The Firebase service key is NOT included in the repository for security reasons.

Each developer must:

1. Go to Firebase Console
2. Open the project
3. Click Project Settings (gear icon)
4. Go to Service Accounts
5. Click "Generate New Private Key"
6. Download the JSON file
7. Rename the downloaded file to `serviceAccountKey.json`

Place it inside:

```bash
/backend/config/
```

Final location must be:

```bash
backend/config/serviceAccountKey.json
```

---

# 5. Create Environment File

Inside `/backend`, create a file named:

```bash
.env
```

Add:

```bash
PORT=5000
GOOGLE_APPLICATION_CREDENTIALS=./config/serviceAccountKey.json
```

Save the file.

---

# 6. Start The Backend Server

Inside `/backend`, run:

```bash
npm run dev
```

You should see:

```bash
Server running on port 5000
```

Open browser:

```
http://localhost:5000
```

If you see a JSON response, the server is running correctly.

---

# 7. Testing With Postman

All protected routes require a Firebase ID token in the header:

```
Authorization: Bearer <YOUR_ID_TOKEN>
Content-Type: application/json
```

---

## 7.1 Create A Test User In Firebase Console

* Authentication → Users → Add user → Email/Password

Example:
- Email: `buyer@test.com` / Password: `Test1234`
- Email: `seller@test.com` / Password: `Test1234`

---

## 7.2 Create User Profile

After creating the Firebase Auth account and obtaining an ID token, call:

**POST** `http://localhost:5000/api/users/profile`

Body:
```json
{
  "username": "john_buyer",
  "role": "buyer"
}
```

For a seller:
```json
{
  "username": "jane_seller",
  "role": "seller"
}
```

---

## 7.3 Get All Cars (no token needed)

**GET** `http://localhost:5000/api/cars`

---

## 7.4 Create Car Listing (seller token required)

**POST** `http://localhost:5000/api/cars`

Body:
```json
{
  "title": "2022 BMW M3",
  "brand": "BMW",
  "year": "2022",
  "price": 75000,
  "description": "Low mileage, excellent condition.",
  "imageUrl": "https://example.com/bmw.jpg"
}
```

---

## 7.5 Get Seller's Own Listings (seller token required)

**GET** `http://localhost:5000/api/cars/my-listings`

---

## 7.6 Purchase A Car (any authenticated user)

**POST** `http://localhost:5000/api/transactions/purchase`

Body:
```json
{
  "carId": "<Firestore car document ID>"
}
```

---

## 7.7 Get Purchase History (any authenticated user)

**GET** `http://localhost:5000/api/transactions/my-purchases`

---

## 7.8 Update Profile (any authenticated user)

**PUT** `http://localhost:5000/api/users/me`

Body (only `username` can be updated — role cannot be changed):
```json
{
  "username": "new_username"
}
```

---

# 8. Stopping The Server

Press:

```
CTRL + C
```

---

Backend is now fully running locally.
