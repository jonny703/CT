//
//  Global.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation

func returnLeftTimedateformatter(date: Double) -> String {
    
    let date1:Date = Date() // Same you did before with timeNow variable
    let date2: Date = Date(timeIntervalSince1970: date)
    
    let calender:Calendar = Calendar.current
    let components: DateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date1, to: date2)
    
    var returnString:String = ""
    
    
    if abs(components.year!) >= 1 {
        returnString = String(describing: abs(components.year!))+" y"
    } else if abs(components.month!) >= 1{
        returnString = String(describing: abs(components.month!))+" m"
    } else if abs(components.day!) >= 1{
        returnString = String(describing: abs(components.day!)) + " d"
    } else if abs(components.hour!) >= 1{
        returnString = String(describing: abs(components.hour!)) + " h"
    } else if abs(components.minute!) >= 1{
        returnString = String(describing: abs(components.minute!)) + " min"
    } else if components.second! < 60 {
        returnString = "Just Now"
    }
    return returnString
}

func returnDayWithDateformatter(date: Double) -> Int {
    
    let date1:Date = Date() // Same you did before with timeNow variable
    let date2: Date = Date(timeIntervalSince1970: date)
    
    let calender:Calendar = Calendar.current
    let components: DateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date1, to: date2)
//    print(components)
    var returnNum: Int = 0
//    print(components.second)
    
    if abs(components.day!) >= 1{
        returnNum = abs(components.day!)
    } else if components.hour! >= 1{
        returnNum = 1
    } else if components.minute! >= 1{
        returnNum = 1
    } else if components.second! < 60 {
        returnNum = 1
    }
    return returnNum
}

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

