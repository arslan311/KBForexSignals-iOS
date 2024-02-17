//
//  AllUsersVC.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 24/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import UIKit

import Firebase
import MBProgressHUD

class Users: UITableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lbluserPhone: UILabel!
    
    @IBOutlet weak var lblUserEmail: UILabel!
    
    @IBOutlet weak var subscriptionStatus: UILabel!
    
    @IBOutlet weak var subscptionDate: UILabel!
}

struct UsersModel {
    let userName: String!
    let userEmail: String!
    let userPhone: String!
    let userSubscription: String!
    let userSubscriptionTime: Double!
    
}


class AllUsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var usersTableView: UITableView!
    var ref: DatabaseReference!
    @IBOutlet weak var tableview: UITableView!
    
    var usersList: [UsersModel] = [UsersModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.show(animated: true)
        progress.mode = MBProgressHUDMode.indeterminate
        progress.label.text = "Please wait..."
        ref = Database.database().reference()
        
        getAllUsers { (success) in
            progress.hide(animated: true)
            if success {
                self.tableview.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
              navigationController?.setNavigationBarHidden(true, animated: animated)
          }
          
          override func viewWillDisappear(_ animated: Bool) {
              navigationController?.setNavigationBarHidden(false, animated: animated)

          }
       
    
    func getAllUsers(_ completion: @escaping(_ success: Bool)->()) {
   
        ref.child("users").observeSingleEvent(of: .value) { (usersSnap) in
            if !usersSnap.exists() {
                completion(false)
            }
            if let users = usersSnap.value as? Dictionary<String, Any> {
                for user in users.values {
                    print(user)
                    if let user = user as? NSDictionary {
                        let userName = user["name"] as? String ?? "Unknown"
                        let userEmail = user["email"] as? String ?? "Unknown"
                        let userPhone = user["phone"] as? String ?? "Unknown"
                        let userSubDate = user["updated_at"] as? Double ?? 0.0
                        let userSubStatus = user["subscription"] as? String ?? "N/A"
                        let user = UsersModel(userName: userName, userEmail: userEmail, userPhone: userPhone, userSubscription: userSubStatus, userSubscriptionTime: userSubDate)
                        self.usersList.append(user)
                    }
                }
                completion(true)
            }
        }
    }
    
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        usersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = usersTableView.dequeueReusableCell(withIdentifier: "usersCell") as? Users {
            
            cell.userName.text = usersList[indexPath.row].userName
            cell.lbluserPhone.text = usersList[indexPath.row].userPhone
            cell.subscriptionStatus.text = usersList[indexPath.row].userSubscription
            cell.lblUserEmail.text = usersList[indexPath.row].userEmail
            cell.subscptionDate.text = getDate(doubleDate: usersList[indexPath.row].userSubscriptionTime)
                
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        150
    }
    
}
