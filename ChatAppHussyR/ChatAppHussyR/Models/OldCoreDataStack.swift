//
//  OldCoreDataStack.swift
//  ChatAppHussyR
//
//  Created by Данил on 08.04.2022.
//

import Foundation
import CoreData

final class OldCoreDataStack {
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "ChatAppHussyR", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url)
        else {
            fatalError("no xcdatamodel")
        }
        return model
    }()
    
    private lazy var persistantStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        var documentDirUrl = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("ChatAppHussyR.sqlite")
        do {
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: documentDirUrl
            )
        } catch {
            print(error.localizedDescription)
        }
        
        return coordinator
    }()
    
    private lazy var readContext: NSManagedObjectContext = {
        // only read context
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistantStoreCoordinator
        return context
    }()
    
    private lazy var writeContext: NSManagedObjectContext = {
        // only write context
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistantStoreCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()
    
    public func fetchChannels() -> [DBChannel] {
        let fetchRequest: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
        do {
            let channels = try readContext.fetch(fetchRequest)
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
            let channels = try readContext.fetch(fetch)
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
        let context = writeContext
        writeContext.perform {
            block(context)
            if context.hasChanges {
                do {
                    try self.performSave(in: context)
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
        }
    }
    
    private func performSave(in context: NSManagedObjectContext) throws {
        try context.save()
        #if COREDATALOG
        print("Данные сохранены")
        #endif
    }
}
