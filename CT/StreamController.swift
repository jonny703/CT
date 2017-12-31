//
//  StreamController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import MessageUI
import skpsmtpmessage
import KRProgressHUD
import KRPullLoader

protocol StreamControllerDelegate {
    func reloadDataWhenNewPosted()
    func reloadDataWhenNewCommented()
}

enum StreamControllerStatus {
    case Following
    case Blog
    case News
    case Miners
    case Charts
    case Analysis
    case Other
}

class StreamController: UIViewController {
    
    let SocialViewXPosition = (DEVICE_WIDTH - 240) / 2
    
    var lastTimestamp: NSNumber?
    var canScroll: Bool = true
    
    let cellId = "cellId"
    var selectedControllerStatus: StreamControllerStatus = .Following
    
    var longClickedCell: PostCell?
    var longClickedPost: Post?
    
    var posts = [Post]()
    var ctUser: CTUser? {
        didSet {
            guard let uid = Auth.auth().currentUser?.uid else {
                
                return
                
            }
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    self.ctUser?.setValuesForKeys(dictionary)
                }
                
            }, withCancel: nil)
            
            
        }
    }
    
    var startingFrame: CGRect?
    
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.backgroundColor = UIColor.lightGray
        colView.alwaysBounceVertical = true
        colView.showsVerticalScrollIndicator = false
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.dataSource = self
        colView.delegate = self
        return colView
    }()
    
    lazy var socialView: SocialView = {
        
        let view = SocialView()
        
        view.backgroundColor = .white
        
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        view.socialViewDelegate = self
        return view
    }()

//    lazy var refreshControl: UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.tintColor = .gray
//        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
//        return refreshControl
//    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPushNotificationObserver()
        setupViewes()
        observePostsByTenWith(page: 0)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarBackground()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        socialView.removeFromSuperview()
        
    }
    
    deinit {
        removePushNotificationObserver()
    }
}

//MARK: handle show ctuser profile
extension StreamController {
    
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
extension StreamController {
    fileprivate func addPushNotificationObserver() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(reloadCollectionView), name: .ReloadCollectionViewDataInStreamController, object: nil)
        
    }
    
    fileprivate func removePushNotificationObserver() {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: .ReloadCollectionViewDataInStreamController, object: nil)
    }
}

//MARK: handle refresh
extension StreamController {
    func handleRefresh() {
        self.observePostsByTenWith(page: 2)
    }
}

//MARK: handle reload data when new posted, commented
extension StreamController: StreamControllerDelegate {
    func reloadDataWhenNewPosted() {
        observePostsByTenWith(page: 0)
    }
    
    func reloadDataWhenNewCommented() {
        collectionView.reloadData()
    }
}

//MARK: handle postcell delegate
extension StreamController: PostCellDelegate {
    
    func reloadCollectionView() {
        
        if self.selectedControllerStatus == .Following {
            observePostsByTenWith(page: 0)
        } else {
            collectionView.reloadData()
        }
    }
    
