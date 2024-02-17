//
//  UserHomeVC.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 11/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import UIKit

class SubscriptionPopupChat: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func btnSubscribe(_ sender: Any) {
        if let subscriptionVC = storyboard?.instantiateViewController(withIdentifier: SubscriptionOptionsController.className) as? SubscriptionOptionsController {
            self.present(subscriptionVC, animated: true)
        }
    }
    
    
}
