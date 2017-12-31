//
//  CreatePostController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class CreatePostController: UIViewController {
    
    var streamControllerDelegate: StreamControllerDelegate?
    var chartDetailControllerDelegate: ChartDetailControllerDelegate?
    
    var selectedControllerStatus: StreamControllerStatus = .Following
    var postChildName: String?
    
    fileprivate var isSelectedPhoto = false
    
    fileprivate let PlaceHolderText = "Write your post here..."
    fileprivate var postImageViewConstraint: NSLayoutConstraint?
    
    //MARK set UI
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let postTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.layer.cornerRadius = 6
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var inputContainerView: ChatInputContainerView = {
        
        let chatInputContainerview = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        chatInputContainerview.containerView.isHidden = true
        chatInputContainerview.seperatorLineView.isHidden = true
        chatInputContainerview.createPostController = self
        
        return chatInputContainerview
        
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupNavBar()
        setupViews()
        
        fetchUserProfile()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override var inputAccessoryView: UIView? {
        
        get {
            return inputContainerView
        }
        
    }
    
    override var canBecomeFirstResponder: Bool {
        
        return true
        
    }

}


//MARK: fetch user profile

extension CreatePostController {
    
    fileprivate func fetchUserProfile() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("users").child(uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let profileImageUrl = dictionary["profilePictureURL"] as? String
                if profileImageUrl != "" {
                    
                    self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl!)
                }
            }
        }, withCancel: nil)
        
        
    }
    
}



//MARK: handle top tab bar 

extension CreatePostController {
    
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


//MARK: handle post and dismiss controller

extension CreatePostController {
    
    func handlePost() {
        KRProgressHUD.set(style: .black)
        KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
        KRProgressHUD.show()
        
        if isSelectedPhoto == true {
            handlePostImage()
        } else {
            
            if postTextView.text == PlaceHolderText {
                KRProgressHUD.dismiss()
                showAlertMessage(vc: self, titleStr: "Oops! Can't post", messageStr: "Please fill out content")
                
                return
            }
            
            let properties = ["text": postTextView.text!,
                "imageUrl": "", "imageWidth": 0, "imageHeight": 0, "isBlock": "false"] as [String : AnyObject]
            
            sendMessageWithProperties(properties: properties)
        }
    }
    
    fileprivate func handlePostImage() {
        
        if let postImage = postImageView.image {
            var image = postImage
            if postImage.size.width > 600 {
                image = postImage.resized(toWidth: 600.0)!
                
            }
            
            uploadToFirebaseStorageUsingImage(image: image, completiion: { (imageUrl) in
                
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                
            })
            
        }
    }

    private func uploadToFirebaseStorageUsingImage(image: UIImage, completiion: @escaping (_ imageUrl: String) -> ()) {
        
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("post_images").child(imageName)
        
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
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        var properties: [String: AnyObject]
        if postTextView.text == "" || postTextView.text == PlaceHolderText {
            properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height, "text": "", "isBlock": "false"] as [String : AnyObject]
        } else {
            properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height, "text": postTextView.text!, "isBlock": "false"] as [String : AnyObject]
        }
        
        
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        var category = String()
        if self.selectedControllerStatus == .Other {
            
            if let postChildName = self.postChildName {
                category = postChildName
            }
            
        } else {
            category = self.returnTabBarStringWithSelection()
        }
        
        
        
        let baseRef = Database.database().reference()
        let childRef = baseRef.child("all-posts").childByAutoId()
        
        
        
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        
        var values = ["category": category, "postId": childRef.key, "fromId": fromId, "timestamp": timestamp] as [String : AnyObject]
        
        
        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error!)
                KRProgressHUD.dismiss()
                return
            }
            
            baseRef.child("posts").child(category).child(childRef.key).updateChildValues(values)
            
            self.postTextView.text = nil
            
            let userPostsRef = baseRef.child("user-posts").child(fromId)
            
            let postId = childRef.key
            userPostsRef.updateChildValues([postId: 1])
            
            let followersRef = baseRef.child("followers").child(fromId)
            followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let groupKeys = snapshot.children.flatMap { $0 as? DataSnapshot }.map { $0.key }
                
                for child in groupKeys {
                    
                    let followingPostsRef = baseRef.child("following-posts").child(child)
                    followingPostsRef.childByAutoId().updateChildValues(values)
                    
                }
                print("test profile for empty")
                KRProgressHUD.dismiss()
                self.dismiss(animated: true, completion: {
                    
                    if self.selectedControllerStatus == .Other {
                        self.chartDetailControllerDelegate?.reloadDataWhenNewPosted()
                    } else {
                        self.streamControllerDelegate?.reloadDataWhenNewPosted()
                    }
                    
                })
            })
        }
    }
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: uiImagePickerDelegate, handle post Image

