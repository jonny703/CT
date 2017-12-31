//
//  Extentions.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

extension NSRange {
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        
        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
        
        return fromIndex ..< toIndex
    }
}
extension Date {
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
        
    }
    var aWeekAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: self)!
    }
    var aMonthAgo: Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }
    var threeMonthAgo: Date {
        return Calendar.current.date(byAdding: .month, value: -3, to: self)!
        
    }
    var sixMonthAgo: Date {
        return Calendar.current.date(byAdding: .month, value: -6, to: self)!
    }
    var aYearAgo: Date {
        return Calendar.current.date(byAdding: .month, value: -12, to: self)!
    }
    
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        var isLess = false
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        return isLess
    }
    
    func equalToDate(dateToCompare: Date) -> Bool {
        var isEqual = false
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqual = true
        }
        return isEqual
    }
}

extension Double {
    //    var clean: String { return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.2f", self) : String(self) }
    
    var cleanFloat: String {
        return  String(format: "%.2f", self)
    }
    
    var cleanFloatSix: String {
        return  String(format: "%.6f", self)
    }
    
    var cleanInt: String {
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

extension UIView {
    
    func addConnstraintsWith(Format:String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: Format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func reoundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 10, height: 10))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
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



extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

let imageCache = NSCache<NSString, UIImage>()
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
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            
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
                    
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                    
                }
            }
            
        }).resume()
    }
}

class CacheImageView: UIImageView {
    var imageUrlString: String?
    
    func loadImageUsingUrlString(urlString: String) {
        
        imageUrlString = urlString
        
        let url = URL(string: urlString)
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                
                let imageToCache = UIImage(data: data!)
                
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                
                imageCache.setObject(imageToCache!, forKey: urlString as NSString)
                
                
            }
            
        }).resume()
    }

}
