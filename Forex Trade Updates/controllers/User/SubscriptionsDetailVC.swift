//
//  SubscriptionsDetailVC.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 18/07/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import UIKit
import FirebaseAuth
import MBProgressHUD
import Firebase
import Purchases

class SubscriptionsDetailVC: UIViewController {

    @IBOutlet weak var lblsubDetail: UITextView!
    
    @IBOutlet weak var lblsubType: UILabel!
    
    @IBOutlet weak var lblsubPrice: UILabel!
    var subPrice: String!
    var subType: String!
    //var productToPurchase: SKProduct?
    var packageToPurchase: Purchases.Package?
    var ref: DatabaseReference!
    var purchasedType: String = "N/A"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(productToPurchase?.localizedPrice as Any)
       // self.lblsubPrice.text = productToPurchase?.localizedPrice //productToPurchase?.localizedPrice
        updateUI()
    }

    @objc func updateUI() {
        let bullet = "•  "
        
        var strings = [String]()
        strings.append("Payment will be charged to your iTunes account at confirmation of purchase.")
        strings.append("Your subscription will automatically renew unless auto-renew is turned off at least 24-hours before the end of the current subscription period.")
        strings.append("Your account will be charged for renewal within 24-hours prior to the end of the current subscription period.")
        strings.append("Automatic renewals will cost the same price you were originally charged for the subscription.")
        strings.append("You can manage your subscriptions and turn off auto-renewal by going to your Account Settings on the App Store after purchase.")
        strings.append("Read our terms of service and privacy policy for more information.")

        strings.append("Privacy Policy:\n\n   https://sites.google.com/view/kbs-forexsignals-privacypolicy/home")

        strings.append("Terms of Use:\n\n    https://sites.google.com/view/kbs-forexsignals-termsofuse/home")
        
        strings = strings.map { return bullet + $0 }
        
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = UIFont.preferredFont(forTextStyle: .body)
        attributes[.foregroundColor] = UIColor.white
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
        attributes[.paragraphStyle] = paragraphStyle

        let string = strings.joined(separator: "\n\n")
        lblsubDetail.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        guard let package = self.packageToPurchase else { return }
        
        self.lblsubPrice.text = "\(package.product.priceLocale.currencySymbol ?? "$")\(package.product.price)"
        
        self.lblsubType.text = subType
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSubscribePressed(_ sender: Any) {
        if let package = self.packageToPurchase {
            self.purchasePackage(package: package)
        }
    }
    
    func purchasePackage(package: Purchases.Package) {
        Purchases.shared.purchasePackage(package) { transaction, pruchaseinfo, error, Success in
            if let err = error as NSError? {
                self.managerSubError(err)
                return
            }
            if pruchaseinfo?.entitlements["Pro Access"]?.isActive ?? false {
                guard let expdate = pruchaseinfo?.expirationDate(forEntitlement: "Pro Access") else { return }
                let subeTime = expdate.timeIntervalSince1970
                if let userID = Auth.auth().currentUser?.uid {
                    let values = ["subscription": self.subType!, "sub_sdate": Date().timeIntervalSince1970, "sub_edate": Double(subeTime)] as [String : Any]
                    self.ref = Database.database().reference()
                    let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
                    progress.show(animated: true)
                    progress.mode = MBProgressHUDMode.indeterminate
                    progress.label.text = "Please wait..."
                    self.ref.child("users").child(userID).updateChildValues(values) { error, snap in
                        progress.hide(animated: true)
                        if error == nil {
                            //UserDefaults.standard.set(subsTime, forKey: "substime")
                            //UserDefaults.standard.set(id.description, forKey: "productid")
                            UserDefaults.standard.set(true, forKey: "subscribed")
                            self.restartApp()
                        }
                    }
                }
            }
        }
    }
    
    
    func managerSubError(_ error: NSError) {
    if let err = error as NSError? {
        // log error details
        print("Error: \(err.userInfo[Purchases.ReadableErrorCodeKey] ?? "")")
        print("Message: \(err.localizedDescription)")
        print("Underlying Error: \(err.userInfo[NSUnderlyingErrorKey] ?? "")")
        // handle specific errors
        switch Purchases.ErrorCode(_nsError: err).code {
        case .purchaseNotAllowedError:
            AlertControllerHelper.showAlert(message: "Purchases not allowed on this device.")
        case .purchaseInvalidError:
            AlertControllerHelper.showAlert(message: "Purchase invalid, check payment source.")
        case .purchaseCancelledError:
            AlertControllerHelper.showAlert(message: "Purchase canceled.")
        default:
            break
        }
    }
    }
    
    
    fileprivate func checkSubStatus(_ pruchaseinfo: Purchases.PurchaserInfo?) {
        if pruchaseinfo?.entitlements["Pro Access"]?.isActive ?? false {
            guard let expdate = pruchaseinfo?.expirationDate(forEntitlement: "Pro Access") else { return }
            //let subsTime = Date().timeIntervalSince1970
            let subeTime = expdate.timeIntervalSince1970
            if let userID = Auth.auth().currentUser?.uid {
                print(Double(subeTime))
                self.ref.child("users").child(userID).updateChildValues(["sub_edate": Double(subeTime)])
            }
            UserDefaults.standard.set(subeTime, forKey: "subetime")
            AlertControllerHelper.showAlert(message: "Congrats! Your purchase is successful")
            Subscriptions.instance.checkSubStatus()
            //UserDefaults.standard.set(true, forKey: "subscribed")
            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    
//      func purchaseSubProduct(product: SKProduct)  {
//          //KBForexProducts.store.restorePurchases()
//          KBForexProducts.store.buyProduct(product) { [weak self] success, productId in
//              guard let self = self else { return }
//              guard success else {
//                  DispatchQueue.main.async {
//                      let alertController = UIAlertController(title: "Failed to purchase product",
//                                                              message: "Check logs for details",
//                                                              preferredStyle: .alert)
//                      alertController.addAction(UIAlertAction(title: "OK", style: .default))
//                      self.present(alertController, animated: true, completion: nil)
//                  }
//                  return
//              }
//              if let id = productId {
//                  switch id.description {
//                  case KBForexProducts.basicMonthPlan:
//                      self.purchasedType = "Standard"
//                      break
//                  case KBForexProducts.superMonthPlan:
//                      self.purchasedType = "Premium"
//                    break
//                  case KBForexProducts.basicWeekly:
//                    self.purchasedType = "Basic"
//                    break
//                  case KBForexProducts.basicMonthPlan:
//                    self.purchasedType = "Essential"
//                    break
//                  default:
//                    break
//                }
//                let subsTime = Date().timeIntervalSince1970
//                let values = ["subscription": self.purchasedType, "sub_sdate": subsTime, "sub_edate": 0.0] as [String : Any]
//                if let userid = Auth.auth().currentUser?.uid {
//                    self.ref = Database.database().reference()
//                    let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
//                    progress.show(animated: true)
//                    progress.mode = MBProgressHUDMode.indeterminate
//                    progress.label.text = "Please wait..."
//                    //self.ref.child("users_test").child(userid).updateChildValues(values) { (error, snap) in
//                        self.ref.child("users").child(userid).updateChildValues(values) { (error, snap) in
//                        progress.hide(animated: true)
//                        if error == nil {
//                            UserDefaults.standard.set(subsTime, forKey: "substime")
//                            UserDefaults.standard.set(id.description, forKey: "productid")
//                            UserDefaults.standard.set(true, forKey: "subscribed")
//                            self.moveToViewController(with: "tabController")
//                        }
//                    }
//                }
//                self.verifyScript(identifier: id.description) { (success, expDate) in
//                    if !success { return }
//                    guard let expdate = expDate else { return }
//                    //let subsTime = Date().timeIntervalSince1970
//                    let subeTime = expdate.timeIntervalSince1970
//                    if let userID = Auth.auth().currentUser?.uid {
//                        print(Double(subeTime))
//                        self.ref.child("users").child(userID).updateChildValues(["sub_edate": Double(subeTime)])
//                    }
//
//                    UserDefaults.standard.set(subeTime, forKey: "subetime")
//                    print(Date(timeIntervalSince1970: subeTime))
//                    print(self.getDate(doubleDate: subeTime))
//                    print(self.getTimeFromDoubleDate(doubleDate: subeTime))
//
//                }
//            }
//          }
//      }
    
//    func verifyReceipt(productID: String) {
//           self.verifyScript(identifier: productID) { (success, expDate) in
//               if !success { return }
//               guard let expdate = expDate else { return }
//               let subsTime = Date().timeIntervalSince1970
//               let subeTime = expdate.timeIntervalSince1970
//               print(Date(timeIntervalSince1970: subeTime))
//               print(self.getDate(doubleDate: subeTime))
//               print(self.getTimeFromDoubleDate(doubleDate: subeTime))
//               let values = ["subscription": self.purchasedType, "sub_sdate": subsTime, "sub_edate": subeTime] as [String : Any]
//               if let userid = Auth.auth().currentUser?.uid {
//                   self.ref = Database.database().reference()
//                 //self.ref.child("users_test").child(userid).updateChildValues(values) { (error, snap) in
//                self.ref.child("users").child(userid).updateChildValues(values) { (error, snap) in
//                       if error == nil {
//                           UserDefaults.standard.set(subsTime, forKey: "substime")
//                           UserDefaults.standard.set(subeTime, forKey: "subetime")
//                           UserDefaults.standard.set(productID, forKey: "productid")
//                           UserDefaults.standard.set(true, forKey: "subscribed")
//                           self.moveToViewController(with: "tabController")
//                       }
//                   }
//               }
//           }
//       }
}
