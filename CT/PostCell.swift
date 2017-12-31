//
//  BlogCell.swift
//  CT
//
//  Created by PAC on 8/3/17.
//  Copyright © 2017 PAC. All rights reserved.
//

import UIKit
import AVFoundation


class BlogCell: UICollectionViewCell {
    
    let textView: UITextView = {
        
        let tv = UITextView()
        tv.text = "sdfs"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.black
        tv.isEditable = false
        tv.textAlignment = .center
        tv.isUserInteractionEnabled = false
        //        tv.backgroundColor = .blue
        return tv
        
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "23:34 AM"
        label.textColor = .black
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
        
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "caesar"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var postImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //        imageView.layer.cornerRadius = 16
        //        imageView.layer.masksToBounds = true
        //        imageView.contentMode = .scaleAspectFill
        //        imageView.backgroundColor = UIColor.brown
        
        //        imageView.isUserInteractionEnabled = true
        //
        //        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return imageView
        
    }()
    
    var textViewHeightConstraint: NSLayoutConstraint?
    var postImageViewConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(textView)
        
        addSubview(timeLabel)
        
        addSubview(postImageView)
        
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        
        
        usernameLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        
        timeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: usernameLabel.heightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: usernameLabel.topAnchor).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        
        
        textView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 0).isActive = true
        textView.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor, constant: 0).isActive = true
        textView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 50)
        textViewHeightConstraint?.isActive = true
        
        postImageView.widthAnchor.constraint(equalTo: textView.widthAnchor).isActive = true
        postImageView.leftAnchor.constraint(equalTo: textView.leftAnchor).isActive = true
        postImageView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0).isActive = true
        postImageViewConstraint = postImageView.heightAnchor.constraint(equalToConstant: 50)
        postImageViewConstraint?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

