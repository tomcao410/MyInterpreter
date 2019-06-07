//
//  SignInViewController.swift
//  MyInterpreter
//
//  Created by Tom on 3/29/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Firebase

class SignInInterpreterVC: UIViewController
{

    // MARK: UI elements
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lblError: UILabel!
    
    
    var ref: DatabaseReference!
    
    // MARK: views
    override func viewDidLoad()
    {
        super.viewDidLoad()

        hideKeyboard() // hide keyboard when tap anywhere outside the textfield
        
        lblError.isHidden = true
        
        idField.delegate = self
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
        
        guard let email = idField.text else
        {
            return
        }
        guard let pass = passwordField.text else
        {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: pass) { (user: AuthDataResult?, error: Error?) in
            if user != nil
            {
                let clientsController = ClientsController()
                clientsController.interpreterEmail = email
                self.navigationController?.pushViewController(clientsController, animated: true)

            }
            else
            {
                self.lblError.isHidden = false
                self.lblError.text = error!.localizedDescription
            }
        }
    }
}

// MARK: --------TEXT FIELD--------
extension SignInInterpreterVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField {
        case idField:
            idField.resignFirstResponder()
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
