//
//  ProfileVC.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 05/07/2023.
//  Copyright © 2023 Arslan. All rights reserved.
//

import UIKit
import StoreKit
import GoogleMobileAds
import FirebaseAuth
import FirebaseDatabase


class ProfileVC: UIViewController {
    
    @IBOutlet weak var imgviewprofile: UIImageView!
    @IBOutlet weak var lblname: UILabel!
    
    @IBOutlet weak var lblemail: UILabel!
    
    @IBOutlet weak var viewebook: UIView!
    
    
    var imagePicker = UIImagePickerController()
    
   // @IBOutlet weak var bannerview: GADBannerView!
    
    fileprivate func setImage() {
        if let profile = UserDefaults.standard.string(forKey: "profile") {
            imgviewprofile.setupImageWithKingFisher(with: profile)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblname.text = UserDefaults.standard.string(forKey: "username") ?? "Guest"
        lblemail.text = UserDefaults.standard.string(forKey: "useremail") ?? "N/A"
        getUserData()
        //setImage()
        // In this case, we instantiate the banner with desired ad size.
//        bannerview.adUnitID = Adomb.AD_BANNER_REAL
//        bannerview.adSize = kGADAdSizeBanner
//        bannerview.rootViewController = self
//        bannerview.load(GADRequest())

    }
    
    
    fileprivate func getUserData() {
        if let user = Auth.auth().currentUser {
            Database.database().reference().child("users").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
                if let dictionary = snapshot.value as? [String: Any] {
                    if let value = dictionary["subscription"] as? String, value != "not active", value != "N/A"  {
                        self.viewebook.isHidden = false
                    }
                }
            })
        }
    }
    
    @IBAction func btnCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        }
    }
    
    
    @IBAction func btneBook(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: LoadPDFVC.className) as? LoadPDFVC {
            vc.fileName = "KB's Forex E-Book-Master Your Mindset"
            vc.pagetitle = "eBook"
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func btnRateApp(_ sender: Any) {
        rateApp()
    }
    
    @IBAction func btnPrivacy(_ sender: Any) {
        open(link: "https://sites.google.com/view/kbs-forexsignals-privacypolicy/home")
    }
    
    @IBAction func btnTerms(_ sender: Any) {
        open(link: "https://sites.google.com/view/kbs-forexsignals-termsofuse/home")
    }
    
    @IBAction func btnLogout(_ sender: Any) {
//        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
//
//        if let vc = self.storyboard?.instantiateViewController(identifier: "SigninVC") as? SigninVC {
//            vc.modalTransitionStyle = .crossDissolve
//            self.present(vc, animated: true, completion: nil)
//        }
        self.logoutUser()
    }
    
    fileprivate func open(link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
    
    
    fileprivate func updateProfile(image: UIImage) {
        AuthenticationService.instance.updateProfileImage(image: image) { error, url in
            if error {
                Actions.instance.showAlert(controller: self, alertTitle: "Error", alertMessage: url)
            }
            self.setImage()
        }
    }
    
    func rateApp() {
        SKStoreReviewController.requestReview()
    }
}

extension ProfileVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //imgviewprofile.image = image
            updateProfile(image: image)
            //save image
            //display image
        }
        self.dismiss(animated: true, completion: nil)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
