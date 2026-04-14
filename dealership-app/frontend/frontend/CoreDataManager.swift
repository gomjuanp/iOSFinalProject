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
    }
