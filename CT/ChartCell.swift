//
//  ChartCell.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class ChartCell: UITableViewCell {
    
    var chartHistories = [ChartBTCTradeHistory]()
    
    var chart: ChartCoin? {
        
        didSet {
            
            self.BitcoinNameLabel.text = chart?.symbol
            
            if let name = chart?.name, let price = chart?.price_usd {
                self.descriptionLabel.text = name + ": " + price + "$"
            }
            
            self.currencyLabel.text = chart?.h24_volume_usd
            
            if let percentStr = chart?.percent_change_1h {
                let percent = Double(percentStr)
                
                self.percentLabel.text = percentStr + "%"
                
                if percentStr == "0.00" {
                    self.percentLabel.text = "0.00%"
                    statusBarView.backgroundColor = .lightGray
                    arrowImageView.image = nil
                    self.percentLabel.textColor = .lightGray
                } else {
                    if Float(percent!) > 0 {
                        statusBarView.backgroundColor = StyleGuideManager.greenColor
                        arrowImageView.image = UIImage(named: AssetName.arrowUp.rawValue)
                        self.percentLabel.textColor = StyleGuideManager.greenColor
                    } else {
                        statusBarView.backgroundColor = StyleGuideManager.redColor
                        self.percentLabel.textColor = StyleGuideManager.redColor
                        arrowImageView.image = UIImage(named: AssetName.arrowDown.rawValue)
                    }
                }
            }
        }
        
    }

    
    let statusBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let BitcoinNameLabel: UILabel = {
        let label = UILabel()
        label.text = "BTC"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let chatLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to Chat"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "BTC"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "16.77"
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
    
    lazy var graphView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.arrowUp.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        setupViews()
    }
    
    func setupViews() {
        
        
        addSubview(statusBarView)
        addSubview(BitcoinNameLabel)
        addSubview(chatLabel)
        addSubview(descriptionLabel)
        addSubview(currencyLabel)
        addSubview(percentLabel)
        addSubview(arrowImageView)
        
        statusBarView.widthAnchor.constraint(equalToConstant: 4).isActive = true
        statusBarView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        statusBarView.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        statusBarView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        
        BitcoinNameLabel.widthAnchor.constraint(equalToConstant: frame.width * 0.25).isActive = true
        BitcoinNameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 2).isActive = true
        BitcoinNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        BitcoinNameLabel.leftAnchor.constraint(equalTo: statusBarView.rightAnchor, constant: 6).isActive = true
        
        chatLabel.widthAnchor.constraint(equalToConstant: frame.width * 0.3).isActive = true
        chatLabel.heightAnchor.constraint(equalTo: BitcoinNameLabel.heightAnchor).isActive = true
        chatLabel.leftAnchor.constraint(equalTo: BitcoinNameLabel.rightAnchor, constant: 30).isActive = true
        chatLabel.centerYAnchor.constraint(equalTo: BitcoinNameLabel.centerYAnchor).isActive = true
        
        descriptionLabel.widthAnchor.constraint(equalToConstant: frame.width * 0.7).isActive = true
        descriptionLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 2).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: BitcoinNameLabel.leftAnchor).isActive = true
        
        currencyLabel.topAnchor.constraint(equalTo: BitcoinNameLabel.topAnchor).isActive = true
        currencyLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        currencyLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 2).isActive = true
        currencyLabel.widthAnchor.constraint(equalToConstant: frame.width * 0.4).isActive = true
        
        percentLabel.topAnchor.constraint(equalTo: descriptionLabel.topAnchor).isActive = true
        percentLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        percentLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 2).isActive = true
        percentLabel.rightAnchor.constraint(equalTo: currencyLabel.rightAnchor).isActive = true
        
        arrowImageView.topAnchor.constraint(equalTo: percentLabel.topAnchor, constant: 12).isActive = true
        arrowImageView.rightAnchor.constraint(equalTo: percentLabel.leftAnchor, constant: 0).isActive = true
        arrowImageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        arrowImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