extension CreatePostController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    func handleSelectPostImageView() {
        
        let alertController = UIAlertController(title: "What would you like?", message: "", preferredStyle: .actionSheet)
        
        let photoGalleryAction = UIAlertAction(title: "Chose a Picture", style: .default) { (action) in
            
            let picker = UIImagePickerController()
            
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            picker.sourceType = .savedPhotosAlbum
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                
                picker.modalPresentationStyle = .popover
                picker.popoverPresentationController?.delegate = self
                self.present(picker, animated: true, completion: nil)
                
            } else {
                self.present(picker, animated: true, completion: nil)
            }
            
            
        }
        
        let cameraAction = UIAlertAction(title: "Take a Picture", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = .camera
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
                
                
                if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                    
                    picker.modalPresentationStyle = .popover
                    picker.popoverPresentationController?.delegate = self
                    self.present(picker, animated: true, completion: nil)
                    
                } else {
                    self.present(picker, animated: true, completion: nil)
                }
                
                
                
            } else {
                self.noCamera()
            }
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(photoGalleryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            
            alertController.modalPresentationStyle = .popover
            alertController.popoverPresentationController?.delegate = self
            present(alertController, animated: true, completion: nil)
            
            
        } else {
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        
        popoverPresentationController.sourceView = postImageView
        popoverPresentationController.sourceRect = postImageView.bounds
        popoverPresentationController.permittedArrowDirections = .up
    }
    
    
    func noCamera() {
        
        showAlertMessage(vc: self, titleStr: "No Camera", messageStr: "Sorry, this device has no camera")
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImmageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImmageFromPicker = editedImage
            
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImmageFromPicker = originalImage
            
        }
        
        if let selectedImage = selectedImmageFromPicker {
            postImageView.image = selectedImage
            
            postImageViewConstraint?.constant = DEVICE_WIDTH *  0.9 * selectedImage.size.height / selectedImage.size.width
            isSelectedPhoto = true
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
        
    }

    
}


//MARK: textView delegate to use placeholder

extension CreatePostController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = PlaceHolderText
            textView.textColor = UIColor.lightGray
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if range.length == 0 {
            if text == "\n" {
                textView.text = String(format: "%@\n", textView.text)
                return false
            }
        }
        
        
        return true
    }
}

//MARK: setup Background

extension CreatePostController {
    
    fileprivate func setupBackground() {
        
        view.backgroundColor = .white
    }
    
    fileprivate func setupNavBar() {
        
        self.navigationController?.isNavigationBarHidden = false
        
        
        let image = UIImage(named: AssetName.close.rawValue)?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissController))
        let postButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(handlePost))
        postButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = postButton
        
        navigationController?.navigationBar.barTintColor = StyleGuideManager.crytpTweetsBarTintColor
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}


//MARK: setup Views

extension CreatePostController {
    
    fileprivate func setupViews() {
        setupProfileImageView()
        setupPostTextView()
        setupPostImageView()
    }
    
    private func setupProfileImageView() {
        
        view.addSubview(profileImageView)
        
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        
    }
    
    fileprivate func setupPostImageView() {
        view.addSubview(postImageView)
        postImageView.widthAnchor.constraint(equalTo: postTextView.widthAnchor).isActive = true
        postImageView.leftAnchor.constraint(equalTo: postTextView.leftAnchor).isActive = true
        postImageView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 3).isActive = true
        postImageViewConstraint = postImageView.heightAnchor.constraint(equalToConstant: 100)
        postImageViewConstraint?.isActive = true
    }
    
    fileprivate func setupPostTextView() {
        postTextView.delegate = self
        
        view.addSubview(postTextView)
        
        postTextView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 15).isActive = true
        postTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        postTextView.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0).isActive = true
        postTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        postTextView.text = PlaceHolderText
        postTextView.textColor = UIColor.lightGray
    }
    
}


