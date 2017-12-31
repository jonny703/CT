//
//  CTUserCell.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

enum CTUserCellStatus {
    case following
    case follower
}

class CTUserCell: BaseCell {
    
    var ctUserFollowingsCell: CTUserFollowingsCell?
    var ctUserFollowersCell: CTUserFollowersCell?
    var ctUserCellStatus: CTUserCellStatus?
    var index: Int?
    
    var ctUser: CTUser? {
        
        didSet {
            
            if let userName = ctUser?.username {
                self.userNameLabel.text = userName
            }
            
            if let imageUrl = ctUser?.profilePictureURL {
                
                if imageUrl != "" {
                    self.profileImageView.loadImageUsingUrlString(urlString: imageUrl)
                } else {
                    self.profileImageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
                }
            }
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            guard let followingUserId = ctUser?.userId else {
                return
            }
            
            if userId == followingUserId {
                self.followButton.isHidden = true
                return
            } else {
                self.followButton.isHidden = false
            }
            
            resetFollowButton(userId: userId, followingUserId: followingUserId)
            
        }
        
    }
    
    private func resetFollowButton(userId: String, followingUserId: String) {
        let followingRef = Database.database().reference().child("followings").child(userId)
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(followingUserId) {
                self.resetFollowButtonWith(status: "Unfollow")
            } else {
                self.resetFollowButtonWith(status: "Follow")
            }
            
        })
    }
    
    let profileImageView: CacheImageView = {
        
        let imageView = CacheImageView()
        imageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
        
    }()
    
//    func handleShowCTUserProfile() {
//        
//        guard let ctUserId = self.ctUser?.userId else { return }
//        
//        let dictionaryData = ["ctUserId": ctUserId] as [String: String]
//        let nc = NotificationCenter.default
//        nc.post(name: .ShowCTUserProfile, object: nil, userInfo: dictionaryData)
//    }
    
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Caesar"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Unfollow", for: .normal)
        button.backgroundColor = .darkGray
        let image = UIImage(named: AssetName.unfollow.rawValue)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 4)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0)
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didClickButton(_:)), for: .touchUpInside)
        return button
    }()

    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        addSubview(userNameLabel)
        addSubview(followButton)
        
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        followButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        followButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        followButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        followButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        userNameLabel.rightAnchor.constraint(equalTo: followButton.leftAnchor, constant: -5).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 15).isActive = true
        userNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
        
        
    }
    
    override func prepareForReuse() {
        
        self.profileImageView.image = nil
        self.userNameLabel.text = ""
        
        self.followButton.setImage(nil, for: .normal)
        self.followButton.setTitle(nil, for: .normal)
        self.followButton.tintColor = .clear
        
        super.prepareForReuse()
    }
    
    func didClickButton(_ sender: UIButton) {
        if sender == followButton {
            
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
            guard let followTargetUserId = ctUser?.userId else { return }
            if currentUserId == followTargetUserId { return }
            
            KRProgressHUD.show()
            
            if self.followButton.titleLabel?.text == "Follow" {
                
                self.handleFollowButtonWith(status: "Follow", currentUserId: currentUserId, followTargetUserId: followTargetUserId)
                
            } else {
                
                self.handleFollowButtonWith(status: "Unfollow", currentUserId: currentUserId, followTargetUserId: followTargetUserId)
                
            }

            
        }
    }
    
    private func handleFollowButtonWith(status: String, currentUserId: String, followTargetUserId: String) {
        
        let followersRef = Database.database().reference().child("followers").child(followTargetUserId).child(currentUserId)
        let followingsRef = Database.database().reference().child("followings").child(currentUserId).child(followTargetUserId)
        let followingPostsRef = Database.database().reference().child("following-posts").child(currentUserId)
        let followingQuery = Database.database().reference().child("all-posts").queryOrdered(byChild: "fromId").queryEqual(toValue: followTargetUserId).queryLimited(toLast: 50)
        let nc = NotificationCenter.default
        if status == "Follow" {
            
            followersRef.updateChildValues(["status": "following"], withCompletionBlock: { (error, ref) in
                
                if error != nil {
                    KRProgressHUD.dismiss()
                    return
                }
                
                followingsRef.updateChildValues(["status": "follower"], withCompletionBlock: { (error, ref) in
                    if error != nil {
                        KRProgressHUD.dismiss()
                        return
                    }
                    
                    
                    followingQuery.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        for child in snapshot.children.allObjects as! [DataSnapshot] {
                            
                            if let dictionary = child.value as? [String: AnyObject] {
                                
                                followingPostsRef.childByAutoId().updateChildValues(dictionary)
                                
                            }
                        }
                        
                        var dictionaryData: [String: Int]
                        
                        self.resetFollowButtonWith(status: "Unfollow")
                        if self.ctUserCellStatus == .following {
                            if let index = self.index {
                                self.ctUserFollowingsCell?.reloadCollectionView(index: index)
                            }
                            dictionaryData = ["index": 1]
                        } else {
                            dictionaryData = ["index": 0]
                        }
                        nc.post(name: .ReloadCollectionViewDataInFollowings, object: nil)
                        nc.post(name: .ReloadCollectionViewDataInStreamController, object: nil)
                        nc.post(name: .ReloadCollectionViewDataInMenuBar, object: nil, userInfo: dictionaryData)
                        KRProgressHUD.dismiss()
                    })
                    
                })
            })
        } else {
            
            followersRef.removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    KRProgressHUD.dismiss()
                    return
                }
                
                followingsRef.removeValue(completionBlock: { (error, ref) in
                    
                    if error != nil {
                        KRProgressHUD.dismiss()
                        return
                    }
                    
                    followingPostsRef.queryOrdered(byChild: "fromId").queryEqual(toValue: followTargetUserId).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        // delete posts from follwoing tabel
                        let groupKeys = snapshot.children.flatMap { $0 as? DataSnapshot }.map { $0.key }
                        
                        for child in groupKeys {
                            
                            followingPostsRef.updateChildValues([child: NSNull()])
                        }
                        
                        // reload data
                        var dictionaryData: [String: Int]
                        self.resetFollowButtonWith(status: "Follow")
                        if self.ctUserCellStatus == .following {
                            if let index = self.index {
                                self.ctUserFollowingsCell?.reloadCollectionView(index: index)
                            }
                            dictionaryData = ["index": 1]
                        } else {
                            dictionaryData = ["index": 0]
                        }
                        
                        nc.post(name: .ReloadCollectionViewDataInFollowings, object: nil)
                        nc.post(name: .ReloadCollectionViewDataInStreamController, object: nil)
                        nc.post(name: .ReloadCollectionViewDataInMenuBar, object: nil, userInfo: dictionaryData)
                        
                        KRProgressHUD.dismiss()
                    })
                    
                })
            })
        }
    }
    
    private func resetFollowButtonWith(status: String) {
        var image: UIImage
        if status == "Follow" {
            image = UIImage(named: AssetName.follow.rawValue)!
            self.followButton.backgroundColor = StyleGuideManager.crytpTweetsDefaultColor
        } else {
            image = UIImage(named: AssetName.unfollow.rawValue)!
            self.followButton.backgroundColor = .darkGray
        }
        self.followButton.setImage(image, for: .normal)
        self.followButton.setTitle(status, for: .normal)
        self.followButton.tintColor = .white
    }
}






















