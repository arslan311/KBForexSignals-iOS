//
//  NotifSentModel.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 18/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import Foundation

class NotifSentModel {
    
    var notifTitle: String!
    var notifBody: String!
    var notifID: String!
    var sentDateTime: Double!
    
    
    init(id: String, title: String, body: String, datetime: Double) {
        self.notifID = id
        self.notifTitle = title
        self.notifBody = body
        self.sentDateTime = datetime
    }
    
    
}
