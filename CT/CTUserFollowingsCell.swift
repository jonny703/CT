//
//  CTUserFollowingsCell.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class CTUserFollowingsCell: CTUserFollowersCell {
    
//    var profileControllerStatus: ProfileControlerStatus?
        
//    override func fetchCTUsers() {
//        addPushNotificationObserver()
        
        
//        fetchCTUsersFromFirebase()
//    }
    
//    deinit {
//        removePushNotificationObserver()
//    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CTUserCell
        
        cell.ctUserFollowingsCell = self
        cell.ctUserCellStatus = .following
        cell.index = indexPath.item
        
        cell.ctUser = ctUsers[indexPath.item]
        
        return cell
        
    }
    
//    //MARK: hanlde notification for reloaddata
//    fileprivate func addPushNotificationObserver() {
//        
//        let nc = NotificationCenter.default
//        nc.addObserver(self, selector: #selector(fetchCTUsersFromFirebase), name: .ReloadCollectionViewDataInFollowings, object: nil)
//        
//    }
//    
//    fileprivate func removePushNotificationObserver() {
//        let nc = NotificationCenter.default
//        nc.removeObserver(self, name: .ReloadCollectionViewDataInFollowings, object: nil)
//    }
//    
//    func reloadCollectionView(index: Int) {
//        
//        if profileController?.profileControllerStatus == .myProfile {
//            self.ctUsers.remove(at: index)
//            self.collectionView.reloadData()
//        }
//        
//    }
    
    override func fetchCTUsersFromFirebase() {
        
        guard let ctUserId = ctUserId else { return }
        
        FirebaseService.sharedInstance.fetchCTFollowings(ctUserId: ctUserId) { (ctUsers) in
            
            self.ctUsers = ctUsers
            self.collectionView.reloadData()
            
        }
    }
    
}
