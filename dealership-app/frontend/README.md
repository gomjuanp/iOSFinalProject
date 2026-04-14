## Frontend

The frontend is built in **Swift using UIKit and Storyboard in Xcode**.  
It handles the user interface, navigation between screens, and local data storage using **Core Data**.

### Main Features Implemented

#### 1. Account Type Routing
The Create Account screen allows the user to choose between:
- Buyer
- Seller

Based on the selected account type, the app opens the correct flow.

#### 2. Seller Flow
The seller side is currently the main completed flow.

It includes:
- **My Listings**
- **Add New Car**

The seller can:
- open the My Listings page
- tap the **+** button
- go to the Add New Car screen
- enter car details
- save the listing

#### 3. Add New Car
The Add New Car screen is connected to Core Data.

It collects:
- Listing Title
- Brand
- Year
- Price
- Image Name
- Description

When the user taps **Add Car**:
- the input is validated
- the car is saved into Core Data
- a success message is shown
- the app returns to My Listings

#### 4. Core Data Integration
Core Data is used to store car listings locally inside the app.

Each car record includes:
- id
- title
- brand
- year
- price
- carDescription
- imageName
- isSold
- createdAt

This allows listings to remain saved even after the app is closed and reopened.

#### 5. My Listings TableView
The My Listings screen uses a **TableView** to display saved cars.

It:
- fetches saved car data from Core Data
- shows the saved listings in a list
- refreshes when a new car is added

This satisfies the assignment requirement for using a **TableView**.

#### 6. Image Display in Listings
Each saved car can also show an image in My Listings.

The image is loaded using the image name entered on the Add New Car page.  
The name must match an image stored in **Assets.xcassets**.

Example:
- If the asset name is `Mercedes`, the image field should contain `Mercedes`

#### 7. Navigation
The app uses **Navigation Controller** and storyboard segues for moving between screens.

Current working navigation includes:
- Create Account → Seller side
- My Listings → Add New Car
- Add New Car → back to My Listings after saving

This satisfies the assignment requirement for using a **Navigation Controller**.

---

## Files and Their Purpose

### `AppDelegate.swift`
Sets up the application and initializes Core Data support.

### `SceneDelegate.swift`
Handles scene lifecycle and saves Core Data when needed.

### `CoreDataManager.swift`
Contains the main Core Data logic:
- save car
- fetch cars

### `AddCarViewController.swift`
Controls the Add New Car screen:
- reads text field input
- validates form data
- saves a car
- returns to My Listings

### `MyListingsViewController.swift`
Controls the My Listings screen:
- fetches saved cars
- displays them in a TableView
- refreshes listings after new data is added

### `ViewController.swift`
Handles account type selection and routing to Buyer or Seller flow.

### `DealershipDataModel.xcdatamodeld`
Defines the Core Data `Car` entity and all saved car fields.

---

## Current Frontend Progress

Completed:
- Seller routing from Create Account
- Add New Car screen
- Core Data save and fetch
- My Listings TableView
- Image loading from asset name
- Navigation between seller screens

Still remaining / next work:
- Buyer side implementation
- Browse Cars using CollectionView
- Car details screen improvements
- Edit / update listing flow
- UI cleanup and final testing
