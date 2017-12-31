//
//  Constants.swift
//  LendSystem
//
//  Created by PAC on 4/5/17.
//  Copyright © 2017 PAC. All rights reserved.
//

import Foundation
import UIKit


let User_Image_Radius: CGFloat = DEVICE_WIDTH * 0.16

let DEVICE_WIDTH = UIScreen.main.bounds.size.width
let DEVICE_HEIGHT = UIScreen.main.bounds.size.height


let TextField_Width: CGFloat = 200

let ShowAnswersTime: Int = 10
let WaitingTime: Int = 5

let AlertDelay: Int = 2

let CorrectPoints: Int = 10


enum RequestStatus {
    case First
    case Second
}

enum ProfileControllerStatus {
    case Signup
    case Update
    case Photo
}
