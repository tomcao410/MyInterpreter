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
        imageURL = ""
        audioURL = ""
    }
    
    init(dic: NSDictionary) {
        sender = dic.value(forKey: "sender") as! String
        user = dic.value(forKey: "user") as! String
        interpreter = dic.value(forKey: "interpreter") as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        guard let date = dateFormatter.date(from: dic.value(forKey: "time") as! String) else {
            fatalError()
        }
        self.time = date
        
        self.text = ""
        self.imageURL = ""
        self.audioURL = ""
        
        if let text = dic.value(forKey: "text") as? String {
            self.text = text
            self.imageURL = ""
            self.audioURL = ""
        }
        if let imageURL = dic.value(forKey: "image") as? String {
            self.text = ""
            self.imageURL = imageURL
            self.audioURL = ""
        }
        if let audioURL = dic.value(forKey: "audio") as? String {
            self.text = ""
            self.imageURL = ""
            self.audioURL = audioURL
        }
    }
    
    init(sender: String, text: String, user: String, interpreter: String, time: String) {
        self.sender = sender
        self.text = text
        self.user = user
        self.interpreter = interpreter
        self.time = time.toDate(with: "yyyy-MM-dd HH:mm:ss")
        self.imageURL = ""
        self.audioURL = ""
    }
    
    init(sender: String, imageURL: String, user: String, interpreter: String, time: String) {
        self.sender = sender
        self.imageURL = imageURL
        self.user = user
        self.interpreter = interpreter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        guard let date = dateFormatter.date(from: time) else {
            fatalError()
        }
        self.time = date
        self.text = ""
        self.audioURL = ""
    }

    
    var sender: String
    var text: String
    var user: String
    var interpreter: String
    var time: Date
    var imageURL: String
    var audioURL: String
}
