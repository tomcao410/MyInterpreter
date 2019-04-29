//
//  SignUpStage2VC.swift
//  MyInterpreter
//
//  Created by Tom on 3/29/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Firebase

class SignUpStage2VC: UIViewController {

    // MARK: UI elements
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPWField: UITextField!
    @IBOutlet weak var lblError: UILabel!
    
    var totalUsers: Int = 0
    
    // MARK: views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboard() // hide keyboard when tap anywhere outside the textfield
        
        lblError.isHidden = true
        
        // Get total users from database
        let ref = Database.database().reference()
        
        ref.child("users/total").observeSingleEvent(of:  .value) { (snapshot) in
            self.totalUsers = snapshot.value as! Int
        }
        
        emailField.delegate = self
        passwordField.delegate = self
        confirmPWField.delegate = self
    }
    
    // MARK: Work place
    // MARK: ---Functions---
    // Create user info in Database (Firebase)
    private func saveUserInfo(user: User)
    {
        let ref = Database.database().reference()
        
        let childPath = "users/" + user.getEncodedEmail()

        ref.child(childPath).setValue(["email": user.email, "name": user.name, "motherLanguage": user.motherLanguage, "secondLanguage": user.secondLanguage])
        
        // Update total users
        ref.child("users/total").setValue(totalUsers)
    }
    
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
    @IBAction func handleCreate(_ sender: UIButton)
    {
        guard let email = emailField.text else {return}
        guard let pass = passwordField.text else {return}
        guard let confirm = confirmPWField.text else {return}
        
        if pass == confirm
        {
            Auth.auth().createUser(withEmail: email, password: pass)
            { (user: AuthDataResult?, error: Error?) in
                if user != nil && error == nil
                {
                    SignUpStage1VC.user.setEmail(email: email)
                    self.saveUserInfo(user: SignUpStage1VC.user)
                    self.performSegue(withIdentifier: "userRegisterSegue2", sender: self)
                }
                else
                {
                    self.lblError.isHidden = false
                    self.lblError.text = error!.localizedDescription
                }
            }
        }
        else
        {
            // MARK: Password and Confirm aren't match
            lblError.isHidden = false
            lblError.text = "Password and Confirm aren't match"
        }
        
    }
}

// MARK: --------TEXT FIELD--------
extension SignUpStage2VC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField {
        case emailField:
            emailField.resignFirstResponder()
            passwordField.becomeFirstResponder()
            break
        case passwordField:
            passwordField.resignFirstResponder()
            confirmPWField.becomeFirstResponder()
        case confirmPWField:
            confirmPWField.resignFirstResponder()
            hideKeyboard()
        default:
            break
        }
        return true
    }
}
