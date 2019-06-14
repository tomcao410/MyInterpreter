//
//  Date-Extension.swift
//  MyInterpreter
//
//  Created by Tom on 6/12/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation


extension Date {
    func getString(with formatString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        formatter.timeZone = TimeZone(abbreviation: "GMT+7:00")
        return formatter.string(from: self)
    }
}
