//
//  MoreController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import StoreKit
import KRProgressHUD

class MoreController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    let FIRSTCOINS_PRODUCT_ID = "com.caesar.alarmset"
    
    var productID = ""
    var productRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    
    
    let cellId = "cellId"
    
    var mores = ["My Profile", "Restore Purchase(Alarm)", "Terms of Service", "Privacy Policy",  "Log off"]
    
    //MARK setup UI
    
    lazy var tableView: UITableView = {
        
        var tableView = UITableView();
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarBackground()
        
        
    }
}

//MARK: handle inapppurchase

extension MoreController {
    
    // Mark: - Restore non-consumable purchase button
    
    func restorePurchase() {
        
        if self.canMakePurchases() {
            
            SKPaymentQueue.default().add(self)
            
            SKPaymentQueue.default().restoreCompletedTransactions()
            defaults.set(true, forKey: "nonConsumablePurchaseMade")
            defaults.synchronize()
            showAlertMessage(vc: self, titleStr: "CoinVerse", messageStr: "You've successfully restored Alarm func")
            
        } else {
            
            showAlertMessage(vc: self, titleStr: "CoinVerse", messageStr: "Restore is disabled in your device!")
            
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        
        
    }
    
    // Mark: Request IAP products
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if (response.products.count > 0) {
            iapProducts = response.products
            
            let firstProduct = response.products[0] as SKProduct
            
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = firstProduct.priceLocale
            let price1Str = numberFormatter.string(from: firstProduct.price)
            print(price1Str!)
        }
        
        KRProgressHUD.dismiss()
        
    }
    
    // Mark: Make Purchase of a Product
    
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            productID = product.productIdentifier
            
        } else {
            
            showAlertMessage(vc: self, titleStr: "CoinVerse", messageStr: "Purchase is disabled in your device!")
            
        }
    }
    
    // Mark: IAP Payment queue
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction: AnyObject in transactions {
            
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    
                    
                    if productID == FIRSTCOINS_PRODUCT_ID {
                        
                        mores[1] = "Alarm"
                        self.tableView.reloadData()
                        
                        defaults.set(true, forKey: "nonConsumablePurchaseMade")
                        defaults.synchronize()
                        showAlertMessage(vc: self, titleStr: "CoinVerse", messageStr: "You've successfully purchased Alarm func")
                    }
                    
                    break
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    self.showErrorAlert("Fail!", message: "Try again later", action: nil, completion: nil)
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    defaults.set(true, forKey: "nonConsumablePurchaseMade")
                    defaults.synchronize()
                    showAlertMessage(vc: self, titleStr: "CoinVerse", messageStr: "You've successfully restored Alarm func")
                    
                    break
                default:
                    break
                }
            }
            
        }
        
    }



}


//MARK: handle tableview delegate

extension MoreController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = mores[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 4 {
            handleLogoff()
        } else if indexPath.row == 0 {
            goingToMyProfileController()
        }
        
        else if indexPath.row == 2 {
            let agreementController = AgreementController()
            agreementController.controllerStatus = .tabController
            agreementController.agreementStatus = .terms
            
            navigationController?.pushViewController(agreementController, animated: true)
        } else if indexPath.row == 3 {
            let agreementController = AgreementController()
            agreementController.controllerStatus = .tabController
            agreementController.agreementStatus = .policy
            
            navigationController?.pushViewController(agreementController, animated: true)
        } else if indexPath.row == 1 {
            
            let nonConsumablePurchaseMade = defaults.bool(forKey: "nonConsumablePurchaseMade")
            
            if nonConsumablePurchaseMade == false {
                self.showErrorAlertWithOKCancel("Do you want to restore Alarm?", message: "", action: { (action) in
                    self.restorePurchase()
                }, completion: nil)
                
            } else {
                
                self.showErrorAlert("You have already purchased!", message: "", action: nil, completion: nil)
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
        
    }
    
    
}


//MARK: handle my profile

extension MoreController {
    
    fileprivate func goingToMyProfileController() {
        
        guard let ctUserId = Auth.auth().currentUser?.uid else { return }
        
        let layout = UICollectionViewFlowLayout()
        let profileController = ProfileController(collectionViewLayout: layout)
        profileController.ctUserId = ctUserId
        profileController.profileControllerStatus = .myProfile
        let navController = UINavigationController(rootViewController: profileController)
        
        self.present(navController, animated: true, completion: nil)
        
    }
    
}

//MARK: handle log off

extension MoreController {
    
    @objc fileprivate func handleLogoff() {
        
        self.showErrorAlertWithOKCancel("Are you sure you want to log off?", message: "", action: { (action) in
            do {
                try Auth.auth().signOut()
            } catch let logoutError {
                print(logoutError)
            }
            
            
            let authController = AuthController()
            
            let naviController = UINavigationController(rootViewController: authController)
            self.present(naviController, animated: true, completion: nil)
        }, completion: nil)
        
    }

    
}



//MARK: setup views

extension MoreController {
    fileprivate func setupViewes() {
        
        setupTableView()
        
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo:view.bottomAnchor, constant: -40).isActive = true
        
    }
    
    fileprivate func setupNavBarBackground() {
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.title = "More"
        
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
    }
}
