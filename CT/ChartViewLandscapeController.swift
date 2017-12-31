//
//  ChartViewLandscapeController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import WBSegmentControl
import KRProgressHUD

enum SegIndex: Int {
    case day = 1
    case week = 7
    case month = 30
    case threeMonth = 90
    case sixMonth = 180
    case year = 365
    
}

class ChartViewLandscapeController: UIViewController, WBSegmentControlDelegate {
    
    var chartHistories = [ChartCoinTradeHistory]()
    
    var chartGraphs = [ChartGraph]()
    var virtualChartGraphs = [ChartGraph]()
    
    var chartCoin: ChartCoin?
    var selectedSegIndex = SegIndex.day.rawValue
    
    var canRequest: Bool = false
    
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = StyleGuideManager.crytpTweetsDefaultColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    let BitcoinNameLabel: UILabel = {
        let label = UILabel()
        label.text = "BTC"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "BTC"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "16.77"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let percentLabel: UILabel = {
        let label = UILabel()
        label.text = "23.5%"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.arrowUp.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    
    let segmentControl: WBSegmentControl = {
        let segment = WBSegmentControl()
        segment.segments = [TextSegment(text: "1D"), TextSegment(text: "1W"), TextSegment(text: "1M"), TextSegment(text: "3M"), TextSegment(text: "6M"), TextSegment(text: "1Y")]
        segment.backgroundColor = StyleGuideManager.crytpTweetsDefaultColor
        segment.style = .cover
        segment.selectedIndex = 0
        segment.segmentTextFontSize = 20.0
        segment.segmentForegroundColor = .white
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    let chartView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    
    }()
    
    let nothingLabel: UILabel = {
        let label = UILabel()
        label.text = "Sorry, It's not avalible now."
        label.font = UIFont.systemFont(ofSize: 15)
        label.sizeToFit()
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavAndBackground()
        handleSetup()
        
    }
    
    @objc private func handleSetup() {
        setupViews()
        
        fetchTradeHistoryWith(dateCount: 1)
        fetchUSDTContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

//MARK: handle wbsegementControl delegate

extension ChartViewLandscapeController {
    
    func segmentControl(_ segmentControl: WBSegmentControl, selectIndex newIndex: Int, oldIndex: Int) {
        
        self.nothingLabel.isHidden = true
        
        if newIndex == 0 {
            self.selectedSegIndex = SegIndex.day.rawValue
        } else if newIndex == 1{
            self.selectedSegIndex = SegIndex.week.rawValue
            
        } else if newIndex == 2 {
            self.selectedSegIndex = SegIndex.month.rawValue
        } else if newIndex == 3 {
            self.selectedSegIndex = SegIndex.threeMonth.rawValue
        } else if newIndex == 4 {
            self.selectedSegIndex = SegIndex.sixMonth.rawValue
        } else if newIndex == 5 {
            self.selectedSegIndex = SegIndex.year.rawValue
        }
        fetchTradeHistoryWith(dateCount: self.selectedSegIndex)
        
        segmentControl.isUserInteractionEnabled = false
    }
    
}

//MARK: handle swift chart()

extension ChartViewLandscapeController {
    
    fileprivate func fetchUSDTContent() {
        
        
        self.BitcoinNameLabel.text = chartCoin?.symbol
        
        if let name = chartCoin?.name, let price = chartCoin?.price_usd {
            self.descriptionLabel.text = name + ": " + price + "$"
        }
        
        self.currencyLabel.text = chartCoin?.h24_volume_usd
        
        if let percentStr = chartCoin?.percent_change_1h {
            let percent = Double(percentStr)
            
            self.percentLabel.text = percentStr + "%"
            
            if percentStr == "0.00" {
                self.percentLabel.text = "0.00%"
                arrowImageView.image = nil
                self.percentLabel.textColor = .lightGray
            } else {
                if Float(percent!) > 0 {
                    arrowImageView.image = UIImage(named: AssetName.arrowUp.rawValue)
                    self.percentLabel.textColor = StyleGuideManager.greenColor
                } else {
                    self.percentLabel.textColor = StyleGuideManager.redColor
                    arrowImageView.image = UIImage(named: AssetName.arrowDown.rawValue)
                }
            }
        }
        
    }
    
    fileprivate func fetchTradeHistoryWith(dateCount: Int) {
        KRProgressHUD.set(style: .black)
        KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
        KRProgressHUD.show()
        
        if self.chartView.subviews.count > 0 {
            
            let viewCleared = self.chartView.subviews[0]
            viewCleared.removeFromSuperview()
            
        }
        
        fetchTradeHistoryWith(bitName: (self.chartCoin?.id)!, dateCount: dateCount)
        
    }
    
    private func createJLLineChart() {
        
        if chartHistories.count == 0 {
            print("counted 0")
            KRProgressHUD.dismiss()
            self.showErrorAlert("Sorry, not available now", message: "", action: { (action) in
                print("okay?")
            }, completion: { 
                print("cancel?")
            })
            return
        }

        
        let jlLineChart = JLLineChart(frame: CGRect(x: 0, y: 15, width: view.frame.width, height: DEVICE_HEIGHT * 0.7))
        let data = JLLineChartData()
        
        data.lineColor = .green
        let set = JLChartPointSet()
        
        for i in 0 ..< self.chartHistories.count {
            
            let point = JLChartPointItem(rawX: self.chartHistories[i].date, andRowY: self.chartHistories[i].volume) as JLChartPointItem
            set.items.add(point)
            
        }
        
        data.sets.add(set)
        
        jlLineChart.chartDatas = NSMutableArray(object: data)

        if self.chartHistories.count > 0 {
            nothingLabel.isHidden = true
            self.chartView.addSubview(jlLineChart)
            jlLineChart.stroke()
        } else {
            nothingLabel.isHidden = false
        }
        
        
        
        
        KRProgressHUD.dismiss()
        
    }
    
    fileprivate func convertChartTradeHistoryData(segmentIndex: Int) {
        
        if segmentIndex == 2 {
            
            for i in 0 ..< 12 {
                let timestampeNum = (NSDate().timeIntervalSince1970 - Double(i * segmentIndex * 60 * 60)) as NSNumber
                
                for j in 0 ..< chartGraphs.count {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = dateFormatter.date(from: chartGraphs[j].date!)
                    
                    let timestampeDate = NSDate(timeIntervalSince1970: timestampeNum.doubleValue)
                    
                    let dateForGraph = dateFormatter.string(from: timestampeDate as Date)
                    
                    if let date = date {
                        let timestamp = date.timeIntervalSince1970 as NSNumber
                        
                        if timestamp.doubleValue <= timestampeNum.doubleValue {
                            let amount = chartGraphs[j].amount
                            
                            let chartGraph = ChartGraph()
                            chartGraph.amount = amount
                            chartGraph.date = dateForGraph
                            self.virtualChartGraphs.append(chartGraph)
                            break
                        }
                    }
                }
            }
        }
        
    }
    
    fileprivate func fetchTradeHistoryWith(bitName: String, dateCount: Int) {
        
        
        var request = String(format: CoinMarketCapService.TradeHistory.rawValue, bitName)
        
        if self.selectedSegIndex == 1 {
            request = String(format: CoinMarketCapService.TradeHistoryWeek.rawValue, bitName)
        }
        
        API?.executeHTTPRequest(Get, url: request, parameters: nil, completionHandler: { (responseDic) in
            self.parseResponseWith(response: responseDic!)
        }, errorHandler: { (error) in
            KRProgressHUD.dismiss()
            print("historyError", error!)
            self.showErrorAlert("Sorry, not available now", message: "", action: { (action) in
                print("okay?")
            }, completion: {
                print("cancel?")
            })
            self.nothingLabel.isHidden = false
        })
        
        
    }
    
    private func parseResponseWith(response: [AnyHashable: Any]) {
        self.chartHistories.removeAll()
        if self.selectedSegIndex == 1 {
            
            let historyDic = response["history"] as! [String: [String: Any]]
            
            for history in historyDic {
                
                let currentDateKey = history.key
                
                let dateFormatterForDay = DateFormatter()
                
                dateFormatterForDay.dateFormat = "hh-dd-MM-yyyy"
                
                let currentDate = dateFormatterForDay.date(from: currentDateKey)
                
                let yesterday = Date().yesterday
                
                if currentDate?.isGreaterThanDate(dateToCompare: yesterday) == true {
                    
                    let priceDic = history.value["price"] as! [String: Any]
                    let price = String(describing: priceDic["usd"] as! NSNumber)
                    let volumeDic = history.value["volume24"] as! [String: Any]
                    let volume = String(describing: volumeDic["usd"] as! NSNumber)
                    
                    let chartCoinTradeHistory = ChartCoinTradeHistory()
                    chartCoinTradeHistory.date = currentDateKey
                    chartCoinTradeHistory.price = price
                    chartCoinTradeHistory.volume = volume
                    self.chartHistories.append(chartCoinTradeHistory)
                }
            }
            
            
        } else {
            let historyArr = response["history"] as! [[String: Any]]
            
            for history in historyArr {
                
                print("history", history)
                
                let date = history["date"] as! String
                let priceDic = history["price"] as! [String: Any]
                let price = String(describing: priceDic["usd"] as! NSNumber)
                let volumeDic = history["volume24"] as! [String: Any]
                let volume = String(describing: volumeDic["usd"] as! NSNumber)
                
                let chartCoinTradeHistory = ChartCoinTradeHistory()
                chartCoinTradeHistory.date = date
                chartCoinTradeHistory.price = price
                chartCoinTradeHistory.volume = volume
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                
                let currentDate = dateFormatter.date(from: date)
                
                if self.selectedSegIndex == 7 {
                    let aWeekAgo = Date().aWeekAgo
                    
                    if currentDate?.isGreaterThanDate(dateToCompare: aWeekAgo) == true {
                        self.chartHistories.append(chartCoinTradeHistory)
                    }
                } else if self.selectedSegIndex == 30 {
                    let aMonthAgo = Date().aMonthAgo
                    if currentDate?.isGreaterThanDate(dateToCompare: aMonthAgo) == true {
                        self.chartHistories.append(chartCoinTradeHistory)
                    }
                } else if self.selectedSegIndex == 90 {
                    let threeMonthAgo = Date().threeMonthAgo
                    if currentDate?.isGreaterThanDate(dateToCompare: threeMonthAgo) == true {
                        self.chartHistories.append(chartCoinTradeHistory)
                    }
                } else if self.selectedSegIndex == 180 {
                    let sixMonthAgo = Date().sixMonthAgo
                    if currentDate?.isGreaterThanDate(dateToCompare: sixMonthAgo) == true {
                        self.chartHistories.append(chartCoinTradeHistory)
                    }
                } else if self.selectedSegIndex == 365 {
                    let aYearAgo = Date().aYearAgo
                    if currentDate?.isGreaterThanDate(dateToCompare: aYearAgo) == true {
                        self.chartHistories.append(chartCoinTradeHistory)
                    }
                }
            }

        }
        
        
        self.createJLLineChart()
        segmentControl.isUserInteractionEnabled = true
    }
    
}



//MARK: handle dismiss

extension ChartViewLandscapeController {
    
    func handleTapGestureWith(sender: UIGestureRecognizer) {
        
        handleDismiss()
        
    }
    
    @objc fileprivate func handleDismiss() {
        
        self.dismiss(animated: false, completion: nil)
    }
    
}

//MARK: setupviews

extension ChartViewLandscapeController {
    
    fileprivate func setupViews() {
        
        
        setupContainerView()
        setupLabels()
        setupSegment()
        setupChartView()
        setupNothingLabel()
    }
    
    private func setupNothingLabel() {
        view.addSubview(nothingLabel)
        
        nothingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nothingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        nothingLabel.isHidden = true
    }
    
    private func setupChartView() {
        view.addSubview(chartView)
        
        chartView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chartView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        chartView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 0).isActive = true
        chartView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    private func setupContainerView() {
        view.addSubview(containerView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureWith(sender:)))
        containerView.addGestureRecognizer(tap)
        
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
    }
    
    private func setupLabels() {
        
        containerView.addSubview(BitcoinNameLabel)
        containerView.addSubview(currencyLabel)
        containerView.addSubview(percentLabel)
        containerView.addSubview(arrowImageView)
        
        BitcoinNameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        BitcoinNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 10).isActive = true
        BitcoinNameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        BitcoinNameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        currencyLabel.topAnchor.constraint(equalTo: BitcoinNameLabel.topAnchor).isActive = true
        currencyLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8).isActive = true
        currencyLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        currencyLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        percentLabel.topAnchor.constraint(equalTo: currencyLabel.bottomAnchor).isActive = true
        percentLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        percentLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        percentLabel.rightAnchor.constraint(equalTo: currencyLabel.rightAnchor).isActive = true
        
        arrowImageView.topAnchor.constraint(equalTo: percentLabel.topAnchor, constant: 12).isActive = true
        arrowImageView.rightAnchor.constraint(equalTo: percentLabel.leftAnchor, constant: 0).isActive = true
        arrowImageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        arrowImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true

        
        let backButton = UIButton(type: .system)
        let image = UIImage(named: AssetName.leftArrow.rawValue)?.withRenderingMode(.alwaysOriginal)
        backButton.setImage(image, for: .normal)
        backButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(backButton)
        backButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        backButton.centerYAnchor.constraint(equalTo: BitcoinNameLabel.centerYAnchor, constant: 0).isActive = true
    }

    
    private func setupSegment() {
        view.addSubview(segmentControl)
        segmentControl.delegate = self
        
        segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        segmentControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        segmentControl.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
    }
    
    fileprivate func setupNavAndBackground() {
        view.backgroundColor = .white
        
        let backButton = UIButton(type: .system)
        let image = UIImage(named: AssetName.leftArrow.rawValue)
        backButton.setImage(image, for: .normal)
        
    }
    
}
