//
//  TestChatVC.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 11/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import FirebaseFirestore
import InputBarAccessoryView
import UserNotifications
import GoogleMobileAds
import SafariServices

struct sender: SenderType {
    var senderId: String
    var displayName: String
}

enum MesseageSenderType: String {
    case admin = "admin"
    case common = "common"
}


struct message: MessageType {

    var sender: SenderType

    var messageId: String

    var sentDate: Date

    var kind: MessageKind
}


extension MessageCollectionViewCell {
    @objc func quote(_ sender: Any?) {
        // Get the collectionView
        if let collectionView = self.superview as? UICollectionView {
            // Get indexPath
            if let indexPath = collectionView.indexPath(for: self) {
                // Trigger action
                
                collectionView.delegate?.collectionView?(collectionView, performAction: #selector(MessageCollectionViewCell.quote(_:)), forItemAt: indexPath, withSender: sender)
            }
        }
    }
}

class TestChatVC: MessagesViewController, MessageCellDelegate {
  
    
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
            if action == NSSelectorFromString("delete:") {
                return true
            } else {
                return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
            }
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

        if action == NSSelectorFromString("quote:") {
            // 1.) Remove from datasource
            // insert your code here
            self.isdeletingMode = true
            self.db.collection(chatNode).document(self.messages[indexPath.section].docId).delete { error in
                if error == nil {
                    // 2.) Delete sections
//                    print(indexPath.section)
//                    self.messages.count
//                    self.messages.remove(at: indexPath.section)
//                    collectionView.deleteSections([indexPath.section])
                    let newindexpath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
                    self.messagesCollectionView.scrollToItem(at: newindexpath, at: .bottom, animated: true)
                    self.isdeletingMode = true
                }
            }
        } else {
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }

    }
    
    
    // MARK: - GADInterstitialDelegate
    //let senderSelf = sender(senderId: "arslan", displayName: "Arslan")
    //let senderOther = sender(senderId: "other", displayName: "Nabeel")
    //var messages = [message]()
    //private var messages: [Message] = []
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lblTitle: UILabel!
   
