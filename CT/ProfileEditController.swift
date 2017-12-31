//
//  ProfileEditController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//


import UIKit
import Firebase
import KRProgressHUD

class ProfileEditController: UIViewController {
    
    var profileControllerDelegate: ProfileControllerDelegate?
    
    fileprivate var isSelectedPhoto = false
    
    var ctUser: CTUser? {
        didSet {
            
            fetchUserProfile()
            
        }
    }
    
    let containerProfileImageView: UIView = {
        
        let view = UIView()
        view.backgroundColor = StyleGuideManager.crytpTweetsDefaultColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let nameTextField: ToplessTextField = {
        
        let textField = ToplessTextField()
        textField.placeholder = "Full Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .lightGray
        return textField
        
    }()
    
    let emailTextField: ToplessTextField = {
        
        let textField = ToplessTextField()
        textField.placeholder = "Email Address"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .lightGray
        textField.isUserInteractionEnabled = false
        return textField
        
    }()
    
    let usernameTextField: ToplessTextField = {
        
        let textField = ToplessTextField()
        textField.placeholder = "Username"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .lightGray
        return textField
        
    }()
    
    let bioTextField: ToplessTextField = {
        
        let textField = ToplessTextField()
        textField.placeholder = "Bio"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .lightGray
        return textField
        
    }()
    
    let locationTextField: ToplessTextField = {
        
        let textField = ToplessTextField()
        textField.placeholder = "Location"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .lightGray
        return textField
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
//        fetchUserProfile()
    }
    
}

//MARK: fetch user profile

extension ProfileEditController {
    
    fileprivate func fetchUserProfile() {
        
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
//        let ref = Database.database().reference().child("users").child(uid)
//        
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                
//                self.usernameTextField.text = dictionary["username"] as? String
//                self.nameTextField.text = dictionary["fullname"] as? String
//                self.emailTextField.text = dictionary["email"] as? String
//                
//                if let location = dictionary["location"] as? String {
//                    
//                    self.locationTextField.text = location
//                }
//                
//                if let bio = dictionary["bio"] as? String {
//                    
//                    self.bioTextField.text = bio
//                }
//                let profileImageUrl = dictionary["profilePictureURL"] as? String
//                if profileImageUrl != "" {
//                    
//                    self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl!)
//                }
//            }
//        }, withCancel: nil)
        
        if let userName = self.ctUser?.username {
            self.usernameTextField.text = userName
        }
        
        if let fullName = self.ctUser?.fullname {
            self.nameTextField.text = fullName
        }
        
        if let email = self.ctUser?.email {
            self.emailTextField.text = email
        }
        
        if let location = self.ctUser?.location {
            self.locationTextField.text = location
        }
        
        if let bio = self.ctUser?.location {
            self.bioTextField.text = bio
        }
        
        if let profileImageUrl = self.ctUser?.profilePictureURL {
            if profileImageUrl != "" {
                
                self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
        }

    }
    
}

//MARK: handle Photo galary

extension ProfileEditController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    func handleSelectProfileImageView() {
        
        let alertController = UIAlertController(title: "What would you like?", message: "", preferredStyle: .actionSheet)
        
        let photoGalleryAction = UIAlertAction(title: "Chose a Photo", style: .default) { (action) in
            
            let picker = UIImagePickerController()
            
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            picker.sourceType = .savedPhotosAlbum
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                
                picker.modalPresentationStyle = .popover
                picker.popoverPresentationController?.delegate = self
                //                picker.popoverPresentationController?.sourceView = self.view
                self.navigationController?.present(picker, animated: true, completion: nil)
                
            } else {
                self.navigationController?.present(picker, animated: true, completion: nil)
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
                    //                    picker.popoverPresentationController?.sourceView = self.view
                    self.navigationController?.present(picker, animated: true, completion: nil)
                    
                } else {
                    self.navigationController?.present(picker, animated: true, completion: nil)
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
            //            alertController.popoverPresentationController?.sourceView = view
            present(alertController, animated: true, completion: nil)
            
            
        } else {
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        
        popoverPresentationController.sourceView = self.profileImageView
        popoverPresentationController.sourceRect = self.profileImageView.bounds
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
            
            self.profileImageView.image = selectedImage
            isSelectedPhoto = true
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}


//MARK: handle update, dismiss controller

extension ProfileEditController {
    
