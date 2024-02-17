//
//  Subscriptions.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 02/07/2023.
//  Copyright © 2023 Arslan. All rights reserved.
//

import Foundation
import Purchases

class Subscriptions {
    
    static fileprivate let _subscriptions = Subscriptions()
    class var instance: Subscriptions {
        return _subscriptions
    }
    var packages = [Purchases.Package]()
    var sub_status: Bool = false
    
    
    func loadPackages(_ completion: @escaping(_ success: Bool) -> Void) {
        // Fetch offerings
        //RappleActivityIndicatorView.startAnimating()
        
        Purchases.shared.offerings { offerings, Error in
            //RappleActivityIndicatorView.stopAnimation()
            if let error = Error {
                print(error)
                completion(false)
                return
            }
            if let packages = offerings?.current?.availablePackages {
                packages.forEach { Subscriptions.instance.packages.append($0) }
            }
            if let package2 = offerings?.offering(identifier: "MonthlyPro")?.availablePackages {
                package2.forEach { Subscriptions.instance.packages.append($0) }
            }
            
            
            completion(true)
        }
    }
    
    func checkSubStatus() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements["Pro Access"]?.isActive == true {
                Subscriptions.instance.sub_status = true
            }
        }
    }
    
}

