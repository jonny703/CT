//
//  User.swift
//  SpaceIn
//
//  Created by PAC on 7/17/17.
//  Copyright © 2017 Ricky. All rights reserved.
//

import UIKit

class SpaceUser: NSObject {
    
    var userId: String?
    var name: String?
    var profilePictureURL: String?
    var email: String?
    var location: String?
    var bio: String?
    var age: NSNumber?
    var job: String?
    var isLogIn: NSNumber?
    var user_location: [String: [String: Any]]?
    var postCount: NSNumber?
}
