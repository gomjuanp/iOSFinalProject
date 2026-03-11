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
* Allows all team members to run the backend locally

### Framework

* **Express.js**
* Lightweight REST API framework
* Handles routing, middleware, and request/response lifecycle

### Database

* **Firebase Firestore**
* NoSQL cloud database
* Real-time capable
* Scalable and easy to integrate with iOS
* Stores users, cars, and transactions

### Authentication (Option A – Recommended)

* **Firebase Authentication**
* Email/Password authentication
* Secure token-based identity verification
* Backend verifies Firebase ID tokens using Firebase Admin SDK
* Simplifies integration with iOS

### Security Layer

* Firebase Admin SDK
* Middleware-based token verification
* Role-based access control (customer, individual dealer, company dealer)

### Development Tools

* VS Code (cross-platform)
* Postman (API testing)
* Git & GitHub (version control)

---

## Backend Responsibilities

The backend is responsible for:

### 1. User Management

* Storing user profiles in Firestore
* Handling user roles:

  * Customer
  * Dealer (Individual)
  * Dealer (Company)

Authentication itself is handled by Firebase Authentication.
The backend verifies identity and manages user data.

---

### 2. Car Listings

* Create car listing (Dealer only)
* Edit car listing
* Delete car listing
* Retrieve all available cars
* Retrieve car details
* Mark car as sold

---

### 3. Fake Payment System

This project does not implement real payment processing.

The backend simulates purchases by:

* Validating the car is available
* Marking the car as sold
* Creating a transaction record
* Returning a success response

This keeps the project realistic without requiring external payment gateways.

---

### 4. Transactions

When a purchase is made:

* A transaction record is created
* The buyer and seller are recorded
* The purchase amount is stored
* Timestamp is saved

---

## Database Structure (Firestore Collections)

### users

Stores user profile information.

Example fields:

* id
* name
* email
* role
* createdAt

---

### cars

Stores dealership listings.

Example fields:

* title
* brand
* price
* dealerId
* isSold
* createdAt

---

### transactions

Stores completed purchases.

Example fields:

* carId
* buyerId
* amount
* status
* createdAt

---

## Folder Structure

The backend follows a modular structure:

```
/backend
  /config
  /controllers
  /routes
  /middleware
  /services
  server.js
```

### config

Firebase configuration and environment setup.

### controllers

Business logic for each resource (users, cars, transactions).

### routes

Express route definitions that map endpoints to controllers.

### middleware

Authentication and authorization logic.

### services

Reusable logic for database interactions and external services.

### server.js

Application entry point.

---

## API Design Philosophy

* RESTful endpoint structure
* Clear separation of concerns
* Middleware-driven authentication
* Role-based access control
* JSON-only responses
* Clean, readable controller logic

---

## Why Firebase Authentication (Option A)

We are using Firebase Authentication instead of custom JWT generation because:

* It integrates directly with iOS
* It reduces backend security complexity
* It is secure and production-ready
* It simplifies identity management
* It allows easier token verification using Firebase Admin

The backend verifies tokens but does not generate them.

---

## Cross-Platform Compatibility

This backend:

* Runs on Windows
* Runs on macOS
* Requires only Node.js
* Can be edited in VS Code
* Can be deployed to cloud providers later

No Mac is required to develop or test the backend.

---

## Future Scalability

The backend can later support:

* Advanced filtering
* Search functionality
* Image uploads (Firebase Storage)
* Admin dashboard
* Real payment integration
* Deployment to cloud hosting

---

## Team Workflow

* Backend development happens inside `/backend`
* iOS team consumes API endpoints
* All work is version-controlled in a single repository
* Clear separation between frontend and backend responsibilities