    func handleUpdate() {
        KRProgressHUD.set(style: .black)
        KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
        KRProgressHUD.show()
        
        
        if !(checkInvalid()) {
            KRProgressHUD.dismiss()
            return
        }
        
        guard let email = emailTextField.text, let fullname = nameTextField.text, let username = usernameTextField.text  else {
            
            showAlertMessage(vc: self, titleStr: "Invalid email & password!", messageStr: "Write correct information")
            KRProgressHUD.dismiss()
            return
        }
        
        var profileImageName = String()
        if let imageName = Auth.auth().currentUser?.uid {
            profileImageName = imageName
        } else {
            profileImageName = NSUUID().uuidString
        }
        
        let storageRef = Storage.storage().reference().child("user_images").child("\(profileImageName)profileImage.jpeg")
        
        if self.isSelectedPhoto == false {
            
            let values = ["username": username, "email": email, "fullname": fullname, "location": self.locationTextField.text == nil ? "" : self.locationTextField.text!, "bio": self.bioTextField.text == nil ? "" : self.bioTextField.text! ]
            
            self.registerUserIntoDatabaseWithUid(values: values as [String : AnyObject])
            
        } else {
            if let profileImageView = self.profileImageView.image {
                
                var image = profileImageView
                if profileImageView.size.width > 350 {
                    image = profileImageView.resized(toWidth: 350.0)!
                    
                }
                if let uploadData = UIImageJPEGRepresentation(image, 0.1) {
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print(error!)
                            KRProgressHUD.dismiss()
                            showAlertMessage(vc: self, titleStr: "Something went wrong!", messageStr: "Try again later")
                            return
                        }
                        if let profilePictureURL = metadata?.downloadURL()?.absoluteString {
                            
                            let values = ["username": username, "email": email, "fullname": fullname, "profilePictureURL": profilePictureURL, "location": self.locationTextField.text == nil ? "" : self.locationTextField.text!, "bio": self.bioTextField.text == nil ? "" : self.bioTextField.text! ]
                            
                            self.registerUserIntoDatabaseWithUid(values: values as [String : AnyObject])
                        }
                    })
                    
                }
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUid(values: [String: AnyObject]) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("users").child(uid)
        ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                KRProgressHUD.dismiss()
                showAlertMessage(vc: self, titleStr: "Something went wrong!", messageStr: "Try again later")
                return
            }
            KRProgressHUD.dismiss()
            
            self.dismiss(animated: true, completion: {
                self.profileControllerDelegate?.resetUserProfile()
            })
            
            
        })
    }
    
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: check invalid

extension ProfileEditController {
    fileprivate func checkInvalid() -> Bool {
        
        if (nameTextField.text?.isEmpty)! {
            showAlertMessage(vc: self, titleStr: "Write Full Name!", messageStr: "ex: Saulius Anders")
            return false
        }
        if (emailTextField.text?.isEmpty)! {
            showAlertMessage(vc: self, titleStr: "Write Email!", messageStr: "ex: Anders703@oulook.com")
            return false
        }
        
        if (usernameTextField.text?.isEmpty)! {
            showAlertMessage(vc: self, titleStr: "Write Username!", messageStr: "ex: Anders703@oulook.com")
            return false
        }
        return true
    }
    
}


//MARK: setup Background

extension ProfileEditController {
    
    fileprivate func setupViews() {
        
        setupBackground()
        setupNavBar()
        setupProfileImageView()
        setupTextFields()
        
    }
    
    private func setupProfileImageView() {
        
        view.addSubview(containerProfileImageView)
        view.addSubview(profileImageView)
        
        containerProfileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerProfileImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerProfileImageView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        containerProfileImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        profileImageView.centerXAnchor.constraint(equalTo: containerProfileImageView.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerProfileImageView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    private func setupTextFields() {
        
        view.addSubview(nameTextField)
        view.addSubview(usernameTextField)
        view.addSubview(emailTextField)
        view.addSubview(locationTextField)
        view.addSubview(bioTextField)
        
        nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        nameTextField.topAnchor.constraint(equalTo: containerProfileImageView.bottomAnchor, constant: 0).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameTextField.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 0).isActive = true
        usernameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 0).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        locationTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationTextField.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        locationTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 0).isActive = true
        locationTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        bioTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bioTextField.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        bioTextField.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 0).isActive = true
        bioTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    fileprivate func setupBackground() {
        
        view.backgroundColor = .white
    }
    
    fileprivate func setupNavBar() {
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Edit Profile"
        
        let image = UIImage(named: AssetName.close.rawValue)?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissController))
        let updateButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleUpdate))
        updateButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = updateButton
        
        navigationController?.navigationBar.barTintColor = StyleGuideManager.crytpTweetsBarTintColor
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}
