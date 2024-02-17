//
//  SplashScreen.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 12/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import UIKit
import Firebase
import Purchases
import FirebaseDatabase

class SplashScreen: UIViewController {
    
    
    var purchaseInfo: Purchases.PurchaserInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        checkSubscription()
    }
    
    fileprivate func moveNext() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            self.moveToMain()
        })
    }
    
    fileprivate func checkSubscription() {
        // Using Swift Concurrency
        
        //DispatchQueue.global().async {
            Purchases.shared.purchaserInfo { purchaseInfo, error in
                if let purchaseInfo = purchaseInfo {
                    self.purchaseInfo = purchaseInfo
                }
                Defaults.shared.isSubActive = purchaseInfo?.entitlements.all["Pro Access"]?.isActive ?? false
                if Defaults.shared.isSubActive {
                    self.moveNext()
                    return
                }
                else {
                    if let _ = purchaseInfo?.originalPurchaseDate?.timeIntervalSince1970 {
                        self.updateStatus(status: "not active")
                    } else {
                        self.updateStatus(status: "N/A")
                    }
                }
            }
        //}
    }
    
    fileprivate func updateStatus(status: String) {
        if !Defaults.shared.isSubActive {
            if let userID = Auth.auth().currentUser?.uid {
                if let purchaseinfo = self.purchaseInfo, let edate = purchaseinfo.expirationDate(forEntitlement: "Pro Access") {
                    let timeinterval = edate.timeIntervalSince1970
                    Defaults.shared.subEndDate = timeinterval
                }
                Database.database().reference().child("users").child(userID).child("subscription").setValue(status)
                moveNext()
            } else {
                moveNext()
            }
        }
    }
    
    @objc func moveToMain() {
        var identifier = "SigninVC"
        if Defaults.shared.isAdmin {
          identifier = "adminNav"
        } else if Defaults.shared.isUser {
            identifier = "tabController"
        }
        moveToViewController(with: identifier)
      }

//    func validateReceipt(){
//        #if DEBUG
//               let urlString = "https://sandbox.itunes.apple.com/verifyReceipt"
//               #else
//               let urlString = "https://buy.itunes.apple.com/verifyReceipt"
//               #endif
//
//        guard let receiptURL = Bundle.main.appStoreReceiptURL, let receiptString = try? Data(contentsOf: receiptURL).base64EncodedString() , let url = URL(string: urlString) else {
//                return
//        }
//
//        let requestData : [String : Any] = ["receipt-data" : receiptString,
//                                            "password" : SHARED_SECRET,
//                                            "exclude-old-transactions" : true]
//
//        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = httpBody
//        URLSession.shared.dataTask(with: request)  { (data, response, error) in
//            // convert data to Dictionary and view purchases
//
//            if let data = data , error == nil {
//                    do {
//                        let appReceiptJSON = try JSONSerialization.jsonObject(with: data)
//                        print("success. here is the json representation of the app receipt: \(appReceiptJSON)")
//                        // if you are using your server this will be a json representation of whatever your server provided
//                    } catch let error as NSError {
//                        print("json serialization failed with error: \(error)")
//                    }
//                } else {
//                    print("the upload task returned an error: \(error)")
//                }
//        }.resume()
//    }
//
//    func expirationDateFor(_ identifier : String) -> Date?{
//            return UserDefaults.standard.object(forKey: identifier) as? Date
//        }
//    let subscriptionDate = IAPManager.shared.expirationDateFor("YOUR_PRODUCT_ID") ?? Date()
//    let isActive = subscriptionDate > Date()
}



