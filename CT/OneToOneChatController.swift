//
//  ChatOnebyOneController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class OneToOneChatController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    var chatUser: CTUser? {
        didSet {
            self.navigationItem.title = chatUser?.username
            
            fetchData()
        }
        
    }
    var messages = [Message]()
    
    var startingFrame: CGRect?
    
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    var inputContainerBottomAncher: NSLayoutConstraint?
    var collectionViewBottomAncher: NSLayoutConstraint?
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        
        let chatInputContainerview = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: 40))
        chatInputContainerview.seperatorLineView.isHidden = false
        chatInputContainerview.oneToOneChatController = self
        return chatInputContainerview
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        setupKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBackground()
        
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
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        
    }
    // keyboard show hide remove
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        
    }
    
    func handleKeyboardDidShow() {
        
        if messages.count > 0 {
            
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
            
        }
        
    }
    
    let cellId = "cellId"
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        //orientaion enable
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.oneToOneChatController = self
        
        let message = messages[indexPath.item]
        
        cell.message = message
        
        if message.text != "" {
            cell.textView.text = message.text
        }
        
        
        if let seconds = message.timestamp?.doubleValue {
            
            let timestampeDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.timeLabel.text = dateFormatter.string(from: timestampeDate as Date)
            cell.timeLabel.text = returnLeftTimedateformatter(date: seconds)
        }
        
        
        setupCell(cell: cell, message: message)
        
        
        if message.text != ""  {
            // a text message
            cell.bubbleWidthAncher?.constant = estimateFrameForText(text: message.text!).width + 32
            cell.textView.isHidden = false
            
        } else if message.imageUrl != "" {
            
            cell.bubbleWidthAncher?.constant = 200
            cell.textView.isHidden = true
            
        } else {
            cell.bubbleWidthAncher?.constant = 50
            cell.textView.isHidden = false
        }
        
        cell.playButton.isHidden = message.videoUrl == ""
        cell.setNeedsDisplay()
        return cell
        
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        let profileImageUrl = self.chatUser?.profilePictureURL
        if profileImageUrl != "" {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl!)
        } else {
            cell.profileImageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = StyleGuideManager.crytpTweetsDefaultColor
            
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAncher?.isActive = true
            cell.bubbleViewLeftAncher?.isActive = false
            cell.timeLabel.textAlignment = .right
        } else {
            cell.bubbleView.backgroundColor = UIColor.lightGray
            
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAncher?.isActive = false
            cell.bubbleViewLeftAncher?.isActive = true
            cell.timeLabel.textAlignment = .left
        }
        
        if let messageImageUrl = message.imageUrl {
            
            if messageImageUrl != "" {
                cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
                cell.messageImageView.isHidden = false
                cell.bubbleView.backgroundColor = UIColor.clear

            } else {
                cell.messageImageView.isHidden = true
            }
        }
    }
    
    private func setBubbleViewCorner(bubbleView: UIView) {
        let path = UIBezierPath(roundedRect: bubbleView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight, .topLeft], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.path  = path.cgPath
        bubbleView.layer.mask = maskLayer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 60
        
        let message = messages[indexPath.item]
        
        if message.text != "" {
            
            height = estimateFrameForText(text: message.text!).height + 35
            
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            if imageWidth != 0 {
                height = CGFloat(imageHeight / imageWidth * 200)
            }
            
            
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
        
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200 - 45, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
}

//MARK: inputTextField delegate
extension OneToOneChatController: InputTextFieldDelegate {
    func inputTextFieldDidChanged(textField: UITextField) {
        
        if (textField.text?.isEmpty)! {
            inputContainerView.sendButton.isUserInteractionEnabled = false
        } else {
            inputContainerView.sendButton.isUserInteractionEnabled = true
        }
        
    }
}

//MARK: - Setup
extension OneToOneChatController {
    
    fileprivate func setup() {
        setupBackground()
        setupNavBar()
        
        inputContainerView.inputTextFieldDelegate = self
    }
    
    fileprivate func setupBackground() {
        
        view.backgroundColor = .white
    }
    
    fileprivate func setupNavBar() {
        
        self.navigationController?.isNavigationBarHidden = false
        let image = UIImage(named: AssetName.close.rawValue)?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissController))
        
        navigationController?.navigationBar.barTintColor = StyleGuideManager.crytpTweetsBarTintColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
}

