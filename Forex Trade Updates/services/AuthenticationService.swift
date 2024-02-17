//
//  AuthenticationService.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 13/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.

import Foundation
import SwiftyJSON
import Alamofire
import Firebase
import FirebaseDatabase
import FirebaseStorage


enum NotifSendingType: String {
    case subscribers
    case nonsubscribers
}

class AuthenticationService {
    
    var ref: DatabaseReference!
    static let instance = AuthenticationService()
    var allNotifsSent = [NotifSentModel]()
    let storage = Storage.storage().reference()
    
    func signupUser(parameters: Parameters, _ completion: @escaping COMPLETION_SIGNUP) {
        
        Auth.auth().createUser(withEmail: parameters["email"] as! String, password: parameters["password"] as! String) { (signupResult, error) in
            if error == nil && signupResult != nil {
                self.ref = Database.database().reference()
                if let currentuser = Auth.auth().currentUser {
                    let uid = currentuser.uid
                    self.ref.child("users").child(uid).setValue(parameters) { (error, usersNodeRef) in
                       //self.ref.child("users_test").child(uid).setValue(parameters) { (error, usersNodeRef) in
                        if error != nil {
                         print("Error Occured")
                            //let user = usersNodeRef.value(forKey: uid) as! [String: Any]
                            completion(true, error!.localizedDescription)
                        } else {
                            UserDefaults.standard.set(usersNodeRef.key, forKey: "userkey")
                            UserDefaults.standard.set(parameters["email"], forKey: "useremail")
                            UserDefaults.standard.set(parameters["name"], forKey: "username")
                            completion(false, "success")
                        }
                    }
                }
            } else {
                completion(true, error!.localizedDescription)
            }
        }
    }
    
    private var authUser : User? {
        return Auth.auth().currentUser
    }

