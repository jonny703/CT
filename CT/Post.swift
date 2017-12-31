//
//  Post.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase

class Post: NSObject {
    
    var fromId: String?
    var category: String?
    var postId: String?
    var text: String?
    var timestamp: NSNumber?
    var imageUrl: String?
    var isBlock: String?
    
    var status: String?
    var interests: NSNumber?
    var comments: NSNumber?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        category = dictionary["category"] as? String
        postId = dictionary["postId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        
        imageUrl = dictionary["imageUrl"] as? String
        isBlock = dictionary["isBlock"] as? String
    }
    
}

