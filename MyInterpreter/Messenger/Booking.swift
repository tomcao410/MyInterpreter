//
//  Booking.swift
//  MyInterpreter
//
//  Created by Macbook on 6/11/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation

class Booking {
    var timeEnd: String
    var timeStart: String
    var confirm: Bool
    var price: String
    var user: String
    
    init(dic: NSDictionary) {
        timeEnd = dic.value(forKey: "timeEnd") as! String
        timeStart = dic.value(forKey: "timeStart") as! String
        confirm = dic.value(forKey: "confirm") as! Bool
        price = dic.value(forKey: "price") as! String
        user = dic.value(forKey: "user") as! String
    }
}
