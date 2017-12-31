//
//  ChartController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import  UserNotifications
import UserNotificationsUI //framework to customize the notification
import KRProgressHUD
import Firebase

enum TableViewStatus {
    case detail
    case name
}

class ChartController: UIViewController {
    
    
    
    var currentTableView = TableViewStatus.detail
    let cellId = "cellId"
    let requestIdentifier = "SampleRequest" //identifier is to cancel the notification request
    
    var chartTableViewConstraint: NSLayoutConstraint?
    var chartNameTableViewConstraintWithView: NSLayoutConstraint?
    var chartNameTableViewConatraintWitTopLayoutGuide: NSLayoutConstraint?
    
    var updatingChartTimer = Timer()
    
    
    
    var chartCoinLists = [ChartCoin]()
    var trendingCoinLists = [ChartCoin]()
    var tableCharts = [ChartCoin]()
    var savedCoinLists = [ChartCoin]()
    
    var savedCoinCount = 0

    
    lazy var segmentControll: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Coinlist", "Trending"])
        segment.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        segment.tintColor = .white
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(handleSegementControl), for: .valueChanged)
        return segment
    }()
    
    lazy var chartTableView: UITableView = {
        
        var tableView = UITableView();
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KRProgressHUD.set(style: .black)
        KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
        KRProgressHUD.show()
        setupViewes()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.chartController = self
        }
        
    }
    
    var count = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBarBackground()
        fetchChartData()
        handleTimer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTimerInvalidate), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleObserverAndTimer), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @objc private func handleTimerInvalidate() {
        print("remove timer")
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        updatingChartTimer.invalidate()
    }
    
    @objc private func handleObserverAndTimer() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTimerInvalidate), name: .UIApplicationDidEnterBackground, object: nil)
        handleTimer()
    }
    
    @objc private func handleTimer() {
        print("restart timer")
        updatingChartTimer.invalidate()
        updatingChartTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(fetchChartData), userInfo: nil, repeats: true)
    }
}

//MARK: fetch chart data

extension ChartController {
    
    @objc fileprivate func fetchChartData() {
        
        API?.getChartsList(withUrl: CoinMarketCapService.Ticker.rawValue, completionHandler: { (responseArr) in
            
            self.parseResponseWith(responseArr: responseArr!)
            
        }, errorHandler: { (error) in
            KRProgressHUD.dismiss()
            print(error!)
        })
    }

    private func parseResponseWith(responseArr: [Any]) {
        
        
        
        savedCoinCount += 1
        self.chartCoinLists.removeAll()
        for json in responseArr {
            
            let chartCoin = ChartCoin(dictionary: json as! [String: AnyObject])
            chartCoin.h24_volume_usd = (json as! [String: AnyObject])["24h_volume_usd"] as? String
            
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.notifyAlarmWith(chart: chartCoin)
            }
            
            self.chartCoinLists.append(chartCoin)
        }
        DispatchQueue.main.async {
            if self.savedCoinCount == 1 {
                self.savedCoinLists = self.chartCoinLists
            }
            
            
            self.switchChartsTableDataSource()
            self.chartTableView.reloadData()
            
            KRProgressHUD.dismiss()
        }
    }
    
    fileprivate func fetchTrendingCoinLists() {
        
        self.trendingCoinLists.removeAll()
        
        for chartCoin in self.savedCoinLists {
            let childPost = chartCoin.symbol
            let postRef = Database.database().reference().child("posts").child(childPost!)
            postRef.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let post = Post(dictionary: dictionary)
                
                if let isBlock = post.isBlock {
                    if isBlock == "false" {
                        
                        let postedDay = returnDayWithDateformatter(date: post.timestamp as! Double)
                        if postedDay < 7 {
                            
                            if postedDay == 1 {
                                
                                self.trendingCoinLists.append(chartCoin)
                                
                            }
                        }

                        
                        
                    }
                }
                
            }, withCancel: nil)
        }
        
    }
    
    fileprivate func switchChartsTableDataSource() {
        
        self.tableCharts.removeAll()
        if self.segmentControll.selectedSegmentIndex == 0 {
            self.tableCharts = self.chartCoinLists
        } else {
            self.tableCharts = self.trendingCoinLists
        }
        
    }
    
    private func notifyAlarmWith(chart: ChartCoin) {
        
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
}

