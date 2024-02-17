//
//  SubscriptionOptionsController.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 05/07/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import UIKit
import SpriteKit
import StoreKit
import Firebase
import MBProgressHUD
import Purchases

class SubscriptionOptionsController: UIViewController {

    @IBOutlet weak var subOneBgView: UIView!
    @IBOutlet weak var subTwoBgView: UIView!
    @IBOutlet weak var subThreeBgView: UIView!
    @IBOutlet weak var subFourBgView: UIView!
    
    @IBOutlet weak var subFirstSideView: UIView!
    @IBOutlet weak var subSecondSideView: UIView!
    @IBOutlet weak var subThirdSideView: UIView!
    @IBOutlet weak var subFourthSideView: UIView!
    
    
    @IBOutlet weak var btnsubBasic: UIButton!
    @IBOutlet weak var btnsubStandard: UIButton!
    @IBOutlet weak var btnsubEssential: UIButton!
    @IBOutlet weak var btnSubPremium: UIButton!
    
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var lblPricePremium: UILabel!
    @IBOutlet weak var lblPriceEssensial: UILabel!
    @IBOutlet weak var lblPriceStandard: UILabel!
    @IBOutlet weak var lblPriceBasic: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    var overlayVC: Bool = false
    
    var products: [SKProduct] = []
    
