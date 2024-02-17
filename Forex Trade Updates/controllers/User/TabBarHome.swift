//
//  TabBarHome.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 12/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import UIKit

class TabBarHome: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBar.unselectedItemTintColor = .white
        self.delegate = self
    }
    
    fileprivate func openSubscriptions() {
        let controller = storyboard?.instantiateViewController(identifier: SubscriptionOptionsController.className) as! SubscriptionOptionsController
        //let navigation = UINavigationController(rootViewController: controller)
        self.present(controller, animated: true)
    }
    
    fileprivate func openChatSubscriptionPopup() {
        let controller = storyboard?.instantiateViewController(identifier: SubscriptionPopupChat.className) as! SubscriptionPopupChat
        //let navigation = UINavigationController(rootViewController: controller)
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController)!
//        if selectedIndex == 0 && !Defaults.shared.isSubActive {
//            openSubscriptions()
//            return false
//        }
        if selectedIndex == 2 {
            if Defaults.shared.isSubActive {
                let controller = storyboard?.instantiateViewController(identifier: TestChatVC.className) as! TestChatVC
                //let navigation = UINavigationController(rootViewController: controller)
                self.present(controller, animated: true)
                return false
            } else {
                openChatSubscriptionPopup()
                return false
            }
        }
        return true
    }
}

extension NSObject {
    class var className: String {
        return String(describing: self.self)
    }
}
