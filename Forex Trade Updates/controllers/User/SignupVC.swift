//
//  SignupVC.swift
//  Forex Updates
//
//  Created by Arslan Khalid on 09/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MBProgressHUD

class SignupVC: UIViewController {

    @IBOutlet weak var topBgView: DesignableView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var txtSignupEmail: UITextField!
    @IBOutlet weak var txtSignupPhone: UITextField!
    @IBOutlet weak var txtSignupPassword: UITextField!
    @IBOutlet weak var txtConfirmPass: UITextField!
    @IBOutlet weak var btnSignup: DesignableButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        topBgView.roundCorners(.bottomLeft, radius: topBgView.frame.height / 2)
    }
    
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // Regular expression pattern to match international phone numbers
        let regexPattern = #"^\+[0-9]{1,4}-?[0-9]{6,}$"#
        
        let regex = try? NSRegularExpression(pattern: regexPattern)
        let range = NSRange(location: 0, length: phoneNumber.utf16.count)
        return regex?.firstMatch(in: phoneNumber, options: [], range: range) != nil
    }

    
    @IBAction func btnEye(_ sender: UIButton) {
        txtSignupPassword.isSecureTextEntry = !txtSignupPassword.isSecureTextEntry
        sender.setImage(txtSignupPassword.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    
    @IBAction func btnSignupPressed(_ sender: Any) {
        
        
        guard let username = userName.text else { return }
        guard let userphone = txtSignupPhone.text else { return }
        guard let useremail = txtSignupEmail.text else { return }
        guard let password = txtSignupPassword.text else { return }
//        guard let cpassword = txtConfirmPass.text else { return }
        
        if username.isEmpty { Actions.instance.showAlert(controller: self, alertTitle: "Empty User Name!", alertMessage: "Please enter a valid User Name")
            return
        }
        
        if useremail.isEmpty { Actions.instance.showAlert(controller: self, alertTitle: "Empty Email!", alertMessage: "Please enter a valid Email")
            return
        }
        
        if userphone.isEmpty || !isValidPhoneNumber(userphone) { Actions.instance.showAlert(controller: self, alertTitle: "Invalid Phone Number!", alertMessage: "Please enter a valid Phone Number")
            return
        }
        
        if password.isEmpty {
            Actions.instance.showAlert(controller: self, alertTitle: "Empty Password!", alertMessage: "Please enter a secure Password")
            return
        }
//        if cpassword.isEmpty {
//            Actions.instance.showAlert(controller: self, alertTitle: "Empty Confirm Password!", alertMessage: "Please Confirm Your Passwrd")
//            return
//        }
//        if !cpassword.elementsEqual(password) {
//            Actions.instance.showAlert(controller: self, alertTitle: "Password Confirm Failed!", alertMessage: "Password does not match")
//            return
//        }
        
        let usertoken = UserDefaults.standard.string(forKey: "token") ?? ""
        let currentDateTime = Date().timeIntervalSince1970 as Double
        let parameters: Parameters = ["name":  username, "email": useremail, "phone": userphone, "profileURL": "", "password": password, "token": usertoken , "updated_at": currentDateTime, "subscription": "N/A", "sub_sdate": 0.0, "sub_edate": 0.0]
        
        btnSignup.isEnabled = false
        btnSignup.alpha = 0.6
        txtSignupPassword.resignFirstResponder()
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.show(animated: true)
        progress.mode = MBProgressHUDMode.indeterminate
        progress.label.text = "Please wait..."
        
        AuthenticationService.instance.signupUser(parameters: parameters) { (error, message) in
            progress.hide(animated: true)
            self.btnSignup.isEnabled = true
            self.btnSignup.alpha = 1.0
            if error == true {
                Actions.instance.showAlert(controller: self, alertTitle: "Signup Failed!", alertMessage: message)
            } else {
                //AuthenticationService.instance.sendVerificationMail()
                self.txtSignupEmail.text = ""
                self.txtSignupPassword.text = ""
                //self.txtConfirmPass.text = ""
                self.txtSignupPhone.text = ""
                self.userName.text = ""
//                AlertControllerHelper.showAlertWithTitleAndMessageCompletion(title: "Signup success!", message: "Please verify your email and login to your account!") { success in
//                    self.dismiss(animated: true)
                var identifier: String?
                identifier = "tabController"
                self.moveToViewController(with: identifier!)
//                if let vc = self.storyboard?.instantiateViewController(withIdentifier: SubscriptionOptionsController.className) {
//
//                    vc.modalTransitionStyle = .crossDissolve
//                    self.present(vc, animated: true)
//                }
            }
        }
    }
}


extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
