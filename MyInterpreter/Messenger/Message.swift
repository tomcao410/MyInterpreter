//
//  Message.swift
//  MyInterpreter
//
//  Created by Macbook on 5/24/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation

class Message {
    init() {
        sender = ""
        text = ""
        user = ""
        interpreter = ""
        time = Date()
    }
    
    init(sender: String, text: String, user: String, interpreter: String, time: String) {
        self.sender = sender
        self.text = text
        self.user = user
        self.interpreter = interpreter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        guard let date = dateFormatter.date(from: time) else {
            fatalError()
        }
        self.time = date
    }
    
    var sender: String
    var text: String
    var user: String
    var interpreter: String
    var time: Date
}