    var productOneWeekLite: Purchases.Package?
    var productOneMonthLite: Purchases.Package?
    var productOneMonthPro: Purchases.Package?
    var productTwoMonthPro: Purchases.Package?

    
    fileprivate func loadSubscriptions() {
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.show(animated: true)
        progress.mode = MBProgressHUDMode.indeterminate
        progress.label.text = "Please wait..."
        Subscriptions.instance.loadPackages { success in
            progress.hide(animated: true)
            if !success {
                AlertControllerHelper.showAlert(message: "Could not load subscriptions")
                return
            }
            self.productOneWeekLite = Subscriptions.instance.packages.first
            self.productOneMonthLite = Subscriptions.instance.packages[1]
            self.productOneMonthPro = Subscriptions.instance.packages.filter({ $0.product.productIdentifier == KBForexProducts.superMonthPlan }).first
            self.productTwoMonthPro = Subscriptions.instance.packages.filter({ $0.product.productIdentifier == KBForexProducts.twoMonthPlan }).first
            
            //self.lblCurrency.text = self.productOneWeekLite?.product.priceLocale.currencySymbol
            if let sub_lite_week = self.productOneWeekLite {
                self.lblPriceBasic.text = "\(sub_lite_week.localizedPriceString)"
            }
            if let sub_lite_month = self.productOneMonthLite {
                self.lblPriceStandard.text = "\(sub_lite_month.localizedPriceString)"
            }
            if let sub_pro_month = self.productTwoMonthPro {
                self.lblPriceEssensial.text = "\(sub_pro_month.localizedPriceString)"
            }
            if let sub_pro_2month = self.productOneMonthPro {
                self.lblPricePremium.text = "\(sub_pro_2month.localizedPriceString)"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subFirstSideView.roundCorners(.allButTopRight, radius: 8)
        subSecondSideView.roundCorners(.allButTopRight, radius: 8)
        subThirdSideView.roundCorners(.allButTopRight, radius: 8)
        subFourthSideView.roundCorners(.allButTopRight, radius: 8)
        loadSubscriptions()
        btnBack.isHidden = overlayVC
    }
    
    @IBAction func btnBasicWeeklySub(_ sender: Any) {
        guard (productOneWeekLite != nil) else {
            print("Cannot purchase subscription because product is empty!")
            return
        }
        //let result = products.filter { $0.productIdentifier == KBForexProducts.basicWeekly }
        self.moveToSubscriptionScreen(subName: "Basic", product: self.productOneWeekLite)
    }
    
    @IBAction func btnMonthlySub(_ sender: Any) {
        guard (productOneMonthLite != nil) else {
                   print("Cannot purchase subscription because products is empty!")
                   return
               }
        //let result = products.filter { $0.productIdentifier == KBForexProducts.basicMonthPlan }
        self.moveToSubscriptionScreen(subName: "Standard", product: self.productOneMonthLite)
    }
    
    @IBAction func btnBackArrow(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            //moveToViewController(with: "SigninVC")
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func btnTwoMonthsSub(_ sender: UIButton) {
        guard (productTwoMonthPro != nil) else {
                 print("Cannot purchase subscription because products is empty!")
                 return
             }
        //let result = products.filter { $0.productIdentifier == KBForexProducts.twoMonthPlan }
        self.moveToSubscriptionScreen(subName: "Essential", product: self.productTwoMonthPro)
    }
    
    
    @IBAction func btnSuperMonthlySub(_ sender: UIButton) {
        guard (productOneMonthPro != nil) else {
                 print("Cannot purchase subscription because products is empty!")
                 return
             }
        //let result = products.filter { $0.productIdentifier == KBForexProducts.superMonthPlan }
        self.moveToSubscriptionScreen(subName: "Premium", product: self.productOneMonthPro)
    }
    
    
    func moveToSubscriptionScreen(subName: String, product: Purchases.Package?) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "SubscriptionsDetailVC") as? SubscriptionsDetailVC {
            vc.subType = subName
            vc.packageToPurchase = product
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func btnRestorePressed(_ sender: UIButton) {
        
        sender.isEnabled = false
        sender.alpha = 0.5
        Purchases.shared.restoreTransactions { info, error in
            sender.isEnabled = true
            sender.alpha = 1
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            if info?.entitlements["Pro"]?.isActive == true {
                Subscriptions.instance.sub_status = true
                Actions.instance.showAlert(controller: self, alertTitle: "Success", alertMessage: "Subscription restored 👍")
                self.dismiss(animated: true, completion: nil)
            } else {
                Actions.instance.showAlert(controller: self, alertTitle: "Failed", alertMessage: "We couldn't find any active subscriptions to restore. Make sure you're signed in with the correct Apple account and try again.")
            }
            
        }
        
        
//        SwiftyStoreKit.restorePurchases(atomically: true) { results in
//            if results.restoreFailedPurchases.count > 0 {
//                print("Restore Failed: \(results.restoreFailedPurchases)")
//                Actions.instance.showAlert(controller: self, alertTitle: "Failed!", alertMessage: "Could no restore product")
//            }
//            else if results.restoredPurchases.count > 0 {
//                if let productID = results.restoredPurchases.first?.productId {
//                    UserDefaults.standard.set(productID, forKey: "productid")
//                    //self.verifyReceipt(productID: productID)
//                }
//                //print("Restore Success: \(results.restoredPurchases.first?.productId)")
//                self.moveToViewController(with: "tabController")
//            }
//            else {
//                print("Nothing to Restore")
//            }
//        }
    }
}

extension UIViewController {
    func storestringUserDefVal(val: String, forKey key: String) {
        UserDefaults.standard.set(val, forKey: key)
    }
    
    func getstringUserDefVal(key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    func verifyScript(identifier: String, _ response: @escaping(_ success: Bool, _ expDate: Date?) -> ()) {
//        //var edate: Date?
//        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: SHARED_SECRET)
//        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//            switch result {
//            case .success(let receipt):
//                let productId = identifier
//                // Verify the purchase of a Subscription
//                let purchaseResult = SwiftyStoreKit.verifySubscription(
//                    ofType: .autoRenewable, // or .nonRenewing (see below)
//                    productId: productId,
//                    inReceipt: receipt)
//                switch purchaseResult {
//                case .purchased(let expiryDate, let items):
//                    //edate = expiryDate
//                    print(items)
//                    print("\(productId) is valid until \(expiryDate)\n")
//                    print("\(productId) is valid until \(expiryDate)\n")
//                    response(true, expiryDate)
//                case .expired(let expiryDate, let items):
//                    //edate = expiryDate
//                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
//                    response(false, expiryDate)
//                case .notPurchased:
//                    //edate = nil
//                    print("The user has never purchased \(productId)")
//                    response(false, nil)
//                }
//            case .error(let error):
//                print("Receipt verification failed: \(error)")
//            }
//        }
    }
}
