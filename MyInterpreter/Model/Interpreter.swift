//
//  Interpreter.swift
//  MyInterpreter
//
//  Created by Tom on 4/26/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation

class Interpreter
{
    var email: String
    var name: String
    var motherLanguage: String
    var secondLanguage: String
    var profileImageURL: String
    var status: Bool
    init()
    {
        email = ""
        name = ""
        motherLanguage = ""
        secondLanguage = ""
        profileImageURL = ""
        status = false
    }
    
    init(email: String, name: String, motherLanguage: String, secondLanguage: String, profileImageURL: String, status: Bool)
    {
        self.email = email
        self.name = name
        self.motherLanguage = motherLanguage
        self.secondLanguage = secondLanguage
        self.profileImageURL = profileImageURL
        self.status = status
    }
    
    init(dic: NSDictionary) {
        self.email = dic.value(forKey: "email") as! String
        self.name = dic.value(forKey: "name") as! String
        self.motherLanguage = dic.value(forKey: "motherLanguage") as! String
        self.secondLanguage = dic.value(forKey: "secondLanguage") as! String
        self.profileImageURL = dic.value(forKey: "profileImageURL") as! String
        self.status = (dic.value(forKey: "status") != nil)
    }
    
    // MARK: email
    func getEmail() -> String
    {
        return email
    }
    
    func setEmail(email: String)
    {
        self.email = email
    }
    
    // MARK: profile image
    func getProfileImageURL() -> String
    {
        return profileImageURL
    }
    
    func setProfileImageURL(imageURL: String)
    {
        self.profileImageURL = imageURL
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
    
    // MARK: status
    func getStatus() -> Bool
    {
        return self.status
    }
    
    func setStatus(status: Bool)
    {
        self.status = status
    }
}

