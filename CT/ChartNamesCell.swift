//
//  ChartNamesCell.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class ChartNamesCell: UITableViewCell {
    
    let BitcoinNameLabel: UILabel = {
        let label = UILabel()
        label.text = "BTC"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "BTC"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.plusIcon.rawValue)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        setupViews()
    }
    
    func setupViews() {
        
        addSubview(BitcoinNameLabel)
        addSubview(descriptionLabel)
        addSubview(plusButton)
        
        BitcoinNameLabel.widthAnchor.constraint(equalToConstant: frame.width * 0.4).isActive = true
        BitcoinNameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 2).isActive = true
        BitcoinNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        BitcoinNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        descriptionLabel.widthAnchor.constraint(equalToConstant: frame.width * 0.7).isActive = true
        descriptionLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 2).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: BitcoinNameLabel.leftAnchor).isActive = true
        
        plusButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        plusButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        plusButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
