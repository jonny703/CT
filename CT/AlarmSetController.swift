//
//  AlarmSetController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

enum AlarmControllerStatus {
    case New
    case Update
}

enum AlarmContentStatus {
    case voulme
    case price
}

class AlarmSetController: UIViewController {
    
    var coinsArr = [String]()
    var selectedCoin: String?
    var isSelectedCoin:Bool = false
    var currentAlarmSet: AlarmSet?
    var currentControllerStatus = AlarmControllerStatus.New
    var currnetContentStatus = AlarmContentStatus.voulme
    var currentAlarmListIndex: Int?
    
    
    lazy var btnSelectField: HADropDown = {
        let field = HADropDown()
        field.title = "Select Coin Name"
        
        field.titleColor = .lightGray
        
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 2
        field.items = ["cat", "mouse"]
        field.isUserInteractionEnabled = true
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
        
    }()
    
    let maxTextField: ToplessTextField = {
        
        let textField = ToplessTextField()
        textField.placeholder = "MAX:"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .lightGray
        textField.keyboardType = .decimalPad
        return textField
        
    }()

    let minTextField: ToplessTextField = {
        
        let textField = ToplessTextField()
        textField.placeholder = "MIN:"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .lightGray
        textField.keyboardType = .decimalPad
        return textField
        
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        fetchAlarmSetData()
    }

}

//MARK: fetch alarmset data 

extension AlarmSetController {
    
    fileprivate func fetchAlarmSetData() {
        
        if self.currentControllerStatus == .Update {
            self.btnSelectField.title = (self.currentAlarmSet?.btnName)!
            self.btnSelectField.titleColor = .black
            self.selectedCoin = self.currentAlarmSet?.btnName!
            isSelectedCoin = true
            
            if let max = self.currentAlarmSet?.max {
                self.maxTextField.text = String(max)
            }
            
            if let min = self.currentAlarmSet?.min {
                self.minTextField.text = String(min)
            }
        }
        
    }
    
}

//MARK: handle Hadropdown delegate

extension AlarmSetController: HADropDownDelegate {
    
    func didSelectItem(dropDown: HADropDown, at index: Int) {
        
        self.selectedCoin = coinsArr[index]
        isSelectedCoin = true
        self.btnSelectField.titleColor = .black
    }

    
}

//MARK: check invalid

extension AlarmSetController {
    fileprivate func checkInvalid() -> Bool {
        if (isSelectedCoin == false) {
            showAlertMessage(vc: self, titleStr: "Please select coin!", messageStr: "")
            return false
        }
        
        if (maxTextField.text?.isEmpty)! && (minTextField.text?.isEmpty)! {
            showAlertMessage(vc: self, titleStr: "Please type MAX or MIN amount!", messageStr: "")
            return false
        }
        return true
    }
    
}



//MARK: handle dismiss controller, save alarm

extension AlarmSetController {
    
    func handleDismiss() {
        
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func handleSaveAlarm() {
        
        if !(checkInvalid()) {
            return
        }
        
        var content = "Volume"
        if self.currnetContentStatus == .price {
            content = "Price($)"
        }
        
        var values: [String: Any] = ["btnName": self.selectedCoin!, "isOn": true, "content": content]
        if !(self.maxTextField.text?.isEmpty)! {
            
            values = ["btnName": self.selectedCoin!, "max": Double(self.maxTextField.text!)!, "isOn": true, "content": content]
            
            if !(self.minTextField.text?.isEmpty)! {
                values = ["btnName": self.selectedCoin!, "max": Double(self.maxTextField.text!)!, "min": Double(self.minTextField.text!)!, "isOn": true, "content": content]
            }
        } else if !(self.minTextField.text?.isEmpty)! {
            values = ["btnName": self.selectedCoin!, "min": Double(self.minTextField.text!)!, "isOn": true, "content": content]
        }
        
        let alarmSet = AlarmSet(json: values as NSDictionary)
        
        if self.currentControllerStatus == .New {
            Global.alarmLists.append(alarmSet)
        } else {
            Global.alarmLists[currentAlarmListIndex!] = alarmSet
        }
        
        
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: Global.alarmLists), forKey: "ALARM_LISTS")
        userDefaults.synchronize()
        
        handleDismiss()
        
    }
    
}

//MARK: handle views

extension AlarmSetController {
    
    fileprivate func setupViews() {
        setupBackground()
        setupNavBar()
        setupBtnSelectedField()
        setupTextFields()
    }
    
    private func setupBtnSelectedField() {
        
        view.addSubview(btnSelectField)
        
        btnSelectField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnSelectField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        btnSelectField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnSelectField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        
        fetchCoinsArr()
        
    }
    
    private func fetchCoinsArr() {
        
        for coin in Global.coinsArray {
            
            coinsArr.append(coin[1])
            
        }
        
        btnSelectField.items = coinsArr
    }
    
    private func setupTextFields() {
        
        view.addSubview(maxTextField)
        view.addSubview(minTextField)
        
        maxTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        maxTextField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        maxTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        maxTextField.topAnchor.constraint(equalTo: btnSelectField.bottomAnchor, constant: 0).isActive = true
        
        minTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        minTextField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        minTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        minTextField.topAnchor.constraint(equalTo: maxTextField.bottomAnchor, constant: 0).isActive = true
    }
    
    
    
    fileprivate func setupBackground() {
        
        view.backgroundColor = .white
    }
    
    fileprivate func setupNavBar() {
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationItem.title = "Add Alarm"
        
        let dismissButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleDismiss))
        dismissButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = dismissButton
        
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSaveAlarm))
        saveButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = saveButton
        navigationController?.navigationBar.barTintColor = StyleGuideManager.crytpTweetsBarTintColor
        //
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}
