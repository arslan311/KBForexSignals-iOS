//
//  LoadPDFVC.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 23/08/2023.
//  Copyright © 2023 Arslan. All rights reserved.
//

import UIKit
import WebKit

class LoadPDFVC: UIViewController {
    
    var fileName: String = ""
    var pagetitle: String = ""
    @IBOutlet weak var webview: WKWebView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pdf = Bundle.main.url(forResource: fileName, withExtension: "pdf", subdirectory: nil, localization: nil) {
            lblTitle.text = pagetitle
            let req = NSURLRequest(url: pdf)
            webview.contentMode = .scaleAspectFill
            webview.scrollView.bouncesZoom = true
            webview.load(req as URLRequest)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    
    @IBAction func btnBack(_ sender: Any) {
        if navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    


}
