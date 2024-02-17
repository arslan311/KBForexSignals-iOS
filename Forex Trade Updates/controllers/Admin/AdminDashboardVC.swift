//
//  AdminDashboardVC.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 16/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.


import UIKit


class AdminDashboardVC: UIViewController {

    @IBOutlet weak var txtloginWelcomeName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtloginWelcomeName.text = UserDefaults.standard.string(forKey: "username")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)

    }
    
    @IBAction func btnAllSentNotifPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "AllNotif", sender: self)
        
    }
    @IBAction func btnAllUsersPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toUsers", sender: self)
    }
    
    @IBAction func btnOpenChatsPressed(_ sender: Any) {
        
    }
    
    @IBAction func btnSendNewNotification(_ sender: Any) {
        
        self.performSegue(withIdentifier: "NewNotif", sender: self)
        
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        var vc: NewNotifForm?
        if #available(iOS 13.0, *) {
            vc = self.storyboard?.instantiateViewController(identifier: "NewNotifForm")
        } else {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "NewNotifForm") as? NewNotifForm
        }
        if identifier == "NewNotif" {
            vc?.intentFrom = identifier
            vc?.titleScreen = "Signals Form"
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if identifier == "AllNotif" {
            vc?.intentFrom = identifier
            vc?.titleScreen = "Live Signals & Updates"
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if identifier == "toUsers" {
            let usersVC: AllUsersVC?
            if #available(iOS 13.0, *) {
                 usersVC = self.storyboard?.instantiateViewController(identifier: "AllUsersVC") as? AllUsersVC
            } else {
                // Fallback on earlier versions
                usersVC = self.storyboard?.instantiateViewController(withIdentifier: "AllUsersVC") as? AllUsersVC
            }
            self.navigationController?.pushViewController(usersVC!, animated: true)
        } else if identifier == "toChat" {
            let usersVC: TestChatVC?
            if #available(iOS 13.0, *) {
                 usersVC = self.storyboard?.instantiateViewController(identifier: "TestChatVC") as? TestChatVC
            } else {
                // Fallback on earlier versions
                usersVC = self.storyboard?.instantiateViewController(withIdentifier: "TestChatVC") as? TestChatVC
            }
            usersVC?.title = "Chat Center"
            self.navigationController?.pushViewController(usersVC!, animated: true)
        }
        
    }
    
    
    @IBAction func btnLogoutPressed(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isAdminLoggedIn")
            
            if #available(iOS 13.0, *) {
                                  if let vc = self.storyboard?.instantiateViewController(identifier: "SigninVC") as? SigninVC {
                                      vc.modalTransitionStyle = .crossDissolve
                                      self.present(vc, animated: true, completion: nil)
                                  }
                              } else {
                                  if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SigninVC") as? SigninVC {
                                      vc.modalTransitionStyle = .crossDissolve
                                      self.present(vc, animated: true, completion: nil)
                                  }
                              }
            
        }
    
    
    
}
