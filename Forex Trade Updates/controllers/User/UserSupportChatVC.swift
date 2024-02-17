//
//  UserSupportChatVC.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 11/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import UIKit
import MessageKit

class UserSupportChatVC: MessagesViewController, MessagesDisplayDelegate, MessagesLayoutDelegate, MessagesDataSource {
    func currentSender() -> SenderType {
        senderSelf
    }
    
//    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//
//        CGSize(width: 100, height: 100)
//    }
    
//    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//        CGSize(width: 100, height: 100)
//    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: 10, height: 10)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    override func viewWillLayoutSubviews() {
     if #available(iOS 11, *) {
            
            self.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.bounds.size)
            self.messagesCollectionView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.bounds.size)
            
            self.messagesCollectionView.contentInsetAdjustmentBehavior = .never
            let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
            let navBarHeight : CGFloat = navigationController?.navigationBar.frame.height ?? 0
            self.edgesForExtendedLayout = .all
            let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
            
            if UIDevice.current.orientation.isLandscape {
                self.messagesCollectionView.contentInset = UIEdgeInsets(top: (navBarHeight) + statusBarHeight,
                                                                        left: self.currentLeftSafeAreaInset,
                                                                        bottom: tabBarHeight + self.messageInputBar.frame.size.height,
                                                                        right: self.currentRightSafeAreaInset)
            }
            else {
                
                self.messagesCollectionView.contentInset = UIEdgeInsets(top: (navBarHeight) + statusBarHeight,
                                                                        left: 0.0,
                                                                        bottom:
                    
                   tabBarHeight + self.messageInputBar.frame.size.height,
                                                                        right: 0.0)
            }
        }
    }

    let senderSelf = sender(senderId: "arslan", displayName: "Arslan")
    let senderOther = sender(senderId: "other", displayName: "Nabeel")
    var currentLeftSafeAreaInset  : CGFloat = 0.0
    var currentRightSafeAreaInset : CGFloat = 0.0



    var messages = [message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDataSource = self
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let label = MessageLabel()
        label.textColor = .green
        self.title = "KB's Support Center"
        storeMessages()
    }
    
    func storeMessages() {
          messages.append(message(sender: senderSelf,
                      messageId: "1",
                      sentDate: Date.init(timeIntervalSinceNow: -343432),
                      kind: .text("text ever since the 1500s, when an unknown ")))
          messages.append(message(sender: senderOther,
          messageId: "2",
          sentDate: Date.init(timeIntervalSinceNow: -303432),
          kind: .text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.")))
          messages.append(message(sender: senderSelf,
          messageId: "3",
          sentDate: Date.init(timeIntervalSinceNow: -253432),
          kind: .text("text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.")))
          messages.append(message(sender: senderOther,
          messageId: "4",
          sentDate: Date.init(timeIntervalSinceNow: -153432),
          kind: .text("Hello...")))
      }
    
}
