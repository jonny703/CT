//
//  ProfileController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD


enum ProfileControlerStatus {
    case myProfile
    case other
}

protocol ProfileControllerDelegate {
    func resetUserProfile()
}

class ProfileController: UICollectionViewController {
    
    let ctUserFollowersCellId = "ctUserFollowersCellId"
    let ctUserFollowingsCellId = "ctUserFollowingsCellId"
    
    var profileControllerStatus: ProfileControlerStatus?
    
    var ctUserId: String? {
        
        didSet {
            fetchUserProfile()
            fetchFollwersAndFollowingsCount(nil)
        }
        
    }
    var ctUser: CTUser?
    
    let profileContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.itunesArtwork.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let userNameLabel: UILabel = {
    
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
    }()
    
    let fullNameLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
    }()
    
    let memberSinceLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .darkGray
        return label
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Follow", for: .normal)
        button.backgroundColor = StyleGuideManager.crytpTweetsDefaultColor
        let image = UIImage(named: AssetName.follow.rawValue)?.withRenderingMode(.alwaysTemplate)
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
    
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.profileController = self
        mb.translatesAutoresizingMaskIntoConstraints = false
        return mb
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addPushNotificationObserver()
    }

    deinit {
        removePushNotificationObserver()
    }
}

//MARK: handle show ctuser profile
extension ProfileController {
    
    func handleShowCTUserProfile(ctUserId: String) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        if currentUserId == ctUserId { return }
        
        let layout = UICollectionViewFlowLayout()
        let profileController = ProfileController(collectionViewLayout: layout)
        profileController.ctUserId = ctUserId
        let navController = UINavigationController(rootViewController: profileController)
        
        self.present(navController, animated: true, completion: nil)
        
    }
}

//MARK: hanlde notification for reloaddata
extension ProfileController {
    fileprivate func addPushNotificationObserver() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(fetchFollwersAndFollowingsCount), name: .ReloadCollectionViewDataInMenuBar, object: nil)
        
    }
    
    fileprivate func removePushNotificationObserver() {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: .ReloadCollectionViewDataInMenuBar, object: nil)
    }
}

//MARK: fetch followers and followings count
extension ProfileController {
    
    func fetchFollwersAndFollowingsCount(_ notification: Notification?) {
        
        guard let userId = ctUserId else { return }
        
        let followersRef = Database.database().reference().child("followers").child(userId)
        
        let followingsRef = Database.database().reference().child("followings").child(userId)
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let count = snapshot.childrenCount
            self.menuBar.titleNames[0] = "Followers \(count)"
            
            print("followers ", count)
            
            followingsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let count = snapshot.childrenCount
                self.menuBar.titleNames[1] = "Followings \(count)"
            
                print("followings ", count)
                self.menuBar.collectionView.reloadData()
                
                var selectedIndexPath: IndexPath
                if let index = notification?.userInfo?["index"] as? Int {
                    selectedIndexPath = IndexPath(item: index, section: 0)
                } else {
                    selectedIndexPath = IndexPath(item: 0, section: 0)
                }
                
                self.menuBar.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
    
}


//MARK: reset userprofile after updating
extension ProfileController: ProfileControllerDelegate {
    func resetUserProfile() {
        
        fetchUserProfile()
        
    }
}

//MARK: handle collectionview
extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ctUserFollowingsCellId, for: indexPath) as! CTUserFollowingsCell
            cell.ctUserId = self.ctUserId
            cell.profileController = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ctUserFollowersCellId, for: indexPath) as! CTUserFollowersCell
            cell.ctUserId = self.ctUserId
            cell.profileController = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 238)
    }
    
    
}

//MARK: handle scroll
extension ProfileController {
    
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: [], animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        menuBar.horizontalBArLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 2
        
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = targetContentOffset.pointee.x / view.frame.width
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        
    }
}

//MARK: fetch user profile 

extension ProfileController {
    
    fileprivate func fetchUserProfile() {
        
        guard let userId = ctUserId else { return }
        let ref = Database.database().reference().child("users").child(userId)
        
        KRProgressHUD.show()
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            self.ctUser = CTUser()
            self.ctUser?.userId = userId
            self.ctUser?.setValuesForKeys(dictionary)
            
            self.setupUserProfile(ctUser: self.ctUser!)
            
            KRProgressHUD.dismiss()
            
        }, withCancel: nil)

        
    }
    
    private func setupUserProfile(ctUser: CTUser) {
        
        if let userName = ctUser.username {
            self.userNameLabel.text = userName
            if self.profileControllerStatus == .myProfile {
                
                self.navigationItem.title = "My Profile"
            } else {
                
                self.navigationItem.title = userName
            }
        }
        
        if let fullName = ctUser.fullname {
            self.fullNameLabel.text = fullName
        }
        
        if let memberSince = ctUser.memberSince {
            memberSinceLabel.text = memberSince
        } else {
            memberSinceLabel.text = "Member since Jun 1, 2017"
        }
        
        
        if let profileImageUrl = ctUser.profilePictureURL {
            if profileImageUrl != "" {
                
                self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
        }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let followingUserId = ctUser.userId else { return }
        
        self.resetFollowButton(userId: userId, followingUserId: followingUserId)
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
    
    fileprivate func resetFollowButtonWith(status: String) {
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

//MARK: handle profile follow button
extension ProfileController {
    
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
                        
                        self.resetFollowButtonWith(status: "Unfollow")
                        NotificationCenter.default.post(name: .ReloadCollectionViewDataInFollowings, object: nil)
                        NotificationCenter.default.post(name: .ReloadCollectionViewDataInStreamController, object: nil)
                        NotificationCenter.default.post(name: .ReloadCollectionViewDataInMenuBar, object: nil)
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
                        
                        self.resetFollowButtonWith(status: "Follow")
                        NotificationCenter.default.post(name: .ReloadCollectionViewDataInFollowings, object: nil)
                        NotificationCenter.default.post(name: .ReloadCollectionViewDataInStreamController, object: nil)
                        
                        NotificationCenter.default.post(name: .ReloadCollectionViewDataInMenuBar, object: nil)
                        KRProgressHUD.dismiss()
                    })
                    
                })
            })
        }
    }

}