    fileprivate func handleFirebaseWith(status: String, userId: String, postId: String, cell: PostCell, index: Int) {
        let interestsRef = Database.database().reference().child("interests").child(postId)
        interestsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(userId) {
                interestsRef.child(userId).removeValue(completionBlock: { (error, ref) in
                    
                    if error != nil {
                        
                        KRProgressHUD.dismiss()
                        return
                    }
                    self.posts[index].status = status
                    self.resetLikeButtonWith(status: status, cell: cell)
                    self.resetInterestsLabelWith(postId: postId, userId: userId, cell: cell)
                    KRProgressHUD.dismiss()
                })
                
            } else {
                
                let value = ["status": status]
                interestsRef.child(userId).updateChildValues(value, withCompletionBlock: { (error, ref) in
                    
                    if error != nil {
                        
                        KRProgressHUD.dismiss()
                        return
                    }
                    self.posts[index].status = status
                    self.resetLikeButtonWith(status: status, cell: cell)
                    self.resetInterestsLabelWith(postId: postId, userId: userId, cell: cell)
                    KRProgressHUD.dismiss()
                    
                })
            }
        })
    }
    
    func didClickLikeButton(index: Int, post: Post, cell: PostCell) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let postId = post.postId else { return }
        KRProgressHUD.show()
        
        if let status = post.status {
            if status == "none" {
                self.handleFirebaseWith(status: "like", userId: userId, postId: postId, cell: cell, index: index)
            } else {
                self.handleFirebaseWith(status: "none", userId: userId, postId: postId, cell: cell, index: index)
            }
        }
        
        
    }
    
    fileprivate func resetLikeButtonWith(status: String, cell: PostCell) {
        var imageName: String
        if status == "like" {
            imageName = AssetName.likeActive.rawValue
            
        } else if status == "love" {
            imageName = AssetName.emoticonLove.rawValue
        } else if status == "haha" {
            imageName = AssetName.emoticonHappy.rawValue
        } else if status == "confused" {
            imageName = AssetName.emoticonConfused.rawValue
        } else if status == "sad" {
            imageName = AssetName.emoticonSad.rawValue
        } else if status == "angry" {
            imageName = AssetName.emoticonAngry.rawValue
        } else {
            imageName = AssetName.likeInactive.rawValue
        }
        
        var image = UIImage()
        
        if status == "none" {
            image = (UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate))!
            cell.likeButton.setTitle("like", for: .normal)
            cell.likeButton.tintColor = .darkGray
            cell.likeButton.setTitleColor(.darkGray, for: .normal)
        } else if status == "like" {
            image = (UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate))!
            cell.likeButton.setTitle("like", for: .normal)
            cell.likeButton.tintColor = StyleGuideManager.likeButtonActiveBlueColor
            cell.likeButton.setTitleColor(StyleGuideManager.likeButtonActiveBlueColor, for: .normal)
        } else {
            image = (UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal))!
            cell.likeButton.setTitle(status, for: .normal)
            cell.likeButton.tintColor = .clear
            if status == "angry" {
                cell.likeButton.setTitleColor(StyleGuideManager.likeButtonAngryColor, for: .normal)
            } else {
                cell.likeButton.setTitleColor(StyleGuideManager.likeButtonEmoticonColor, for: .normal)
            }
            
        }
        
        cell.likeButton.setImage(image, for: .normal)
        
    }
    
    func didClickCommentButton(index: Int, post: Post) {
        
        var category: String
        if self.returnTabBarStringWithSelection() == "following" {
            category = post.category!
        } else {
            category = self.returnTabBarStringWithSelection()
        }
        
        let postCommentsController = PostCommentsController()
        postCommentsController.category = category
        postCommentsController.currentPost = post
        postCommentsController.streamControllerDelegate = self
        let navController = UINavigationController(rootViewController: postCommentsController)
        self.present(navController, animated: true, completion: nil)
    }
    
    func didLongClickLikeButton(index: Int, post: Post, gesture: UILongPressGestureRecognizer, cell: PostCell) {
        
        let touchPoint = gesture.location(in: self.view)
        
        var yPosition: CGFloat
        if touchPoint.y > DEVICE_HEIGHT / 2 {
            yPosition = touchPoint.y - 60.0
        } else {
            yPosition = touchPoint.y + 40.0
        }
        
        longClickedCell = cell
        longClickedPost = post
        
        addSocialView(yPosition: yPosition)
    }
}

//MARK: handle social view delegate
extension StreamController: SocialViewDelegate {
    func addSocialView(yPosition: CGFloat) {
        
        socialView.frame = CGRect(x: SocialViewXPosition, y: yPosition, width: 240, height: 40)
        view.addSubview(socialView)
        
    }
    
