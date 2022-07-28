//
//  CoreDataService.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/28.
//

import CoreData

class CoreDataService {
    static let shared = CoreDataService()
    
    lazy var persistentContrainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error) \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContrainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContrainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError) \(nsError.userInfo)")
            }
        }
    }
    
    func fetch<T: NSManagedObject>(
        request: NSFetchRequest<T> = NSFetchRequest(entityName: "SavedModel")
    ) -> [T] {
        
        //TODO: - Sort 메서드 추가하기
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    @discardableResult
    func deleteAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> Bool {
        let request: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try self.persistentContrainer.viewContext.execute(delete)
            return true
        } catch {
            return false
        }
    }
}
