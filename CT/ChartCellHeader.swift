//
//  ChartCellHeader.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class ChartCellHeader: UICollectionReusableView, UIGestureRecognizerDelegate {
    
    
    lazy var chartContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
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
    
    func handleChartView(sender: UIGestureRecognizer) {
        print("tapped")
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(chartContainerView)
        
        
        chartContainerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        chartContainerView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        chartContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        chartContainerView.heightAnchor.constraint(equalToConstant: 210).isActive = true
        
        chartContainerView.addSubview(nothingLabel)
        
        nothingLabel.centerXAnchor.constraint(equalTo: chartContainerView.centerXAnchor).isActive = true
        nothingLabel.centerYAnchor.constraint(equalTo: chartContainerView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