    func didClickEmoticon(index: Int) {
        socialView.removeFromSuperview()
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let postId = longClickedPost?.postId else { return }
        guard let cell = longClickedCell else { return }
        
        var status: String
        if index == 0 {
            status = "like"
        } else if index == 1 {
            status = "love"
        } else if index == 2 {
            status = "haha"
        } else if index == 3 {
            status = "confused"
        } else if index == 4 {
            status = "sad"
        } else {
            status = "angry"
        }
        
        KRProgressHUD.show()
        
        let interestsRef = Database.database().reference().child("interests").child(postId)
        let value = ["status": status]
        interestsRef.child(userId).updateChildValues(value, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                
                KRProgressHUD.dismiss()
                return
            }
            
            self.posts[index].status = status
            self.resetLikeButtonWith(status: status, cell: cell)
            self.resetInterestsLabelWith(postId: postId, userId: userId, cell: cell)
            KRProgressHUD.dismiss()
            
        })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        socialView.removeFromSuperview()
        
    }
}


//MARK: handle collection view delegate

extension StreamController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate {
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        //orientaion enable
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
//        if self.posts.count - 1 == indexPath.item {
//            if (self.canScroll) {
//                self.observePostsByTenWith(page: 1)
//            }
//            
//        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PostCell
        
        cell.stremController = self
        cell.textView.delegate = self
        cell.postCellDelegate = self
        cell.postCellStatus = .stream
        cell.index = indexPath.item
        cell.moreButton.tag = indexPath.item
        cell.moreButton.addTarget(self, action: #selector(handleBlockAndReport(sender:)), for: .touchUpInside)
        
        
        let post = posts[indexPath.item]
        cell.post = post
        
        setupStuffWith(post: post, cell: cell)
        setupCell(cell: cell, post: post)
        setupSocialViewWith(post: post, cell: cell)
        
        cell.setNeedsDisplay()
        return cell
        
    }
    
