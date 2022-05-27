//
//  NewCoreDataStack.swift
//  ChatAppHussyR
//
//  Created by Данил on 04.04.2022.
//

import Foundation
import CoreData

// MARK: - UNUSED

final class NewCoreDataStack {
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
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    public func fecthChannels() -> [DBChannel] {
        let fetch: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
        do {
            let channels = try container.viewContext.fetch(fetch)
            #if COREDATALOG
            print("Данные о \(channels.count) каналах считаны")
            #endif
            return channels
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    public func fecthChannel(predicate: NSPredicate) -> [DBChannel] {
        let fetch: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
        fetch.predicate = predicate
        do {
            let channels = try container.viewContext.fetch(fetch)
            #if COREDATALOG
            print("Данные о канале считаны")
            #endif
            return channels
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
