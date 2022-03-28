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


struct MyData {
    var name: String?
    var message: String?
    var date: Date?
    var online: Bool
    var hasUnreadMessages: Bool
    
    static var stringDates: [Date] {
        let strings = [
            "2022 14 Jan 23:55",
            "2022 16 Feb 02:55",
            "2022 07 Mar 03:55",
            "2022 01 Jan 04:55",
            "2022 09 Feb 05:55",
            "2022 07 Mar 06:55",
            "2022 05 Jan 07:55",
            "2022 27 Feb 08:55",
            "2022 07 Mar 09:55",
            "2022 24 Jan 10:55"
        ]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy dd MMM HH:mm"
        return strings.compactMap { formatter.date(from: $0) }
    }

    static func getOnlineData() -> [MyData] {
        return [
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[0], online: true, hasUnreadMessages: true),
            MyData(name: "Danila", message: nil, date: stringDates[1], online: true, hasUnreadMessages: false),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[2], online: true, hasUnreadMessages: false),
            MyData(name: "Danila", message: nil, date: stringDates[3], online: true, hasUnreadMessages: false),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[4], online: true, hasUnreadMessages: false),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[5], online: true, hasUnreadMessages: true),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[6], online: true, hasUnreadMessages: false),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[7], online: true, hasUnreadMessages: true),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[8], online: true, hasUnreadMessages: false),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[9], online: true, hasUnreadMessages: true),
        ]
    }
    
    static func getOfflineData () -> [MyData] {
        return [
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[0], online: false, hasUnreadMessages: true),
            MyData(name: "Danila", message: nil, date: stringDates[1], online: false, hasUnreadMessages: false),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[2], online: false, hasUnreadMessages: false),
            MyData(name: "Danila", message: nil, date: stringDates[3], online: false, hasUnreadMessages: false),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[4], online: false, hasUnreadMessages: false),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[5], online: false, hasUnreadMessages: true),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[6], online: false, hasUnreadMessages: false),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[7], online: false, hasUnreadMessages: true),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[8], online: false, hasUnreadMessages: false),
            MyData(name: "Danila", message: "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello", date: stringDates[9], online: false, hasUnreadMessages: true),
        ]
    }
    
}
