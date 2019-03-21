//
//  CoreDataManager.swift
//  WorldVenture_CodingChallenge
//
//  Created by ruijia lin on 3/19/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

import UIKit
import CoreData

struct CoreDataManager {
    static var container: NSPersistentContainer!
    static var favoriteLocations = [NSManagedObject]()
    
    static func setupCoreData() {
        container = NSPersistentContainer(name: "FavoriteLocationModel")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("Unresolved error::: \(error)")
            }
        }
    }
    
    static func saveContext(name: String?,
                            street: String?, city: String?,
                            state: String?, zipCode: String?,
                            latitude: Double, longitude: Double){
                            //, distanceText: String?, radius: Double?){
        
        let managedContext =
            container.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "FavoriteLocationEntity",
                                       in: managedContext)!
        
        let favoriteLocation = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        favoriteLocation.setValue(NSUUID().uuidString, forKey: "identifier")
        
        if let name = name {
            favoriteLocation.setValue(name, forKeyPath: "name")
        }
        if let street = street {
            favoriteLocation.setValue(street, forKeyPath: "street")
        }
        if let city = city {
            favoriteLocation.setValue(city, forKeyPath: "city")
        }
        if let state = state {
            favoriteLocation.setValue(state, forKeyPath: "state")
        }
        if let zipCode = zipCode {
            favoriteLocation.setValue(zipCode, forKeyPath: "zipCode")
        }
        favoriteLocation.setValue(longitude, forKeyPath: "longitude")
        favoriteLocation.setValue(latitude, forKeyPath: "latitude")
        
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    static func fetchContext() -> [NSManagedObject] {
        let managedContext =
            container.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "FavoriteLocationEntity")
        
        do {
            favoriteLocations = try managedContext.fetch(fetchRequest)
            return favoriteLocations
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return []
    }
    
}
