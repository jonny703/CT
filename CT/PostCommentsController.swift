//
//  PostCommentsController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD
import MessageUI
import skpsmtpmessage

enum PostCommentsControllerStatus {
    case stream
    case chartDetail
}

class PostCommentsController: UIViewController {
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    var postCommentControllerStatus: PostCommentsControllerStatus?
    
    var streamControllerDelegate: StreamControllerDelegate?
    var chartDetailControllerDelegate: ChartDetailControllerDelegate?
    
    var category = String()
    var posts = [Post]()
    var currentPost: Post?
    
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
    
    lazy var inputContainerView: ChatInputContainerView = {
        
        let chatInputContainerview = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: 40))
        chatInputContainerview.seperatorLineView.isHidden = false
        chatInputContainerview.postCommentController = self
        chatInputContainerview.inputTextFieldDelegate = self
        return chatInputContainerview
        
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        observePosts()
//        setupKeyboardObservers()
    }
    
    // scroll containerView
    
    override var inputAccessoryView: UIView? {
        
        get {
            return inputContainerView
        }
        
    }
    
    override var canBecomeFirstResponder: Bool {
        
        return true
        
    }
    
//    func setupKeyboardObservers() {
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
//        
//    }
    // keyboard show hide remove
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
//        NotificationCenter.default.removeObserver(self)
        
    }
    
//    func handleKeyboardDidShow() {
//        
//        if posts.count > 0 {
//            
//            let indexPath = IndexPath(item: messages.count - 1, section: 0)
//            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
//            
//        }
//        
//    }
    
}

//MARK: handle collection view delegate

extension PostCommentsController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate {
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        //orientaion enable
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("collectionView selected")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.postCommentsController = self
        cell.textView.delegate = self
        cell.moreButton.tag = indexPath.item
        cell.moreButton.addTarget(self, action: #selector(handleBlockAndReport(sender:)), for: .touchUpInside)
        
        let post = posts[indexPath.item]
        
        setupStuffWith(post: post, cell: cell)
        setupCell(cell: cell, post: post)
        
        cell.setNeedsDisplay()
        return cell
        
    }
    
