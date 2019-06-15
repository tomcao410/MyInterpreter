//
//  Data-Extension.swift
//  MyInterpreter
//
//  Created by Tom on 6/7/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation
 

extension Date {
    func toDate() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        let date = dateFormatter.string(from: self)
        return date
    }
    
    func getString(with formatString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        formatter.timeZone = TimeZone(abbreviation: "GMT+7:00")
        return formatter.string(from: self)
    }
}
