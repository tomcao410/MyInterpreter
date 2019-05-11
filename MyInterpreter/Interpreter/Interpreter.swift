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
    
    init()
    {
        name = ""
        motherLanguage = ""
        secondLanguage = ""
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
