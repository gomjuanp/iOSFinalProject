# Dealership App

A car dealership iOS application with a Node.js/Express backend and Firebase Firestore database.

---

## Project Structure

```
repository-root/
├── dealership-app/
│   ├── backend/                    # Node.js/Express REST API
│   │   ├── config/                 # Firebase configuration
│   │   ├── controllers/            # Business logic (users, cars, transactions)
│   │   ├── middleware/             # Auth + role middleware
│   │   ├── routes/                 # Express route definitions
│   │   ├── server.js               # Application entry point
│   │   ├── README.md               # Backend documentation
│   │   └── SETUP.md                # Backend setup instructions
│   │
│   └── frontend/                   # iOS app (Swift/UIKit/Storyboard)
│       ├── frontend/               # Xcode source files
│       ├── frontend.xcodeproj/     # Xcode project
│       ├── README.md               # Frontend documentation
│       └── INTEGRATION_GUIDE.md    # How to connect frontend to backend API
│
├── firebase.json                   # Firebase project config
└── firestore.indexes.json          # Firestore composite indexes
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Swift, UIKit, Storyboard (Xcode) |
| Backend | Node.js, Express.js |
| Database | Firebase Firestore (NoSQL) |
| Authentication | Firebase Authentication (email/password) |
| Security | Firebase Admin SDK, role-based access control |

---

## User Roles

| Role | Can Do |
|------|--------|
| **Buyer** | Browse all cars, view car details, purchase cars, view purchase history |
| **Seller** | Everything a buyer can do, plus create/update/delete own car listings |

Roles are chosen at sign-up and cannot be changed.

---

## API Endpoints Summary

| Method | Path | Auth | Role | Description |
|--------|------|------|------|-------------|
| `POST` | `/api/users/profile` | ✅ | Any | Create user profile |
| `GET` | `/api/users/me` | ✅ | Any | Get own profile |
| `PUT` | `/api/users/me` | ✅ | Any | Update username |
| `GET` | `/api/cars` | ❌ | Any | Get all car listings |
| `GET` | `/api/cars/:id` | ❌ | Any | Get a single car |
| `GET` | `/api/cars/my-listings` | ✅ | Seller | Get own listings |
| `POST` | `/api/cars` | ✅ | Seller | Create car listing |
| `PUT` | `/api/cars/:id` | ✅ | Seller | Update car listing |
| `DELETE` | `/api/cars/:id` | ✅ | Seller | Delete car listing |
| `POST` | `/api/transactions/purchase` | ✅ | Any | Purchase a car |
| `GET` | `/api/transactions/my-purchases` | ✅ | Any | Get purchase history |

Full API documentation with request/response examples: see **[Backend README](backend/README.md)** and **[Integration Guide](frontend/INTEGRATION_GUIDE.md)**.

---

## Database Schema (Firestore)

### `users` collection
| Field | Type | Description |
|-------|------|-------------|
| uid | string | Firebase Auth user ID |
| username | string | Display name |
| email | string | User email |
| role | string | `"buyer"` or `"seller"` |
| createdAt | timestamp | Account creation time |

### `cars` collection
| Field | Type | Description |
|-------|------|-------------|
| title | string | Listing title |
| brand | string | Car manufacturer |
| year | string | Model year |
| price | number | Listing price |
| description | string | Detailed description |
| imageUrl | string / null | Car image URL |
| sellerId | string | UID of seller |
| isSold | boolean | Whether car is sold |
| createdAt | timestamp | Listing creation time |

### `transactions` collection
| Field | Type | Description |
|-------|------|-------------|
| carId | string | Firestore car document ID |
| buyerId | string | UID of buyer |
| carTitle | string | Snapshot of car title |
| carBrand | string | Snapshot of car brand |
| carYear | string | Snapshot of car year |
| carImageUrl | string / null | Snapshot of car image |
| amount | number | Purchase price |
| status | string | `"completed"` |
| createdAt | timestamp | Purchase time |

---

## Getting Started

### Backend

See **[Backend SETUP.md](backend/SETUP.md)** for step-by-step instructions:

1. Install Node.js
2. Run `npm install` inside `/backend`
3. Download Firebase service account key → place in `/backend/config/serviceAccountKey.json`
4. Create `.env` file with `PORT=5000` and `GOOGLE_APPLICATION_CREDENTIALS=./config/serviceAccountKey.json`
5. Run `npm run dev`
6. Server starts at `http://localhost:5000`

### Frontend (iOS)

See **[Frontend Integration Guide](frontend/INTEGRATION_GUIDE.md)** for complete instructions:

1. Open `frontend.xcodeproj` in Xcode
2. Add Firebase iOS SDK via Swift Package Manager
3. Add `GoogleService-Info.plist` from Firebase Console
4. Configure `APIService.swift` with the backend URL
5. Build and run

---

## Current Status

### Backend ✅ Complete
- All 11 API endpoints implemented and tested
- Firebase Auth token verification
- Role-based access control (buyer/seller)
- Input validation on all endpoints
- Atomic Firestore transactions for purchases
- Rate limiting (100 requests per 15 minutes)
- CORS configuration
- Comprehensive error handling

### Frontend ⚠️ In Progress
- ✅ Seller flow (add car, view my listings)
- ✅ Core Data local storage (working but needs to be replaced with API calls)
- ✅ Navigation and UI components
- ❌ No connection to backend API yet
- ❌ Buyer flow not implemented
- ❌ No Firebase Auth integration
- ❌ No purchase flow
- ❌ No edit/delete car functionality

### What the Frontend Developer Needs to Do

Read the **[Integration Guide](frontend/INTEGRATION_GUIDE.md)** which contains:
- Firebase SDK setup instructions for Xcode
- Complete Swift code for authentication (sign up, sign in, get token)
- Ready-to-use `APIService.swift` class for all API calls
- Swift data models matching every API response
- Step-by-step migration guide from Core Data to API
- Detailed checklist of all remaining screens and features