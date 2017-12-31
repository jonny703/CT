//
//  UsersController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import skpsmtpmessage
import KRProgressHUD

class UsersController: UITableViewController {
    
    let cellId = "cellId"
    
    var users = [CTUser]()
    var blocks = [String]()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchController.isActive = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.isActive = false
        dismiss(animated: true) {
            
            let user = self.users[indexPath.row]
            
            self.messagesController?.showChatControllerForUser(user: user)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        
        cell.user = user
        cell.userCellStatus = .usersController
        cell.usersController = self
//        cell.textLabel?.text = user.username
//        cell.detailTextLabel?.text = user.fullname
//        cell.timeLabel.text = nil
//        let profileImageUrl = user.profilePictureURL
//        if profileImageUrl != "" {
//            
//            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl!)
//            
//        } else {
//            cell.profileImageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
//        }
//
//        cell.moreButton.isHidden = true
//        cell.moreButton.tag = indexPath.row
//        cell.moreButton.addTarget(self, action: #selector(handleBlockAndReport(sender:)), for: .touchUpInside)
        
        return cell
    }
}

//MARK: handle show ctuser profile
extension UsersController {
    
    func handleShowCTUserProfile(ctUserId: String) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        if currentUserId == ctUserId { return }
        self.searchController.isActive = false
        
        let layout = UICollectionViewFlowLayout()
        let profileController = ProfileController(collectionViewLayout: layout)
        profileController.ctUserId = ctUserId
        let navController = UINavigationController(rootViewController: profileController)
        
        self.present(navController, animated: true, completion: nil)
        
    }
}

//MARK: handle block and report

extension UsersController: SKPSMTPMessageDelegate {
    
    func handleBlockAndReport(sender: UIButton) {
        
        let moreButton = sender
        let ctUser = users[moreButton.tag]
        
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
                self.handleBlockWith(ctUser: ctUser)
                
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

    
    fileprivate func handleBlockWith(ctUser: CTUser) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        if let chatPartnerId = ctUser.userId {
            
            let blockRef = Database.database().reference().child("blocks").child(uid)
            let value = [chatPartnerId: 1]
            blockRef.updateChildValues(value, withCompletionBlock: { (error, blockRef) in
                if error != nil {
                    print(error!)
                    return
                    
                }
                self.fetchUser()
                
            })
        }
    }

    
    
    fileprivate func handleReportEmailWith(content: String) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ctUser = CTUser()
        
        let ref = Database.database().reference().child("users").child(userId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
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

//MARK: handle search
extension UsersController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            
            
            self.fetchUsersWith(searchedName: searchText)
            
        }
    }
}

//MARK: fetch users data

extension UsersController {
    
    fileprivate func fetchUsersWith(searchedName: String) {
        
        KRProgressHUD.show()
        
        let query = Database.database().reference().child("users").queryOrdered(byChild: "username").queryStarting(atValue: searchedName).queryEnding(atValue: searchedName + "\u{f8ff}")
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.users.removeAll()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                guard let dictionary = child.value as? [String: AnyObject] else {
                    KRProgressHUD.dismiss()
                    return
                }
                
                let user = CTUser()
                user.userId = child.key
                user.setValuesForKeys(dictionary)
                
                guard let currentUserId = Auth.auth().currentUser?.uid else {
                    KRProgressHUD.dismiss()
                    return
                }
                
                if currentUserId != user.userId {
                    self.users.append(user)
                }
                
            }
            
            self.tableView.reloadData()
            KRProgressHUD.dismiss()
            
            
        }, withCancel: nil)
        
    }
    
    
    
    func fetchUser() {
        
//        users.removeAll()
//        
//        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
//            
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                let user = CTUser()
//                user.userId = snapshot.key
//                user.setValuesForKeys(dictionary)
//                
//                guard let uid = Auth.auth().currentUser?.uid else {
//                    KRProgressHUD.dismiss()
//                    return
//                }
//                
//                self.blocks.removeAll()
//                
//                if uid != user.userId {
//                    
//                    Database.database().reference().child("blocks").child(uid).observe(.childAdded, with: { (snapshot) in
//                        
//                        let blockedId = snapshot.key
//                        self.blocks.append(blockedId)
//                        
//                    }, withCancel: nil)
//                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//                        
//                        if self.blocks.count > 0 {
//                            var blocked = false
//                            for blockedId in self.blocks {
//                                if user.userId == blockedId {
//                                    blocked = true
//                                }
//                            }
//                            
//                            if blocked == false {
//                                print("reloadtable3", self.users.count)
//                                self.users.append(user)
//                            }
//                            
//                        } else {
//                            print("reloadtable2", self.users.count)
//                            self.users.append(user)
//                        }
//                    })
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
//                        
//                        print("reloadtable1", self.users.count)
//                        self.tableView.reloadData()
//                        KRProgressHUD.dismiss()
//                    })
//                }
//            }
//        }, withCancel: nil)
        
    }

}

//MARK: handle dismiss controller 

extension UsersController {
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: setup Background

extension UsersController {
    
    fileprivate func setupViews() {
        setupBackground()
        setupNavBar()
        
        setupTableView()
        
    }
    
    private func setupTableView() {
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.titleView = searchController.searchBar
    }
    
    fileprivate func setupBackground() {
        
        view.backgroundColor = .white
    }
    
    fileprivate func setupNavBar() {
        
        self.navigationItem.title = "Users"
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = true
        
        let image = UIImage(named: AssetName.close.rawValue)?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissController))
        
        navigationController?.navigationBar.barTintColor = StyleGuideManager.crytpTweetsBarTintColor       
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}
