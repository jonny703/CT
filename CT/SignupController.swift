//
//  SignupController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class SignupController: UIViewController {
    
    
    //MARK: set UI
    
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
        textField.keyboardType = .emailAddress
        textField.borderColor = .lightGray
        return textField
        
    }()
    
    let usernameTextField: ToplessTextField = {
        
        let textField = ToplessTextField()
        textField.placeholder = "Username"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .lightGray
        return textField
        
    }()
    
    let passwordTextField: ToplessTextField = {
        
        let textField = ToplessTextField()
        textField.placeholder = "Password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .lightGray
        textField.isSecureTextEntry = true
        return textField
        
    }()
    
    lazy var signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN UP", for: .normal)
        button.backgroundColor = UIColor(r: 1, g: 128, b: 255, a: 0.6)
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        
    }
}

//MARK handle signup

extension SignupController {
    func handleSignup() {
        
        KRProgressHUD.set(style: .black)
        KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
        KRProgressHUD.show()
        
        
        if !(checkInvalid()) {
            KRProgressHUD.dismiss()
            return
        }
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let fullname = nameTextField.text, let username = usernameTextField.text  else {
            
            showAlertMessage(vc: self, titleStr: "Invalid email & password!", messageStr: "Write correct information")
            
            print("Form is not invalid")
            KRProgressHUD.dismiss()
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                showAlertMessage(vc: self, titleStr: "Fail!", messageStr: "Write correct information")
                
                print(error!)
                KRProgressHUD.dismiss()
                
                return
            } else {
                
                guard let uid = user?.uid else {
                    return
                }
                
                //successfluly authenticated user
                //member since date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy"
                let memberSinceDate = Date()
                let memberSinceDateString = dateFormatter.string(from: memberSinceDate)
                let memberSinceString = "Member since \(memberSinceDateString)"
                
                let values = ["username": username, "email": email, "fullname": fullname, "profilePictureURL": "", "location": "", "bio": "", "memberSince": memberSinceString]
                
                self.registerUserIntoDatabaseWithUid(uid: uid, values: values as [String : AnyObject])
                
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUid(uid: String, values: [String: AnyObject]) {
        
        let ref = Database.database().reference()
        let userReference = ref.child("users").child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                KRProgressHUD.dismiss()
                showAlertMessage(vc: self, titleStr: "Something went wrong!", messageStr: "Try again later")
                return
            }
            KRProgressHUD.dismiss()
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                
                
                self.showErrorAlert("Success!", message: "Please check your email", action: { (action) in
                    self.navigationController?.popViewController(animated: true)
                }, completion: nil)
                
                
            })

            
            
        })
    }
}

//MARK: check invalid

extension SignupController {
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
        
        if (passwordTextField.text?.isEmpty)! {
            showAlertMessage(vc: self, titleStr: "Write Password!", messageStr: "t.ex: Belle@703")
            return false
        }
        return true
    }

}


//MARK: Setup views

extension SignupController {
    
    fileprivate func setupViews() {
        setupNavigationBarAndBackground()
        setupTextFields()
        setupButtons()
    }
    
    private func setupTextFields() {
        
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        
        nameTextField.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameTextField.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        
        emailTextField.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 0).isActive = true
        
        usernameTextField.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        usernameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 0).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 0).isActive = true
        
    }
    
    private func setupButtons() {
        view.addSubview(signupButton)
        
        signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signupButton.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        signupButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        signupButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
    }
    
    private func setupNavigationBarAndBackground() {
        
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Sign Up"
        navigationController?.navigationBar.barTintColor = StyleGuideManager.crytpTweetsBarTintColor
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        view.backgroundColor = .white
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissController))
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func dismissController() {
        self.navigationController?.popViewController(animated: true)
    }
    
}


