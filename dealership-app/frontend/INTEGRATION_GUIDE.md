# iOS Frontend Integration Guide

This document explains exactly how to connect the iOS app to the backend API.
It is written for the frontend developer who will finish the Swift/Xcode implementation.

After reading this guide you will know how to:

- Set up Firebase Authentication in Xcode
- Obtain an ID token for every API call
- Call every backend endpoint from Swift
- Parse every response into Swift models

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Firebase SDK Setup in Xcode](#2-firebase-sdk-setup-in-xcode)
3. [Authentication Flow](#3-authentication-flow)
4. [Swift Data Models](#4-swift-data-models)
5. [API Service Layer](#5-api-service-layer)
6. [API Endpoints – Complete Reference](#6-api-endpoints--complete-reference)
7. [Error Handling](#7-error-handling)
8. [Migration from Core Data to API](#8-migration-from-core-data-to-api)
9. [Firestore Indexes](#9-firestore-indexes)
10. [Checklist for Frontend Completion](#10-checklist-for-frontend-completion)

---

## 1. Architecture Overview

```
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│   iOS App        │         │  Express Backend  │         │ Firebase         │
│   (Swift/UIKit)  │──HTTP──▶│  (Node.js)        │──SDK───▶│ Firestore DB     │
│                  │◀─JSON──│  localhost:5000    │         │ Authentication   │
└──────────────────┘         └──────────────────┘         └──────────────────┘
```

**Authentication flow:**

1. User signs up or signs in using **Firebase Auth SDK** (client-side, in the iOS app).
2. iOS app retrieves an **ID Token** from the signed-in Firebase user.
3. iOS app sends this token as `Authorization: Bearer <token>` in every API request.
4. Backend verifies the token using **Firebase Admin SDK**.
5. Backend checks the user role stored in Firestore and applies role-based access.

**Important:** The backend does NOT handle registration or login directly. The iOS app uses the Firebase Auth SDK to handle authentication, and then communicates with the backend API for all business logic.

---

## 2. Firebase SDK Setup in Xcode

### 2.1 Add Firebase to the Xcode project

1. Open the project in Xcode.
2. Go to **File → Add Package Dependencies**.
3. Enter the Firebase iOS SDK URL:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
4. Select version **11.0.0** or later.
5. Choose these libraries:
   - `FirebaseAuth`
   - `FirebaseCore`

### 2.2 Add GoogleService-Info.plist

1. Go to the **Firebase Console** → Project Settings → General.
2. Under **Your apps**, add an iOS app (if not already added).
   - Bundle ID must match the Xcode project bundle identifier.
3. Download `GoogleService-Info.plist`.
4. Drag it into the Xcode project root (make sure "Copy items if needed" is checked).

### 2.3 Initialize Firebase in AppDelegate

In `AppDelegate.swift`, add:

```swift
import FirebaseCore

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
}
```

---

## 3. Authentication Flow

### 3.1 Sign Up (Create Account)

```swift
import FirebaseAuth

func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        if let user = authResult?.user {
            completion(.success(user))
        }
    }
}
```

After sign-up, the app must call `POST /api/users/profile` to create the user profile in Firestore (see Section 6.1).

### 3.2 Sign In

```swift
func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        if let user = authResult?.user {
            completion(.success(user))
        }
    }
}
```

### 3.3 Get ID Token

Every backend API call needs a Firebase ID token. Get it like this:

```swift
func getIDToken(completion: @escaping (String?) -> Void) {
    guard let user = Auth.auth().currentUser else {
        completion(nil)
        return
    }
    user.getIDToken { token, error in
        if let error = error {
            print("Error getting ID token: \(error.localizedDescription)")
            completion(nil)
            return
        }
        completion(token)
    }
}
```

> **Note:** Firebase tokens expire after 1 hour. `getIDToken()` automatically refreshes expired tokens. Always call it before each API request instead of caching the token.

### 3.4 Sign Out

```swift
func signOut() {
    do {
        try Auth.auth().signOut()
    } catch {
        print("Sign out error: \(error.localizedDescription)")
    }
}
```

### 3.5 Check Current User

```swift
if let user = Auth.auth().currentUser {
    print("Signed in as: \(user.email ?? "unknown")")
} else {
    print("Not signed in")
}
```

---

## 4. Swift Data Models

Create these models to match the backend API responses.

### 4.1 User Model

```swift
struct UserProfile: Codable {
    let uid: String
    let username: String
    let email: String?
    let role: String        // "buyer" or "seller"
    let createdAt: FirestoreTimestamp?
}
```

### 4.2 Car Model

```swift
struct Car: Codable {
    let id: String
    let title: String
    let brand: String
    let year: String
    let price: Double
    let description: String
    let imageUrl: String?
    let sellerId: String
    let isSold: Bool
    let createdAt: FirestoreTimestamp?
}
```

### 4.3 Transaction Model

```swift
struct Transaction: Codable {
    let id: String?
    let carId: String
    let buyerId: String
    let carTitle: String?
    let carBrand: String?
    let carYear: String?
    let carImageUrl: String?
    let amount: Double
    let status: String      // "completed"
    let createdAt: FirestoreTimestamp?
}
```

### 4.4 Firestore Timestamp Helper

Firestore timestamps arrive as `{ "_seconds": 123, "_nanoseconds": 456 }`. Create a helper:

```swift
struct FirestoreTimestamp: Codable {
    let _seconds: Int
    let _nanoseconds: Int

    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(_seconds))
    }
}
```

### 4.5 API Response Wrappers

All API responses follow these patterns:

```swift
// For single-item responses:
struct APIResponse<T: Codable>: Codable {
    let message: String?
    let data: T?
    let error: String?
}

// For car creation (includes id at top level):
struct CreateCarResponse: Codable {
    let message: String?
    let id: String?
    let data: Car?
    let error: String?
}

// For purchase response:
struct PurchaseResponse: Codable {
    let message: String?
    let data: PurchaseData?
    let error: String?
}

struct PurchaseData: Codable {
    let transactionId: String
    let carId: String
    let buyerId: String
    let carTitle: String?
    let carBrand: String?
    let carYear: String?
    let carImageUrl: String?
    let amount: Double
    let status: String
    let createdAt: FirestoreTimestamp?
}
```

---

## 5. API Service Layer

Create a single class that handles all API communication.

### 5.1 APIService.swift

```swift
import Foundation
import FirebaseAuth

class APIService {

    static let shared = APIService()

    // For local development with the iOS simulator, localhost works:
    // private let baseURL = "http://localhost:5000/api"
    //
    // App Transport Security (ATS) blocks plain HTTP by default on iOS.
    // If you use the HTTP localhost URL above for development, add a
    // localhost-only exception to Info.plist:
    //
    // <key>NSAppTransportSecurity</key>
    // <dict>
    //     <key>NSExceptionDomains</key>
    //     <dict>
    //         <key>localhost</key>
    //         <dict>
    //             <key>NSExceptionAllowsInsecureHTTPLoads</key>
    //             <true/>
    //         </dict>
    //     </dict>
    // </dict>
    //
    // For a physical device on the same network, use your Mac's IP address
    // instead of localhost, and if you still use HTTP for development, add a
    // matching ATS exception for that host as well. Prefer HTTPS in production.
    private let baseURL = "http://localhost:5000/api"

    private init() {}

    // MARK: - Core Request Method

    /// Sends an authenticated HTTP request to the backend.
    /// - Parameters:
    ///   - endpoint: The API path (e.g., "/users/me")
    ///   - method: HTTP method (GET, POST, PUT, DELETE)
    ///   - body: Optional request body dictionary
    ///   - requiresAuth: Whether to include the Firebase ID token
    ///   - completion: Callback with raw Data or Error
    func request(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        requiresAuth: Bool = true,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let buildRequest: (String?) -> Void = { token in
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            if let body = body {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                } catch {
                    completion(.failure(error))
                    return
                }
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }

                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }

                if httpResponse.statusCode >= 400 {
                    // Try to parse error message from response
                    if let errorResponse = try? JSONDecoder().decode(
                        [String: String].self, from: data
                    ),
                       let errorMessage = errorResponse["error"] {
                        completion(.failure(
                            APIError.serverError(
                                statusCode: httpResponse.statusCode,
                                message: errorMessage
                            )
                        ))
                    } else {
                        completion(.failure(
                            APIError.serverError(
                                statusCode: httpResponse.statusCode,
                                message: "Unknown error"
                            )
                        ))
                    }
                    return
                }

                completion(.success(data))
            }.resume()
        }

        if requiresAuth {
            guard let user = Auth.auth().currentUser else {
                completion(.failure(APIError.notAuthenticated))
                return
            }
            user.getIDToken { token, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                buildRequest(token)
            }
        } else {
            buildRequest(nil)
        }
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case notAuthenticated
    case serverError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .notAuthenticated:
            return "User is not authenticated"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        }
    }
}
```

### 5.2 Usage Examples

**Get all cars (no auth needed):**
```swift
APIService.shared.request(endpoint: "/cars", requiresAuth: false) { result in
    switch result {
    case .success(let data):
        let response = try? JSONDecoder().decode(APIResponse<[Car]>.self, from: data)
        let cars = response?.data ?? []
        DispatchQueue.main.async {
            // Update your UI with cars
        }
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

**Create a car listing (seller only):**
```swift
let carData: [String: Any] = [
    "title": "2022 BMW M3",
    "brand": "BMW",
    "year": "2022",
    "price": 75000,
    "description": "Low mileage, excellent condition."
]

APIService.shared.request(endpoint: "/cars", method: "POST", body: carData) { result in
    switch result {
    case .success(let data):
        let response = try? JSONDecoder().decode(CreateCarResponse.self, from: data)
        print("Car created with ID: \(response?.id ?? "unknown")")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

---

## 6. API Endpoints – Complete Reference

**Base URL:** `http://localhost:5000/api`

All protected endpoints require the header:
```
Authorization: Bearer <Firebase ID Token>
```

---

### 6.1 Create User Profile

Called once after Firebase sign-up to register the user role in the database.

| Field | Value |
|-------|-------|
| Method | `POST` |
| Path | `/users/profile` |
| Auth | ✅ Required |
| Role | Any |

**Request body:**
```json
{
  "username": "john_doe",
  "role": "buyer"
}
```

> `role` must be exactly `"buyer"` or `"seller"`. Once set it cannot be changed.

**Success response (201):**
```json
{
  "message": "User profile created",
  "data": {
    "uid": "abc123",
    "username": "john_doe",
    "email": "john@example.com",
    "role": "buyer",
    "createdAt": { "_seconds": 1700000000, "_nanoseconds": 0 }
  }
}
```

**Error responses:**

| Code | Body | When |
|------|------|------|
| 400 | `{ "error": "username is required" }` | Missing username |
| 400 | `{ "error": "role must be one of: buyer, seller" }` | Invalid role |
| 401 | `{ "error": "Unauthorized: Missing Bearer token" }` | No token |
| 409 | `{ "error": "User profile already exists" }` | Profile already created |

---

### 6.2 Get My Profile

| Field | Value |
|-------|-------|
| Method | `GET` |
| Path | `/users/me` |
| Auth | ✅ Required |
| Role | Any |

**Success response (200):**
```json
{
  "data": {
    "uid": "abc123",
    "username": "john_doe",
    "email": "john@example.com",
    "role": "buyer",
    "createdAt": { "_seconds": 1700000000, "_nanoseconds": 0 }
  }
}
```

**Error responses:**

| Code | Body | When |
|------|------|------|
| 401 | `{ "error": "Unauthorized: Missing Bearer token" }` | No token |
| 404 | `{ "error": "User profile not found" }` | Profile not created yet |

---

### 6.3 Update My Profile

Only `username` can be updated. Role cannot be changed.

| Field | Value |
|-------|-------|
| Method | `PUT` |
| Path | `/users/me` |
| Auth | ✅ Required |
| Role | Any |

**Request body:**
```json
{
  "username": "new_username"
}
```

**Success response (200):**
```json
{
  "message": "User profile updated",
  "data": {
    "uid": "abc123",
    "username": "new_username",
    "email": "john@example.com",
    "role": "buyer",
    "createdAt": { "_seconds": 1700000000, "_nanoseconds": 0 }
  }
}
```

**Error responses:**

| Code | Body | When |
|------|------|------|
| 400 | `{ "error": "Role cannot be changed after account creation" }` | Tried to change role |
| 400 | `{ "error": "No valid fields provided for update" }` | Empty or invalid body |
| 401 | `{ "error": "Unauthorized: Missing Bearer token" }` | `Authorization` header missing or malformed |
| 401 | `{ "error": "Unauthorized: Token verification failed" }` | Firebase ID token is invalid or expired |
| 404 | `{ "error": "User profile not found" }` | No profile exists |

---

### 6.4 Get All Cars

Public endpoint. No authentication required.

| Field | Value |
|-------|-------|
| Method | `GET` |
| Path | `/cars` |
| Auth | ❌ Not required |
| Role | Any |

**Success response (200):**
```json
{
  "data": [
    {
      "id": "car123",
      "title": "2022 BMW M3",
      "brand": "BMW",
      "year": "2022",
      "price": 75000,
      "description": "Low mileage, excellent condition.",
      "imageUrl": "https://example.com/bmw.jpg",
      "sellerId": "seller456",
      "isSold": false,
      "createdAt": { "_seconds": 1700000000, "_nanoseconds": 0 }
    }
  ]
}
```

---

### 6.5 Get Car By ID

Public endpoint.

| Field | Value |
|-------|-------|
| Method | `GET` |
| Path | `/cars/:id` |
| Auth | ❌ Not required |
| Role | Any |

**Success response (200):**
```json
{
  "data": {
    "id": "car123",
    "title": "2022 BMW M3",
    "brand": "BMW",
    "year": "2022",
    "price": 75000,
    "description": "Low mileage, excellent condition.",
    "imageUrl": "https://example.com/bmw.jpg",
    "sellerId": "seller456",
    "isSold": false,
    "createdAt": { "_seconds": 1700000000, "_nanoseconds": 0 }
  }
}
```

**Error responses:**

| Code | Body | When |
|------|------|------|
| 404 | `{ "error": "Car not found" }` | Invalid car ID |

---

### 6.6 Get My Listings (Seller)

| Field | Value |
|-------|-------|
| Method | `GET` |
| Path | `/cars/my-listings` |
| Auth | ✅ Required |
| Role | `seller` only |

**Success response (200):**
```json
{
  "data": [
    {
      "id": "car123",
      "title": "2022 BMW M3",
      "brand": "BMW",
      "year": "2022",
      "price": 75000,
      "description": "Low mileage",
      "imageUrl": null,
      "sellerId": "seller456",
      "isSold": false,
      "createdAt": { "_seconds": 1700000000, "_nanoseconds": 0 }
    }
  ]
}
```

**Error responses:**

| Code | Body | When |
|------|------|------|
| 401 | `{ "error": "Unauthorized: Missing Bearer token" }` | No token |
| 403 | `{ "error": "Forbidden: Insufficient role permissions" }` | User is not a seller |

---

### 6.7 Create Car Listing (Seller)

| Field | Value |
|-------|-------|
| Method | `POST` |
| Path | `/cars` |
| Auth | ✅ Required |
| Role | `seller` only |

**Request body:**
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

> `imageUrl` is optional. All other fields are required.

**Success response (201):**
```json
{
  "message": "Car created",
  "id": "car123",
  "data": {
    "id": "car123",
    "title": "2022 BMW M3",
    "brand": "BMW",
    "year": "2022",
    "price": 75000,
    "description": "Low mileage, excellent condition.",
    "imageUrl": "https://example.com/bmw.jpg",
    "sellerId": "seller456",
    "isSold": false,
    "createdAt": { "_seconds": 1700000000, "_nanoseconds": 0 }
  }
}
```

**Error responses:**

| Code | Body | When |
|------|------|------|
| 400 | `{ "error": "title, brand, year, price, and description are required" }` | Missing fields |
| 400 | `{ "error": "year must be a valid 4-digit year between 1900 and next year" }` | Invalid year |
| 400 | `{ "error": "price must be a finite non-negative number" }` | Invalid price |
| 403 | `{ "error": "Forbidden: Insufficient role permissions" }` | Not a seller |

---

### 6.8 Update Car Listing (Seller)

Only the seller who created the listing can update it.

| Field | Value |
|-------|-------|
| Method | `PUT` |
| Path | `/cars/:id` |
| Auth | ✅ Required |
| Role | `seller` only |

**Request body (all fields optional):**
```json
{
  "title": "Updated Title",
  "price": 70000
}
```

> Only these fields can be updated: `title`, `brand`, `year`, `price`, `description`, `imageUrl`.

**Success response (200):**
```json
{
  "message": "Car updated",
  "data": {
    "id": "car123",
    "title": "Updated Title",
    "brand": "BMW",
    "year": "2022",
    "price": 70000,
    "description": "Low mileage, excellent condition.",
    "imageUrl": "https://example.com/bmw.jpg",
    "sellerId": "seller456",
    "isSold": false,
    "createdAt": { "_seconds": 1700000000, "_nanoseconds": 0 }
  }
}
```

**Error responses:**

| Code | Body | When |
|------|------|------|
| 400 | `{ "error": "No valid fields provided for update" }` | Empty or invalid body |
| 403 | `{ "error": "Forbidden: You can only update your own listings" }` | Not the car owner |
| 404 | `{ "error": "Car not found" }` | Invalid car ID |

---

### 6.9 Delete Car Listing (Seller)

Only the seller who created the listing can delete it.

| Field | Value |
|-------|-------|
| Method | `DELETE` |
| Path | `/cars/:id` |
| Auth | ✅ Required |
| Role | `seller` only |

**Success response (200):**
```json
{
  "message": "Car deleted successfully"
}
```

**Error responses:**

| Code | Body | When |
|------|------|------|
| 403 | `{ "error": "Forbidden: You can only delete your own listings" }` | Not the car owner |
| 404 | `{ "error": "Car not found" }` | Invalid car ID |

---

### 6.10 Purchase Car

Any authenticated user can purchase a car that is not already sold.

| Field | Value |
|-------|-------|
| Method | `POST` |
| Path | `/transactions/purchase` |
| Auth | ✅ Required |
| Role | Any |

**Request body:**
```json
{
  "carId": "car123"
}
```

**Success response (200):**
```json
{
  "message": "Car purchased successfully",
  "data": {
    "transactionId": "tx789",
    "carId": "car123",
    "buyerId": "buyer456",
    "carTitle": "2022 BMW M3",
    "carBrand": "BMW",
    "carYear": "2022",
    "carImageUrl": "https://example.com/bmw.jpg",
    "amount": 75000,
    "status": "completed",
    "createdAt": { "_seconds": 1700000000, "_nanoseconds": 0 }
  }
}
```

**Error responses:**

| Code | Body | When |
|------|------|------|
| 400 | `{ "error": "carId is required" }` | Missing carId |
| 400 | `{ "error": "Car is already sold" }` | Car already purchased |
| 404 | `{ "error": "Car not found" }` | Invalid car ID |

---

### 6.11 Get My Purchases

| Field | Value |
|-------|-------|
| Method | `GET` |
| Path | `/transactions/my-purchases` |
| Auth | ✅ Required |
| Role | Any |

**Success response (200):**
```json
{
  "data": [
    {
      "id": "tx789",
      "carId": "car123",
      "buyerId": "buyer456",
      "carTitle": "2022 BMW M3",
      "carBrand": "BMW",
      "carYear": "2022",
      "carImageUrl": "https://example.com/bmw.jpg",
      "amount": 75000,
      "status": "completed",
      "createdAt": { "_seconds": 1700000000, "_nanoseconds": 0 }
    }
  ]
}
```

---

## 7. Error Handling

### 7.1 HTTP Status Codes Used by the Backend

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Successful read, update, or delete |
| 201 | Created | Successful creation (user profile, car) |
| 400 | Bad Request | Missing or invalid input |
| 401 | Unauthorized | Missing, expired, or invalid Firebase token |
| 403 | Forbidden | Role not allowed or not the resource owner |
| 404 | Not Found | Resource does not exist |
| 409 | Conflict | User profile already exists |
| 429 | Too Many Requests | Rate limit exceeded (100 requests per 15 minutes) |
| 500 | Internal Server Error | Unexpected server failure |

### 7.2 Error Response Format

All error responses follow this format:

```json
{
  "error": "Human-readable error message"
}
```

### 7.3 Swift Error Handling Pattern

```swift
APIService.shared.request(endpoint: "/cars", method: "POST", body: carData) { result in
    DispatchQueue.main.async {
        switch result {
        case .success(let data):
            // Parse and use data
            break
        case .failure(let error):
            if let apiError = error as? APIError {
                switch apiError {
                case .notAuthenticated:
                    // Redirect to login screen
                    break
                case .serverError(let code, let message):
                    if code == 403 {
                        // Show "not authorized" alert
                    } else {
                        // Show error message to user
                    }
                default:
                    // Show generic error
                    break
                }
            }
        }
    }
}
```

---

## 8. Migration from Core Data to API

The current frontend uses Core Data for local storage. To connect to the backend, the following changes are needed:

### 8.1 What to Replace

| Current (Core Data) | Replace With (API) |
|---------------------|--------------------|
| `CoreDataManager.shared.saveCar(...)` | `APIService.shared.request(endpoint: "/cars", method: "POST", body: ...)` |
| `CoreDataManager.shared.fetchCars()` | `APIService.shared.request(endpoint: "/cars/my-listings")` for seller listings |
| Local `Car` NSManagedObject | `Car` Codable struct (see Section 4.2) |
| No authentication | Firebase Auth sign-up/sign-in before any action |

### 8.2 Screens to Update

1. **ViewController.swift (Account Type):**
   - Add Firebase Auth sign-up / sign-in flow before account type selection.
   - After Firebase sign-up, call `POST /api/users/profile` with the chosen role.
   - After sign-in, call `GET /api/users/me` to determine the role and route accordingly.

2. **AddCarViewController.swift:**
   - Replace `CoreDataManager.shared.saveCar(...)` with `POST /api/cars`.
   - Use the car data from the API response, not Core Data.

3. **MyListingsViewController.swift:**
   - Replace `CoreDataManager.shared.fetchCars()` with `GET /api/cars/my-listings`.
   - Parse the JSON response into an array of `Car` structs.
   - Display in the existing table view.

4. **New screens needed:**
   - **Login / Sign Up screen** — Firebase Auth email/password.
   - **Browse Cars screen** (Buyer) — Calls `GET /api/cars` to list all available cars.
   - **Car Detail screen** — Shows full details, with a "Buy" button for buyers.
   - **My Purchases screen** (Buyer) — Calls `GET /api/transactions/my-purchases`.

### 8.3 Core Data: Keep or Remove?

You can keep Core Data for offline caching if desired, but the API should be the source of truth. The simplest approach is to remove Core Data and rely entirely on the API.

---

## 9. Firestore Indexes

The backend queries `transactions` by `buyerId` + `createdAt` (descending). This requires a Firestore composite index.

The index is already defined in `firestore.indexes.json` at the repository root:

```json
{
  "indexes": [
    {
      "collectionGroup": "transactions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "buyerId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

Deploy indexes with:
```bash
firebase deploy --only firestore:indexes
```

---

## 10. Checklist for Frontend Completion

Use this checklist to track progress on the frontend implementation:

### Setup
- [ ] Add Firebase iOS SDK to Xcode project (FirebaseAuth, FirebaseCore)
- [ ] Add GoogleService-Info.plist to the project
- [ ] Initialize Firebase in AppDelegate
- [ ] Create `APIService.swift` (see Section 5)
- [ ] Create Swift data models (see Section 4)

### Authentication Screens
- [ ] Create Login screen (email + password → `Auth.auth().signIn`)
- [ ] Create Sign Up screen (email + password + role selector → `Auth.auth().createUser` + `POST /api/users/profile`)
- [ ] Add sign-out button
- [ ] Route to correct flow after login based on user role from `GET /api/users/me`

### Seller Flow
- [ ] Update Add Car screen to use `POST /api/cars` instead of Core Data
- [ ] Update My Listings screen to use `GET /api/cars/my-listings` instead of Core Data
- [ ] Add Edit Car screen using `PUT /api/cars/:id`
- [ ] Add Delete Car using `DELETE /api/cars/:id`

### Buyer Flow
- [ ] Create Browse Cars screen using `GET /api/cars` (CollectionView or TableView)
- [ ] Create Car Detail screen using `GET /api/cars/:id`
- [ ] Add Buy button using `POST /api/transactions/purchase`
- [ ] Create My Purchases screen using `GET /api/transactions/my-purchases`

### Polish
- [ ] Handle loading states (show spinner during API calls)
- [ ] Handle error states (show alerts for API errors)
- [ ] Handle empty states (no cars, no purchases)
- [ ] Filter out sold cars on the browse screen (`isSold == false`)
- [ ] Test with both buyer and seller accounts
