//
//  Chart.swift
//  CT
//
//  Created by PAC on 7/30/17.
//  Copyright © 2017 PAC. All rights reserved.
//

import UIKit

class ChartBTC: NSObject {
    
    var name: String?
    var baseVolume: String?
    var high24hr: String?
    var highestBid: String?
    var id: NSNumber?
    var isFronzen: String?
    var last: String?
    var low24hr: String?
    var lowestAsk: String?
    var percentChange: String?
    var quoteVolume: String?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        name = dictionary["name"] as? String
        baseVolume = dictionary["baseVolume"] as? String
        high24hr = dictionary["high24hr"] as? String
        highestBid = dictionary["highestBid"] as? String
        id = dictionary["id"] as? NSNumber
        isFronzen = dictionary["isFronzen"] as? String
        last = dictionary["last"] as? String
        low24hr = dictionary["low24hr"] as? String
        lowestAsk = dictionary["lowestAsk"] as? String
        percentChange = dictionary["percentChange"] as? String
        quoteVolume = dictionary["quoteVolume"] as? String
    }

}
