//
//  BlogCell.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import KRProgressHUD

enum PostCellStatus {
    case chart
    case stream
}

protocol PostCellDelegate {
    func didClickLikeButton(index: Int, post: Post, cell: PostCell)
    func didLongClickLikeButton(index: Int, post: Post, gesture: UILongPressGestureRecognizer, cell: PostCell)
    func didClickCommentButton(index: Int, post: Post)
}

class PostCell: UICollectionViewCell {
    
    var stremController: StreamController?
    var chartDetailController: ChartDetailController?
    var post: Post? {
        didSet {
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            if let postUserId = post?.fromId {
                self.resetFollowButton(userId: userId, postUserId: postUserId)
            }
        }
    }
    var index: Int?
    var postCellStatus = PostCellStatus.stream
    
    var postCellDelegate: PostCellDelegate?
    
    
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
        //PRO Tip: don't perform a lot of custom logic inside of a view class
        guard let postUserId = post?.fromId else { return }
        if self.postCellStatus == .stream {
            self.stremController?.handleShowCTUserProfile(ctUserId: postUserId)
        } else {
            self.chartDetailController?.handleShowCTUserProfile(ctUserId: postUserId)
        }
    }
    
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
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
//        let image = UIImage(named: AssetName.likeInactive.rawValue)?.withRenderingMode(.alwaysTemplate)
//        button.setImage(image, for: .normal)
//        button.setTitle("like", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
//        button.tintColor = .darkGray
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 4)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(didClickButton(_:)), for: .touchUpInside)
        
        button.isUserInteractionEnabled = true
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongClickButton(_:)))
        gesture.minimumPressDuration = 0.5
        button.addGestureRecognizer(gesture)
        
        return button
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Unfollow", for: .normal)
        let image = UIImage(named: AssetName.unfollow.rawValue)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 4)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0)
        button.tintColor = .darkGray
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didClickButton(_:)), for: .touchUpInside)
        return button
    }()

    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.comment.rawValue)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setTitle("comment", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.tintColor = .darkGray
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 4)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(didClickButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    let interestedLabel: UILabel = {
        let label = UILabel()
        label.text = "0 interested"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    let commentedLabel: UILabel = {
        let label = UILabel()
        label.text = "0 commented"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        
        if let imageView = tapGesture.view as? UIImageView {
            
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            
            if self.postCellStatus == .stream {
                self.stremController?.performZoomingForStartingImageView(startingImageView: imageView)
            } else {
                self.chartDetailController?.performZoomingForStartingImageView(startingImageView: imageView)
            }
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
        
        
        
        
        let bottomStackView = UIStackView(arrangedSubviews: [likeButton, followButton, commentButton])
        bottomStackView.distribution = .fillEqually
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomStackView)
        
        NSLayoutConstraint.activate([
            
            bottomStackView.widthAnchor.constraint(equalTo: widthAnchor),
            bottomStackView.heightAnchor.constraint(equalToConstant: 30),
            bottomStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
            
            ])
        
        let bottomDivderLineView = UIView()
        bottomDivderLineView.backgroundColor = .lightGray
        bottomDivderLineView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomDivderLineView)
        bottomDivderLineView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        bottomDivderLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        bottomDivderLineView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        bottomDivderLineView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: 0).isActive = true
        
        let topStackView = UIStackView(arrangedSubviews: [interestedLabel, commentedLabel])
        topStackView.distribution = .fillEqually
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(topStackView)
        
        NSLayoutConstraint.activate([
            
            topStackView.widthAnchor.constraint(equalTo: widthAnchor),
            topStackView.heightAnchor.constraint(equalToConstant: 30),
            topStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            topStackView.bottomAnchor.constraint(equalTo: bottomDivderLineView.topAnchor, constant: 0)
            
            ])
        
        let topDivderLineView = UIView()
        topDivderLineView.backgroundColor = .lightGray
        topDivderLineView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(topDivderLineView)
        topDivderLineView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        topDivderLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        topDivderLineView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        topDivderLineView.bottomAnchor.constraint(equalTo: topStackView.topAnchor, constant: 0).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.profileImageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
        self.usernameLabel.text = ""
        self.textView.attributedText = nil
        self.textView.linkTextAttributes = nil
        
        self.likeButton.setImage(nil, for: .normal)
        self.likeButton.setTitle(nil, for: .normal)
        self.likeButton.setTitleColor(nil, for: .normal)
        self.likeButton.tintColor = .clear
        
        self.followButton.setImage(nil, for: .normal)
        self.followButton.setTitle(nil, for: .normal)
        self.followButton.setTitleColor(nil, for: .normal)
        self.followButton.tintColor = .clear
        
        self.interestedLabel.text = "0 interested"
        self.commentedLabel.text = "0 commented"
        super.prepareForReuse()
    }
    
    
    //handle follow button
    private func resetFollowButton(userId: String, postUserId: String) {
        if userId == postUserId {
            self.followButton.isHidden = true
            return
        } else {
            self.followButton.isHidden = false
        }
        
        let followingRef = Database.database().reference().child("followings").child(userId)
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var image: UIImage
            var title: String
            if snapshot.hasChild(postUserId) {
                image = UIImage(named: AssetName.unfollow.rawValue)!
                title = "Unfollow"
                self.followButton.tintColor = .darkGray
            } else {
                image = UIImage(named: AssetName.follow.rawValue)!
                title = "Follow"
                self.followButton.tintColor = StyleGuideManager.crytpTweetsDefaultColor
            }
            
            self.followButton.setImage(image, for: .normal)
            self.followButton.setTitle(title, for: .normal)
        })
    }
    
    private func didClickFollowButton() {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let followTargetUserId = post?.fromId else { return }
        if currentUserId == followTargetUserId { return }
        
        KRProgressHUD.show()
        
        if self.followButton.titleLabel?.text == "Follow" {
            
            self.handleFollowButtonWith(status: "Follow", currentUserId: currentUserId, followTargetUserId: followTargetUserId)
            
        } else {
            
            self.handleFollowButtonWith(status: "Unfollow", currentUserId: currentUserId, followTargetUserId: followTargetUserId)
            
        }
    }
    
    private func handleFollowButtonWith(status: String, currentUserId: String, followTargetUserId: String) {
        
        let followersRef = Database.database().reference().child("followers").child(followTargetUserId).child(currentUserId)
        let followingsRef = Database.database().reference().child("followings").child(currentUserId).child(followTargetUserId)
        let followingPostsRef = Database.database().reference().child("following-posts").child(currentUserId)
        let followingQuery = Database.database().reference().child("all-posts").queryOrdered(byChild: "fromId").queryEqual(toValue: followTargetUserId).queryLimited(toLast: 50)
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
                        self.reloadCollectionView()
                        NotificationCenter.default.post(name: .ReloadCollectionViewDataInStreamController, object: nil)
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
                        
                        let groupKeys = snapshot.children.flatMap { $0 as? DataSnapshot }.map { $0.key }
                        
                        for child in groupKeys {
                            
                            followingPostsRef.updateChildValues([child: NSNull()])
                        }
                        
                        self.reloadCollectionView()
                        NotificationCenter.default.post(name: .ReloadCollectionViewDataInStreamController, object: nil)
                        KRProgressHUD.dismiss()
                    })
                })
                
            })
        }
    }
    
    private func reloadCollectionView() {
        if self.postCellStatus == .stream {
            self.stremController?.reloadCollectionView()
        } else {
            self.chartDetailController?.reloadCollectionView()
        }
    }

    
    // handle method and delegate
    
    func didClickButton(_ sender: UIButton) {
        if sender == likeButton {
            self.postCellDelegate?.didClickLikeButton(index: index!, post: post!, cell: self)
        } else if sender == commentButton {
            self.postCellDelegate?.didClickCommentButton(index: index!, post: post!)
        } else if sender == followButton {
            
            self.didClickFollowButton()
            
        }
    }
    
    func didLongClickButton(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != UIGestureRecognizerState.ended {
            return
        }
        self.postCellDelegate?.didLongClickLikeButton(index: index!, post: post!, gesture: gesture, cell: self)
    }
    
    
}

