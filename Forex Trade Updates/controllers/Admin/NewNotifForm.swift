//
//  NewNotifForm.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 14/06/2020.
//  Copyright © 2020 Arslan. All rights reserved.

import UIKit
import UserNotifications
import MBProgressHUD
import FirebaseMessaging
import Firebase
import Alamofire


class notifsCell: UITableViewCell {
    
    @IBOutlet weak var notifTitle: UILabel!
    @IBOutlet weak var lblNotifBody: UILabel!
    @IBOutlet weak var lblNotifDate: UILabel!
    @IBOutlet weak var timesLbl: UILabel!
        
    @IBOutlet weak var viewcontent: UIView!
    var blurViewForTitle: UIVisualEffectView?
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        addblur()
//    }
//
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
    override func awakeFromNib() {
        super.awakeFromNib()
        //addblur()
        //notifTitle.subviews.forEach({ $0.removeFromSuperview() })
        //lblNotifBody.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    override func prepareForReuse() {
//        self.viewcontent.subviews.forEach { view in
//            if view == blurViewForTitle {
//                view.removeFromSuperview()
//            }
//        }
        //notifTitle.subviews.forEach({ $0.removeFromSuperview() })
        //lblNotifBody.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    fileprivate func addblur() {
        if blurViewForTitle == nil {
            
            // Create a blur effect
            let blurEffect = UIBlurEffect(style: .light)
            
            // Create separate blur views for notifTitle and lblNotifBody
            blurViewForTitle = UIVisualEffectView(effect: blurEffect)
            let blurViewForBody = UIVisualEffectView(effect: blurEffect)
            
            // Configure alpha and frame for the blur views
            blurViewForTitle?.alpha = 0.98
            blurViewForTitle?.frame = self.viewcontent.bounds
            blurViewForTitle?.isOpaque = true
            //blurViewForTitle?.layer.cornerRadius = 8
            blurViewForTitle?.clipsToBounds = true
            blurViewForBody.clipsToBounds = true
            //        blurViewForBody.alpha = 0.97
            //        blurViewForBody.frame = self.contentView.bounds
            //        blurViewForBody.layer.cornerRadius = 8
            //        blurViewForBody.clipsToBounds = true
            
            // Add blur views to their respective labels
            self.viewcontent.addSubview(blurViewForTitle!)
            //self.contentView.insertSubview(blurViewForTitle, at: 0)
            //setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !Defaults.shared.isSubActive && !Defaults.shared.isAdmin {
            //addblur()
        }
    }
    
    
    func setupCell(notif: NotifSentModel) {
        self.notifTitle.text = notif.notifTitle
        self.lblNotifBody.text = notif.notifBody
        self.lblNotifDate.text = getDate(doubleDate:  notif.sentDateTime)
        self.timesLbl.text = getTimesAgo(doubleTime: notif.sentDateTime)
        //addBlurEffect()
    }
    
    fileprivate func addBlurEffect() {
        let blureffect = UIBlurEffect(style: .extraLight)
        let blurview = UIVisualEffectView(effect: blureffect)
        blurview.frame = self.viewcontent.bounds
        self.viewcontent.insertSubview(blurview, at: 0)
            //notifTable.backgroundView = blurview
    }
    
    func getDate(doubleDate: Double) -> String {
        let date = Date(timeIntervalSince1970: doubleDate)
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.string(from: date)
        //let interval = date.timeIntervalSince1970
        return dateString
    }
    
    func getTimesAgo(doubleTime: Double) -> String {
        let date = Date(timeIntervalSince1970: doubleTime)
        return date.timeAgoDisplay()
    }
    
    
}


class NewNotifForm: UIViewController {
    
    let reuseIdentifier = "notifCell"
    
    @IBOutlet weak var txtNotifForm: UITextField!
    
    @IBOutlet weak var txtNotifBody: UITextView!
    
    @IBOutlet weak var notifFormVieew: UIView!
    
