//
//  StyleGuideManager.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation
import UIKit


public class StyleGuideManager {
    private init(){}
    
    static let sharedInstance : StyleGuideManager = {
        let instance = StyleGuideManager()
        return instance
    }()
    
    //intro
    static let introBackgroundColor = UIColor(r: 0, g: 204, b: 253)
    static let floatingSpaceinLabelFont = UIFont(name: "Helvetica-Bold", size: 72)
    static let crytpTweetsDefaultColor = UIColor(r: 52, g: 76, b: 104)
    static let crytpTweetsBarTintColor = UIColor(r: 19, g: 45, b: 79)
    
    //chart colors
    static let redColor = UIColor(r: 218, g: 31, b: 38)
    static let greenColor = UIColor(r: 142, g: 216, b: 89)
    
    static let likeButtonActiveBlueColor = UIColor(r: 0, g: 116, b: 240)
    static let likeButtonEmoticonColor = UIColor(r: 255, g: 192, b: 6)
    static let likeButtonAngryColor = UIColor(r: 251, g: 90, b: 38)
    
    
    //Fonts
    func loginFontLarge() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 30)!

    }
    
    func loginPageFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 15)!
    }
    
    func loginPageSmallFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 13)!
    }
    
    func askLocationViewFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 16)!
    }
    
    //MARK: - Forgot Password
    
    func forgotPasswordPageFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 17)!
    }
    
    //MARK: - Profile
    func profileNameLabelFont() -> UIFont {
        return UIFont(name: "Helvetica", size: 20)!
    }
    
    func profileSublabelFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 16)!
    }
    
    func profileBioFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 14)!
    }
    
    func profileNotificationsFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 10)!
    }
}


