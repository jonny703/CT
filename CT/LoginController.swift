//
//  LoginController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class LoginController: UIViewController {
    
    
    //MARK: set UI
    
    let emailTextField: ToplessTextField = {
        
        let textField = ToplessTextField()
        textField.placeholder = "Email Address"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .emailAddress
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
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor(r: 1, g: 128, b: 255, a: 0.6)
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Forgot your password?", for: .normal)
        button.tintColor  = UIColor.black
        button.titleLabel?.font = UIFont.systemFont(ofSize: DEVICE_WIDTH * 0.04)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        return button
    }()
    
    let invalidCommandLabel: UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: DEVICE_WIDTH * 0.05)
        label.backgroundColor = UIColor(r: 134, g: 251, b: 236, a: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
        
    }()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    
    
}

//MARK: handle forgot Password 

extension LoginController {
    func handleForgotPassword() {
        
        let alert = UIAlertController(title: "Forgot password?", message: "Type your email", preferredStyle: .alert)
        
        let OkAction = UIAlertAction(title: "Ok!", style: .default) { (action) in
            KRProgressHUD.set(style: .black)
            KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
            KRProgressHUD.show()
            
            let textField = alert.textFields![0]
            textField.placeholder = "1"
            
            if textField.text == "" {
                KRProgressHUD.dismiss()
                
                self.showAlert(warnigString: "Oops! Write youremail")
            } else {
                
                Auth.auth().sendPasswordReset(withEmail: textField.text!, completion: { (error) in
                    
                    if error != nil {
                        KRProgressHUD.dismiss()
                        self.showAlert(warnigString: "Oops! Invalid email")
                    } else {
                        KRProgressHUD.dismiss()
                        self.showAlert(warnigString: "Please check your email")
                    }
                })
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addTextField { (textField: UITextField) in
            
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Email"
            textField.clearButtonMode = .whileEditing
            
        }
        
        alert.addAction(OkAction)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(warnigString: String) {
        
        view.addSubview(invalidCommandLabel)
        
        invalidCommandLabel.text = warnigString
        
        invalidCommandLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        invalidCommandLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        fadeViewInThenOut(view: invalidCommandLabel, delay: 3)
        
    }
    
    func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
        
        let animationDuration = 0.25
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 1
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
                view.alpha = 0
            }, completion: nil)
        }
    }

}

//MARK: handle login

extension LoginController {
    
    func handleLogin() {
        KRProgressHUD.set(style: .black)
        KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
        KRProgressHUD.show()
        
        if !(checkInvalid()) {
            KRProgressHUD.dismiss()
            return
        }
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not invalid")
            KRProgressHUD.dismiss()
            showAlertMessage(vc: self, titleStr: "Invalid email & password!", messageStr: "Write correct information")
            
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error!)
                KRProgressHUD.dismiss()
                showAlertMessage(vc: self, titleStr: "Invalid email & password!", messageStr: "Write correct information")
                return
            }
            if let user = Auth.auth().currentUser {
                

                if !user.isEmailVerified {
                    
                    let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email to \(email).", preferredStyle: .alert)
                    let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                        (_) in
                        user.sendEmailVerification(completion: nil)
                    }
                    let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    
                    alertVC.addAction(alertActionOkay)
                    alertVC.addAction(alertActionCancel)
                    self.present(alertVC, animated: true, completion: nil)
                    KRProgressHUD.dismiss()
                    
                } else {
                    
                    
                    KRProgressHUD.dismiss()
                    self.dismiss(animated: true, completion: { 
                        
                        NotificationCenter.default.post(name: .ReloadCollectionViewDataInStreamController, object: nil)
                        
                        NotificationCenter.default.post(name: .ReloadMessageTableViewData, object: nil)
                    })
                    
                }
            }
        })
        
        
    }
}


//MARK: check invalid

extension LoginController {
    fileprivate func checkInvalid() -> Bool {
        if (emailTextField.text?.isEmpty)! {
            showAlertMessage(vc: self, titleStr: "Write Email!", messageStr: "ex: Anders703@oulook.com")
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

extension LoginController {
    
    fileprivate func setupViews() {
        setupNavigationBarAndBackground()
        setupTextFields()
        setupButtons()
    }
    
    private func setupTextFields() {
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        
        emailTextField.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 0).isActive = true
        
    }

    
    private func setupButtons() {
        view.addSubview(loginButton)
        view.addSubview(forgotPasswordButton)
        
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        
        forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        forgotPasswordButton.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        forgotPasswordButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10).isActive = true
    }
    
    private func setupNavigationBarAndBackground() {
        
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Login"
        view.backgroundColor = .white
        
        navigationController?.navigationBar.barTintColor = StyleGuideManager.crytpTweetsBarTintColor
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissController))
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton

    }
    func dismissController() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

