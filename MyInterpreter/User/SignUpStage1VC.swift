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
        
        hideKeyboard() // hide keyboard when tap anywhere outside the text field
        
        lblError.isHidden = true
        
        nameField.delegate = self
        secondLanguagePicker.delegate = self
        motherLanguagePicker.delegate = self
    }
    
    // MARK: Work place
    
    // MARK: --------KEYBOARD--------
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (dissmissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dissmissKeyboard()
    {
        view.endEditing(true)
    }
    
    // MARK: --------BUTTON--------
    @IBAction func nextButtonClicked(_ sender: Any)
    {
        guard  let name = nameField.text else {
            lblError.isHidden = false
            lblError.text = "Name field must be filled!!!"
            return
        }
        
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

// MARK: --------TEXT FIELD--------
extension SignUpStage1VC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField {
        case nameField:
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
