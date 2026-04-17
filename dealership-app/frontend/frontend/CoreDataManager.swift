//
//  CoreDataManager.swift
//  frontend
//
//  Created by Ishanpreet Singh on 2026-04-10.
//

import UIKit
import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()

    private init() {}

    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    func saveCar(
        title: String,
        brand: String,
        year: String,
        price: String,
        carDescription: String,
        imageName: String
    ) {
        let newCar = Car(context: context)
        newCar.id = UUID()
        newCar.title = title
        newCar.brand = brand
        newCar.year = year
        newCar.price = price
        newCar.carDescription = carDescription
        newCar.imageName = imageName
        newCar.isSold = false
        newCar.createdAt = Date()
        newCar.setValue(SessionManager.shared.currentUserEmail ?? "", forKey: "sellerEmail")
        newCar.setValue(nil, forKey: "buyerEmail")

        saveContextWithLogging(successMessage: "Car saved successfully")
    }

    func fetchCars(
        searchText: String? = nil,
        availableOnly: Bool = false,
        sellerOnly: Bool = false
    ) -> [Car] {
        let request: NSFetchRequest<Car> = Car.fetchRequest()
        var predicates: [NSPredicate] = []

        if availableOnly {
            predicates.append(NSPredicate(format: "isSold == NO"))
        }

        if sellerOnly, let email = SessionManager.shared.currentUserEmail, !email.isEmpty {
            predicates.append(NSPredicate(format: "sellerEmail == %@", email))
        }

        if let searchText, !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            predicates.append(
                NSPredicate(
                    format: "title CONTAINS[cd] %@ OR brand CONTAINS[cd] %@ OR year CONTAINS[cd] %@ OR price CONTAINS[cd] %@",
                    term, term, term, term
                )
            )
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch cars: \(error.localizedDescription)")
            return []
        }
    }

    func fetchPurchasedCarsForCurrentBuyer() -> [Car] {
        let request: NSFetchRequest<Car> = Car.fetchRequest()
        if let email = SessionManager.shared.currentUserEmail, !email.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "isSold == YES"),
                NSPredicate(format: "buyerEmail == %@", email)
            ])
        } else {
            request.predicate = NSPredicate(format: "isSold == YES")
        }
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch purchased cars: \(error.localizedDescription)")
            return []
        }
    }

    func purchase(car: Car) -> Bool {
        context.refresh(car, mergeChanges: true)

        guard !car.isSold else {
            return false
        }

        car.isSold = true
        car.setValue(SessionManager.shared.currentUserEmail ?? "", forKey: "buyerEmail")
        saveContextWithLogging(successMessage: "Car purchased successfully")
        return true
    }

    func deleteCar(_ car: Car) {
        context.delete(car)
        saveContextWithLogging(successMessage: "Car deleted successfully")
    }

    func toggleSoldStatus(for car: Car) {
        car.isSold.toggle()
        if car.isSold == false {
            car.setValue(nil, forKey: "buyerEmail")
        }
        saveContextWithLogging(successMessage: "Car status updated")
    }

    func sellerDashboardStats() -> (total: Int, active: Int, sold: Int) {
        let sellerCars = fetchCars(sellerOnly: true)
        let dataSet = sellerCars.isEmpty ? fetchCars() : sellerCars
        let total = dataSet.count
        let sold = dataSet.filter { $0.isSold }.count
        let active = total - sold
        return (total, active, sold)
    }

    func saveUser(name: String, email: String, password: String, accountType: String) {
        let newUser = User(context: context)
        newUser.id = UUID()
        newUser.name = name
        newUser.email = email
        newUser.password = password
        newUser.accountType = accountType

        saveContextWithLogging(successMessage: "User saved successfully")
    }

    func userExists(email: String) -> Bool {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)

        do {
            let users = try context.fetch(request)
            return !users.isEmpty
        } catch {
            print("Failed to check user: \(error.localizedDescription)")
            return false
        }
    }

    func loginUser(email: String, password: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)

        do {
            let users = try context.fetch(request)
            return users.first
        } catch {
            print("Login failed: \(error.localizedDescription)")
            return nil
        }
    }

    private func saveContextWithLogging(successMessage: String) {
        do {
            try context.save()
            print(successMessage)
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
