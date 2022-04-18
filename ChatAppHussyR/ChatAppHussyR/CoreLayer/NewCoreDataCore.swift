//
//  NewCoreDataCore.swift
//  ChatAppHussyR
//
//  Created by Данил on 18.04.2022.
//

import Foundation
import CoreData

protocol CoreDataCoreProtocol {
    func fetch<T: NSManagedObject>(type: T.Type, with predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]) -> [T]
    func performSave(block: @escaping (NSManagedObjectContext) -> Void)
    var contextForFetchedResultController: NSManagedObjectContext { get }
}

class NewCoreDataCore: CoreDataCoreProtocol {
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChatAppHussyR")
        container.loadPersistentStores { desc, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print(desc)
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var contextForFetchedResultController: NSManagedObjectContext {
        viewContext
    }
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func fetch<T: NSManagedObject>(type: T.Type, with predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]) -> [T] {
        let fetch = type.fetchRequest()
        fetch.predicate = predicate
        fetch.sortDescriptors = sortDescriptors
        do {
            let objects = try container.viewContext.fetch(fetch)
            #if COREDATALOG
            print("Данные о \(objects.count) каналах считаны")
            #endif
            guard let objects = objects as? [T] else { return [] }
            return objects
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    public func performSave(block: @escaping (NSManagedObjectContext) -> Void) {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSOverwriteMergePolicy
        context.perform { [weak self] in
            guard let self = self else { return }
            block(context)
            self.performSave(context: context)
        }
    }
    
    private func performSave(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                #if COREDATALOG
                print("Данные сохранены")
                #endif
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}
