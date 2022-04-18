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
    func addSnapshotListenerToChannel(block: @escaping (QuerySnapshot) -> Void)
    func addSnapshotListenerToMessages(channelID: String, block: @escaping (QuerySnapshot) -> Void)
    func removeChannelWithID(_ id: String)
}

class FirebaseService: FirebaseServiceProtocol {
    let firebaseCore: FirebaseCoreProtocol
    
    init() {
        firebaseCore = FirebaseCore()
    }
    
    func addMessage(message: Message, channelID: String) {
        firebaseCore.channelsReference
            .document(channelID)
            .collection("messages")
            .addDocument(data: message.toDict())
    }
    
    func addChannel(name: String, uuid: String) {
        let ref = firebaseCore.channelsReference.addDocument(data: ["name": name])
        let message = Message(content: "First message", created: Date(), senderId: uuid, senderName: "Danila")
        ref.collection("messages").addDocument(data: message.toDict())
    }
    
    func addSnapshotListenerToChannel(block: @escaping (QuerySnapshot) -> Void) {
        firebaseCore.channelsReference.order(by: "lastActivity", descending: true).addSnapshotListener { snap, error in
            guard let snap = snap,
                  error == nil
            else { return }
            block(snap)
        }
    }
    
    func removeChannelWithID(_ id: String) {
        firebaseCore.channelsReference.document(id).delete()
    }
    
    func addSnapshotListenerToMessages(channelID: String, block: @escaping (QuerySnapshot) -> Void) {
        firebaseCore.channelsReference.document(channelID).collection("messages").addSnapshotListener { snap, error in
            guard let snap = snap,
                  error == nil
            else { return }
            block(snap)
        }
    }
}
