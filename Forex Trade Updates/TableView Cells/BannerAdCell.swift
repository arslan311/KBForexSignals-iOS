//
//  BannerAdCell.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 10/07/2023.
//  Copyright © 2023 Arslan. All rights reserved.
//

import UIKit
import GoogleMobileAds

class BannerAdCell: UITableViewCell {

    
    
    @IBOutlet weak var addview: GADBannerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
