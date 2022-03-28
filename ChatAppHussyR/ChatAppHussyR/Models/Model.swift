//
//  Model.swift
//  ChatAppHussyR
//
//  Created by Данил on 07.03.2022.
//

import Foundation

struct Channel {
    let identifier: String
    let name: String
    let lastMessage: String?
    let lastActivity: Date?
}

struct Message {
    let content: String
    let created: Date
    let senderId: String
    let senderName: String
}
