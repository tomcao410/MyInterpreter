//
//  SignInUserVC.swift
//  MyInterpreter
//
//  Created by Tom on 3/29/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Firebase

class SignInUserVC: UIViewController
{

    // MARK: UI elements
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lblError: UILabel!
    
    // MARK: views
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboard() // hide keyboard when tap anywhere outside the text field
        
        lblError.isHidden = true
        
        emailField.delegate = self
        passwordField.delegate = self
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
    @IBAction func handleLogIn(_ sender: UIButton)
    {
        guard let email = emailField.text else {return}
        guard let pass = passwordField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: pass) { (user: AuthDataResult?, error: Error?) in
            if user != nil
            {
                self.performSegue(withIdentifier: "userLogInSegue", sender: self)
            }
            else
            {
                self.lblError.isHidden = false
                self.lblError.text = error!.localizedDescription
            }
        }
    }
    

}

// MARK: Delegate --------TEXT FIELD--------
extension SignInUserVC: UITextFieldDelegate
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
            hideKeyboard()
        default:
            break
        }
        return true
    }
}
