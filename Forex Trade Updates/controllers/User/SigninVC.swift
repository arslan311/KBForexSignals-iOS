//
//  ViewController.swift
//  Forex Updates
//
//  Created by Arslan Khalid on 09/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MBProgressHUD
import FirebaseAuth


class SigninVC : UIViewController, SubExpiredProtocol {
    
    func subExpired() {
        //        AlertControllerHelper.showAlertWithTitleAndMessageCompletion(title: "Subscription Expired!", message: "Your subscription has expired, please login again and renew your subscriptions plan") { (success) in
        //            if success {
        //
        //            }
        //}
    }

@IBOutlet weak var topBgView: DesignableView!

@IBOutlet weak var txtEmailInput: UITextField!

@IBOutlet weak var txtPasswordInput: UITextField!

    @IBOutlet weak var userType: UISegmentedControl!
    
    var userTypetxt: String = ""
    
    @IBOutlet weak var btnSignin: DesignableButton!
    var userHome: UserDashVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userHome?.subExpiredDelegate = self
        userType.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        userType.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        topBgView.roundCorners(.bottomLeft, radius: topBgView.frame.height / 2)
        //getTimesAgo()
    }
    
    @IBAction func userTypeSelected(_ sender: UISegmentedControl) {
        
    }

    @IBAction func btnForgotPasswordPressed(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
              vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func btnLoginPressed(_ sender: Any) {
        guard let txtEmail = txtEmailInput.text, txtEmailInput.text != "" else { Actions.instance.showAlert(controller: self, alertTitle: "Empty Email", alertMessage: "Please enter your email"); return }
        guard let txtPassword = txtPasswordInput.text, txtEmailInput.text != "" else {
            Actions.instance.showAlert(controller: self, alertTitle: "Empty Password", alertMessage: "Please enter your password"); return }
        guard let userTypeSelected = userType.titleForSegment(at: userType.selectedSegmentIndex) else { return }
        
        let parameters: Parameters = ["email": txtEmail, "password": txtPassword]
        btnSignin.alpha = 0.6
        txtPasswordInput.resignFirstResponder()
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.show(animated: true)
        progress.mode = MBProgressHUDMode.indeterminate
        progress.label.text = "Please wait..."
        if userTypeSelected == "User" {
            btnSignin.isEnabled = false
            AuthenticationService.instance.loginUser(parameters: parameters) { (error, message) in
                progress.hide(animated: true)
                self.btnSignin.alpha = 1
                self.btnSignin.isEnabled = true
                if error == false {
                    Defaults.shared.isUser = true
                    Defaults.shared.isAdmin = false
                    Defaults.shared.userLoggedIn = true
                    //UserDefaults.standard.synchronize()
                    var identifier: String?
                    identifier = "tabController"
                    self.moveToViewController(with: identifier!)
                } else {
                    Actions.instance.showAlert(controller: UIViewController.topPresentedViewController, alertTitle: "Signin Failed!", alertMessage: message)
                }
            }
        } else if userTypeSelected == "Admin" {
            Auth.auth().signIn(withEmail: txtEmail, password: txtPassword) { (result, error) in
                if error == nil {
                    AuthenticationService.instance.adminSignin(parameters: parameters) { (success, loginResult) in
                        progress.hide(animated: true)
                        self.btnSignin.alpha = 1
                        self.txtPasswordInput.text = ""
                        self.txtEmailInput.text = ""
                        if success {
                            Defaults.shared.isAdmin = true
                            Defaults.shared.isUser = false
                            UserDefaults.standard.set(loginResult["name"], forKey: "username")
                            print(loginResult)
                            if let vc = self.storyboard?.instantiateViewController(identifier: "adminNav") {
                                vc.modalTransitionStyle = .crossDissolve
                                self.present(vc, animated: true, completion: nil)
                            }
                            Actions.instance.showAlert(controller: self, alertTitle: "Success", alertMessage: loginResult["message"] as! String)
                        } else {
                            self.btnSignin.shakebutton()
                            Actions.instance.showAlert(controller: self, alertTitle: "Failed", alertMessage: loginResult["message"] as! String)
                        }
                    }
                }
            }
        }
    }
    
    private func authenticateUser(_ userEmail: String, _ userPassword: String, _ userType: String) {
        
    }
}