//MARK: handle goingto detail controller from search
extension ChartController {
    
    func goingToChartDetailControllerFromSearch(coinName: String) {
        
        for coin in self.chartCoinLists {
            
            if coinName == coin.name {
                let chartDetailController = ChartDetailController()
                
                chartDetailController.chartCoin = coin
                
                
                self.navigationController?.pushViewController(chartDetailController, animated: true)
                return
            }
            
        }
        
        
    }
    
}

//MARK: handle tableview delegate

extension ChartController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return self.tableCharts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChartCell
        
        cell.chart = tableCharts[indexPath.row]
        
        
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chartDetailController = ChartDetailController()
        
        chartDetailController.chartCoin = self.tableCharts[indexPath.row]
        
        
        self.navigationController?.pushViewController(chartDetailController, animated: true)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == chartTableView {
            return 75
        } else {
            return 55
        
        }
        
        
        
    }
    
}

//MARK: handle segementControll(watchlist and trending)

extension ChartController {
    
    @objc fileprivate func handleSegementControl() {
        print("selected:", segmentControll.selectedSegmentIndex)
        
        if segmentControll.selectedSegmentIndex == 0 {
            self.switchChartsTableDataSource()
            
            chartTableView.reloadData()
        } else {
            KRProgressHUD.set(style: .black)
            KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
            KRProgressHUD.show()
            
            self.fetchTrendingCoinLists()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                
                self.switchChartsTableDataSource()
                self.chartTableView.reloadData()
                KRProgressHUD.dismiss()
            })
        }
        
    }
}

//MARK: setup views

extension ChartController {
    fileprivate func setupViewes() {
        setupChartTableView()
    }
    
    private func setupChartTableView() {
        view.addSubview(chartTableView)
        
        chartTableView.register(ChartCell.self, forCellReuseIdentifier: cellId)
        
        chartTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chartTableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        chartTableViewConstraint =  chartTableView.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor, constant: 0)
        chartTableViewConstraint?.isActive = true
        chartTableView.bottomAnchor.constraint(equalTo:view.bottomAnchor, constant: -40).isActive = true
    }

    
    fileprivate func setupNavBarBackground() {
        
        self.tabBarController?.navigationItem.titleView = self.segmentControll
        
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        let image = UIImage(named: AssetName.search.rawValue)?.withRenderingMode(.alwaysOriginal)
        let searchButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleSearchController))
        self.tabBarController?.navigationItem.leftBarButtonItem = searchButton
    }
}

//MARK: handle serch controller 

extension ChartController {
    @objc fileprivate func handleSearchController() {
        let searchController = SearchController()
        searchController.chartController = self
        let navController = UINavigationController(rootViewController: searchController)
        
        self.present(navController, animated: true, completion: nil)
    }
}

//MARK: handle local notification

extension ChartController {
    
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
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 19.0, repeats: false)
        
        let request = UNNotificationRequest(identifier:coinName, content: content, trigger: trigger)
        
        
//        UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current().add(request){(error) in
//            
//            if (error != nil){
//                
//                print(error!.localizedDescription)
//            }
//        }

        
    }
    
    func stopLocalNotification(requestId: String) {
        print("Removed all pending notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestId])
    }

}

////MARK: handle local notification delegate
//
//extension ChartController:UNUserNotificationCenterDelegate{
//    
//    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        
//        print("Tapped in notification")
//        
//        for alarmSet in Global.alarmLists {
//            if response.notification.request.identifier == alarmSet.btnName {
//                
//                print("alarm switch reset")
//                alarmSet.isOn = false
//                let userDefaults = UserDefaults.standard
//                userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: Global.alarmLists), forKey: "ALARM_LISTS")
//                userDefaults.synchronize()
//                
////                self.stopLocalNotification(requestId: alarmSet.btnName!)
//            }
//        }
//        
//        
//    }
//    
//    //This is key callback to present notification while the app is in foreground
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        
//        print("Notification being triggered")
//        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
//        //to distinguish between notifications
//        
//        for alarmSet in Global.alarmLists {
//            
//            if notification.request.identifier == alarmSet.btnName {
//                
//                completionHandler( [.alert,.sound,.badge])
//                
//            }
//        }
//    }
//}


