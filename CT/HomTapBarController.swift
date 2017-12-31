//
//  HomTapBarController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import LXPageViewWithButtonsViewController

class HomeTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupViews()
        setupControllers()
        checkIfUserIsLoggedIn()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
}

//MARK: handle controllers

extension HomeTabBarController {
    
    fileprivate func setupControllers() {
        
        let chartController = ChartController()
        chartController.tabBarItem.title = "Coins"
        chartController.tabBarItem.image = UIImage(named: AssetName.icStream.rawValue)
        let chartNavController = UINavigationController(rootViewController: chartController)
        
        let followingController = StreamController()
        followingController.selectedControllerStatus = .Following
        followingController.title = "Following"
        
        let blogController = StreamController()
        blogController.selectedControllerStatus = .Blog
        blogController.title = "Blog"
        
        let newsController = StreamController()
        newsController.selectedControllerStatus = .News
        newsController.title = "News"
        
        let minersController = StreamController()
        minersController.selectedControllerStatus = .Miners
        minersController.title = "Miners"
        
        let chartsController = StreamController()
        chartsController.selectedControllerStatus = .Charts
        chartsController.title = "Charts"
        
        let analasisController = StreamController()
        analasisController.selectedControllerStatus = .Analysis
        analasisController.title = "Analysis"
        
        let streamPwbController = LXPageViewWithButtonsViewController()
        streamPwbController.viewControllers = [followingController, blogController, newsController, minersController, chartsController, analasisController]
        streamPwbController.buttonsScrollView.backgroundColor = StyleGuideManager.crytpTweetsDefaultColor
        
        streamPwbController.buttonsScrollView.appearance.button.foregroundColor.normal =  UIColor.white
        streamPwbController.buttonsScrollView.appearance.button.foregroundColor.selected =  UIColor(r: 0, g: 128, b: 255, a: 1)
        
        streamPwbController.buttonsScrollView.appearance.button.width = 90

        streamPwbController.buttonsScrollView.appearance.selectionIndicator.color = UIColor(r: 0, g: 128, b: 255, a: 1)
        
        streamPwbController.tabBarItem.title = "Stream"
        streamPwbController.tabBarItem.image = UIImage(named: AssetName.icTvDark.rawValue)
        
        let streamNavController = UINavigationController(rootViewController: streamPwbController)
        
        let messageController = MessagesController()
        messageController.tabBarItem.title = "Chat"
        messageController.tabBarItem.image = UIImage(named: AssetName.icInbox.rawValue)
        
        let messageNavController = UINavigationController(rootViewController: messageController)
        
        let moreController = MoreController()
        moreController.tabBarItem.title = "More"
        moreController.tabBarItem.image = UIImage(named: AssetName.icStreamMore.rawValue)
        
        let moreNavController = UINavigationController(rootViewController: moreController)
        
        let alarmListController = AlarmListController()
        
        let nonConsumablePurchaseMade = defaults.bool(forKey: "nonConsumablePurchaseMade")
        
        if nonConsumablePurchaseMade == false {
            
            alarmListController.tabBarItem.title = "Alarm($0.99)"
            
        } else {
            
            alarmListController.tabBarItem.title = "Alarm"
            
        }
        alarmListController.tabBarItem.image = UIImage(named: AssetName.alarm.rawValue)
        let alarmNavController = UINavigationController(rootViewController: alarmListController)
        
        
        
        viewControllers = [chartController, streamPwbController, messageNavController, moreNavController, alarmNavController]
        self.selectedViewController = chartController
    }
    
}

//MARK: check user log in 

extension HomeTabBarController {
    
    fileprivate func checkIfUserIsLoggedIn() {
        // user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogoff), with: nil, afterDelay: 0)
            
            
            
        } else {
            
            if let user = Auth.auth().currentUser {
                if !user.isEmailVerified {
                    perform(#selector(handleLogoff), with: nil, afterDelay: 0)
                }
            }

        }

    }
    
    @objc fileprivate func handleLogoff() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }

        
        let authController = AuthController()
        
        let naviController = UINavigationController(rootViewController: authController)
        present(naviController, animated: true, completion: nil)
    }
    
}

//MARK: Setup views

extension HomeTabBarController {
    
    fileprivate func setupViews() {
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        
        view.backgroundColor = .white
        
    }
    
}
