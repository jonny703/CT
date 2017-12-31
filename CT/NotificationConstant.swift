//
//  NotificationConstant.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

extension Notification.Name {
    
    static let DidSetCurrentUser = Notification.Name("did-set-current-user")
    static let DidSetCurrentUserProfilePicture = Notification.Name("did-set-current-user-profile-picture")
    static let DidUpdateCurrentUser = Notification.Name("did-update-current-user")
    static let DidFailGoogleLogin = Notification.Name("did-fail-google-login")
    static let DidFailAuthentication = Notification.Name("did-fail-auth")
    static let DidFailLogin = Notification.Name("did-fail-login-firebase")
    static let didSetUserLocation = Notification.Name("did-set-user-location")
    static let deniedLocationPermission = Notification.Name("did-deny-user-location")
    static let restrictedLocationPermission = Notification.Name("restricted-user-location")
    
    static let NotLogInMessage = Notification.Name("not-login-user")
    static let FetchUsersWhenLogOut = Notification.Name("fetch-users-logout")
    static let FetchUsers = Notification.Name("fetch-users")
    
    static let ShowAcceptController = Notification.Name("show-accept-controller")
    static let SetupOneSignal = Notification.Name("setup-onesignal")
    
    
    static let ReloadCollectionViewDataInStreamController = Notification.Name("reload-collectionviewdata-instreamcontroller")
    
    static let ReloadCollectionViewDataInMenuBar = Notification.Name("reload-collectionviewdata-inmenubar")
    static let ReloadCollectionViewDataInFollowings = Notification.Name("reload-collectionviewdata-infollowing")
    static let ShowCTUserProfile = Notification.Name("show-ctuser-profile")
    static let ReloadMessageTableViewData = Notification.Name("reload-messagetableviewdata")
}
