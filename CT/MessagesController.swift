//
//  MessagesController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import skpsmtpmessage
import KRProgressHUD

class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var blocks = [String]()

    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KRProgressHUD.set(style: .black)
        KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
        KRProgressHUD.show()
        self.setupViewes()
        addPushNotificationObserver()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavBarBackground()
        
    }
    
    deinit {
        removePushNotificationObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                   print("Failed to delete message:", error!)
                    return
                }
                
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadTable()
                
            })
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.messagesController = self
        
        let message = messages[indexPath.row]
        
        cell.message = message
        cell.userCellStatus = .messageController
        
        cell.moreButton.tag = indexPath.row
        cell.moreButton.addTarget(self, action: #selector(handleBlockAndReport(sender:)), for: .touchUpInside)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = CTUser()
            
            user.userId = chatPartnerId
            
            user.setValuesForKeys(dictionary)
            
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
        
    }
}

//MARK: handle show ctuser profile
extension MessagesController {
    
    func handleShowCTUserProfile(ctUserId: String) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        if currentUserId == ctUserId { return }
        
        let layout = UICollectionViewFlowLayout()
        let profileController = ProfileController(collectionViewLayout: layout)
        profileController.ctUserId = ctUserId
        let navController = UINavigationController(rootViewController: profileController)
        
        self.present(navController, animated: true, completion: nil)
        
    }
}

//MARK: hanlde notification for reloaddata
extension MessagesController {
    fileprivate func addPushNotificationObserver() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(observeUserMessages), name: .ReloadMessageTableViewData, object: nil)
        
    }
    
    fileprivate func removePushNotificationObserver() {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: .ReloadMessageTableViewData, object: nil)
    }
}

//MARK: handel delete, report, block

extension MessagesController: SKPSMTPMessageDelegate {
    
    func handleBlockAndReport(sender: UIButton) {
        
        let moreButton = sender
        let message = self.messages[moreButton.tag]
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: .default) { (action) in
            
            let alert = UIAlertController(title: "Are you sure you want to report this user?", message: "", preferredStyle: .alert)
            
            let OkAction = UIAlertAction(title: "Ok!", style: .default) { (action) in
                self.handleReportEmailWith(content: "report")
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(OkAction)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
        let blockAction = UIAlertAction(title: "Block", style: .default) { (action) in
            
            let alert = UIAlertController(title: "Are you sure you want to block this user?", message: "", preferredStyle: .alert)
            
            let OkAction = UIAlertAction(title: "Ok!", style: .default) { (action) in
                            self.handleReportEmailWith(content: "block")
                            self.handleBlockWith(message: message)

                
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(OkAction)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(reportAction)
        alertController.addAction(blockAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }

    
    fileprivate func handleBlockWith(message: Message) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        if let chatPartnerId = message.chatPartnerId() {
            
            let blockRef = Database.database().reference().child("blocks").child(uid)
            let value = [chatPartnerId: 1]
            blockRef.updateChildValues(value, withCompletionBlock: { (error, blockRef) in
                if error != nil {
                    print(error!)
                    return
                    
                }
                self.observeUserMessages()
            })
        }
    }
    
    fileprivate func handleDeleteMessageWith(message: Message) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        if let chatPartnerId = message.chatPartnerId() {
            
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadTable()
                
            })
        }
    }
    