    fileprivate func resetInterestsLabelWith(postId: String, userId: String, cell: PostCell) {
        let interstsRef = Database.database().reference().child("interests").child(postId)
        interstsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let count = snapshot.childrenCount as NSNumber
            let numberStr = self.returnNumberStringWith(number: count)
            cell.interestedLabel.text = "\(numberStr) interested"
        })
    }
    
    fileprivate func resetCommentsLabelWith(postId: String, cell: PostCell, post: Post) {
        var childName = self.returnTabBarStringWithSelection()
        if childName == "following" {
            childName = post.category!
        }
        let commentsRef = Database.database().reference().child("posts-comments").child(childName).child(postId)
        commentsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let count = snapshot.childrenCount as NSNumber
            let numberStr = self.returnNumberStringWith(number: count)
            cell.commentedLabel.text = "\(numberStr) commented"
        })
    }
    
    
    private func setupSocialViewWith(post: Post, cell: PostCell) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let postId = post.postId {
            
            self.resetInterestsLabelWith(postId: postId, userId: userId, cell: cell)
            
            self.resetCommentsLabelWith(postId: postId, cell: cell, post: post)
        }
        
        if let status = post.status {
            self.resetLikeButtonWith(status: status, cell: cell)
        }
    }
    
    private func returnNumberStringWith(number: NSNumber) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let numberStr = numberFormatter.string(from: number)! as String
        return numberStr
    }
    
    private func setupStuffWith(post: Post, cell: PostCell) {
        if let seconds = post.timestamp?.doubleValue {
            
            let timestampeDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.timeLabel.text = dateFormatter.string(from: timestampeDate as Date)
            
            cell.timeLabel.text = returnLeftTimedateformatter(date: seconds)
            
        }
        
        
        if post.imageUrl != "" {
            cell.postImageView.isHidden = false
        } else {
            cell.postImageView.isHidden = true
        }
        
        if let postImageUrl = post.imageUrl {
            
            if postImageUrl != "" {
                
                cell.postImageView.loadImageUsingCacheWithUrlString(urlString: postImageUrl)
                cell.postImageView.isHidden = false
            } else {
                cell.postImageView.isHidden = true
            }
            
        }
    }
    
    private func setupCell(cell: PostCell, post: Post) {
        
        if let userId = post.fromId {
            let ref = Database.database().reference().child("users").child(userId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let profileImageUrl = dictionary["profilePictureURL"] as? String
                    if profileImageUrl != "" {
                        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl!)
                    } else {
                        cell.profileImageView.image = UIImage(named: "iTunesArtwork")
                    }
                    cell.usernameLabel.text = dictionary["username"] as? String
                }
                
                
            }, withCancel: nil)
        }
        
        if post.text != "" {
            
            let postStr = post.text
            
            let postAttributedString = NSMutableAttributedString(string: postStr!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: postStr!, options: [], range: NSRange(location: 0, length: (postStr!.utf16.count)))
            
            if matches.count > 0 {
                for match in matches {
                    if let url = postStr?.substring(with: match.range.range(for: postStr!)!) {
                        if let range = postStr?.range(of: url) {
                            if let index = postStr?.distance(from: (postStr?.startIndex)!, to: range.lowerBound) {
                                
                                let urlRange = NSMakeRange(index, url.characters.count)
                                
                                postAttributedString.addAttribute(NSLinkAttributeName, value: url, range: urlRange)
                                
                                postAttributedString.removeAttribute(NSFontAttributeName, range: urlRange)
                                postAttributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16), range: urlRange)
                                
                                let linkAttribute: [String: Any] = [NSForegroundColorAttributeName: StyleGuideManager.likeButtonActiveBlueColor, NSUnderlineColorAttributeName: StyleGuideManager.likeButtonActiveBlueColor, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
                                cell.textView.linkTextAttributes = linkAttribute
                                cell.textView.attributedText = postAttributedString
                            }
                        }
                    }
                    
                }
            }
            else  {
                cell.textView.attributedText = nil
                cell.textView.typingAttributes = Dictionary()
                cell.textView.text = post.text
                cell.textView.font = UIFont.systemFont(ofSize: 16)
            }
            
            cell.textView.isHidden = false
            let height = estimateFrameForText(text: post.text!).height + 20
            cell.textViewHeightConstraint?.constant = height
            
        } else {
            cell.textView.isHidden = false
            cell.textViewHeightConstraint?.constant = 15
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 65
        
        let post = posts[indexPath.item]
        
        height = estimateFrameForText(text: post.text!).height + 55
        
        if post.imageUrl != "" {
            height += 165
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height + 60)
        
    }
    
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: DEVICE_WIDTH - 80, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
        
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    
}

//MARK: handle report and block

extension StreamController: MFMailComposeViewControllerDelegate, SKPSMTPMessageDelegate {
    
