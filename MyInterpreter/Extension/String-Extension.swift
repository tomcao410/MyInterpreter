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
}
