//
//  FireBaseService.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class FirebaseService: NSObject {
    
    static let sharedInstance = FirebaseService()
    
    func fetchCTFollowers(ctUserId: String, completion: @escaping ([CTUser]) -> ()) {
        let databaseRef = Database.database().reference().child("followers").child(ctUserId)
        fetchCTUsersWith(databaseRef: databaseRef, completion: completion)
    }
    
    func fetchCTFollowings(ctUserId: String, completion: @escaping ([CTUser]) -> ()) {
        let databaseRef = Database.database().reference().child("followings").child(ctUserId)
        fetchCTUsersWith(databaseRef: databaseRef, completion: completion)
    }

    
    func fetchCTUsersWith(databaseRef: DatabaseReference, completion: @escaping ([CTUser]) -> ()) {
        
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var ctUsers = [CTUser]()
            
            let groupKeys = snapshot.children.flatMap { $0 as? DataSnapshot }.map { $0.key }
            let group = DispatchGroup()
            
            for child in groupKeys as [String] {
                
                group.enter()
                
                let userRef = Database.database().reference().child("users").child(child)
                
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    group.leave()
                    
                    guard let dictionary = snapshot.value as? [String: AnyObject] else { return
                    }
                    
                    let ctUser = CTUser()
                    ctUser.userId = snapshot.key
                    ctUser.setValuesForKeys(dictionary)
                    
                    ctUsers.append(ctUser)
                    
                    
                    
                }, withCancel: nil)
                
                
            }
            
            group.notify(queue: .main, execute: {
                DispatchQueue.main.async {
                    completion(ctUsers)
                }
            })
            
            
        }, withCancel: nil)
        
    }
    
    
}
