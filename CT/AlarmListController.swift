//
//  AlarmListController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import StoreKit
import KRProgressHUD



class AlarmListController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    
    let FIRSTCOINS_PRODUCT_ID = "com.caesar.alarmset"
    
    var productID = ""
    var productRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    
    

    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchAlarmsList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        
        let nonConsumablePurchaseMade = defaults.bool(forKey: "nonConsumablePurchaseMade")
        
        if nonConsumablePurchaseMade == false {
            fetchAvailableProducts()
        }
        
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Global.alarmLists.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        Global.alarmLists.remove(at: indexPath.row)
        let userDefaults = UserDefaults.standard
        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: Global.alarmLists), forKey: "ALARM_LISTS")
        userDefaults.synchronize()
        tableView.reloadData()
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alarmSetController = AlarmSetController()
        alarmSetController.currentControllerStatus = .Update
        alarmSetController.currentAlarmSet = Global.alarmLists[indexPath.row]
        
        if Global.alarmLists[indexPath.row].content == "Volume" {
            alarmSetController.currnetContentStatus = .voulme
        } else {
            alarmSetController.currnetContentStatus = .price
        }
        
        alarmSetController.currentAlarmListIndex = indexPath.row
        self.navigationController?.pushViewController(alarmSetController, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AlarmListCell
        
        let alarmSet = Global.alarmLists[indexPath.row]
        
        setupCell(cell: cell, alarmSet: alarmSet, indexPath: indexPath)
        
        return cell
    }
    
    private func setupCell(cell: AlarmListCell, alarmSet: AlarmSet, indexPath: IndexPath) {
        
        cell.btcNameLabel.text = alarmSet.btnName
        
        if let max = alarmSet.max {
            cell.maxLabel.text = "MAX: " + String(max)
        } else {
            cell.maxLabel.text = "MAX:    -"
        }
        if let min = alarmSet.min {
            cell.minLabel.text = "MIN: " + String(min)
        } else {
            cell.minLabel.text = "MIN:     -"
        }
        
        cell.turnSwitch.isOn = alarmSet.isOn == true ? true : false
        cell.turnSwitch.tag = indexPath.row
        cell.turnSwitch.addTarget(self, action: #selector(turnSwitchTriggered(sender:)), for: .valueChanged)
        cell.contentLabel.text = alarmSet.content
        
    }


}

//MARK: handle turnSwitch value

extension AlarmListController {
    func turnSwitchTriggered(sender: UISwitch) {
        
        let currentTurnSwitch = sender 
        
        if currentTurnSwitch.isOn == true {
            
            Global.alarmLists[currentTurnSwitch.tag].isOn = true
            
        } else {
            Global.alarmLists[currentTurnSwitch.tag].isOn = false
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: Global.alarmLists), forKey: "ALARM_LISTS")
        userDefaults.synchronize()
    }
}

//MARK: fetch alarms list data

extension AlarmListController {
    func fetchAlarmsList() {
        
        
        
    }
    
}

//MARK: handle dismiss controller, add Alarm

extension AlarmListController {
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleAddAlarm() {
        
        
        handleAlarmActionSheet()
    }
    
}

//MARK: handle inapppurchase

extension AlarmListController {
    func fetchAvailableProducts() {
        
        KRProgressHUD.set(style: .black)
        KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
        KRProgressHUD.show()
        
        let productIdentifier = NSSet(objects: FIRSTCOINS_PRODUCT_ID)
        
        productRequest = SKProductsRequest(productIdentifiers: productIdentifier as! Set<String>)
        
        productRequest.delegate = self
        productRequest.start()
        
    }
    
    // Mark: - Restore non-consumable purchase button
    
    func restorePurchase() {
        
        if self.canMakePurchases() {
            
            SKPaymentQueue.default().add(self)
            
            SKPaymentQueue.default().restoreCompletedTransactions()
            
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
            
            KRProgressHUD.dismiss()
            self.showErrorAlertWithOKCancel("You should purchase to use alarm", message: "Do you want to buy it?", action: { (action) in
                self.purchaseMyProduct(product: self.iapProducts[0])
            }, completion: nil)
            
        } else {
            KRProgressHUD.dismiss()
            
            self.showErrorAlert(message: "Can't connect to Apple server, try againg later!")
        }
        
        
        
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
                        
                        self.tabBarItem.title = "Alarm"
                        
                        defaults.set(true, forKey: "nonConsumablePurchaseMade")
                        defaults.synchronize()
                        showAlertMessage(vc: self, titleStr: "CoinVerse", messageStr: "You've successfully purchased Alarm func")
                        self.setupNavBar()
                    }
                    
                    break
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    self.showErrorAlert("Fail!", message: "Try again later", action: nil, completion: nil)
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    self.tableView.reloadData()
                    defaults.set(true, forKey: "nonConsumablePurchaseMade")
                    defaults.synchronize()
                    showAlertMessage(vc: self, titleStr: "CoinVerse", messageStr: "You've successfully restored Alarm func")
                    self.setupNavBar()
                    
                    break
                default:
                    break
                }
            }
            
        }
        
    }
    
    
    
}


//MARK: handle alarm

extension AlarmListController {
    
    fileprivate func handleAlarmActionSheet() {
        
        let alertController = UIAlertController(title: "What would you like?", message: "", preferredStyle: .actionSheet)
        
        let volumeAction = UIAlertAction(title: "Volume", style: .default) { (action) in
            
            let alarmSetController = AlarmSetController()
            alarmSetController.currentControllerStatus = .New
            alarmSetController.currnetContentStatus = .voulme
            let navController = UINavigationController(rootViewController: alarmSetController)
//            self.navigationController?.pushViewController(alarmSetController, animated: true)
            self.present(navController, animated: true, completion: nil)
        }
        
        let priceAction = UIAlertAction(title: "Price", style: .default) { (action) in
            let alarmSetController = AlarmSetController()
            alarmSetController.currentControllerStatus = .New
            alarmSetController.currnetContentStatus = .price
            let navController = UINavigationController(rootViewController: alarmSetController)
//            self.navigationController?.pushViewController(alarmSetController, animated: true)
            self.present(navController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(volumeAction)
        alertController.addAction(priceAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}



//MARK: setup Background

extension AlarmListController {
    
    fileprivate func setupViews() {
        setupBackground()
        
        tableView.register(AlarmListCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    fileprivate func setupBackground() {
        
        view.backgroundColor = .white
        self.tabBarController?.navigationItem.titleView = nil
        
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        
        self.tabBarController?.navigationItem.title = "Alarm"
    }
    
    fileprivate func setupNavBar() {
        
        
        
        
        let nonConsumablePurchaseMade = defaults.bool(forKey: "nonConsumablePurchaseMade")
//        let nonConsumablePurchaseMade = true
        if nonConsumablePurchaseMade == false {
//            self.tabBarController?.navigationItem.rightBarButtonItem = nil
            self.tabBarItem.title = "Alarm($0.99)"
            
        } else {
            
            self.tabBarItem.title = "Alarm"
            
            let addImage = UIImage(named: AssetName.addUser.rawValue)?.withRenderingMode(.alwaysOriginal)
            self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: addImage, style: .plain, target: self, action: #selector(handleAddAlarm))
            
        }

        
        
    }
}

