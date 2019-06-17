//
//  Data-Extension.swift
//  MyInterpreter
//
//  Created by Tom on 6/7/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation
 

extension Date {
    func toDate(with formatString: String) -> String
    {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = formatString
        
        let date = dataFormatter.string(from: self)
        return date
    }
}