    public func sendVerificationMail() {
        if self.authUser != nil && !self.authUser!.isEmailVerified {
            self.authUser!.sendEmailVerification(completion: { (error) in
                // Notify the user that the mail has sent or couldn't because of an error.
            })
        }
        else {
            // Either the user is not available, or the user is already verified.
        }
    }
    
    
    func loginUser(parameters: Parameters, _ completion: @escaping(_ success: Bool, _ message: String) -> ()) {
        Auth.auth().signIn(withEmail: parameters["email"] as! String, password: parameters["password"] as! String) { (user, error) in
                   if error == nil && user != nil {
                       self.ref = Database.database().reference()
                       if let newuser = Auth.auth().currentUser {
                           let userid = newuser.uid
//                        let userToken = UserDefaults.standard.string(forKey: "token")
//                       //self.ref.child("users").child(userid).child("token").setValue(userToken)
//                        self.ref.child("users_test").child(userid).child("token").setValue(userToken)
                        
                        self.ref.child("users").child(userid).observeSingleEvent(of: .value, with: { (userdataSnap) in
                           // self.ref.child("users_test").child(userid).observeSingleEvent(of: .value, with: { (userdataSnap) in
                               if userdataSnap.exists() {
                                   print(userdataSnap.value as Any)
                                   if let token = UserDefaults.standard.string(forKey: "token") {
                            self.ref.child("users").child(userid).updateChildValues(["token": token])
                                    //self.ref.child("users_test").child(userid).updateChildValues(["token": token])
                                   }
                                   if let userdata = userdataSnap.value as? NSDictionary {
                                       if let username = userdata["name"] as? String {
                                           UserDefaults.standard.set(username, forKey: "username")
                                       }
                                       if let useremail = userdata["email"] as? String {
                                           UserDefaults.standard.set(useremail, forKey: "useremail")
                                       }
                                       if let profile = userdata["profileURL"] as? String {
                                           UserDefaults.standard.set(profile, forKey: "profile")
                                       }
                                       
                                    if let subedate = userdata["sub_edate"] {
                                        UserDefaults.standard.set(subedate, forKey: "subedate")
                                    }
                                    if let subsdate = userdata["sub_sdate"] {
                                        UserDefaults.standard.set(subsdate, forKey: "subsdate")
                                    }
                                    
                                       if let letusertoken = UserDefaults.standard.string(forKey: "token") {
                                           print(letusertoken)
                                       }
                                       UserDefaults.standard.set(userid, forKey: "userkey")
                                   }
                                   print(user?.credential as Any)
                                   completion(false, "success")
                               }
                           })
                       }
                       else {
                           completion(true, error?.localizedDescription ?? "something went wrong")
                           return
                       }
                       
                   } else {
                       completion(true, error?.localizedDescription ?? "something went wrong")
                   }
               }
    }
    
    
    func adminSignin(parameters: Parameters, _ completion: @escaping(_ success: Bool, _ message: [String: Any]) -> ())  {
        ref = Database.database().reference()
        ref.child("admin").observeSingleEvent(of: .value) { (adminSnap) in
            if adminSnap.exists() {
                if let adminRecord = adminSnap.value as? NSDictionary {
                    let adminEmail = adminRecord["email"] as? String ?? ""
                    let adminPassword = adminRecord["password"] as? String ?? ""
                    let adminName = adminRecord["name"] as? String ?? ""
                        if adminEmail == parameters["email"] as! String && adminPassword == parameters["password"] as! String {
                            completion(true, ["message": "logged in successful", "name": adminName])
                        } else {
                            completion(false, ["message": "logged in failed", "name": adminName])
                    }
                    
                }
            } else {
                completion(false, ["message": "no admin found with given values", "name": ""])
            }
        }
        
    }
    
    
    func getAllUsersTokens(type: NotifSendingType, _ completion: @escaping (_ tokens: [String]) -> ()) {
        var usersTokens = [String]()
        ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value) { (usersSnap) in
        //ref.child("users_test").observeSingleEvent(of: .value) { (usersSnap) in
            usersTokens.removeAll()
            if usersSnap.exists() {
                for singleUserNode in usersSnap.value as! Dictionary<String, Any> {
                    if let user = singleUserNode.value as? NSDictionary {
                        let token = user["token"] as? String ?? ""
                        let subStatus = user["subscription"] as? String ?? ""
                        let subedate = user["sub_edate"] as? Double ?? 0.0
                        //, subedate > Date().timeIntervalSince1970
                        if !(subStatus == "not active" || subStatus == "N/A") && type == .subscribers {
                            usersTokens.append(token)
                        } else if (subStatus == "not active" || subStatus == "N/A") && type == .nonsubscribers {
                            usersTokens.append(token)
                        }
                    }
                }
                completion(usersTokens)
            }
        }
    }
    
    public func forgotPassword(email: String, completion: @escaping COMPLETION_SIGNUP) {
           Auth.auth().sendPasswordReset(withEmail: email) { error in
               if error == nil {
                   completion(false, "success")
               }
               else {
                   completion(true, error?.localizedDescription ?? "failed")
               }
           }
           
       }
    
    
    
    func addNewNotifs(params: Parameters, _ completion: @escaping (_ success: Bool) -> ()) {
        
        self.ref = Database.database().reference()
        ref.child("notifs_sent").childByAutoId().setValue(params, andPriority: params["date"]) { (error, ref) in
       // ref.child("notifs_test").childByAutoId().setValue(params, andPriority: params["date"]) { (error, ref) in
            error != nil ? completion(true) : completion(false)
        }
    }
    
    func getAllNotifsSent(_ completion: @escaping (_ success: Bool) -> ()) {
        AuthenticationService.instance.allNotifsSent.removeAll()
        self.ref = Database.database().reference()
        ref.child("notifs_sent").observeSingleEvent(of: .value) { (notificationsSnap) in
        //ref.child("notifs_test").observeSingleEvent(of: .value) { (notificationsSnap) in
            if notificationsSnap.exists() {
                if let allNotifs = notificationsSnap.value as? [String: Any] {
                    for notif in allNotifs {
                        if let notifDetails = notif.value as? [String: Any] {
                            let title = notifDetails["title"] as? String ?? ""
                            let body = notifDetails["body"] as? String ?? ""
                            let date = notifDetails["date"] as? Double ?? 0
                            let notifID = notif.key
                            let notification = NotifSentModel(id: notifID, title: title, body: body, datetime: date)
                            //let notification = NotifSentModel(notifTitle: title, notifBody: body, notifID: notifID, sentDateTime: date)
                            AuthenticationService.instance.allNotifsSent.append(notification)
                        }
                    }
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func updateProfileImage(image: UIImage?, completion: @escaping (Bool,String) -> Void) {
        if let image = image {
            guard let user = Auth.auth().currentUser else { return }
            let imageData = image.jpegData(compressionQuality: 0.5)
            let imageRef = storage.child("users/\(user.uid).jpg")
            imageRef.putData(imageData!, metadata: nil) { (metadata, error) in
                if let error = error {
                    completion(true, error.localizedDescription)
                    return
                }
                imageRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(true, error.localizedDescription)
                        return
                    }
                    if let url = url {
                        let urrl = url.absoluteString
                        
                        self.ref.child("users").child(user.uid).child("profileURL").setValue(urrl) { error, databaseReference in
                            if let error = error {
                                completion(true, error.localizedDescription)
                            } else {
                                UserDefaults.standard.set(urrl, forKey: "profile")
                                completion(false, urrl)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}
