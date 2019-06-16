//
//  String-Extension.swift
//  MyInterpreter
//
//  Created by Tom on 6/7/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation


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
    
    // From this: 2016-06-15 12:24:26 PM
    // to: Jun 15, 2019 at 12:24:26 PM
    func dateFormatter(date: String) -> String
    {
        var result = ""
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss a"
        dateFormatterGet.amSymbol = "AM"
        dateFormatterGet.pmSymbol = "PM"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy 'at' H:mm:ss a"
        dateFormatterPrint.amSymbol = "AM"
        dateFormatterPrint.pmSymbol = "PM"
        

        if let formattedDate = dateFormatterGet.date(from: date) {
            result = dateFormatterPrint.string(from: formattedDate)
        } else {
            print("There was an error decoding the string")
        }
        
        return result
    }
}
