//
//  Actions.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 13/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import Purchases

class Actions {
    
    static let instance = Actions()
    var ref: DatabaseReference!

    func showAlert(controller: UIViewController, alertTitle: String, alertMessage: String)  {
              let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           controller.present(alert, animated: false)
          }
      
    func checkSubscriptions()  {
        
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements["Pro Access"]?.isActive == true {
                Subscriptions.instance.sub_status = true
            } else {
                //self.subExpiredDelegate?.subExpired()
                UserDefaults.standard.set(false, forKey: "subscribed")
                if let userID = Auth.auth().currentUser?.uid {
                    self.ref = Database.database().reference()
                    let inactiveSub = ["subscription": "not active"]
                    //self.ref.child("users_test").child(userID).updateChildValues(inactiveSub)
                    self.ref.child("users").child(userID).updateChildValues(inactiveSub)
                    self.signoutUser()
                }
                AlertControllerHelper.showAlertWithTitleAndMessageCompletion(title: "Subscription Expired!", message: "Your subscription has expired, please login again and renew your subscriptions plan") { (success) in
                    if success {
                        
                    }
                    return
                }
            }
        }
    }
    func signoutUser() {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        //moveToViewController(with: "SigninVC")
        if #available(iOS 13.0, *) {
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            //set storyboard ID to your root navigationController.
            if let vc = storyBoard.instantiateViewController(identifier: "SigninVC") as? SigninVC {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.window?.rootViewController = vc
            }
            
        } else {
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            //set storyboard ID to your root navigationController.
            if let vc = storyBoard.instantiateViewController(withIdentifier: "SigninVC") as? SigninVC {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.window?.rootViewController = vc
            }
        }
    }
//
//        func verifyScript(identifier: String, _ response: @escaping(_ success: Bool, _ expDate: Date?) -> ()) {
//            //var edate: Date?
//            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: SHARED_SECRET)
//            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//                switch result {
//                case .success(let receipt):
//                 let productId = identifier
//                 // Verify the purchase of a Subscription
//                 let purchaseResult = SwiftyStoreKit.verifySubscription(
//                     ofType: .autoRenewable, // or .nonRenewing (see below)
//                     productId: productId,
//                     inReceipt: receipt)
//                 switch purchaseResult {
//                 case .purchased(let expiryDate, let items):
//                     //edate = expiryDate
//                     print(items)
//                     print("\(productId) is valid until \(expiryDate)\n")
//                     print("\(productId) is valid until \(expiryDate)\n")
//                     response(true, expiryDate)
//                 case .expired(let expiryDate, let items):
//                     //edate = expiryDate
//                     print("\(productId) is expired since \(expiryDate)\n\(items)\n")
//                     response(false, expiryDate)
//                 case .notPurchased:
//                     //edate = nil
//                     print("The user has never purchased \(productId)")
//                     response(false, nil)
//                 }
//             case .error(let error):
//                 print("Receipt verification failed: \(error)")
//             }
//         }
//     }
    }


protocol DatabaseRepresentation {
  var representation: [String: Any] { get }
}
