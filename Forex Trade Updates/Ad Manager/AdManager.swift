////
////  AdManager.swift
////  Forex Trade Updates
////
////  Created by Arslan Khalid on 11/07/2023.
////  Copyright © 2023 Arslan. All rights reserved.
////
//
//import Foundation
//import GoogleMobileAds
//
//class AdManager: NSObject, GADInterstitialDelegate {
//
//    static let shared = AdManager()
//    private var interstitalad: GADInterstitial?
//    private var adDisplayCallback: (() -> Void)?
//    private var controller: UIViewController?
//
//    private override init() {
//        super.init()
//        initAd()
//    }
//
//    func initAd() {
//        interstitalad = GADInterstitial(adUnitID: Adomb.AD_INTERSTITIAL_TEST)
//        interstitalad?.delegate = self
//        loadInterstitialAd(completion: { })
//    }
//
//    func loadInterstitialAd(completion: @escaping () -> Void) {
//        adDisplayCallback = completion
//        let request = GADRequest()
//        interstitalad?.load(request)
//    }
//
//    func showInterstitialAd(from viewController: UIViewController) {
//        //self.controller = viewController
//        if interstitalad?.isReady == true {
//            //adDisplayCallback = completion
//            interstitalad?.present(fromRootViewController: viewController)
//        }
////           else {
////            // If the ad is not ready, load it and then display it
////            adDisplayCallback = completion
////            loadInterstitialAd()
////        }
//    }
//
//    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
////        if let controller = controller {
////            showInterstitialAd(from: controller) {
////                print("ad displayed from inner class")
////            }
////        }
//        adDisplayCallback?()
//        adDisplayCallback = nil
//    }
//
//    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
//        initAd()
//        // Invoke the callback when the ad is dismissed
//        //adDisplayCallback?()
//        //adDisplayCallback = nil
//    }
//
//}
