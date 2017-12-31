//
//  AppDelegate.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import  UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var chartController: ChartController?

    var window: UIWindow?
    var repeatTimerForBackground = Timer()
    var updatingChartTimer = Timer()
    var count = 0
    
//    var orientationLock = UIInterfaceOrientationMask.portrait


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        
        
        handleNotification()
        
        let key = isKeyPresentInUserDefaults(key: "ALARM_LISTS")
        
        if key == true {
            Global.alarmLists = NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.object(forKey: "ALARM_LISTS") as! Data)) as! [AlarmSet]
        }
        
        let values: [String: Any] = ["btnName": "Bitcoin", "isOn": true, "content": "Price$"]
        let alarmSet = AlarmSet(json: values as NSDictionary)
        Global.alarmLists.append(alarmSet)
        
        
        let watchListKey = isKeyPresentInUserDefaults(key: "WATCH_LIST")
        
        if watchListKey == true {
            Global.watchLists = UserDefaults.standard.array(forKey: "WATCH_LIST") as! [String]
        }
        
        FirebaseApp.configure()
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let homeTabBarController = HomeTabBarController()
        let navigationController = UINavigationController(rootViewController: homeTabBarController)
        
        window?.rootViewController = navigationController
        
        navigationController.navigationBar.barTintColor = StyleGuideManager.crytpTweetsBarTintColor
        
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        return true
    }
    
    
    
    
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return self.orientationLock
//    }
    
    
    var fetchStart: Date?
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("fetch background")
        
        fetchStart = Date()
        
        fetchChartData(completionHandler: completionHandler)
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("enter background")
//        handleRepeatTimerForeBakground()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("enter forground")
        
        updatingChartTimer.invalidate()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    fileprivate func handleNotification() {
        
        //Requesting Authorization for User Interactions
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
    }
    
    
}


//MARK: handle local notification

extension AppDelegate {
    
    fileprivate func fetchChartData(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        API?.getChartsList(withUrl: CoinMarketCapService.Ticker.rawValue, completionHandler: { (responseArr) in
            
            self.parseResponseWith(responseArr: responseArr!, completionHandler: completionHandler)
            
        }, errorHandler: { (error) in
            print("api error", error!)
            
            let fetchEnd = Date()
            let timeInterval = fetchEnd.timeIntervalSince(self.fetchStart!)
            print("backgroundfetchfail: ", timeInterval)
            
            
            completionHandler(UIBackgroundFetchResult.failed)
        })
    }
    
    private func parseResponseWith(responseArr: [Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        
        for json in responseArr {
            
            let chartCoin = ChartCoin(dictionary: json as! [String: AnyObject])
            chartCoin.h24_volume_usd = (json as! [String: AnyObject])["24h_volume_usd"] as? String
            
            print(chartCoin.name!)
            
            self.notifyAlarmWith(chart: chartCoin)
        }
        
        if responseArr.count > 0 {
            let fetchEnd = Date()
            let timeInterval = fetchEnd.timeIntervalSince(self.fetchStart!)
            print("backgroundfetchsuccess: ", timeInterval)
            completionHandler(UIBackgroundFetchResult.newData)
        } else {
            let fetchEnd = Date()
            let timeInterval = fetchEnd.timeIntervalSince(self.fetchStart!)
            print("backgroundfetchNodata: ", timeInterval)
            completionHandler(UIBackgroundFetchResult.noData)
        }
    }
    
    func notifyAlarmWith(chart: ChartCoin) {
        
        let nonConsumablePurchaseMade = defaults.bool(forKey: "nonConsumablePurchaseMade")
        
        if nonConsumablePurchaseMade == true {
            for alarmSet in Global.alarmLists {
                
                if alarmSet.btnName == chart.name {
                    
                    if alarmSet.isOn == true {
                        
                        if alarmSet.content == "Volume" {
                            if let max = alarmSet.max, let baseVolume = Double(chart.h24_volume_usd!) {
                                
                                if baseVolume > max {
                                    handleLocalNotificationWith(coinName: alarmSet.btnName!, volume: chart.h24_volume_usd!, type: "max", alarmType: "Base Volume")
                                }
                                
                            }
                            
                            if let min = alarmSet.min, let baseVolume = Double(chart.h24_volume_usd!) {
                                if baseVolume < min {
                                    handleLocalNotificationWith(coinName: alarmSet.btnName!, volume: chart.h24_volume_usd!, type: "min", alarmType: "Base Volume")
                                }
                            }
                            
                        } else {
                            
                            if let max = alarmSet.max, let baseVolume = Double(chart.price_usd!) {
                                
                                if baseVolume > max {
                                    handleLocalNotificationWith(coinName: alarmSet.btnName!, volume: chart.price_usd!, type: "max", alarmType: "Price")
                                }
                                
                            }
                            
                            if let min = alarmSet.min, let baseVolume = Double(chart.price_usd!) {
                                if baseVolume < min {
                                    handleLocalNotificationWith(coinName: alarmSet.btnName!, volume: chart.price_usd!, type: "min", alarmType: "price")
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }


    
    func handleLocalNotificationWith(coinName: String, volume: String, type: String, alarmType: String) {
        
        let content = UNMutableNotificationContent()
        content.title = "CoinVerse Notification"
        
        if type == "max" {
            content.subtitle = coinName + "'s " + alarmType + " is going up"
            content.body = "MAX: " + volume
        } else {
            content.subtitle = coinName + "'s " + alarmType + " is going down"
            content.body = "MIN: " + volume
        }
        
        content.sound = UNNotificationSound.default()
        
        //To Present image in notification
        if let path = Bundle.main.path(forResource: "iTunesArtwork", ofType: "png") {
            let url = URL(fileURLWithPath: path)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: coinName, url: url, options: nil)
                content.attachments = [attachment]
            } catch {
                print("attachment not found.")
            }
        }
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5.0, repeats: false)
        
        let request = UNNotificationRequest(identifier:coinName, content: content, trigger: trigger)
        
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            
            if (error != nil){
                
                print(error!.localizedDescription)
            }
        }
        
        
    }
    
    func stopLocalNotification(requestId: String) {
        print("Removed all pending notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestId])
    }
    
}

//MARK: handle local notification delegate

extension AppDelegate: UNUserNotificationCenterDelegate{
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
        
        for alarmSet in Global.alarmLists {
            if response.notification.request.identifier == alarmSet.btnName {
                
                print("alarm switch reset")
                alarmSet.isOn = false
                let userDefaults = UserDefaults.standard
                userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: Global.alarmLists), forKey: "ALARM_LISTS")
                userDefaults.synchronize()
                
                self.stopLocalNotification(requestId: alarmSet.btnName!)
            }
        }
        
        
    }
    
    
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        
        for alarmSet in Global.alarmLists {
            
            if notification.request.identifier == alarmSet.btnName {
                
                completionHandler( [.alert,.sound,.badge])
                
            }
        }
    }
}


