//
//  UserDashVC.swift
//  Forex Updates
//  Created by Arslan Khalid on 10/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.


import UIKit
import MBProgressHUD
import Firebase
import StoreKit
import Purchases


protocol SubExpiredProtocol {
    func subExpired()
}

class UserDashVC: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var notifTable: UITableView!
    let reuseIdentifier = "notifCell"
    var ref: DatabaseReference!
    @IBOutlet weak var lbluserName: UILabel!
    let pasteboard = UIPasteboard.general
    var alertController = UIAlertController()
    var products = [SKProduct]()
    var subExpiredDelegate: SubExpiredProtocol?
    // Banner Ad random variables
    var maxNumAds = UInt32(3);
    var numberOfAds: Int = 0
    var dataSource : [AnyObject] = [];
    var isSubActive: Bool = Defaults.shared.isSubActive
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notifTable.delegate = self
        notifTable.dataSource = self
        //numberOfAds = Int(arc4random_uniform(maxNumAds))
        notifTable.estimatedRowHeight = 200
        notifTable.rowHeight = UITableView.automaticDimension
        notifTable.contentInset.top = 30
        lbluserName.text = UserDefaults.standard.string(forKey: "username") ?? "Guest"
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        self.updateList()
//        AdManager.shared.loadInterstitialAd {
//           // DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//                if !UserDefaults.standard.bool(forKey: "firstsigndone") {
//                    AdManager.shared.showInterstitialAd(from: self)
//                }
//           // })
//        }
    }
    
    fileprivate func checkSub() {
        if !Defaults.shared.isSubActive {
            //if !UserDefaults.standard.bool(forKey: "firstsigndone") {
            //    DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: {
            //        self.addBlurView()
            //    })
            //} else {
                self.addBlurView()
           // }
        }
    }
    
    @objc fileprivate func openSubView(_ sender: UIButton) {
        if let subscriptionVC = storyboard?.instantiateViewController(withIdentifier: SubscriptionOptionsController.className) as? SubscriptionOptionsController {
            self.present(subscriptionVC, animated: true)
        }
    }
        
        fileprivate func addBlurView() {
        if let subscriptionVC = storyboard?.instantiateViewController(withIdentifier: SubscriptionPopup.className) as? SubscriptionPopup {
            //subscriptionVC.overlayVC = true
            addChild(subscriptionVC)
            view.addSubview(subscriptionVC.view)
            subscriptionVC.didMove(toParent: self)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        //checkSubscriptions()
    }
    
    func checkSubscriptions() {
        Purchases.shared.purchaserInfo { purchaseInfo, error in
            if error != nil {
                return
            }
            if purchaseInfo?.entitlements["Pro Access"]?.isActive ?? false {
                //self.updateList()
            } else {
                self.expireSubscription()
            }
        }
    }

fileprivate func expireSubscription() {
    AlertControllerHelper.showAlertWithTitleAndMessageCompletion(title: "Subscription Expired!", message: "Your subscription is not active, please update it!!!") { (success) in
        if success {
            //self.signoutUser()
            
        }
        return
    }
    //self.subExpiredDelegate?.subExpired()
    UserDefaults.standard.set(false, forKey: "subscribed")
    
//    if let userID = Auth.auth().currentUser?.uid {
//        self.ref = Database.database().reference()
//        let inactiveSub = ["subscription": "not active"]
//        self.ref.child("users").child(userID).updateChildValues(inactiveSub)
//        //self.ref.child("users_test").child(userID).updateChildValues(inactiveSub)
//    }
    
}
    
    override func viewDidAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: "firstsigndone") {
            UserDefaults.standard.set(true, forKey: "firstsigndone")
            Actions.instance.showAlert(controller: self, alertTitle: WELCOME_TITLE, alertMessage: WELCOME_MESSAGE)
        }
    }
    
    func updateList() {
        self.ref = Database.database().reference()
        let notifProgress = MBProgressHUD.showAdded(to: self.view, animated: true)
        notifProgress.mode = .indeterminate
        notifProgress.show(animated: true)
        notifProgress.label.text = "Loading Data..."
        //self.ref.child("notifs_test").observe(.value) { (updatedSnap) in
            self.ref.child("notifs_sent").observe(.value) { (updatedSnap) in
            notifProgress.hide(animated: true)
            if updatedSnap.exists() {
                AuthenticationService.instance.allNotifsSent.removeAll()
                self.dataSource.removeAll()
                if let allNotifs = updatedSnap.value as? [String: Any] {
                    for notif in allNotifs {
                        if let notifDetails = notif.value as? [String: Any] {
                            let title = notifDetails["title"] as? String ?? ""
                            let body = notifDetails["body"] as? String ?? ""
                            let date = notifDetails["date"] as? Double ?? 0
                            let notification = NotifSentModel(id: "", title: title, body: body, datetime: date)
                            //let notification = NotifSentModel(notifTitle: title, notifBody: body, sentDateTime: date)
                            AuthenticationService.instance.allNotifsSent.append(notification)
                            //self.dataSource.append(notification)
                        }
                    }
                    //self.maxNumAds = UInt32(arc4random_uniform(UInt32(Double(AuthenticationService.instance.allNotifsSent.count) / 6)))
                    
                    self.numberOfAds = Int(arc4random_uniform(self.maxNumAds))
                    
                    self.dataSource = AuthenticationService.instance.allNotifsSent.sorted(by: { $0.sentDateTime > $1.sentDateTime })
                    for _ in 0...self.numberOfAds {
                        
                        let index = Int(arc4random_uniform(UInt32(self.generateRandomNumber(length: self.dataSource.count)))); //find random index to insert at
                      let ad = AdModel() //generate whatever your data source object for Ads is
                        self.dataSource.insert(ad, at: index);
                    }
                    //AuthenticationService.instance.allNotifsSent = AuthenticationService.instance.allNotifsSent.sorted(by: { $0.sentDateTime > $1.sentDateTime })
                    self.checkSub()

                    self.notifTable.reloadData()
                }
            }
        }
    }
    
    func generateRandomNumber(length: Int) -> Int {
        
        let randomNumber = Int.random(in: 0...length)
        
        if randomNumber <= 20 {
            // Generate a random number between 1 and 20
            return Int.random(in: 0...15)
        } else {
            // Generate a random number between 21 and 100
            let probability = Double.random(in: 0..<1)
            if probability < 0.5 {
                return Int.random(in: 5...25)
            } else {
                return Int.random(in: 25...length)
            }
        }
    }
    
    @IBAction func btnLogoutPressed(_ sender: Any) {

    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("called")
    }
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        print("dsfsdf")
    }
    
    
}



