//
//  UserCell.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase

enum UserCellStatus {
    case messageController
    case usersController
}

class UserCell: UITableViewCell {
    
    var messagesController: MessagesController?
    var usersController: UsersController?
    
    var userCellStatus: UserCellStatus?
    
    var user: CTUser? {
        
        didSet {
            
            if let userName = user?.username {
                self.textLabel?.text = userName
            }
            
            if let fullName = user?.fullname {
                self.detailTextLabel?.text = fullName
            }
            
            self.timeLabel.text = nil
            self.moreButton.isHidden = true
            if let profileImageUrl = user?.profilePictureURL {
                if profileImageUrl != "" {
                    
                    self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    
                } else {
                    self.profileImageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
                }
            } else {
                self.profileImageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
            }
        }
        
    }
    
    var message: Message? {
        
        didSet {
            
            setupNameAndProfileImage()
            
            if let message = message?.text {
                self.detailTextLabel?.text = message
            } else {
                if let imageUrl = message?.imageUrl {
                    print(imageUrl)
                    self.detailTextLabel?.text = "shared photo"
                }
            }
            
            if let seconds = message?.timestamp?.doubleValue {
                
                let timestampeDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd HH:mm"
                timeLabel.text = dateFormatter.string(from: timestampeDate as Date)
                
            }
        }
        
    }
    
    private func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
        
            let ref = Database.database().reference().child("users").child(id)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    self.textLabel?.text = dictionary["username"] as? String
                    
                    
                    let profileImageUrl = dictionary["profilePictureURL"] as? String
                    if profileImageUrl != "" {
                        
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl!)
                    } else {
                        self.profileImageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: (textLabel?.frame.height)!)
        
        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
    }
    
    override func prepareForReuse() {
        self.textLabel?.text = ""
        self.profileImageView.image = nil
        super.prepareForReuse()
        
    }
    
    lazy var profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapProfileImage)))
        return imageView
        
    }()
    
    func handleTapProfileImage(tapGesture: UITapGestureRecognizer) {
        
        if self.userCellStatus == .messageController {
            guard let chatPartnerId = message?.chatPartnerId() else { return }
            
            self.messagesController?.handleShowCTUserProfile(ctUserId: chatPartnerId)
        } else {
            guard let userId = user?.userId else { return }
            self.usersController?.handleShowCTUserProfile(ctUserId: userId)
        }
        
        
    }
    
    let timeLabel: UILabel = {
        
        let label = UILabel()
//        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.textAlignment = .right
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        addSubview(profileImageView)
        addSubview(moreButton)
        addSubview(timeLabel)
        
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        moreButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        moreButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: moreButton.leftAnchor, constant: -5).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