struct Global {
//    static var coinsArr = [
//        ["ETH_GNT", "ETH", "Ethereum", "Golem"],
//        ["BTC_BELA", "BTC", "Bitcoin", "Belacoin"],
//        ["BTC_GAME", "BTC", "Bitcoin", "GameCredits"],
//        ["USDT_ETC", "USDT", "USDT", "Ethereum Classic"],
//        ["BTC_GRC", "BTC", "Bitcoin", "Gridcoin Research"],
//        ["BTC_SBD", "BTC", "Bitcoin", "Steem Dollars"],
//        ["XMR_ZEC", "XMR", "Monero", "Zcash"],
//        ["XMR_BLK", "XMR", "Monero", "BlackCoin"],
//        ["BTC_REP","BTC", "Bitcoin", "Augur"],
//        ["USDT_ZEC", "USDT", "USDT", "Zcash"],
//        ["BTC_LBC", "BTC", "Bitcoin", "LBRY Credits"],
//        ["BTC_BCY", "BTC", "Bitcoin", "BitCrystaks"],
//        ["BTC_VTC", "BTC", "Bitcoin", "Vertcoin"],
//        ["BTC_RIC", "BTC", "Bitcoin", "Riecoin"],
//        ["BTC_FCT", "BTC", "Bitcoin", "Factom"],
//        ["BTC_POT", "BTC", "Bitcoin", "PotCoin"],
//        ["XMR_BCN", "USDT", "USDT", "Bytecoin"],
//        ["BTC_PPC", "BTC", "Bitcoin", "Peercoin"],
//        ["USDT_NXT", "USDT", "USDT", "NXT"],
//        ["USDT_BCH", "USDT", "USDT", "Bitcoin Cash"],
//        ["BTC_FLDC", "BTC", "Bitcoin", "FoldingCoin"],
//        ["BTC_GNO", "BTC", "Bitcoin", "Gnosis"],
//        ["ETH_STEEM", "ETH", "Ethereum", "STEEM"],
//        ["BTC_DASH", "BTC", "Bitcoin", "Dash"],
//        ["BTC_RADS", "BTC", "Bitcoin", "Radium"],
//        ["BTC_BCN", "BTC", "Bitcoin", "Bytecoin"],
//        ["BTC_MAID", "BTC", "Bitcoin", "MaidSafeCoin"],
//        ["BTC_VRC", "BTC", "Bitcoin", "VeriCoin"],
//        ["BTC_DOGE", "BTC", "Bitcoin", "Dogecoin"],
//        ["BTC_CLAM", "BTC", "Bitcoin", "CLAMS"],
//        ["BTC_DGB", "BTC", "Bitcoin", "DigiByte"],
//        ["BTC_XVC", "BTC", "Bitcoin", "Vcash"],
//        ["XMR_DASH", "XMR", "Monero", "Dash"],
//        ["BTC_BTS", "BTC", "Bitcoin", "BitShares"],
//        ["BTC_ETH", "BTC", "Bitcoin", "Ethereum"],
//        ["BTC_NAV", "BTC", "Bitcoin", "NAVCoin"],
//        ["BTC_SYS", "BTC", "Bitcoin", "Syscoin"],
//        ["BTC_VIA", "BTC", "Bitcoin", "Viacoin"],
//        ["XMR_LTC", "XMR", "Monero", "Litecoin"],
//        ["BTC_SC", "BTC", "Bitcoin", "Siacoin"],
//        ["BTC_NOTE", "BTC", "Bitcoin", "DNotes"],
//        ["ETH_ETC", "ETH", "Ethereum", "Ethereum Classic"],
//        ["BTC_SJCX", "BTC", "Bitcoin", "Storjcoin X"],
//        ["BTC_BURST", "BTC", "Bitcoin", "Burst"],
//        ["BTC_NXC", "BTC", "Bitcoin", "Nexium"],
//        ["BTC_GNT", "BTC", "Bitcoin", "Golem"],
//        ["USDT_XMR", "USDT", "USDT", "Monero"],
//        ["BTC_NAUT", "BTC", "Bitcoin", "Nautiluscoin"],
//        ["BTC_ETC", "BTC", "Bitcoin", "Ethereum Classic"],
//        ["BTC_EXP", "BTC", "Bitcoin", "Expanse"],
//        ["BTC_OMNI", "BTC", "Bitcoin", "Omni"],
//        ["BTC_XMR", "BTC", "Bitcoin", "Monero"],
//        ["BTC_ZEC", "BTC", "Bitcoin", "Zcash"],
//        ["BTC_XCP", "BTC", "Bitcoin", "Counterparty"],
//        ["USDT_ETH", "USDT", "USDT", "Ethereum Classic"],
//        ["USDT_REP", "USDT", "USDT", "Augur"],
//        ["BTC_XPM", "BTC", "Bitcoin", "Primecoin"],
//        ["BTC_XEM", "BTC", "Bitcoin", "NEM"],
//        ["BTC_BTM", "BTC", "Bitcoin", "Bitmark"],
//        ["ETH_ZEC", "ETH", "Ethereum", "Zcash"],
//        ["BTC_STEEM", "BTC", "Bitcoin", "STEEM"],
//        ["BTC_XBC", "BTC", "Bitcoin", "BitcoinPlus"],
//        ["USDT_STR", "USDT", "USDT", "Stellar"],
//        ["BTC_BTCD", "BTC", "Bitcoin", "BitcoinDark"],
//        ["BTC_LTC", "BTC", "Bitcoin", "Litecoin"],
//        ["BTC_DCR", "BTC", "Bitcoin", "Decred"],
//        ["BTC_BLK", "BTC", "Bitcoin", "BlackCoin"],
//        ["BTC_PINK", "BTC", "Bitcoin", "Pinkcoin"],
//        ["XMR_NXT", "XMR", "Monero", "NXT"],
//        ["BTC_NMC", "BTC", "Bitcoin", "Namecoin"],
//        ["USDT_XRP", "USDT", "USDT", "Ripple"],
//        ["BTC_FLO", "BTC", "Bitcoin", "Florincoin"],
//        ["BTC_EMC2", "BTC", "Bitcoin", "Einsteinium"],
//        ["ETH_REP", "ETH", "Ethereum", "Augur"],
//        ["XMR_MAID", "XMR", "Monero", "MaidSafeCoin"],
//        ["BTC_XRP", "BTC", "Bitcoin", "Ripple"],
//        ["BTC_NEOS", "BTC", "Bitcoin", "Neoscoin"],
//        ["XMR_BTCD", "XMR", "Monero", "BitcoinDark"],
//        ["BTC_STR", "BTC", "Bitcoin", "Stellar"],
//        ["USDT_DASH", "USDT", "USDT", "Dash"],
//        ["BTC_ARDR", "BTC", "Bitcoin", "Ardor"],
//        ["ETH_BCH", "ETH", "Ethereum", "Bitcoin Cash"],
//        ["BTC_LSK", "BTC", "Bitcoin", "Lisk"],
//        ["USDT_BTC", "USDT", "USDT", "Bitcoin"],
//        ["ETH_GNO", "ETH", "Ethereum", "Gnosis"],
//        ["BTC_NXT", "BTC", "Bitcoin", "NXT"],
//        ["BTC_STRAT", "BTC", "Bitcoin", "Stratis"],
//        ["ETH_LSK", "ETH", "Ethereum", "Lisk"],
//        ["BTC_AMP", "BTC", "Bitcoin", "Synereo AMP"],
//        ["BTC_BCH", "BTC", "Bitcoin", "Bitcoin Cash"],
//        ["BTC_HUC", "BTC", "Bitcoin", "Huntercoin"],
//        ["USDT_LTC", "USDT", "USDT", "Litecoin"],
//        ["BTC_PASC", "BTC", "Bitcoin", "PascalCoin"]
//    ]
    
