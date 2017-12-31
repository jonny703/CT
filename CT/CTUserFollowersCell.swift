//
//  CTUsersCell.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class CTUserFollowersCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var profileController: ProfileController?
    
    var ctUserId: String? {
        didSet {
            fetchCTUsers()
        }
    }
    
    var ctUsers = [CTUser]()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .lightGray
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    override func setupViews() {
        super.setupViews()
        
        
        
        addSubview(collectionView)
        addConnstraintsWith(Format: "H:|[v0]|", views: collectionView)
        addConnstraintsWith(Format: "V:|[v0]|", views: collectionView)
        
        collectionView.register(CTUserCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func fetchCTUsers() {
        addPushNotificationObserver()
        fetchCTUsersFromFirebase()
    }
    
    deinit {
        removePushNotificationObserver()
    }

    
    //MARK: hanlde notification for reloaddata
    fileprivate func addPushNotificationObserver() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(fetchCTUsersFromFirebase), name: .ReloadCollectionViewDataInFollowings, object: nil)
        
    }
    
    fileprivate func removePushNotificationObserver() {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: .ReloadCollectionViewDataInFollowings, object: nil)
    }
    
    func reloadCollectionView(index: Int) {
        
        if profileController?.profileControllerStatus == .myProfile {
            self.ctUsers.remove(at: index)
            self.collectionView.reloadData()
        }
        
    }
    
     func fetchCTUsersFromFirebase() {
        
        guard let ctUserId = ctUserId else { return }
        FirebaseService.sharedInstance.fetchCTFollowers(ctUserId: ctUserId) { (ctUsers) in
            
            self.ctUsers = ctUsers
            self.collectionView.reloadData()
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ctUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CTUserCell
        cell.ctUserFollowersCell = self
        cell.ctUserCellStatus = .follower
        cell.index = indexPath.item
        cell.ctUser = ctUsers[indexPath.item]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let userId = ctUsers[indexPath.item].userId else { return }
        profileController?.handleShowCTUserProfile(ctUserId: userId)
    }
    
}















