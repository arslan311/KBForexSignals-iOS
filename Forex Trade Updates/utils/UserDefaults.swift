//
//  UserDefaults.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 24/08/2023.
//  Copyright © 2023 Arslan. All rights reserved.
//

import UIKit

class Defaults {

    static let shared = Defaults()
    
    var isSubActive: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "subscription")
        }
        get {
            return UserDefaults.standard.value(forKey: "subscription") as? Bool ?? false
        }
    }
    
    var subEndDate: Double {
        set {
            UserDefaults.standard.set(newValue, forKey: "subedate")
        }
        get {
            return UserDefaults.standard.value(forKey: "subedate") as? Double ?? 0.0
        }
    }
    
    var isAdmin: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isAdminLoggedIn")
        }
        get {
            return UserDefaults.standard.value(forKey: "isAdminLoggedIn") as? Bool ?? false
        }
    }
    
    var isUser: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isUserLoggedIn")
        }
        get {
            return UserDefaults.standard.value(forKey: "isUserLoggedIn") as? Bool ?? false
        }
    }
    
    
    var userLoggedIn: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isLogin")
        }
        get {
            return UserDefaults.standard.value(forKey: "isLogin") as? Bool ?? false
        }
    }
    
    

}
