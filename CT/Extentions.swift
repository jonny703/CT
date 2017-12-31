//
//  Extentions.swift
//  LendSystem
//
//  Created by PAC on 3/28/17.
//  Copyright © 2017 PAC. All rights reserved.
//

import UIKit

extension Float {
    //    var clean: String { return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.2f", self) : String(self) }
    
    var clean: String {
        return  String(format: "%.1f", self)
    }
    
    var cleanKm: String {
        return  String(format: "%d", self)
    }
    
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
        
    }
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
}

extension String
{
    var md5: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        return String(format: hash as String)
    }
}


extension UIView {
    
    func addConstraintsWithFormat(format: String, views:UIView...) {
        var viewDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewDictionary))
    }
    
}

extension UIButton {
    
    func buttonNameWith(name: String) {
        
        self.setTitle(name, for: .normal)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.setTitleColor(UIColor.black, for: .normal)
        self.setTitleColor(UIColor.blue, for: .selected)
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func imageWithString(name: String, radius: CGFloat) {
        
        let image = UIImage(named: name)
        
        self.image = image
        
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.borderWidth = DEVICE_WIDTH * 0.004
        self.layer.borderColor = UIColor.black.cgColor
        
    }
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.sync {
                
                if let downloadedImage = UIImage(data: data!) {
                    
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                    
                }
            }
            
        }).resume()
    }
}
