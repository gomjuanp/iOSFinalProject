# Dealership App – Backend

## Overview

This backend powers the Dealership iOS application.
It is responsible for handling business logic, database communication, authentication verification, and API endpoints used by the iOS frontend.

The backend is built using **Node.js and Express**, with **Firebase Firestore** as the database and **Firebase Authentication** for user authentication.

This architecture allows the iOS team to focus entirely on UI/UX and frontend development while interacting with a secure and structured API.

---

## Architecture

The system follows a standard REST API structure:

iOS App → Express API → Firebase Firestore → JSON Response → iOS UI Update

Authentication flow:

iOS App → Firebase Authentication → ID Token → Backend Verification → Authorized API Access

The backend does not handle passwords directly. Authentication is managed by Firebase Authentication, and the backend verifies user identity using Firebase Admin SDK.

---

## Tech Stack

### Runtime Environment

* **Node.js**
* Cross-platform (Windows & macOS compatible)

### Framework

* **Express.js**
* Lightweight REST API framework

### Database

* **Firebase Firestore**
* NoSQL cloud database
* Stores users, cars, and transactions

### Authentication

* **Firebase Authentication**
* Email/Password authentication
* Secure token-based identity verification
* Backend verifies Firebase ID tokens using Firebase Admin SDK

### Security Layer

* Firebase Admin SDK
* Middleware-based token verification
* Role-based access control (`buyer`, `seller`)

---

## User Roles

| Role | Description |
|------|-------------|
| `buyer` | Can browse all cars, purchase cars, and view their own purchase history |
| `seller` | Can do everything a buyer can, plus create, update, and delete their own car listings |

Roles are chosen at registration and **cannot be changed** afterwards.

---

## API Endpoints

All protected routes require the header:
```
Authorization: Bearer <Firebase ID Token>
```

### Users — `/api/users`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/api/users/profile` | ✅ | Create user profile (set username + role) |
| `GET` | `/api/users/me` | ✅ | Get the authenticated user's profile |
| `PUT` | `/api/users/me` | ✅ | Update username or email (role cannot be changed) |

#### POST `/api/users/profile` body
```json
{
  "username": "john_doe",
  "role": "buyer"
}
```
> `role` must be `"buyer"` or `"seller"`.

---

### Cars — `/api/cars`

| Method | Path | Auth | Role | Description |
|--------|------|------|------|-------------|
| `GET` | `/api/cars` | ❌ | Any | Get all car listings |
| `GET` | `/api/cars/:id` | ❌ | Any | Get a single car by ID |
| `GET` | `/api/cars/my-listings` | ✅ | seller | Get the authenticated seller's own listings |
| `POST` | `/api/cars` | ✅ | seller | Create a new car listing |
| `PUT` | `/api/cars/:id` | ✅ | seller | Update a car listing (own listings only) |
| `DELETE` | `/api/cars/:id` | ✅ | seller | Delete a car listing (own listings only) |

#### POST/PUT `/api/cars` body
```json
{
  "title": "2022 BMW M3",
  "brand": "BMW",
  "year": "2022",
  "price": 75000,
  "description": "Low mileage, excellent condition.",
  "imageUrl": "https://..."
}
```
> `title`, `brand`, `year`, `price`, and `description` are required. `imageUrl` is optional.

---

### Transactions — `/api/transactions`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/api/transactions/purchase` | ✅ | Purchase a car (any authenticated user) |
| `GET` | `/api/transactions/my-purchases` | ✅ | Get all purchases made by the authenticated user |

#### POST `/api/transactions/purchase` body
```json
{
  "carId": "<Firestore car document ID>"
}
```

---

## Database Structure (Firestore Collections)

### `users`

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string | Firebase Auth user ID |
| `username` | string | Display name chosen at registration |
| `email` | string | User's email address |
| `role` | string | `"buyer"` or `"seller"` |
| `createdAt` | timestamp | Account creation time |

### `cars`

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Listing title |
| `brand` | string | Car manufacturer |
| `year` | string | Model year |
| `price` | number | Listing price |
| `description` | string | Detailed description |
| `imageUrl` | string \| null | URL of the car image |
| `sellerId` | string | UID of the seller who created the listing |
| `isSold` | boolean | Whether the car has been sold |
| `createdAt` | timestamp | Listing creation time |

### `transactions`

| Field | Type | Description |
|-------|------|-------------|
| `carId` | string | Firestore ID of the purchased car |
| `buyerId` | string | UID of the buyer |
| `carTitle` | string | Snapshot of car title at purchase time |
| `carBrand` | string | Snapshot of car brand at purchase time |
| `carYear` | string | Snapshot of car year at purchase time |
| `carImageUrl` | string \| null | Snapshot of car image URL at purchase time |
| `amount` | number | Purchase price |
| `status` | string | `"completed"` |
| `createdAt` | timestamp | Purchase time |

---

## Folder Structure

```
/backend
  /config         Firebase configuration
  /controllers    Business logic (users, cars, transactions)
  /routes         Express route definitions
  /middleware     Auth + role middleware
  server.js       Application entry point
```

---

## Cross-Platform Compatibility

This backend:

* Runs on Windows
* Runs on macOS
* Requires only Node.js
* Can be edited in VS Code
* Can be deployed to cloud providers

---

## Future Scalability

The backend can later support:

* Advanced filtering and search
* Image uploads via Firebase Storage
* Admin dashboard
* Real payment integration
* Deployment to cloud hosting
