//
//  User.swift
//  MyInterpreter
//
//  Created by Tom on 4/1/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation

class User
{
    var name: String
    var motherLanguage: String
    var secondLanguage: String
    var email: String
    
    init()
    {
        name = ""
        motherLanguage = ""
        secondLanguage = ""
        email = ""
    }
    
    // MARK: name
    func getName() -> String
    {
        return name
    }
    
    func setName(name: String)
    {
        self.name = name
    }
    
    // MARK: motherlanguage
    func getMotherLanguage() -> String
    {
        return motherLanguage
    }
    
    func setMotherLanguage(motherLanguage: String)
    {
        self.motherLanguage = motherLanguage
    }
    
    // MARK: secondlanguage
    func getSecondLanguage() -> String
    {
        return secondLanguage
    }
    
    func setSecondLanguage(secondLanguage: String)
    {
        self.secondLanguage = secondLanguage
    }
    
    // MARK: Email
    func getEmail() -> String
    {
        return email
    }
    
    func getEncodedEmail() -> String
    {
        return email.replacingOccurrences(of: "@gmail.com", with: "")
    }
    
    func setEmail(email: String)
    {
        self.email = email
    }
}
