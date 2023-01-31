//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Олеся Егорова on 31.01.2023.
//

import Foundation
import CoreData

// MARK: - Core Data stack
final class StorageManager {
    
    static let shared = StorageManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext!
    
    private init() {
        context = persistentContainer.viewContext
    }

    func fetchData(completion: (Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        do {
            let tasks = try context.fetch(fetchRequest)
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func remove(task: Task) {
        context.delete(task)
        saveContext()
    }
    
    func update(task: Task, taskName: String) {
        task.name = taskName
        saveContext()
    }
    
    func save(_ taskName: String, completion: (Task) -> Void) {
        let task = Task(context: context)
        task.name = taskName
        completion(task)
        saveContext()
    }
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}