    @IBOutlet weak var tableviewAllNotifs: UITableView!
    @IBOutlet weak var notifswitch: UISegmentedControl!
    
    
    @IBOutlet weak var txtTitle: UILabel!
    var titleScreen: String = ""
    var ref: DatabaseReference!
    var intentFrom: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtTitle.text = titleScreen
        tableviewAllNotifs.delegate = self
        tableviewAllNotifs.dataSource = self
        if intentFrom == "AllNotif" {
            notifFormVieew.isHidden = true
            tableviewAllNotifs.isHidden = false
            tableviewAllNotifs.estimatedRowHeight = 200
            tableviewAllNotifs.rowHeight = UITableView.automaticDimension
            let notifProgress = MBProgressHUD.showAdded(to: self.view, animated: true)
            notifProgress.mode = .indeterminate
            notifProgress.show(animated: true)
            notifProgress.label.text = "Loading Data..."
            
            AuthenticationService.instance.getAllNotifsSent { (success) in
                notifProgress.hide(animated: true)
                if success {
                    AuthenticationService.instance.allNotifsSent = AuthenticationService.instance.allNotifsSent.sorted(by: { $0.sentDateTime > $1.sentDateTime })
                    self.tableviewAllNotifs.reloadData()
                }
            }
        } else {
            notifFormVieew.isHidden = false
            tableviewAllNotifs.isHidden = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
           navigationController?.setNavigationBarHidden(true, animated: animated)
       }
       
       override func viewWillDisappear(_ animated: Bool) {
           navigationController?.setNavigationBarHidden(false, animated: animated)
       }
    
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func btnSendPressed(_ sender: Any) {
    
        guard let notifTitle = txtNotifForm.text else {
            Actions.instance.showAlert(controller: self, alertTitle: "Empty Title", alertMessage: "Please enter notification Title")
            return
        }
        guard let notifBody = txtNotifBody.text else {
             Actions.instance.showAlert(controller: self, alertTitle: "Empty Body", alertMessage: "Please enter notification Body")
                return
        }
        
//        self.sendPushNotif(userId: "dStmcQVvQ0svpfhIaaS1OO:APA91bG6qT58SHyFNOFr3X7O69NRQhby_SyepzwdGz9PHbJ23oQ-vcy8Pfw4_Y_qm_ApZ8gfLUGHjqZfZXwmZSsBSNo_QAutC4UioGZghVYToOgdvGRU7IYx7Gf9FfBPQojDjJ-wZPGN", notifTitle: notifTitle, notifBody: notifBody)
//        return
        
//        let notifContent = UNMutableNotificationContent()
//        notifContent.title = notifTitle
//        notifContent.body = notifBody
//        notifContent.sound = UNNotificationSound.default
//        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 4, repeats: false)
//        let notifRequest = UNNotificationRequest(identifier: "Trading Alert", content: notifContent, trigger: trigger)
        //UNUserNotificationCenter.current().add(notifRequest, withCompletionHandler: nil)
        
 
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.mode = .indeterminate
        progress.show(animated: true)
        progress.label.text = "Sending, please wait..."
        let type: NotifSendingType = notifswitch.selectedSegmentIndex == 0 ? .subscribers : .nonsubscribers
        AuthenticationService.instance.getAllUsersTokens (type: type, { (usersToken) in
            progress.hide(animated: true)
            for token in usersToken {
                self.sendPushNotif(userId: token, notifTitle: notifTitle, notifBody: notifBody)
            }
            let date = Date().timeIntervalSince1970 as Double
            let notifSent: Parameters = ["title": notifTitle, "body": notifBody, "date": date]
            if type == .subscribers {
                AuthenticationService.instance.addNewNotifs(params: notifSent) { (success) in
                    progress.hide(animated: true)
                    self.txtNotifForm.text = ""
                    self.txtNotifBody.text = ""
                    if !success {
                        AlertControllerHelper.showAlertWithAction(fromViewController: self, title: "", message: "Congrates, \n Your notification is published to all users")
                    } else {
                        AlertControllerHelper.showAlertWithAction(fromViewController: self, title: "", message: "Oops, Error saving notification")
                    }
                }
            }
        })
    }
    
    
    @IBAction func arrowBackPressed(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }
    

}