    private var messageListener: ListenerRegistration?
    private let db = Firestore.firestore()
    private var realtimeDB: DatabaseReference!
    private var reference: CollectionReference?
    let refreshControl = UIRefreshControl()
    var currentUser: User = Auth.auth().currentUser!
    private var docReference: DocumentReference?
    var messages: [Message] = []
    //I've fetched the profile of user 2 in previous class from which //I'm navigating to chat view. So make sure you have the following //three variables information when you are on this class.
    var user2Name: String?
    var user2ImgUrl: String?
    var user2UID: String?
    var chatNode: String = "MainChat"
    var isdeletingMode: Bool = false
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var headerview: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1254901961, green: 0.2235294118, blue: 0.4862745098, alpha: 1)
        return view
    }()
    
    var titlelbl: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.text = "Chats"
        return label
    }()
    
    var backArrow: UIButton = {
       var button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(btnBack(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK :- Ad interstitial
    //var interstitial: GADInterstitial!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadChat()
//        AdManager.shared.loadInterstitialAd {
//            AdManager.shared.showInterstitialAd(from: self)
        //        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Traderoom"
        configureMessageInputBar()
        configureMessagesCollectionView()
        if UserDefaults.standard.bool(forKey: "isAdminLoggedIn") {
            let customMenuItem = UIMenuItem(title: "Delete", action: #selector(MessageCollectionViewCell.quote(_:)))
            UIMenuController.shared.menuItems = [customMenuItem]
        }
        
//        interstitial = GADInterstitial(adUnitID: Adomb.AD_INTERSTITIAL_TEST)
//        interstitial.delegate = self
//        interstitial.load(GADRequest())
//        AdManager.shared.showInterstitialAd(from: self) { }
//        AdManager.shared.loadInterstitialAd {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//                AdManager.shared.showInterstitialAd(from: self)
//            })
//        }
    }
    
    
    
    @objc fileprivate func btnBack(_ sender: UIButton) {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    
    fileprivate func headerView() {
        self.view.addSubview(headerview)
        headerview.addSubview(titlelbl)
        //headerview.addSubview(buttonBack)
        headerview.addSubview(backArrow)

        headerview.translatesAutoresizingMaskIntoConstraints = false
        headerview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        headerview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        headerview.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        //headerview.heightAnchor.constraint(equalToConstant: 100).isActive = true

        // Title Label
        titlelbl.translatesAutoresizingMaskIntoConstraints = false
        
        titlelbl.bottomAnchor.constraint(equalTo: headerview.bottomAnchor, constant: -16).isActive = true
        titlelbl.centerXAnchor.constraint(equalTo: headerview.centerXAnchor, constant: 0).isActive = true
        titlelbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        // Button Back
//        buttonBack.translatesAutoresizingMaskIntoConstraints = false
//        buttonBack.leadingAnchor.constraint(equalTo: headerview.leadingAnchor, constant: 12).isActive = true
//        buttonBack.widthAnchor.constraint(equalToConstant: 24).isActive = true
//        buttonBack.heightAnchor.constraint(equalToConstant: 24).isActive = true
//        buttonBack.centerYAnchor.constraint(equalTo: titlelbl.centerYAnchor, constant: 0).isActive = true
        
        backArrow.translatesAutoresizingMaskIntoConstraints = false
        backArrow.widthAnchor.constraint(equalToConstant: 24).isActive = true
        backArrow.heightAnchor.constraint(equalToConstant: 24).isActive = true
        backArrow.leadingAnchor.constraint(equalTo: headerview.leadingAnchor, constant: 12).isActive = true
        backArrow.centerYAnchor.constraint(equalTo: titlelbl.centerYAnchor, constant: 0).isActive = true
    }
    
    func configureMessagesCollectionView()  {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        
        headerView()
        
        refreshControl.addTarget(self, action: #selector(loadChat), for: .valueChanged)
    }
    
    
    func configureMessageInputBar() {
          messageInputBar.inputTextView.tintColor = .primary
            messageInputBar.sendButton.setTitleColor(
                UIColor.primaryColor.withAlphaComponent(0.3),
                for: .highlighted)
            messageInputBar.delegate = self
      }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    deinit {
        messageListener?.remove()
    }
    @objc func loadChat() {
        //messageListener = self.db.collection("MainChat_test").order(by: "created", descending: false).addSnapshotListener(includeMetadataChanges: true) { (chatQuerySnap, error) in
        messageListener = self.db.collection(chatNode).order(by: "created", descending: false).addSnapshotListener(includeMetadataChanges: true) { (chatQuerySnap, error) in
              
        if let error = error {
                print("Error: \(error)")
                return
            } else {
                guard let queryCount = chatQuerySnap?.documents.count else {
                    return
                }
                if queryCount == 0 {
                    return
                } else if queryCount >= 1 {
                    //self.sendLocalNotif()
                    self.messages.removeAll()
                    for message in chatQuerySnap!.documents {
                        let messagenew = Message(docId: message.documentID, dictionary: message.data())
                        self.messages.append(messagenew!)
                        //print(message?.sentDate)
                        print("Data: \(messagenew?.content ?? "No message found")")
                    }
                    self.messagesCollectionView.reloadData()
                    if !self.isdeletingMode {
                        self.messagesCollectionView.scrollToLastItem()
                    }
                    //self.messagesCollectionView.scrollToItem(at: <#T##IndexPath#>, at: <#T##UICollectionView.ScrollPosition#>, animated: <#T##Bool#>)
                    return
                }
            }
        }
    }
//    func sendLocalNotif() {
//        let notifContent = UNMutableNotificationContent()
//        notifContent.title = "Traderoom"
//        notifContent.body = "You have a new message in Traderoom"
//        notifContent.sound = UNNotificationSound.default
//        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 4, repeats: false)
//        let notifRequest = UNNotificationRequest(identifier: "Trading Alert", content: notifContent, trigger: trigger)
//        UNUserNotificationCenter.current().add(notifRequest, withCompletionHandler: nil)
//    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
         CGSize(width: 10, height: 10)
     }
    
//    func storeMessages() {
//
//        messages.append(message(sender: senderSelf,
//                    messageId: "1",
//                    sentDate: Date.init(timeIntervalSinceNow: -343432),
//                    kind: .text("Hello KB, Arslan Here...")))
//        messages.append(message(sender: senderOther,
//        messageId: "2",
//        sentDate: Date.init(timeIntervalSinceNow: -303432),
//        kind: .text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")))
//        messages.append(message(sender: senderSelf,
//        messageId: "3",
//        sentDate: Date.init(timeIntervalSinceNow: -253432),
//        kind: .text(" Excepteur sint occaecat cupidatat non proident, officia deserunt mollit anim id est laborum.")))
//
//        messages.append(message(sender: senderOther,
//        messageId: "4",
//        sentDate: Date.init(timeIntervalSinceNow: -153432),
//        kind: .text("officia deserunt mollit anim id est laborum.")))
//        messages.append(message(sender: senderSelf,
//        messageId: "4",
//        sentDate: Date.init(timeIntervalSinceNow: -153432),
//        kind: .text("officia deserunt")))
//        messages.append(message(sender: senderSelf,
//        messageId: "5",
//        sentDate: Date.init(timeIntervalSinceNow: -153432),
//        kind: .text("Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequa")))
//        messages.append(message(sender: senderOther,
//             messageId: "6",
//             sentDate: Date.init(timeIntervalSinceNow: -153432),
//             kind: .text("Ok Cool")))
//    }
    
    private func insertNewMessage(_ message: Message) {
        
        
        //add the message to the messages array and reload it
        messages.append(message)
        //messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    private func save(_ message: Message) {
        //Preparing the data as per our firestore collection
        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": message.senderID,
            "senderName": message.senderName,
            "senderType": message.senderType
        ]
        
        //Writing it to the thread using the saved document reference we saved in load chat function
        
        
        //self.db.collection("MainChat_test").addDocument(data: data, completion: { (error) in
        self.db.collection(chatNode).addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
            //self.realtimeDB = Database.database().reference()
            //self.realtimeDB.child("message").childByAutoId().setValue(["msg": data["content"]])
            if self.chatNode != "MainChat_test" {
                AuthenticationService.instance.getAllUsersTokens(type: .subscribers) { (usersToken) in
                    for token in usersToken {
                        self.sendPushNotifWithoutSound(userId: token, notifTitle: "Traderoom", notifBody: "There's a new chat message")
                    }
                }
            }
            self.messagesCollectionView.scrollToLastItem()
        })
//docReference?.collection("thread").document().collection("chats").addDocument(data: data, completion: { (error) in
//            if let error = error {
//                print("Error Sending message: \(error)")
//                return
//            }
//            self.messagesCollectionView.scrollToBottom()
//        })
    }
    
    
    
}

