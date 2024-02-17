//
//  Chat.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 30/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import Foundation


struct Chat {
    var users: [String]
    
    var dictionary: [String: Any] {
        
        return ["users": users]
    }
}

extension Chat {
    
    init?(dictionary: [String: Any]) {
        guard let chatUsers = dictionary["users"] as? [String] else { return nil }
        
        self.init(users: chatUsers)
        
    }
    
}
