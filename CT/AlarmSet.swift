//
//  AlarmSet.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class AlarmSet: NSObject, NSCoding {

    var btnName: String?
    var content: String?
    var max: Double?
    var min: Double?
    var isOn: Bool?
    
    init(json: NSDictionary) {
        
        self.btnName = json["btnName"] as? String
        self.content = json["content"] as? String
        self.max = json["max"] as? Double
        self.min = json["min"] as? Double
        self.isOn = json["isOn"] as? Bool
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.btnName = aDecoder.decodeObject(forKey: "btnName") as? String
        self.content = aDecoder.decodeObject(forKey: "content") as? String
        self.max = aDecoder.decodeObject(forKey: "max") as? Double
        self.min = aDecoder.decodeObject(forKey: "min") as? Double
        self.isOn = aDecoder.decodeObject(forKey: "isOn") as? Bool
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.btnName
            , forKey: "btnName")
        aCoder.encode(self.content, forKey: "content")
        aCoder.encode(self.max, forKey: "max")
        aCoder.encode(self.min, forKey: "min")
        aCoder.encode(self.isOn, forKey: "isOn")
        
    }
}
