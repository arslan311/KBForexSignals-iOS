//
//  Message.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 30/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import Foundation
import UIKit
import MessageKit
import FirebaseFirestore
import FirebaseAuth
import Firebase

struct Message {
var id: String
var docId: String = ""
var content: String
var created: Timestamp
var senderID: String
var senderName: String
var senderType: String
var dictionary: [String: Any] {
return [
"id": id,
"content": content,
"created": created,
"senderID": senderID,
"senderName":senderName,
"senderType": senderType]
    }
}
extension Message {
    init?(docId: String, dictionary: [String: Any]) {
        let docId = docId
        guard let id = dictionary["id"] as? String,
let content = dictionary["content"] as? String,
let created = dictionary["created"] as? Timestamp,
let senderID = dictionary["senderID"] as? String,
let senderType = dictionary["senderType"] as? String,
let senderName = dictionary["senderName"] as? String

    
else {return nil}
    self.init(id: id, docId: docId, content: content, created: created, senderID: senderID, senderName:senderName, senderType: senderType)
    }
}

extension Message: MessageType {
var sender: SenderType {
return Sender(id: senderID, displayName: senderName)
    }
var messageId: String {
return id
    }
var sentDate: Date {
return created.dateValue()
    }
var kind: MessageKind {
return .text(content)
    }
}
