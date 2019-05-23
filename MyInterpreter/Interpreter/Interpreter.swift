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
    var name: String
    var motherLanguage: String
    var secondLanguage: String
    var profileImageURL: String
    init()
    {
        name = ""
        motherLanguage = ""
        secondLanguage = ""
        profileImageURL = ""
    }
    
    init(name: String, motherLanguage: String, secondLanguage: String, profileImageURL: String)
    {
        self.name = name
        self.motherLanguage = motherLanguage
        self.secondLanguage = secondLanguage
        self.profileImageURL = profileImageURL
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
}
