//
//  Booking.swift
//  MyInterpreter
//
//  Created by Tom on 6/7/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation

class Booking
{
    var interpreterID: String?
    var userID: String?
    var price: Float?
    var timeStart: Date?
    var timeEnd: Date?
    
    init()
    {
        
    }
    
    init(interpreterID: String, userID: String, price: Float, start: Date, end: Date)
    {
        self.interpreterID = interpreterID
        self.userID = userID
        self.price = price
        self.timeStart = start
        self.timeEnd = end
    }
    
    
}
