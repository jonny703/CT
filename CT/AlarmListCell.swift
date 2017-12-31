//
//  AlarmListCell.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class AlarmListCell: UITableViewCell {
    
    let btcNameLabel: UILabel = {
        let label = UILabel()
        label.text = "BTC_ETH"
        label.font = UIFont.systemFont(ofSize: 19)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "Volume"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    let maxLabel: UILabel = {
        let label = UILabel()
        label.text = "MAX: 20000"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let minLabel: UILabel = {
        let label = UILabel()
        label.text = "MIN: 3400"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let turnSwitch: UISwitch = {
        
        let turnSwitch = UISwitch()
        turnSwitch.translatesAutoresizingMaskIntoConstraints = false
        return turnSwitch
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        setupViews()
    }
    
    private func setupViews() {
        addSubview(btcNameLabel)
        addSubview(contentLabel)
        addSubview(maxLabel)
        addSubview(minLabel)
        addSubview(turnSwitch)
        
        
        btcNameLabel.widthAnchor.constraint(equalToConstant: 110).isActive = true
        btcNameLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        btcNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        btcNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        contentLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        contentLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        contentLabel.leftAnchor.constraint(equalTo: btcNameLabel.rightAnchor, constant: 3).isActive = true
        
        maxLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        maxLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 2).isActive = true
        maxLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        maxLabel.leftAnchor.constraint(equalTo: contentLabel.rightAnchor, constant: 3).isActive = true
        
        minLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        minLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 2).isActive = true
        minLabel.topAnchor.constraint(equalTo: maxLabel.bottomAnchor, constant: 0).isActive = true
        minLabel.leftAnchor.constraint(equalTo: maxLabel.leftAnchor, constant: 0).isActive = true
    
        turnSwitch.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        turnSwitch.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