//MARK: handle update, dismiss controller

extension ProfileController {
    
    func handleEditProfile() {
        
        let profileEditController = ProfileEditController()
        profileEditController.ctUser = self.ctUser
        profileEditController.profileControllerDelegate = self
        let navController = UINavigationController(rootViewController: profileEditController)
        present(navController, animated: true, completion: nil)

    }

    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}


//MARK: setup Background

extension ProfileController {
    
    fileprivate func setupViews() {
        
        setupBackground()
        setupNavBar()
        setupProfileView()
        setupMenuBar()
        setupCollectionView()
        
    }
    
    private func setupProfileView() {
        
        view.addSubview(profileContainerView)
        
        profileContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        profileContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileContainerView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        profileContainerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        
        profileContainerView.addSubview(profileImageView)
        profileContainerView.addSubview(userNameLabel)
        profileContainerView.addSubview(fullNameLabel)
        profileContainerView.addSubview(memberSinceLabel)
        profileContainerView.addSubview(followButton)
        
        profileImageView.leftAnchor.constraint(equalTo: profileContainerView.leftAnchor, constant: 20).isActive = true
        profileImageView.topAnchor.constraint(equalTo: profileContainerView.topAnchor, constant: 20).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant:60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        
        followButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        followButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        followButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        followButton.rightAnchor.constraint(equalTo: profileContainerView.rightAnchor, constant: -10).isActive = true
        
        if self.profileControllerStatus == .myProfile {
            self.followButton.isHidden = true
        } else {
            self.followButton.isHidden = false
        }
        
        userNameLabel.rightAnchor.constraint(equalTo: followButton.leftAnchor, constant: -5).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 15).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5).isActive = true
        
        fullNameLabel.rightAnchor.constraint(equalTo: userNameLabel.rightAnchor).isActive = true
        fullNameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        fullNameLabel.leftAnchor.constraint(equalTo: userNameLabel.leftAnchor, constant: 0).isActive = true
        fullNameLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -5).isActive = true
        
        memberSinceLabel.widthAnchor.constraint(equalTo: profileContainerView.widthAnchor).isActive = true
        memberSinceLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        memberSinceLabel.leftAnchor.constraint(equalTo: profileImageView.leftAnchor, constant: 0).isActive = true
        memberSinceLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10).isActive = true
        
        

    }
    
    private func setupMenuBar() {
        
        view.addSubview(menuBar)
        
//        view.addConnstraintsWith(Format: "H:|[v0]|", views: menuBar)
//        view.addConnstraintsWith(Format: "V:[v0(50)]", views: menuBar)
        
        menuBar.topAnchor.constraint(equalTo: profileContainerView.bottomAnchor).isActive = true
        menuBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        menuBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        menuBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupCollectionView() {
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        collectionView?.backgroundColor = .lightGray
        
        collectionView?.register(CTUserFollowersCell.self, forCellWithReuseIdentifier: ctUserFollowersCellId)
        collectionView?.register(CTUserFollowingsCell.self, forCellWithReuseIdentifier: ctUserFollowingsCellId)
        
        collectionView?.contentInset = UIEdgeInsets(top: 172, left: 0, bottom: 0, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        
        collectionView?.isPagingEnabled = true
    }
    
    fileprivate func setupBackground() {
        
        view.backgroundColor = .lightGray
    }
    
    fileprivate func setupNavBar() {
        
        self.navigationController?.isNavigationBarHidden = false
        
        
        let image = UIImage(named: AssetName.close.rawValue)?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissController))
        
        if self.profileControllerStatus == .myProfile {
            let updateButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleEditProfile))
            updateButton.tintColor = .white
            self.navigationItem.rightBarButtonItem = updateButton

            self.navigationItem.title = "My Profile"
        } else {
            self.navigationItem.rightBarButtonItem = nil
            
            if let userName = ctUser?.username {
                self.navigationItem.title = userName
            }
        }
        
        
        navigationController?.navigationBar.barTintColor = StyleGuideManager.crytpTweetsBarTintColor
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}
