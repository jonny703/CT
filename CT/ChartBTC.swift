//
//  Chart.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
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

class ChartCoin: NSObject {
    var id: String?
    var name: String?
    var symbol: String?
    var rank: String?
    var price_usd: String?
    var price_btc: String?
    var h24_volume_usd: String?
    var market_cap_usd: String?
    var available_supply: String?
    var total_supply: String?
    var percent_change_1h: String?
    var percent_change_24h: String?
    var percent_change_7d: String?
    var last_updated: String?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        symbol = dictionary["symbol"] as? String
        rank = dictionary["rank"] as? String
        price_usd = dictionary["price_usd"] as? String
        price_btc = dictionary["price_btc"] as? String
        h24_volume_usd = dictionary["h24_volume_usd"] as? String
        market_cap_usd = dictionary["market_cap_usd"] as? String
        available_supply = dictionary["available_supply"] as? String
        total_supply = dictionary["total_supply"] as? String
        percent_change_1h = dictionary["percent_change_1h"] as? String
        percent_change_24h = dictionary["percent_change_24h"] as? String
        percent_change_7d = dictionary["percent_change_7d"] as? String
        last_updated = dictionary["last_updated"] as? String
    }
}

class ChartCoinName: NSObject {
    var symbol: String?
    var name: String?
}
