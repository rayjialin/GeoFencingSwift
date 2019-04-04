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
    
    // MARK: setup coredata
    static func setupCoreData() {
        container = NSPersistentContainer(name: "FavoriteLocationModel")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("Unresolved error::: \(error)")
            }
        }
    }
    
    // MARK: Save Record
    static func saveContext(name: String?,
                            street: String?, city: String?,
                            state: String?, zipCode: String?,
                            latitude: Double, longitude: Double,
                            identifier: String){
        
        let managedContext =
            container.viewContext
        
        guard let entity =
            NSEntityDescription.entity(forEntityName: "FavoriteLocationEntity",
                                       in: managedContext) else { return }
        
        let favoriteLocation = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        favoriteLocation.setValue(identifier, forKey: "identifier")
        
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
    
    // MARK: Delte record from core data
    static func removeContextFor(annotation: WVAnnotation) {
        let managedContext =
            container.viewContext
        let entity = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteLocationEntity")
        entity.predicate = NSPredicate(format: "identifier = %@", annotation.identifier)
        
        // fetch result based on coordinate and delete object
        do {
           let result = try managedContext.fetch(entity)
            guard let resultData = result as? [NSManagedObject] else { return }
            for object in resultData {
                managedContext.delete(object)
            }
            
            // save context after deletion
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        } catch {
            print("Fail to fetch result from coreData")
        }
    }
    
    // MARK: Fetch data from core data
    static func fetchContext() -> [NSManagedObject] {
        let managedContext =
            container.viewContext
        
        let entity =
            NSFetchRequest<NSManagedObject>(entityName: "FavoriteLocationEntity")
        
        do {
            favoriteLocations = try managedContext.fetch(entity)
            return favoriteLocations
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return []
    }
    
    // MARK: Fetch data from core data
    static func fetchContextFor(identifier: String) -> String? {
        let managedContext =
            container.viewContext
        let entity = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteLocationEntity")
        entity.predicate = NSPredicate(format: "identifier = %@", identifier)
        entity.fetchLimit = 1
        
        do {
            let favoriteLocations = try managedContext.fetch(entity)
            guard let favLocation = favoriteLocations.first as? NSManagedObject ,
            let name = favLocation.value(forKey: "name") as? String else { return nil }
            return name
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return nil
    }
}
