//
//  FirebaseService.swift
//  ChatAppHussyR
//
//  Created by Данил on 18.04.2022.
//

import Foundation
import Firebase

protocol FirebaseServiceProtocol {
    
    func addChannel(name: String, uuid: String)
    func addMessage(message: Message, channelID: String)
    func getChannels(block: @escaping (QuerySnapshot) -> Void)
    func getMessages(channelID: String, block: @escaping (QuerySnapshot) -> Void)
    func removeChannelWithID(_ id: String)
    
}

class FirebaseService: FirebaseServiceProtocol {
    
    let firebaseCore: FirebaseCoreProtocol
    
    init(firebaseCore: FirebaseCoreProtocol) {
        self.firebaseCore = firebaseCore
    }
    
    func addMessage(message: Message, channelID: String) {
        firebaseCore.channelsReference
            .document(channelID)
            .collection("messages")
            .addDocument(data: message.toDict())
    }
    
    func addChannel(name: String, uuid: String) {
        let ref = firebaseCore.channelsReference.addDocument(data: ["name": name])
        let message = Message(
            content: "First message",
            created: Date(),
            senderId: uuid,
            senderName: "Danila")
        ref.collection("messages").addDocument(data: message.toDict())
    }
    
    func removeChannelWithID(_ id: String) {
        firebaseCore.channelsReference.document(id).delete()
    }
    
    func makeReference(channelID: String?) -> CollectionReference {
        if let channelID = channelID {
            return firebaseCore.channelsReference.document(channelID).collection("messages")
        } else {
            return firebaseCore.channelsReference
        }
    }
    
    func getChannels(block: @escaping (QuerySnapshot) -> Void) {
        self.firebaseCore.addSnapshotListener(reference: makeReference(channelID: nil)) { snap in
            block(snap)
        }
    }
    
    func getMessages(channelID: String, block: @escaping (QuerySnapshot) -> Void) {
        self.firebaseCore.addSnapshotListener(reference: makeReference(channelID: channelID)) { snap in
            block(snap)
        }
    }
}