    fileprivate func handleReportEmailWith(content: String) {
        
        let userId = Auth.auth().currentUser?.uid
        let ctUser = CTUser()
        
        let ref = Database.database().reference().child("users").child(userId!)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            //            print(snapshot)
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            ctUser.userId = userId
            
            ctUser.setValuesForKeys(dictionary)
            
        }, withCancel: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            
            if let toEmail = ctUser.email {
                let emailMessage = SKPSMTPMessage()
                emailMessage.fromEmail = "zhichaocaesar702@gmail.com"
                emailMessage.toEmail = toEmail
                emailMessage.subject = "CoinVerse"
                emailMessage.relayHost = "smtp.gmail.com"
                emailMessage.requiresAuth = true
                emailMessage.login = "zhichaocaesar702@gmail.com"
                emailMessage.pass = "juliuscaesar0703"
                emailMessage.wantsSecure = true
                emailMessage.delegate = self
                
                let messageBody = "Thank you for taking a moment to " + content + " a user/content on CoinVerse. It is a great help us to have our own members assist us in keeping the CrptoTweets steams as informative and constructive as possible. We are presently processing your report. CoinVerse"
                
                let plainPart: NSDictionary = [kSKPSMTPPartContentTypeKey: "text/plain", kSKPSMTPPartMessageKey: messageBody, kSKPSMTPPartContentTransferEncodingKey: "8bit"]
                emailMessage.parts = [plainPart]
                emailMessage.send()
            }
            
        })
        
        
    }
    
    func messageSent(_ message: SKPSMTPMessage!) {
        print("email sent")
    }
    
    func messageFailed(_ message: SKPSMTPMessage!, error: Error!) {
        print("email sending fail")
    }

    
}

//MARK: handle fetch data

extension MessagesController {
    
    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            KRProgressHUD.dismiss()
            return
        }
        
        messages.removeAll()
        messagesDictionary.removeAll()
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            self.blocks.removeAll()
            
            let userId = snapshot.key
            
            Database.database().reference().child("blocks").child(uid).observe(.childAdded, with: { (snapshot) in
                
                let blockedId = snapshot.key
                self.blocks.append(blockedId)
                
            }, withCancel: nil)
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                if self.blocks.count > 0 {
                    var blocked = false
                    for blockedId in self.blocks {
                        if userId == blockedId {
                            blocked = true
                        }
                    }
                    
                    if blocked == false {
                        Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                            
                            let messageId = snapshot.key
                            
                            self.fetchMessageWithMessageId(messageId: messageId)
                            
                        }, withCancel: nil)
                    }
                    
                } else {
                    Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                        
                        let messageId = snapshot.key
                        
                        self.fetchMessageWithMessageId(messageId: messageId)
                        
                    }, withCancel: nil)
                }
            })
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadTable()
            
        }, withCancel: nil)
        
    }
    
    private func fetchMessageWithMessageId(messageId: String) {
        
        let messageReference = Database.database().reference().child("messages").child(messageId)
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let message = Message(dictionary: dictionary)
                if let chatPartnerId = message.chatPartnerId() {
                    
                    self.messagesDictionary[chatPartnerId] = message
                }
                
                KRProgressHUD.dismiss()
                self.attemptReloadTable()
                
            }
            
        }, withCancel: nil)
    }
    
    fileprivate func attemptReloadTable() {
        
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        
    }
    
    
    
    func handleReloadTable() {
        
        self.messages = Array(self.messagesDictionary.values)
        
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
            
        })
        
        DispatchQueue.main.async {
            print("reload table")
            self.tableView.reloadData()
        }
        
    }
    
    func observeMessages() {
        
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let message = Message(dictionary: dictionary)
                
                if let toId = message.toId {
                    
                    self.messagesDictionary[toId] = message
                    
                    self.messages = Array(self.messagesDictionary.values)
                    
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        
                        return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                        
                    })
                    
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
        
    }

    
}

//MARK: handel navigation controller

extension MessagesController {
    
    func goingToUsersController() {
        
        let usersController = UsersController()
        usersController.messagesController = self
        let navController = UINavigationController(rootViewController: usersController)
        
        self.present(navController, animated: true, completion: nil)
        
    }
    
    func showChatControllerForUser(user: CTUser) {
        let oneToOneChatController = OneToOneChatController(collectionViewLayout: UICollectionViewFlowLayout())
        oneToOneChatController.chatUser = user
        let navController = UINavigationController(rootViewController: oneToOneChatController)
        
        self.present(navController, animated: true, completion: nil)
        
    }
    
}

//MARK: setup views

extension MessagesController {
    fileprivate func setupViewes() {
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        observeUserMessages()
        
    }
    
    fileprivate func setupNavBarBackground() {
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.title = "Message"
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        
        let image = UIImage(named: AssetName.addUser.rawValue)?.withRenderingMode(.alwaysOriginal)

        let addUserButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(goingToUsersController))
        self.tabBarController?.navigationItem.rightBarButtonItem = addUserButton
    }
}