    static var coinsArr = [
        ["USDT_ETC", "USDT", "USDT", "Ethereum Classic"],
        ["USDT_ZEC", "USDT", "USDT", "Zcash"],
        ["USDT_NXT", "USDT", "USDT", "NXT"],
        ["USDT_BCH", "USDT", "USDT", "Bitcoin Cash"],
        ["USDT_XMR", "USDT", "USDT", "Monero"],
        ["USDT_ETH", "USDT", "USDT", "Ethereum"],
        ["USDT_REP", "USDT", "USDT", "Augur"],
        ["USDT_STR", "USDT", "USDT", "Stellar"],
        ["USDT_XRP", "USDT", "USDT", "Ripple"],
        ["USDT_DASH", "USDT", "USDT", "Dash"],
        ["USDT_BTC", "USDT", "USDT", "Bitcoin"],
        ["USDT_LTC", "USDT", "USDT", "Litecoin"],
    ]

    static var coinsArray = [
        ["BTC", "Bitcoin"],
        ["ETH", "Ethereum"],
        ["BCH", "Bitcoin Cash"],
        ["XRP", "Ripple"],
        ["LTC", "Litecoin"],
        ["DASH", "Dash"],
        ["XEM", "NEM"],
        ["MIOTA", "IOTA"],
        ["XMR", "Monero"],
        ["ETC", "Ethereum Classic"],
        ["OMG", "OmiseGO"],
        ["NEO", "NEO"],
        ["BCC", "BitConnect"],
        ["QTUM", "Qtum"],
        ["LSK", "Lisk"],
        ["STRAT", "Stratis"],
        ["ZEC", "Zcash"],
        ["WAVES", "Waves"],
        ["HSR", "Hshare"],
        ["USDT", "Tether"],
        ["ARK", "Ark"],
        ["BCN", "Bytecoin"],
        ["BTS", "BitShares"],
        ["STEEM", "Steem"],
        ["MAID", "MaidSafeCoin"],
        ["XLM", "Stellar Lumens"],
        ["PAY", "TenX"],
        ["GNT", "Golem"],
        ["EOS", "EOS"],
        ["REP", "Augur"],
        ["MTL", "Metal"],
        ["BAT", "Basic Attention Token"],
        ["FCT", "Factom"],
        ["KMD", "Komodo"],
        ["PIVX", "PIVX"],
        ["ICN", "Iconomi"],
        ["SC", "Siacoin"],
        ["GBYTE", "Byteball Bytes"],
        ["VERI", "Veritaseum"],
        ["DOGE", "Dogecoin"],
        ["NXS", "Nexus"],
        ["SYS", "Syscoin"],
        ["DCR", "Decred"],
        ["DGD", "DigixDAO"],
        ["MCAP", "MCAP"],
        ["DGB", "DigiByte"],
        ["CVC", "Civic"],
        ["GNO", "Gnosis"],
        ["ZRX", "0x"],
        ["ARDR", "Ardor"],
        ["PPT", "Populous"],
        ["GAME", "GameCredits"],
        ["BTCD", "BitcoinDark"],
        ["BNB", "Binance Coin"],
        ["XVG", "Verge"],
        ["SNT", "Status"],
        ["GAS", "Gas"],
        ["BNT", "Bancor"],
        ["SNGLS", "SingularDTV"],
        ["AE", "Aeternity"],
        ["FUN", "FunFair"],
        ["GXS", "GXShares"],
        ["LKK", "Lykke"],
        ["MCO", "Monaco"],
        ["NXT", "Nxt"],
        ["BLOCK", "Blocknet"],
        ["UBQ", "Ubiq"],
        ["NAV", "NAV Coin"],
        ["PART", "Particl"],
        ["WINGS", "Wings"],
        ["BQX", "Bitquence"],
        ["EDG", "Edgeless"],
        ["ANT", "Aragon"],
        ["STORJ", "Storj"],
        ["MGO", "MobileGo"],
        ["MTH", "Monetha"],
        ["TNT", "Tierion"],
        ["WTC", "Walton"],
        ["FRST", "FirstCoin"],
        ["OK", "OKCash"],
        ["NLC2", "NoLimitCoin"],
        ["PLR", "Pillar"],
        ["CFI", "Cofound.it"],
        ["CLOAK", "CloakCoin"],
        ["BTM", "Bytom"],
        ["NLG", "Gulden"],
        ["RISE", "Rise"],
        ["XEL", "Elastic"],
        ["RLC", "iExec RLC"],
        ["TRIG", "Triggers"],
        ["LEO", "LEOcoin"],
        ["MLN", "Melon"],
        ["ADX", "AdEx"],
        ["DLT", "Delta"],
        ["IOC", "I/O Coin"],
        ["ADK", "Aidos Kuneen"],
        ["DCT", "DECENT"],
        ["PPC", "Peercoin"],
        ["XCP", "Counterparty"],
        ["RDD", "ReddCoin"],
        ]
    static var alarmLists = [AlarmSet]()
    
    static var watchLists = [String]()
}

//struct AppUtility {
//    
//    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
//        
//        if let delegate = UIApplication.shared.delegate as? AppDelegate {
//            delegate.orientationLock = orientation
//        }
//        
//    }
//    
//    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
//    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
//        
//        self.lockOrientation(orientation)
//        
//        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
//    }
//    
//    
//}














