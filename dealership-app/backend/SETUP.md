# 📄 1️⃣ `SETUP.md` (Put This Inside `/backend/SETUP.md`)

You can copy everything below exactly as-is.

---

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

1. Go to Firebase Console (I sent you an email invitation for that)
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

If you see a response, the server is running correctly.

---

# 7. Testing With Postman

All protected routes require a Firebase ID token.

---

## 7.1 Create A Test User

Go to Firebase Console:

* Authentication
* Users
* Add user
* Use email/password

Example:

Email: [dealer@test.com](mailto:dealer@test.com)
Password: 123456

---

## 7.2 Get Firebase ID Token

To get token:

Option 1 (Recommended):
Use frontend later.

Option 2 (Temporary Testing):
Use a small script or ask backend owner to generate token.

Token must be included in Postman header:

```
Authorization: Bearer YOUR_TOKEN_HERE
```

---

## 7.3 Test Endpoints

### Get All Cars

Method: GET
URL:

```
http://localhost:5000/api/cars
```

No token required.

---

### Create Car (Dealer Only)

Method: POST
URL:

```
http://localhost:5000/api/cars
```

Headers:

```
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json
```

Body (raw JSON):

```json
{
  "title": "BMW M3",
  "brand": "BMW",
  "price": 50000
}
```

---

### Purchase Car

Method: POST
URL:

```
http://localhost:5000/api/purchase
```

Headers:

```
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json
```

Body:

```json
{
  "carId": "CAR_DOCUMENT_ID"
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