extension UserDashVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //AuthenticationService.instance.allNotifsSent.count
        self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.dataSource[indexPath.row];
        
        if object is AdModel {
//            if let cell = notifTable.dequeueReusableCell(withIdentifier: BannerAdCell.className) as? BannerAdCell {
//                let randomNumber = Int.random(in: 0..<Adomb.AD_BANNERS_LIST.count)
//                cell.addview.adUnitID = Adomb.AD_BANNERS_LIST[randomNumber]
//                cell.addview.rootViewController = self
//                //cell.addview.delegate = self
//                cell.addview.adSize = kGADAdSizeLargeBanner
//                // Load the ad
//                cell.addview.load(GADRequest())
//
//                return cell
//            }
        } else {
            if let cell = notifTable.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? notifsCell {
                cell.setupCell(notif: self.dataSource[indexPath.row] as! NotifSentModel)
//                // Create a blur effect
//                let blurEffect = UIBlurEffect(style: .regular)
//                let blurView = UIVisualEffectView(effect: blurEffect)
//                blurView.frame = cell.contentView.bounds
//                blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//                blurView.alpha = 0.75
                
                // Add the blur view to the cell's content view
                //cell.contentView.addSubview(blurView)
                
                return cell
            }
        }
            return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isSubActive {
            popUpController(indexPath: indexPath)
        } else {
            openSubView(UIButton())
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        alertController.dismiss(animated: true, completion: nil)
    }
    
    
    
    func popUpController(indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        
        let margin:CGFloat = 8.0
        let rect = CGRect(x: margin, y: margin, width: alertController.view.bounds.size.width - margin * 4.0, height: 100.0)
        let customView = UITextView(frame: rect)
        customView.backgroundColor = UIColor.clear
        customView.font = UIFont(name: "Helvetica", size: 25)
        //customView.backgroundColor = UIColor.greenColor()
        customView.text = (self.dataSource[indexPath.row] as? NotifSentModel)?.notifBody
        customView.isEditable = false
        alertController.view.addSubview(customView)
//        let somethingAction = UIAlertAction(title: "Something", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in print("something")
//        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in self.notifTable.deselectRow(at: indexPath, animated: true); print("cancel")})
        //alertController.addAction(somethingAction)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let cell = notifTable.cellForRow(at: indexPath) {
                alertController.popoverPresentationController?.sourceView = cell
                alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.width, y: 25, width: 100, height: 50)
            }
        }
   
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion:{})

    }
    
    
    
    func showWelcomePopup() {
        let alert = UIAlertController(title: "Spring Element \("springNumber")",
            message: "Add spring properties",
            preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { (action: UIAlertAction!) -> Void in
        }

        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default) { (action: UIAlertAction!) -> Void in
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert,
            animated: true,
            completion: nil)
    }
    
    func checkSubscription() -> Bool {
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
            }
        }
        return true
    }
    
    
    
    func showAlert(indexpath: IndexPath)  {
        let textView = UITextView()
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.text = AuthenticationService.instance.allNotifsSent[indexpath.row].notifBody
        textView.font = UIFont(name: textView.font!.fontName, size: 45)
        let controller = UIViewController()
        textView.frame = controller.view.frame
        controller.view.addSubview(textView)
        
        alertController.setValue(controller, forKey: "contentViewController")
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.frame.height * 0.4)
        alertController.view.addConstraint(height)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height - 145, width: 170, height: 50))
    toastLabel.backgroundColor = #colorLiteral(red: 1, green: 0.3652611301, blue: 1, alpha: 1)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.numberOfLines = 0
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
}
    
}

 extension Date {
     func timeAgoDisplay() -> String {
        if #available(iOS 13.0, *) {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: self, relativeTo: Date())
        } else {
            return ""
        }
     }
 }