    private func setupStuffWith(post: Post, cell: CommentCell) {
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
    
    private func setupCell(cell: CommentCell, post: Post) {
        
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
                        //                        print("urlPost", url)
                        
                        
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
            let height = estimateFrameForText(text: post.text!).height + 10
            cell.textViewHeightConstraint?.constant = height
            
        } else {
            cell.textView.isHidden = false
            cell.textViewHeightConstraint?.constant = 15
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = posts[indexPath.item]
        
        let height = self.returnHeightWith(post: post)
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
        
    }
    
    private func returnHeightWith(post: Post) -> CGFloat {
        var height: CGFloat = 60
        
        if post.text != "" {
            
            height = estimateFrameForText(text: post.text!).height + 55
            
        }
        if post.imageUrl != "" {
            height += 150
        }
        return height
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height: CGFloat = 200
        if let post = currentPost {
            height = self.returnHeightWith(post: post)
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView? = nil
        
        if kind == UICollectionElementKindSectionHeader {
            
            if let post = currentPost {
                let height = self.returnHeightWith(post: post)
                
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! CommentCell
                
                headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
                headerView.moreButton.isHidden = true
                self.setupStuffWith(post: post, cell: headerView)
                self.setupCell(cell: headerView, post: post)
                
                reusableView = headerView
            }
        }
        
        return reusableView!
        
    }
    
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: DEVICE_WIDTH - 70, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
        
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
    
    
}
//MARK: handle report and block

extension PostCommentsController: MFMailComposeViewControllerDelegate, SKPSMTPMessageDelegate {
    
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
                self.handleBlockWith(post: post)
                
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
    
    fileprivate func handleBlockWith(post: Post) {
        
        if let postId = post.postId {
            
            let childPost = self.category
            let postsRef = Database.database().reference().child("posts").child(childPost).child(postId)
            
            let value = ["isBlock": "true"] as [String: AnyObject]
            postsRef.updateChildValues(value
                , withCompletionBlock: { (error, postRef) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    self.observePosts()
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
        mailComposerVC.setSubject("CoinVerse Report")
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

//MARK: inputTextField delegate
extension PostCommentsController: InputTextFieldDelegate {
    func inputTextFieldDidChanged(textField: UITextField) {
        
        if (textField.text?.isEmpty)! {
            inputContainerView.sendButton.isUserInteractionEnabled = false
        } else {
            inputContainerView.sendButton.isUserInteractionEnabled = true
        }
        
    }
}


//MARK: - handleChat
extension PostCommentsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    func handleSend() {
        
        let properties = ["text": inputContainerView.inputTextField.text!, "imageUrl": "", "imageWidth": 0, "imageHeight": 0, "isBlock": "false"] as [String : AnyObject]
        print("chat", properties)
        sendMessageWithProperties(properties: properties)
        
        
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        
        let properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height, "text": "", "isBlock": "false"] as [String : AnyObject]
        
        sendMessageWithProperties(properties: properties)
        
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        
        let ref = Database.database().reference().child("comments").child(category)
        let childRef = ref.childByAutoId()
        
        let fromId = Auth.auth().currentUser!.uid
        
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        
        var values = ["postId": childRef.key, "fromId": fromId, "timestamp": timestamp] as [String : AnyObject]
        
        
        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        //        childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            if let currentPostId = self.currentPost?.postId {
                let postReplyRef = Database.database().reference().child("posts-comments").child(self.category).child(currentPostId)
                let postId = childRef.key
                postReplyRef.updateChildValues([postId: 1])
                
                if self.postCommentControllerStatus == .stream {
                    self.streamControllerDelegate?.reloadDataWhenNewCommented()
                } else {
                    self.chartDetailControllerDelegate?.reloadDataWhenNewCommented()
                }
                
            }
        }
    }
    
    
    func handleUploadTap() {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.sourceType = .savedPhotosAlbum
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        handleImageSelectedForInfo(info: info as [String : AnyObject])        
        dismiss(animated: true, completion: nil)
        
    }
    
    private func handleImageSelectedForInfo(info: [String: AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            var image = selectedImage
            if selectedImage.size.width > 600 {
                image = selectedImage.resized(toWidth: 600.0)!
                
            }
            
            uploadToFirebaseStorageUsingImage(image: image, completiion: { (imageUrl) in
                
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                
                
            })
        }
        
        
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completiion: @escaping (_ imageUrl: String) -> ()) {
        
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("comments-images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image", error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    completiion(imageUrl)
                    
                }
                
            })
            
        }
        
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}


//MARK: fetch posts Data

extension PostCommentsController {
    
    fileprivate func observePosts() {
        
        let childPost = self.category
        self.posts.removeAll()
        
//        if let currentPost = currentPost {
//            self.posts.append(currentPost)
//        }
        
        if let currentPostId = currentPost?.postId {
            let postsCommentRef = Database.database().reference().child("posts-comments").child(childPost).child(currentPostId)
            postsCommentRef.observe(.childAdded, with: { (snapshot) in
                
                let postId = snapshot.key
                let postsRef = Database.database().reference().child("comments").child(childPost).child(postId)
                postsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: AnyObject] else {
                        KRProgressHUD.dismiss()
                        return
                    }
                    
                    let post = Post(dictionary: dictionary)
                    
                    if let isBlock = post.isBlock {
                        if isBlock == "false" {
                            
                            self.posts.insert(post, at: 0)
                            DispatchQueue.main.async {
                                print("collectionView reloaddata")
                                self.collectionView.reloadData()
                                KRProgressHUD.dismiss()
                                
                            }
                        }
                    }
                }, withCancel: nil)
                
            }, withCancel: nil)
        }
    }
    
    
}

//MARK: - handleImage, Video
extension PostCommentsController {
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


//MARK: setup Background, views

extension PostCommentsController {
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupViews() {
        setupBackground()
        setupNavBar()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        
        
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(CommentCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        view.addSubview(collectionView)
        
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    private func setupBackground() {
        
        view.backgroundColor = .white
    }
    
    private func setupNavBar() {
        
        self.navigationController?.isNavigationBarHidden = false
        
        navigationItem.title = "Comments"
        
        let image = UIImage(named: AssetName.close.rawValue)?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissController))
        let postButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissController))
        postButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = postButton
        
        navigationController?.navigationBar.barTintColor = StyleGuideManager.crytpTweetsBarTintColor
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}

