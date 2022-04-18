//
//  Model.swift
//  ChatAppHussyR
//
//  Created by Данил on 07.03.2022.
//

import Foundation
import Firebase

protocol FirebaseModel {
    func toDict() -> [String: Any]
}

struct Channel: Hashable {
    let identifier: String
    let name: String
    let lastMessage: String
    let lastActivity: Date
}

struct Message: Hashable {
    let content: String
    let created: Date
    let senderId: String
    let senderName: String
}

extension Message: FirebaseModel {
    func toDict() -> [String: Any] {
        return [
            "content": content,
            "senderID": senderId,
            "created": created,
            "senderName": senderName
        ]
    }
}

extension Channel: FirebaseModel {
    func toDict() -> [String: Any] {
        return [
            "name": name
        ]
    }
}

extension Message {
    init (dictionary: [String: Any]) {
        content = (dictionary["content"] as? String) ?? ""
        senderId = (dictionary["senderID"] as? String) ?? ""
        created = (dictionary["created"] as? Timestamp)?.dateValue() ?? Date()
        senderName = (dictionary["senderName"] as? String) ?? ""
    }
}

extension Channel {
    init (dictionary: [String: Any], identifier: String) {
        self.identifier = identifier
        name = dictionary["name"] as? String ?? ""
        lastMessage = (dictionary["lastMessage"] as? String) ?? ""
        lastActivity = (dictionary["lastActivity"] as? Timestamp)?.dateValue() ?? Date()
    }
}
