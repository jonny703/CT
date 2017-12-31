//
//  PoloniexServiceUrl.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation


enum PoloniexService: String {
    case ReturnTicker = "https://poloniex.com/public?command=returnTicker"
    case Return24Volume = "https://poloniex.com/public?command=return24hVolume"
    case ReturnOrderBook = "https://poloniex.com/public?command=returnOrderBook&currencyPair=BTC_NXT&depth=10"
    case ReturnTradeHistory = "https://poloniex.com/public?command=returnTradeHistory&currencyPair=%@&start=%@&end=%@"
    case ReturnChartData = "https://poloniex.com/public?command=returnChartData&currencyPair=BTC_XMR&start=1405699200&end=9999999999&period=14400"
    case ReturnCurrencies = "https://poloniex.com/public?command=returnCurrencies"
    case ReturnLoanOrders = "https://poloniex.com/public?command=returnLoanOrders&currency=BTC"
}

enum CoinMarketCapService: String {
    case Ticker = "https://api.coinmarketcap.com/v1/ticker/?limit=100"
    case TradeHistory = "http://coinmarketcap.northpole.ro/history.json?coin=%@"
    case TradeHistoryWeek = "http://coinmarketcap.northpole.ro/history.json?coin=%@&period=14days"
}
