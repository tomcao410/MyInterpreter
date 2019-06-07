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
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date = dataFormatter.string(from: self)
        return date
    }
}
