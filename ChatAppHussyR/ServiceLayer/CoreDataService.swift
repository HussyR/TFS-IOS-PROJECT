//
//  CoreDataService.swift
//  ChatAppHussyR
//
//  Created by Данил on 18.04.2022.
//

import Foundation
import CoreData
import Firebase

protocol CoreDataServiceProtocol {
    func updateRemoveOrDeleteChannels(
        objectsForUpdate: [DocumentChange],
        isFirstLaunch: Bool
    )
    func updateRemoveOrDeleteMessages(
        objectsForUpdate: [DocumentChange],
        channelID: String
    )
    var contextForFetchedResultController: NSManagedObjectContext { get }
}

class CoreDataService: CoreDataServiceProtocol {
    
    private let coreDataCore: CoreDataCoreProtocol
    
    var contextForFetchedResultController: NSManagedObjectContext {
        return coreDataCore.contextForFetchedResultController
    }
    
    init(coreDataCore: CoreDataCoreProtocol) {
        self.coreDataCore = coreDataCore
    }
    
    func updateRemoveOrDeleteChannels(
        objectsForUpdate: [DocumentChange],
        isFirstLaunch: Bool
    ) {
        coreDataCore.performSave { context in
            let dbChannels = self.coreDataCore.fetch(type: DBChannel.self, with: nil, sortDescriptors: [], context: context)
            var channels = [Channel]()
            objectsForUpdate.forEach { documentC in
                let channel = Channel(dictionary: documentC.document.data(), identifier: documentC.document.documentID)
                
                switch documentC.type {
                case .removed:
                    self.removeChannelFromCoreData(context: context, identifier: channel.identifier)
                default:
                    if let dbchannel = self.doesChannelExist(id: channel.identifier, dbChannels: dbChannels) {
                        dbchannel.lastActivity = channel.lastActivity
                        dbchannel.lastMessage = channel.lastMessage
                    } else {
                        let dbchannel = DBChannel(context: context)
                        dbchannel.name = channel.name
                        dbchannel.identifier = channel.identifier
                        dbchannel.lastMessage = channel.lastMessage
                        dbchannel.lastActivity = channel.lastActivity
                    }
                    channels.append(channel)
                }
            }
            
        }
    }
    
    private func doesChannelExist(id: String, dbChannels: [DBChannel]) -> DBChannel? {
        guard let channel = dbChannels.filter({ $0.identifier == id }).first else { return nil }
        return channel
    }
    
    private func getRemovedDBChannels(
        frChannels: [Channel],
        dbChannels: [DBChannel]) -> [DBChannel] {
            // dbchannels уже сохраненные в кор дате каналы
            // frchannels каналы которые пришли их firestore
            // требуется найти были ли удалены каналы и вернуть их
            guard !frChannels.isEmpty && !dbChannels.isEmpty else { return [] }
            let oldChannels = dbChannels.map { dbchannel in
                return Channel(identifier: dbchannel.identifier ?? "",
                               name: dbchannel.name ?? "",
                               lastMessage: dbchannel.lastMessage ?? "",
                               lastActivity: dbchannel.lastActivity ?? Date())
            }
            let newChannelsSet = Set(frChannels)
            let oldChannelsSet = Set(oldChannels)
            
            let resultsID = oldChannelsSet.subtracting(newChannelsSet).map { $0.identifier }
            let returnArray = dbChannels.filter { resultsID.contains($0.identifier ?? "")
            }
            return returnArray
    }
    
    private func removeChannelFromCoreData(context: NSManagedObjectContext, identifier: String) {
        let fetch: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
        fetch.predicate = NSPredicate(format: "%K == %@", #keyPath(DBChannel.identifier), identifier)
        guard let channel = try? context.fetch(fetch).first else { return }
        context.delete(channel)
    }
    
    func updateRemoveOrDeleteMessages(
        objectsForUpdate: [DocumentChange],
        channelID: String) {
            coreDataCore.performSave { context in
                let predicate = NSPredicate(
                    format: "%K == %@",
                    #keyPath(DBChannel.identifier),
                    channelID
                )
                guard let dbChannel = self.coreDataCore.fetch(type: DBChannel.self, with: predicate, sortDescriptors: [], context: context).first,
                      let dbmessages = dbChannel.messages?.array as? [DBMessage]
                else { return }
                objectsForUpdate.forEach { documentChange in
                    if !self.doesMessageExist(dbmessages: dbmessages, id: documentChange.document.documentID) {
                        let message = Message(dictionary: documentChange.document.data())
                        let dbMessage = DBMessage(context: context)
                        dbMessage.content = message.content
                        dbMessage.created = message.created
                        dbMessage.senderId = message.senderId
                        dbMessage.senderName = message.senderName
                        dbMessage.identifier = documentChange.document.documentID
                        dbChannel.addToMessages(dbMessage)
                    }
                }
            }
        }
    
    private func doesMessageExist(dbmessages: [DBMessage], id: String) -> Bool {
        if dbmessages.filter({ $0.identifier == id }).first != nil {
            return true
        }
        return false
    }
}