extension UIViewController {
    
    func getTimesAgo(doubleTime: Double) -> String {
        let date = Date(timeIntervalSince1970: doubleTime)
        return date.timeAgoDisplay()
    }
    
    func getDate(doubleDate: Double) -> String {
        let date = Date(timeIntervalSince1970: doubleDate)
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.string(from: date)
        //let interval = date.timeIntervalSince1970
        return dateString
    }
    
    func getTimeFromDoubleDate(doubleDate: Double) -> String {
        let date = Date(timeIntervalSince1970: doubleDate)
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss a"
        return dateFormatter.string(from: date)
    }
    
    
    func moveToViewController(with identifier: String) {
        if let vc = self.storyboard?.instantiateViewController(identifier: identifier) {
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func restartApp() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SplashScreen") as? SplashScreen {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.window?.rootViewController = vc
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
    
    func signoutUser() {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        moveToViewController(with: "SigninVC")
    }
}

extension UIViewController {
    
    class var topPresentedViewController : UIViewController {
        let sourceViewController = (UIApplication.shared.keyWindow?.rootViewController)!
        //Find the presented view controller
        var presentedController = sourceViewController
        if let navController = sourceViewController as? UINavigationController, let topViewController = navController.topViewController {
            presentedController = topViewController
        }
        while presentedController.presentedViewController != nil && presentedController.presentedViewController?.isBeingDismissed == false {
            presentedController = presentedController.presentedViewController!
            if let navController = presentedController as? UINavigationController, let topViewController = navController.topViewController {
                presentedController = topViewController
            }
        }
        return presentedController
    }
}

//extension UserDashVC: GADBannerViewDelegate {
//
//    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        //print(bannerView.adUnitID)
//    }
//}
