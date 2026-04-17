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

        do {
            try context.save()
            print("Car saved successfully")
        } catch {
            print("Failed to save car: \(error.localizedDescription)")
        }
    }

    func fetchCars() -> [Car] {
        let request: NSFetchRequest<Car> = Car.fetchRequest()

        let sort = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sort]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch cars: \(error.localizedDescription)")
            return []
        }
    }
    func saveUser(name: String, email: String, password: String, accountType: String) {
        let newUser = User(context: context)
        newUser.id = UUID()
        newUser.name = name
        newUser.email = email
        newUser.password = password
        newUser.accountType = accountType

        do {
            try context.save()
            print("User saved successfully")
        } catch {
            print("Failed to save user: \(error.localizedDescription)")
        }
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
    }
