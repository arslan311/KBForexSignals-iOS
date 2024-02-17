//
//  AlertControllerHelper.swift
//  WorldSportsBuddies
//
//  Created by DCMac01 on 11/1/17.
//  Copyright © 2017 Devclan. All rights reserved.
//

import UIKit

class AlertControllerHelper {
    
    class func showAlert(message:String) {
        let alert = UIAlertController(title: "KB's Forex Updates", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default ,handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        if let topVC = UIApplication.topViewController() {
            topVC.present(alert, animated: true, completion: nil)
        }
    }
    
//    class func showAlertToDismiss(fromViewController: UIViewController, message:String) {
//        let alert = UIAlertController(title: "kWBS", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .default ,handler: { action in
//            fromViewController.dismissSemiModalViewWithCompletion {
//                fromViewController.dismissDetail(fromViewController)
//            }
//        }))
//       // alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        if let topVC = UIApplication.topViewController() {
//            topVC.present(alert, animated: true, completion: nil)
//        }
//    }
    
    class func showAlertWithAction(fromViewController: UIViewController, title: String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default ,handler: { action in
           
        }))
        if let topVC = UIApplication.topViewController() {
            topVC.present(alert, animated: true, completion: nil)
        }
    }
    
    class func showAlertWithTitleAndMessageCompletion(title: String, message:String , buttonTitle: String = "OK", completion : @escaping (_ success : Bool) -> Void) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: buttonTitle, style: .default ,handler: { action in
               completion(true)
               alert.dismiss(animated: true, completion: nil)
               
           }))
           
           if let topVC = UIApplication.topViewController() {
               topVC.present(alert, animated: true, completion: nil)
           }
       }
    
    
}
