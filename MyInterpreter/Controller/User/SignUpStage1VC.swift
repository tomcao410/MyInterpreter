//
//  SignUpVC.swift
//  MyInterpreter
//
//  Created by Tom on 3/29/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

class SignUpStage1VC: UIViewController {

    // MARK: UI elements
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var motherLanguagePicker: UIPickerView!
    @IBOutlet weak var secondLanguagePicker: UIPickerView!
    @IBOutlet weak var lblError: UILabel!
    
    static var user = User()
    
    var languages: [String] = ["English",
                               "Vietnamese",
                               "German",
                               "Korean",
                               "Spanish",
                               "Japanese"]
    var name: String = ""
    var motherLang: String = ""
    var secondLang: String = ""
    
    // MARK: views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        nameField.delegate = self
        secondLanguagePicker.delegate = self
        motherLanguagePicker.delegate = self
    }
    
    // MARK: Work place
    
    // MARK: Set UI
    private func setUI()
    {
        hideKeyboard() // hide keyboard when tap anywhere outside the text field
        
        navigationItem.setCustomNavBar(title: "Register")
        
        lblError.isHidden = true
    }
    
    // MARK: --------BUTTON--------
    @IBAction func nextButtonClicked(_ sender: Any)
    {
        if (nameField.text?.isEmpty)!
        {
            lblError.isHidden = false
            lblError.text = "Name field must be filled!!!"
        }
        else
        {
            lblError.isHidden = true
            name = nameField.text!
            if motherLang.isEmpty
            {
                motherLang = languages[0]
            }
            if secondLang.isEmpty
            {
                secondLang = languages[0]
            }
            
            SignUpStage1VC.user.setName(name: name)
            SignUpStage1VC.user.setMotherLanguage(motherLanguage: motherLang)
            SignUpStage1VC.user.setSecondLanguage(secondLanguage: secondLang)
            performSegue(withIdentifier: "userRegisterSegue1", sender: self)
        }
        
        
    }
    
    

}

// MARK: --------TEXT FIELD--------
extension SignUpStage1VC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField {
        case nameField:
            if !(nameField.text?.isEmpty)!
            {
                lblError.isHidden = true
            }
            nameField.resignFirstResponder()
            hideKeyboard()
            break
        default:
            break
        }
        return true
    }
}

// MARK: --------PICKER VIEW--------
extension SignUpStage1VC: UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == motherLanguagePicker)
        {
            motherLang = languages[row]
        }
        else
        {
            secondLang = languages[row]
        }
    }
    
}