//extension TestChatVC: InputBarAccessoryViewDelegate {
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//    //When use press send button this method is called.
//
//    let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: currentUser.uid, senderName: currentUser.displayName!)
//    //calling function to insert and save message
//    insertNewMessage(message)
//    save(message)
//    //clearing input field
//    inputBar.inputTextView.text = ""
//    messagesCollectionView.reloadData()
//    messagesCollectionView.scrollToBottom(animated: true)
//    }
//}

// MARK: - MessageDataSource
extension TestChatVC: MessagesDataSource {

    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
    }
    
    // 1
    func currentSender() -> SenderType {
        //let ddd = Auth.auth().currentUser!.uid
        //let dddddd = UserDefaults.standard.string(forKey: "username")
        return sender(senderId: Auth.auth().currentUser!.uid, displayName: UserDefaults.standard.string(forKey: "username") ?? "Unknown")
    }
    
    // 2
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }

    // 3
    func messageForItem(at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> MessageType {

      return messages[indexPath.section]
    }
    
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        return UserDefaults.standard.bool(forKey: "isAdminLoggedIn")
//    }
    
    
   
    
//    //This method return the current sender ID and name
//    func currentSender() -> Sender {
//        print(UserDefaults.standard.string(forKey: "username"))
//        return Sender(id: Auth.auth().currentUser!.uid, displayName: UserDefaults.standard.string(forKey: "username") ?? "Name not found")
//    }
    

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
            return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    
     func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)])
    }
    
     func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
         if indexPath.section % 3 == 0 {
                return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            }
        
            return nil
    }
}


// MARK: - MessagesDisplayDelegate
extension TestChatVC: MessagesDisplayDelegate {
    
    // 1
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if messages[indexPath.section].senderType == MesseageSenderType.admin.rawValue {
            return #colorLiteral(red: 0.2607796788, green: 0.4254390597, blue: 0.6755281687, alpha: 1)
        } else {
            return isFromCurrentSender(message: message) ? .primary : .lightGray
        }
        
//        if isFromCurrentSender(message: message) {
//            return messages[indexPath.row].senderType == MesseageSenderType.admin.rawValue ? #colorLiteral(red: 0.2607796788, green: 0.4254390597, blue: 0.6755281687, alpha: 1) : .primary
//            //return UserDefaults.standard.bool(forKey: "isAdminLoggedIn") ? #colorLiteral(red: 0.2607796788, green: 0.4254390597, blue: 0.6755281687, alpha: 1) : .primary
//        } else {
//            return isFromCurrentSender(message: message) ? .primary : .lightGray
//        }
        
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        
        // 2
        return true
    }


    func messageStyle(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

      let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft

      // 3
      return .bubbleTail(corner, .curved)
    }
}


// MARK: - InputBarAccessoryViewDelegate
extension TestChatVC: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let senderType = UserDefaults.standard.bool(forKey: "isAdminLoggedIn") ? MesseageSenderType.admin.rawValue : MesseageSenderType.common.rawValue
        
        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: currentUser.uid, senderName: UserDefaults.standard.string(forKey: "username") ?? "Unknown", senderType: senderType)
        insertNewMessage(message)
        
        save(message)
        inputBar.inputTextView.text = ""
        
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
        
        
    }
    
}

// MARK: - MessagesLayoutDelegate
extension TestChatVC: MessagesLayoutDelegate, MessageLabelDelegate {
    
    func didSelectURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            let config = SFSafariViewController.Configuration()
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("tapped")
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        [.url, .phoneNumber, .date]
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        switch detector {
        case .url, .phoneNumber:
            return [.foregroundColor: UIColor.systemBlue]
        case .address:
            break
        case .date:
            break
        case .transitInformation:
            break
        case .custom(_):
            break
        }
        return MessageLabel.defaultAttributes
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        18
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        18
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }
    
    

}

//
//extension TestChatVC: GADInterstitialDelegate {
//    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
//        if interstitial.isReady {
//            interstitial.present(fromRootViewController: self)
//        }
//    }
//
//    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
//        // Load a new interstitial ad when it is dismissed
//        interstitial = GADInterstitial(adUnitID: Adomb.AD_INTERSTITIAL_TEST)
//        interstitial.load(GADRequest())
//    }
//}
