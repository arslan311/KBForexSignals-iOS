//
//  KBForexProducts.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 07/07/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import Foundation

public struct KBForexProducts {
    public static let basicMonthPlan = "com.KBs.ForexSignals.subplans"
    public static let superMonthPlan = "com.KBs.ForexSignals.onemonthsuper"
    public static let twoMonthPlan = "com.KBs.ForexSignals.twomonths"
    public static let basicWeekly = "com.KBs.ForexSignals.weekly"
    public static let instance = KBForexProducts()
    //public static let store = IAPManager(productIDs: KBForexProducts.productIDs)
    //private static let productIDs: Set<ProductID> = [KBForexProducts.basicWeekly, KBForexProducts.basicMonthPlan, KBForexProducts.superMonthPlan, KBForexProducts.twoMonthPlan]
}


public func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}


