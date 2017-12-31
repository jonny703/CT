//
//  ChartBTCTradeHistory.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class ChartBTCTradeHistory: NSObject {
    
    var amount: String?
    var date: String?
    var globalTradeID: NSNumber?
    var rate: String?
    var total: String?
    var tradeID: NSNumber?
    var type: String?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        amount = dictionary["amount"] as? String
        date = dictionary["date"] as? String
        globalTradeID = dictionary["globalTradeID"] as? NSNumber
        rate = dictionary["rate"] as? String
        total = dictionary["total"] as? String
        tradeID = dictionary["tradeID"] as? NSNumber
        type = dictionary["type"] as? String
    }


}

class ChartCoinTradeHistory: NSObject {
    
    var date: String?
    var price: String?
    var volume: String?
}
