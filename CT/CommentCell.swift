//
//  CommentCell.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var postCommentsController: PostCommentsController?
    
    var textView: UITextView = {
        
        let tv = UITextView()
        tv.text = ""
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.black
        tv.isEditable = false
        tv.textAlignment = .left
        tv.isUserInteractionEnabled = true
        tv.isScrollEnabled = false
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
    
    lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.more.rawValue)
        button.setImage(image, for: .normal)
        button.tintColor = StyleGuideManager.crytpTweetsDefaultColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
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
        label.text = ""
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var postImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return imageView
        
    }()
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        
        if let imageView = tapGesture.view as? UIImageView {
            
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            
//            self.postCommentsController?.performZoomingForStartingImageView(startingImageView: imageView)
        }
    }
    
    var textViewHeightConstraint: NSLayoutConstraint?
    var postImageViewConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(textView)
        
        addSubview(timeLabel)
        addSubview(moreButton)
        
        addSubview(postImageView)
        
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        
        
        usernameLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -5).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        
        moreButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        moreButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        
        timeLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: usernameLabel.heightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: usernameLabel.topAnchor).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: moreButton.leftAnchor, constant: -5).isActive = true
        
        
        textView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 0).isActive = true
        textView.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor, constant: 0).isActive = true
        textView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 50)
        textViewHeightConstraint?.isActive = true
        
        postImageView.widthAnchor.constraint(equalTo: textView.widthAnchor).isActive = true
        postImageView.leftAnchor.constraint(equalTo: textView.leftAnchor).isActive = true
        postImageView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0).isActive = true
        postImageViewConstraint = postImageView.heightAnchor.constraint(equalToConstant: 160)
        postImageViewConstraint?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.profileImageView.image = nil
        self.usernameLabel.text = ""
        self.textView.attributedText = nil
        self.textView.linkTextAttributes = nil
        super.prepareForReuse()
    }

    
}
