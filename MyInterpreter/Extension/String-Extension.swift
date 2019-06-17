//
//  String-Extension.swift
//  MyInterpreter
//
//  Created by Tom on 6/7/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
let stringFormatFromFirebase = "yyyy-MM-dd HH:mm:ss a"


extension String {
    func getEncodedEmail() -> String {
        var result = ""
        
        result = self.replacingOccurrences(of: "@", with: "-")
        
        if let index = result.range(of: ".")?.lowerBound
        {
            let substring = result[..<index]
            result = String(substring)
        }
        
        return result
    }
    func getTextViewRect(sizeToFit: CGSize, font: UIFont, startPoint: CGPoint) -> CGRect {
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: self).boundingRect(with: sizeToFit, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
        return CGRect(x: startPoint.x, y: startPoint.y, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
    }
    
    func stringDateToInt(with stringFormat: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = stringFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        let date = dateFormatter.date(from:self)!
        let timeInterval = date.timeIntervalSince1970
        return Int(timeInterval)
    }
    
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = stringFormatFromFirebase
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        guard let date = dateFormatter.date(from: self) else {
            return Date()
        }
        return date
    }
    
    func toDate(with formatString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        guard let date = dateFormatter.date(from: self) else {
            return Date()
        }
        return date
    }
}
