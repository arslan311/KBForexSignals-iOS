//
//  AppDelegate.swift
//  Forex Trade Updates
//  Created by Arslan Khalid on 10/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.


import UIKit
import CoreData
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import FirebaseFirestore
import FirebaseMessaging
import Purchases
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var gcmSenderID = ""
    var isAppinBackground: Bool = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
//            let dictRoot = NSDictionary(contentsOfFile: path)
//            if let dict = dictRoot {
//                if let gcmSenderId = dict["GCM_SENDER_ID"] as? String {
//                    self.gcmSenderID = gcmSenderId
//                }
//            }
//        }
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_RkGNjJzAyJfNqlIeAamViVwXOVr")
        Subscriptions.instance.checkSubStatus()
        //GADMobileAds.sharedInstance().start(completionHandler: nil)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        registerForPushNotifications()
        UIApplication.shared.registerForRemoteNotifications()
        IQKeyboardManager.shared.enable = true
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = token {
                print("Remote instance ID token: \(result)")
                let token  = "Remote InstanceID token: \(result)"
                if let tokenSaved = UserDefaults.standard.string(forKey: "token") {
                    if tokenSaved == result {
                        print(token as Any)
                    } else {
                        UserDefaults.standard.set(result, forKey: "token")
                    }
                } else {
                    UserDefaults.standard.set(result, forKey: "token")
                }
            }
        }
        return true
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //SKPaymentQueue.default().restoreCompletedTransactions()
        print("Hello")
        UIApplication.shared.applicationIconBadgeNumber = 0
        isAppinBackground = false
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        isAppinBackground = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("do")
        isAppinBackground = true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Forex_Trade_Updates")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}



@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        UserDefaults.standard.set(deviceToken, forKey: "token")
        print("token: \(deviceToken)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("notif Did Received")
        Actions.instance.checkSubscriptions()
        let userInfo = response.notification.request.content.userInfo
        if let notificationdetails = userInfo["aps"] as? NSDictionary {
            let details = notificationdetails["alert"] as! Dictionary<String, Any>
            let title = details["title"] as? String ?? ""
            let body = details["body"] as? String ?? ""
            print("\(title), \(body)")
        }
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        if response.notification.request.identifier == "Trading Alert" {
            print("This is Trading Notification")
        }
        completionHandler()
    }
    
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("hello")
        
        
        completionHandler([.alert, .sound, .badge])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        if let value = userInfo["title"] as? String {
//           print(value) // output: "some-value"
//        }
        Actions.instance.checkSubscriptions()
        completionHandler(.newData)
    }
    
}


extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken!)")
        
        let dataDict:[String: String] = ["token": fcmToken!]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        let fcmTokenUser = fcmToken
        //print(fcmTokenUser)
        
        UserDefaults.standard.set(fcmTokenUser, forKey: "token")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
    }
}


extension AppDelegate: PurchasesDelegate {
    
    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
        
    }
}
