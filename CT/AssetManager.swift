//
//  AssetManager.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation
import UIKit

enum AssetName: String {
    
    
    case itunesArtwork = "iTunesArtwork"
    case icStreamMore = "ic_stream_more"
    case icStream = "ic_stream"
    case icInbox = "ic_inbox"
    case icTvDark = "ic_tv"
    case icNotification = "ic_notification"
    case arrowUp = "arrow_up"
    case arrowDown = "arrow_down"
    case addPost = "addPost"
    case sendButton = "sendButton"
    case addPhoto = "addPhoto"
    case addPhotos = "addPhotos"
    case close = "close"
    case addUser = "addUser"
    case playIcon = "playbutton_image"
    case logo = "logo"
    case plusIcon = "plusIcon"
    case more = "more"
    case cancel = "cancel"
    case leftArrow = "left-arrow"
    case alarm = "alarm"
    case search = "search"
    case emoticonLove = "emoticon_love"
    case emoticonSad = "emoticon_sad"
    case emoticonLike = "emoticon_like"
    case emoticonAngry = "emoticon_angry"
    case emoticonHappy = "emoticon_happy"
    case emoticonConfused = "emoticon_confused"
    
    case likeActive = "like_actived"
    case likeInactive = "like_inactive-1"
    case comment = "comment"
    
    case follow = "follow"
    case unfollow = "unfollow"
}

class AssetManager {
    static let sharedInstance = AssetManager()
    
    static var assetDict = [String : UIImage]()
    
    class func imageForAssetName(name: AssetName) -> UIImage {
        let image = assetDict[name.rawValue] ?? UIImage(named: name.rawValue)
        assetDict[name.rawValue] = image
        return image!
    }
    
}