//MARK: - fetchData
extension OneToOneChatController {
    
    fileprivate func fetchData() {
        observeMessages()
    }
    
    fileprivate func observeMessages() {
        
        self.messages.removeAll()
        
        guard let uid = Auth.auth().currentUser?.uid, let toId = chatUser?.userId else {
            return
        }
        
        
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        let messageQuery = userMessagesRef.queryLimited(toLast: 25)
        
        messageQuery.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                self.messages.append(Message(dictionary: dictionary))
                
                DispatchQueue.main.async {
                    print("collectionView reloaddata")
                    self.collectionView?.reloadData()
                    
                    //scroll to the last index
                    
                    let indexpath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexpath, at: .bottom, animated: true)
                    
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
}

//MARK: - handleChat
extension OneToOneChatController {
    
    func handleSend() {
        
        let properties = ["text": inputContainerView.inputTextField.text!,
            "imageUrl": "", "imageWidth": 0, "imageHeight": 0, "videoUrl": ""] as [String : AnyObject]
        print("chat", properties)
        sendMessageWithProperties(properties: properties)
        
        
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        
        let properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height, "videoUrl": "", "text": ""] as [String : AnyObject]
        
        sendMessageWithProperties(properties: properties)
        
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = chatUser!.userId
        
        let fromId = Auth.auth().currentUser!.uid
        
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        
        var values = ["toId": toId!, "fromId": fromId, "timestamp": timestamp] as [String : AnyObject]
        properties.forEach({values[$0] = $1})
        
        
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            self.inputContainerView.sendButton.isUserInteractionEnabled = false
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId!)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId!).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
            
        }
    }
    
    
    func handleUploadTap() {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL{
            
            
            //we selected video
            
            handleVideoSelectedForUrl(url: videoUrl as URL)
            
            
        } else {
            
            //we selected an image
            handleImageSelectedForInfo(info: info as [String : AnyObject])
            
        }
        
        
        dismiss(animated: true, completion: nil)
        
    }
    private func handleVideoSelectedForUrl(url: URL) {
        
        let filename = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("Failed upload of video!", error!)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                if let thumbmailImage = self.thumbmailImageForFileUrl(fileUrl: url) {
                    
                    self.uploadToFirebaseStorageUsingImage(image: thumbmailImage, completiion: { (imageUrl) in
                        
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbmailImage.size.width as AnyObject, "imageHeight": thumbmailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject, "text": "" as AnyObject]
                        
                        self.sendMessageWithProperties(properties: properties)
                        
                    })
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            
            if let completeUniCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completeUniCount)
            }
            
        }
        uploadTask.observe(.success) { (snapshot) in
            
            self.navigationItem.title = self.chatUser?.username
            
        }
        
        
    }
    
    private func thumbmailImageForFileUrl(fileUrl: URL) -> UIImage? {
        
        
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbmailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbmailCGImage)
            
        } catch let err {
            print(err)
        }
        
        
        return nil
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
            if selectedImage.size.width > 800 {
                image = selectedImage.resized(toWidth: 800.0)!
                
            }
            uploadToFirebaseStorageUsingImage(image: image, completiion: { (imageUrl) in
                
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
            })
        }
        
        
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completiion: @escaping (_ imageUrl: String) -> ()) {
        
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
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

//MARK: - handleImage, Video
extension OneToOneChatController {
    
    
    
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
                self.inputContainerView.alpha = 0
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
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
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed) in
                
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                
            })
        }
    }
}














