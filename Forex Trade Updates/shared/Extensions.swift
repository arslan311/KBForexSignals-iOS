//
//  Extensions.swift
//  Face Gallery
//
//  Created by Muazam Khokher on 21/01/2020.
//  Copyright © 2020 Muazam Khokher. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import FirebaseAuth

extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


extension Notification.Name {
    static let removeBlurView = Notification.Name("removeBlurView")
    static let addBlurView = Notification.Name("addBludView")
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage1() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UITextField {
    func roundtxtEmail(radius: CGFloat)  {
        self.layer.cornerRadius = radius
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 2
        self.placeholder = "Enter your Email"
    }
    
    
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}


class Helper: NSObject
{
    class func addBlurView(_ inView : UIView) -> UIVisualEffectView
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        //always fill the view
        blurEffectView.frame = inView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.5

        return blurEffectView
    }
    
}

extension UIViewController {
    
    func getCellHeight() -> CGFloat {
        let deviceType = UIDevice.current.modelName
            switch deviceType {
                    case "iPhone10,3", "iPhone10,6":
                        print("iPhoneX")
                        return 150
                    case "iPhone11,2":
                        print("iPhone XS")
                        return 150
                    case "iPhone11,4":
                        print("iPhone XS Max")
                        return 150
                    case "iPhone11,6":
                        print("iPhone XS Max China")
                        return 150
                    case "iPhone11,8":
                        print("iPhone XR")
                        return 150
                    case "iPhone12,3":
                        print("iPhone 11 Pro")
                        return 150
                    case "iPhone12,5":
                        print("iPhone 11 Pro Max")
                        return 150
                    default:
                        return 145
            }

    }
    
    func logoutUser() {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        try? Auth.auth().signOut()
        if let vc = self.storyboard?.instantiateViewController(identifier: "SigninVC") as? SigninVC {
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
}


public extension UIDevice {

    enum `Type` {
        case iPad
        case iPhone_unknown
        case iPhone_5_5S_5C
        case iPhone_6_6S_7_8
        case iPhone_6_6S_7_8_PLUS
        case iPhone_X_Xs
        case iPhone_Xs_11_Pro_Max
        case iPhone_Xr_11
        case iPhone_11_Pro
    }

    var hasHomeButton: Bool {
        switch type {
        case .iPhone_X_Xs, .iPhone_Xr_11, .iPhone_Xs_11_Pro_Max, .iPhone_11_Pro:
            return false
        default:
            return true
        }
    }
    
    func heightForCell() -> CGFloat {
        switch type {
            case .iPhone_X_Xs, .iPhone_Xr_11, .iPhone_Xs_11_Pro_Max, .iPhone_11_Pro,.iPhone_6_6S_7_8_PLUS:
                return 150
            default:
                return 140
        }
    }

    var type: Type {
        if userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136: return .iPhone_5_5S_5C
            case 1334: return .iPhone_6_6S_7_8
            case 1920, 2208: return .iPhone_6_6S_7_8_PLUS
            case 2436: return .iPhone_X_Xs
            case 2688: return .iPhone_Xs_11_Pro_Max
            case 1792: return .iPhone_Xr_11
            case 2426: return .iPhone_11_Pro
            default: return .iPhone_unknown
        }
        }
        return .iPad
   }
}


extension UIView {
    func roundCorners(_ corners: Corners, radius: CGFloat) {
        var cornerMasks = [CACornerMask]()
        
        // Top left corner
        switch corners {
        case .all, .top, .topLeft, .allButTopRight, .allButBottomLeft, .allButBottomRight, .topLeftBottomRight:
            cornerMasks.append(CACornerMask(rawValue: UIRectCorner.topLeft.rawValue))
        default:
            break
        }
        
        // Top right corner
        switch corners {
        case .all, .top, .topRight, .allButTopLeft, .allButBottomLeft, .allButBottomRight, .topRightBottomLeft:
            cornerMasks.append(CACornerMask(rawValue: UIRectCorner.topRight.rawValue))
        default:
            break
        }
        
        // Bottom left corner
        switch corners {
        case .all, .bottom, .bottomLeft, .allButTopRight, .allButTopLeft, .allButBottomRight, .topRightBottomLeft:
            cornerMasks.append(CACornerMask(rawValue: UIRectCorner.bottomLeft.rawValue))
        default:
            break
        }
        
        // Bottom right corner
        switch corners {
        case .all, .bottom, .bottomRight, .allButTopRight, .allButTopLeft, .allButBottomLeft, .topLeftBottomRight:
            cornerMasks.append(CACornerMask(rawValue: UIRectCorner.bottomRight.rawValue))
        default:
            break
        }
        
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = CACornerMask(cornerMasks)
    }
    
    enum Corners {
        case all
        case top
        case bottom
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case allButTopLeft
        case allButTopRight
        case allButBottomLeft
        case allButBottomRight
        case left
        case right
        case topLeftBottomRight
        case topRightBottomLeft
    }
}

extension UIButton {
    
    func shakebutton()  {
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.05
        shake.autoreverses = true
        shake.repeatCount = 4
        let fromPoint = CGPoint(x: center.x - 10, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 10, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        layer.add(shake, forKey: nil)
        
    }
    func stopPlayerAnim()  {
        layer.removeAllAnimations()
    }
    
    
    
    func flashButton()  {
        let flash = CABasicAnimation(keyPath: "position")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 100
        layer.add(flash, forKey: nil)
        
    }
}


import UIKit

extension UIColor {
    
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    
    static var primary: UIColor {
        return UIColor(red: 1 / 255, green: 93 / 255, blue: 48 / 255, alpha: 1)
    }
    
    static var incomingMessage: UIColor {
        return UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    }
  
}

extension UIImageView {
    
    func setupImageWithKingFisher(with url: String = "") {
        //let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let myURL = URL(string: url)

        let processor = DownsamplingImageProcessor(size: self.bounds.size)
            |> RoundCornerImageProcessor(cornerRadius: 0)
        self.self.kf.indicatorType = .activity
        
        self.kf.setImage(
            with: myURL,
            placeholder: UIImage(named: "imageloading"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ], completionHandler:
            {
                result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    self.self.image = UIImage(named: "NoImageFound")
                    self.tintColor = .lightGray
                    print("Job failed: \(error.localizedDescription)")
                }
        })
    }
}
