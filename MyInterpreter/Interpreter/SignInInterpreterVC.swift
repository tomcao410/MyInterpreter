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
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lblError: UILabel!
    
    
    var ref: DatabaseReference!
    
    // MARK: views
    override func viewDidLoad()
    {
        super.viewDidLoad()

        hideKeyboard() // hide keyboard when tap anywhere outside the textfield
        
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
        
        guard let email = emailField.text else
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
                
                self.ref = Database.database().reference()
                
                self.ref.child("bookings").observe(.value, with: { (snapshot) in
                    
                    let enumerator = snapshot.children
                    while let rest = enumerator.nextObject() as? DataSnapshot {
                        if let dataChange = rest.value as? [String:AnyObject] {
                            let encodedEmail = email.getEncodedEmail()
                            if ((dataChange["interpreter"] as! String) == encodedEmail) {
                                clientsController.usersId.append(dataChange["user"] as! String)
                                print(dataChange["user"] as! String)
                            }
                        }
                    }
                    
                    self.navigationController?.pushViewController(clientsController, animated: true)
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
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