extension NewNotifForm: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AuthenticationService.instance.allNotifsSent.count
        
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//
//    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableviewAllNotifs.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? notifsCell {
            
            cell.notifTitle.text = AuthenticationService.instance.allNotifsSent[indexPath.row].notifTitle
            cell.lblNotifBody.text = AuthenticationService.instance.allNotifsSent[indexPath.row].notifBody
            //print(AuthenticationService.instance.allNotifsSent[indexPath.row].sentDateTime)
            cell.lblNotifDate.text = getDate(doubleDate:  AuthenticationService.instance.allNotifsSent[indexPath.row].sentDateTime)
            cell.timesLbl.text = getTimesAgo(doubleTime: AuthenticationService.instance.allNotifsSent[indexPath.row].sentDateTime)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if (editingStyle == .delete) {
//            let ref = Database.database().reference()
//            let notifID = AuthenticationService.instance.allNotifsSent[indexPath.row].notifID!
//            AuthenticationService.instance.allNotifsSent.remove(at: indexPath.row)
//           // ref.child("notifs_sent").child(notifID).removeValue()
//            print(indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .middle)
//            //print(AuthenticationService.instance.allNotifsSent[indexPath.row].notifBody)
//            // handle delete (by removing the data from your array and updating the tableview)
//        }
//    }
    
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "bounds"{
//              if let rect = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgRectValue {
//                  let margin:CGFloat = 8.0
//                  self.textView.frame = CGRect.init(x: rect.origin.x + margin, y: rect.origin.y + margin, width: rect.width - 2*margin, height: rect.height / 2)
//                  self.textView.bounds = CGRect.init(x: rect.origin.x + margin, y: rect.origin.y + margin, width: rect.width - 2*margin, height: rect.height / 2)
//              }
//          }
//    }
    

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        self.ref = Database.database().reference()
        let notifID = AuthenticationService.instance.allNotifsSent[indexPath.row].notifID!

        
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: {_,_,_ in
            
            // Custom Alert
            let alert = UIAlertController(title: "Edit Signal", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
            
            // MARK: TextView title starts
            let tvtitle = UITextView(frame: .zero)
            tvtitle.translatesAutoresizingMaskIntoConstraints = false
            let tvtitleleadConstraint = NSLayoutConstraint(item: alert.view!, attribute: .leading, relatedBy: .equal, toItem: tvtitle, attribute: .leading, multiplier: 1.0, constant: -8.0)
            let tvtitletrailConstraint = NSLayoutConstraint(item: alert.view!, attribute: .trailing, relatedBy: .equal, toItem: tvtitle, attribute: .trailing, multiplier: 1.0, constant: 8.0)
            let tvtitletopConstraint = NSLayoutConstraint(item: alert.view!, attribute: .top, relatedBy: .equal, toItem: tvtitle, attribute: .top, multiplier: 1.0, constant: -64.0)
            let tvtitleheightConstraint = NSLayoutConstraint(item: tvtitle, attribute: .height, relatedBy: .equal, toItem: alert.view!, attribute: .height, multiplier: 0, constant: 64)
            alert.view.addSubview(tvtitle)
            NSLayoutConstraint.activate([tvtitleleadConstraint, tvtitletrailConstraint, tvtitletopConstraint, tvtitleheightConstraint])
            tvtitle.backgroundColor = UIColor.systemBackground
            tvtitle.layer.borderColor = UIColor.darkGray.cgColor
            tvtitle.layer.borderWidth = 0.25
            tvtitle.layer.cornerRadius = 8
            tvtitle.font = UIFont(name: "Helvetica", size: 15)
            tvtitle.text = AuthenticationService.instance.allNotifsSent[indexPath.row].notifTitle
            // MARK: TextView title ends

            // MARK: TextView description starts
            let tvdescription = UITextView(frame: .zero)
            tvdescription.translatesAutoresizingMaskIntoConstraints = false
            let leadConstraint = NSLayoutConstraint(item: alert.view!, attribute: .leading, relatedBy: .equal, toItem: tvdescription, attribute: .leading, multiplier: 1.0, constant: -8.0)

            let trailConstraint = NSLayoutConstraint(item: alert.view!, attribute: .trailing, relatedBy: .equal, toItem: tvdescription, attribute: .trailing, multiplier: 1.0, constant: 8.0)
            let topConstraint = NSLayoutConstraint(item: tvtitle, attribute: .bottom, relatedBy: .equal, toItem: tvdescription, attribute: .top, multiplier: 1.0, constant: -8.0)
            let bottomConstraint = NSLayoutConstraint(item: alert.view!, attribute: .bottom, relatedBy: .equal, toItem: tvdescription, attribute: .bottom, multiplier: 1.0, constant: 64.0)

            alert.view.addSubview(tvdescription)
            NSLayoutConstraint.activate([leadConstraint, trailConstraint, topConstraint, bottomConstraint])
            tvdescription.backgroundColor = UIColor.systemBackground
            tvdescription.layer.borderColor = UIColor.darkGray.cgColor
            tvdescription.layer.borderWidth = 0.25
            tvdescription.layer.cornerRadius = 8
            tvdescription.font = UIFont(name: "Helvetica", size: 16)
            // MARK: TextView Description Ends

//            alert.addTextField { (textfield) in
//                textfield.text = AuthenticationService.instance.allNotifsSent[indexPath.row].notifTitle
//            }
            alert.view.addSubview(tvdescription)
            tvdescription.text = AuthenticationService.instance.allNotifsSent[indexPath.row].notifBody

//            alert.addTextField { (textfield) in
//                textfield.text = AuthenticationService.instance.allNotifsSent[indexPath.row].notifBody
//            }
            //               alert.addTextField(configurationHandler: { (textField) in
            //                   textField.text = self.list[indexPath.row]
            //               })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                //guard let title = alert.textFields?.first?.text else { return }
                //guard let body = alert.textFields?.last?.text else { return }
                guard let txttitle = tvtitle.text else { return }
                guard let txtbody = tvdescription.text else { return }
                
                let params = ["title": txttitle, "body": txtbody]
                AuthenticationService.instance.allNotifsSent[indexPath.row].notifBody = txtbody
                AuthenticationService.instance.allNotifsSent[indexPath.row].notifTitle = txttitle
                //self.ref.child("notifs_test").child(notifID).updateChildValues(params)
                self.ref.child("notifs_sent").child(notifID).updateChildValues(params)
                tableView.reloadRows(at: [indexPath], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            //alert.view.addSubview(self.textView)
            //self.textView.text = AuthenticationService.instance.allNotifsSent[indexPath.row].notifBody

            self.present(alert, animated: false)
        })
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {_,_,_ in
            //self.list.remove(at: indexPath.row)
            AuthenticationService.instance.allNotifsSent.remove(at: indexPath.row)
            self.ref.child("notifs_sent").child(notifID).removeValue()
            //self.ref.child("notifs_test").child(notifID).removeValue()
            print(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            //print(AuthenticationService.instance.allNotifsSent[indexPath.row].notifBody)
            // handle delete (by removing the data from your array and updating the tableview)
            tableView.reloadData()
        })
        
        editAction.backgroundColor = #colorLiteral(red: 0.2143596303, green: 0.6447295368, blue: 0.3848516412, alpha: 1)
        

        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
}

extension UIViewController {
    func sendPushNotif(userId: String, notifTitle: String, notifBody: String) {
          
          let notification = ["to": userId, "notification": ["title": notifTitle, "body": notifBody, "badge": 1, "sound": "default"], "data": ["body": "Body", "title": "Title here"]] as [String : Any]
          let header: HTTPHeaders = [
              "content-type" : "application/json",
              "Authorization" : "key=\(SERVER_KEY)"
          ]
          
          AF.request("https://fcm.googleapis.com/fcm/send" as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
              print(response.result)
              switch response.result {
              case .success(let response):
                  print(response)
              case .failure(let error):
                  print(error.localizedDescription)
              }
          }
      }
    func sendPushNotifWithoutSound(userId: String, notifTitle: String, notifBody: String) {
             
             let notification = ["to": userId, "notification": ["title": notifTitle, "body": notifBody, "badge": 1], "data": ["body": "Body", "title": "Title here"]] as [String : Any]
             let header: HTTPHeaders = [
                 "content-type" : "application/json",
                 "Authorization" : "key=\(SERVER_KEY)"
             ]
             
             AF.request("https://fcm.googleapis.com/fcm/send" as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
                 print(response.result)
                 switch response.result {
                 case .success(let response):
                     print(response)
                 case .failure(let error):
                     print(error.localizedDescription)
                 }
             }
         }
}
