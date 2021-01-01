//
//  DataMAnager.swift
//  VirtualTourist
//
//  Created by Giovanni Luidi Bruno on 01/01/21.
//  Copyright © 2021 Giovanni Luigi Bruno. All rights reserved.
//

import Foundation
import CoreData


class DataManager {
    static let shared = DataManager()
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "VirtualTourist")
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { [weak self] (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self?.autosave()
            completion?()
        }
    }
    
    func autosave() {
        saveContext()
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
            self?.autosave()
        }
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
}

// Handles user preferences
extension DataManager {
    
    func save<T: Codable>(object: T, key: String? = nil) {
        if let data = try? JSONEncoder().encode(object) {
            UserDefaults.standard.set(data, forKey: key ?? String(describing: T.self))
        }
    }
    
    func get<T: Codable>(key: String? = nil) -> T? {
        if let data = UserDefaults.standard.value(forKey: key ?? String(describing: T.self)) as? Data ,let object = try? JSONDecoder().decode(T.self, from: data) {
            return object
        }
        return nil
    }
    
}