    func handleBlockAndReport(sender: UIButton) {
        
        let moreButton = sender
        
        let post = posts[moreButton.tag]
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: .default) { (action) in
            
            let alert = UIAlertController(title: "Are you sure you want to report this content?", message: "", preferredStyle: .alert)
            
            let OkAction = UIAlertAction(title: "Ok!", style: .default) { (action) in
                self.handleReportEmailWith(content: "report")
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(OkAction)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
        let blockAction = UIAlertAction(title: "Block", style: .default) { (action) in
            
            let alert = UIAlertController(title: "Are you sure you want to block this content?", message: "", preferredStyle: .alert)
            
            let OkAction = UIAlertAction(title: "Ok!", style: .default) { (action) in
                self.handleReportEmailWith(content: "block")
                self.handleBlockWith(post: post, index: moreButton.tag)

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
    
    fileprivate func handleBlockWith(post: Post, index: Int) {
        
        if let postId = post.postId {
            
            let childPost = self.returnTabBarStringWithSelection()
            let postsRef = Database.database().reference().child("posts").child(childPost).child(postId)
            
            let value = ["isBlock": "true"] as [String: AnyObject]
            postsRef.updateChildValues(value
                , withCompletionBlock: { (error, postRef) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    self.posts.remove(at: index)
                    self.collectionView.reloadData()
            })
        }
    }
    
    fileprivate func handleReportEmailWith(content: String) {
        
        let userId = Auth.auth().currentUser?.uid
        let ctUser = CTUser()
        
        let ref = Database.database().reference().child("users").child(userId!)
        
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
                emailMessage.subject = "CryptoTweets"
                emailMessage.relayHost = "smtp.gmail.com"
                emailMessage.requiresAuth = true
                emailMessage.login = "zhichaocaesar702@gmail.com"
                emailMessage.pass = "juliuscaesar0703"
                emailMessage.wantsSecure = true
                emailMessage.delegate = self
                
                let messageBody = "Thank you for taking a moment to " + content + " a user/content on CryptoTweets. It is a great help us to have our own members assist us in keeping the CrptoTweets steams as informative and constructive as possible. We are presently processing your report. CryptoTweets"
                
                let plainPart: NSDictionary = [kSKPSMTPPartContentTypeKey: "text/plain", kSKPSMTPPartMessageKey: messageBody, kSKPSMTPPartContentTransferEncodingKey: "8bit"]
                emailMessage.parts = [plainPart]
                emailMessage.send()
            }
            
        })
        
        
    }
    
    func messageSent(_ message: SKPSMTPMessage!) {
    }
    
    func messageFailed(_ message: SKPSMTPMessage!, error: Error!) {
    }
    
    fileprivate func handleReport() {
        let mailComposeController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["hellojohn703@hotmail.com"])
        mailComposerVC.setSubject("CryptoTweets Report")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        
        showAlertMessage(vc: self, titleStr: "Could Not Send Email", messageStr: "Your device could not send e-mail.  Please check e-mail configuration and try again.")
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    
}

//MARK: handle top tab bar

extension StreamController {
    
    fileprivate func returnTabBarStringWithSelection() -> String {
        var tabStr = "following"
        if self.selectedControllerStatus == .Following {
            tabStr = "following"
        } else if self.selectedControllerStatus == .Blog {
            tabStr = "blog"
        } else if self.selectedControllerStatus == .News {
            tabStr = "news"
        } else if self.selectedControllerStatus == .Miners {
            tabStr = "miners"
        } else if self.selectedControllerStatus == .Charts {
            tabStr = "charts"
        } else if self.selectedControllerStatus == .Analysis {
            tabStr = "analysis"
        }
        return tabStr
    }
    
}

//MARK: fetch posts Data

extension StreamController {
    
    fileprivate func observePostsByTenWith(page: Int) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if page == 0 {
            KRProgressHUD.set(style: .black)
            KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
            KRProgressHUD.show()
        }
        
        
        let childName = self.returnTabBarStringWithSelection()
        
        var postsRef: DatabaseQuery
        
        if self.selectedControllerStatus == .Following {
            if page == 0 || page == 2 {
                postsRef = Database.database().reference().child("following-posts").child(userId).queryOrdered(byChild: "timestamp")
            } else {
                postsRef = Database.database().reference().child("following-posts").child(userId).queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestamp)
            }
            
        } else {
            if page == 0 || page == 2 {
                postsRef = Database.database().reference().child("posts").child(childName).queryOrdered(byChild: "timestamp")
            } else {
                postsRef = Database.database().reference().child("posts").child(childName).queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestamp)
            }
            
        }
        
        var tempPosts = [Post]()
        
        postsRef.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.childrenCount < 10 {
                self.canScroll = false
            }
            
            //            let groupKeys = snapshot.children.flatMap { $0 as? DataSnapshot }.map { $0.key }
            
            
            let group = DispatchGroup()
            
            
            for child in snapshot.children.reversed() as! [DataSnapshot] {
                
                if let dictionary = child.value as? [String: AnyObject] {
                    let post = Post(dictionary: dictionary)
                    if let timestamp = post.timestamp {
                        self.lastTimestamp = timestamp.intValue - 1 as NSNumber
                    }
                    guard let userId = Auth.auth().currentUser?.uid else { return }
                    guard let postId = post.postId else { return }
                    
                    group.enter()
                    let interstsRef = Database.database().reference().child("interests").child(postId).child(userId)
                    interstsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        group.leave()
                        
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let status = dictionary["status"] as! String
                            post.status = status
                            if let isBlock = post.isBlock {
                                if isBlock == "false" {
                                    tempPosts.append(post)
                                }
                            }
                        } else {
                            post.status = "none"
                            if let isBlock = post.isBlock {
                                if isBlock == "false" {
                                    tempPosts.append(post)
                                }
                            }
                        }
                    })
                }
            }
            
            group.notify(queue: .main, execute: {
                DispatchQueue.main.async {
                    
                    if page == 0 || page == 2 {
                        self.posts.removeAll()
                    }
                    
                    tempPosts.forEach({ (post) in
                        self.posts.append(post)
                    })
                    
                    self.collectionView.reloadData()
                    KRProgressHUD.dismiss()
                    
                    if page == 2 {
                        self.canScroll = true
                    }
                }
            })
        })

    }
}

