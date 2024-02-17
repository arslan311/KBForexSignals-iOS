//
//  ForgotPasswordVC.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 15/07/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    
    @IBOutlet weak var topBg: DesignableView!
    
    
    @IBOutlet weak var txtEmail: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

     topBg.roundCorners(.bottomLeft, radius: topBg.frame.height / 2)
    }
    
    @IBAction func btnResetPressed(_ sender: Any) {
        guard let email = txtEmail.text, txtEmail.text != "" else {
                Actions.instance.showAlert(controller: self, alertTitle: "Empty Email", alertMessage: "Please enter account email")
                return
            }
            
            AuthenticationService.instance.forgotPassword(email: email) { (error, errormsg) in
                if error == false {
                    Actions.instance.showAlert(controller: self, alertTitle: "Email Sent", alertMessage: "Please check your email address")
                } else {
                    Actions.instance.showAlert(controller: self, alertTitle: "Error Occured", alertMessage: errormsg)
                }
            }
    }
    
    
    
    @IBAction func btnBackPrsd(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
