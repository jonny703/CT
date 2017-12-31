//
//  AgreementController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

enum AgreementStatus {
    case terms
    case policy
}

enum ControllerStatus {
    case authController
    case tabController
}

class AgreementController: UIViewController {
    
    var controllerStatus = ControllerStatus.authController
    var agreementStatus = AgreementStatus.terms
    
    let agreementWebView : UIWebView = {
        let webView = UIWebView()
        
        webView.backgroundColor = .clear
        webView.contentMode = .scaleToFill
        webView.scalesPageToFit = true
        webView.isOpaque = false
        webView.gapBetweenPages = 0
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        handleLoadingWebView()
    }

}

//MARK: handle webview Delegate

extension AgreementController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        for subview: UIView in webView.scrollView.subviews {
            
            print("subview description--", subview.description)
            
            subview.layer.shadowOpacity = 0
            if subview.isKind(of: UIImageView.self) {
                subview.isHidden = true
            }
            for subSubView in subview.subviews {
                
                print("subSubView description--", subSubView.description)
                
                subSubView.layer.shadowOpacity = 0
                if subSubView.isKind(of: UIImageView.self) {
                    subSubView.isHidden = true
                }
            }
            
        }
        
    }
    
    
    
    func getAllSubViewsOfView(v: UIView) -> [UIView] {
        var viewArr = [UIView]()
        for subView in v.subviews {
            viewArr += getAllSubViewsOfView(v: subView)
            viewArr.append(subView)
        }
        return viewArr
    }
    
}

//MARK: handle webview loading

extension AgreementController {
    
    fileprivate func handleLoadingWebView() {
        
        var pdfStr: String?
        
        if agreementStatus == .terms {
            pdfStr = Bundle.main.path(forResource: "termsofservice", ofType: ".pdf")
        } else {
            pdfStr = Bundle.main.path(forResource: "privacypolicy", ofType: ".pdf")
        }
        
        
        
        if let url = URL(string: pdfStr!) {
            
            print("loading pdf")
            let request = URLRequest(url: url)
            self.agreementWebView.loadRequest(request)
        }
    }
    
}

//MARK: Setup views

extension AgreementController {
    
    fileprivate func setupViews() {
        setupNavigationBarAndBackground()
        setupAgreementWebView()
    }
    
    private func setupAgreementWebView() {
        
        view.addSubview(agreementWebView)
        
        agreementWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        agreementWebView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        agreementWebView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        agreementWebView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        
        agreementWebView.delegate = self
    }
    
    private func setupNavigationBarAndBackground() {
        view.backgroundColor = .white
        if self.controllerStatus == .authController {
            navigationController?.isNavigationBarHidden = false
            navigationItem.title = self.agreementStatus == .terms ? "Terms of Service" : "Privacy Policy"
            
            
            navigationController?.navigationBar.barTintColor = UIColor(r: 85, g: 113, b: 153, a: 0.6)
            
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissController))
            backButton.tintColor = .white
            self.navigationItem.leftBarButtonItem = backButton
        } else {
            self.tabBarController?.navigationItem.titleView = nil
            self.tabBarController?.navigationItem.title = self.agreementStatus == .terms ? "Terms of Service" : "Privacy Policy"
            
            let dismissButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissController))
            dismissButton.tintColor = .white
            self.tabBarController?.navigationItem.leftBarButtonItem = dismissButton
        }
        
        
        
    }
    func dismissController() {
        self.navigationController?.popViewController(animated: true)
    }
    
}