//MARK: handle krpullloader delegate
extension StreamController: KRPullLoadViewDelegate {
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        
        if type == .loadMore {
            switch state {
            
            case let .loading(completionHandler):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    completionHandler()
                    if (self.canScroll) {
                        self.observePostsByTenWith(page: 1)
                    }
                }
                
            default:
                break
            }
            
            return
        }
        
        switch state {
        case .none:
            pullLoadView.messageLabel.text = ""
            
        case let .pulling(offset, threshould):
            if offset.y > threshould {
                pullLoadView.messageLabel.text = "Pull more. offset: \(Int(offset.y)), threshould: \(Int(threshould)))"
            } else {
                pullLoadView.messageLabel.text = "Release to refresh. offset: \(Int(offset.y)), threshould: \(Int(threshould)))"
            }
            
        case let .loading(completionHandler):
            pullLoadView.messageLabel.text = "Updating..."
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                completionHandler()
                self.observePostsByTenWith(page: 2)
            }
        }
        
    }
}

//MARK: - handleImage, Video
extension StreamController {
    //my custom zooming logic
    
    func performZoomingForStartingImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1

                let height = (self.startingImageView?.image?.size.height)! / (self.startingImageView?.image?.size.width)! * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                
                //                zoomOutImageView.removeFromSuperview()
                
            })
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view {
            
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }, completion: { (completed) in
                
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                
            })
        }
    }
}



//MARK: handle Post

extension StreamController {
    
    func handlePost() {
        
        let createPostController = CreatePostController()
        
        createPostController.selectedControllerStatus = self.selectedControllerStatus
        createPostController.streamControllerDelegate = self
        let navController = UINavigationController(rootViewController: createPostController)
        
        self.present(navController, animated: true, completion: nil)
        
    }
    
}


//MARK: setup views

extension StreamController {
    fileprivate func setupViewes() {
        
        setupCollectionView()
        
//        setupSocialView()
    }
    
    func setupSocialView() {
        view.addSubview(socialView)
        
        socialView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        socialView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        socialView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        socialView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setupCollectionView() {
        
        
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: cellId)
        view.addSubview(collectionView)
        
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0).isActive = true
        
        let refreshView = KRPullLoadView()
        refreshView.delegate = self
        collectionView.addPullLoadableView(refreshView, type: .refresh)
        
        let loadMoreView = KRPullLoadView()
        loadMoreView.delegate = self
        collectionView.addPullLoadableView(loadMoreView, type: .loadMore)
        
    }

    
    fileprivate func setupNavBarBackground() {
        
        
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.title = "Stream"
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        
        if self.selectedControllerStatus == .Following {
            self.tabBarController?.navigationItem.rightBarButtonItem = nil
        } else {
            let image = UIImage(named: AssetName.addPost.rawValue)?.withRenderingMode(.alwaysOriginal)
            self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handlePost))
        }
        
        
    }
}
