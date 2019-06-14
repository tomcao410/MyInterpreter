//
//  SignInUserVC.swift
//  MyInterpreter
//
//  Created by Tom on 3/29/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignInUserVC: UIViewController
{

    // MARK: UI elements
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: views
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    // MARK: Work place
    private func setUI()
    {
        keyboardEvents()
        hideKeyboard()
        
        lblError.isHidden = true
        
        navigationItem.setCustomNavBar(title: "Sign In")
        
        navigationController?.navigationBar.tintColor = .black
        
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    // MARK: --------KEYBOARD--------
    func keyboardEvents()
    {
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification)
    {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else
        {
            return
        }
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification
        {
            
            view.frame.origin.y = -0.5 * keyboardRect.height
        }
        else
        {
            view.frame.origin.y = 0
        }
    }
    
    // MARK: --------BUTTON--------
    @IBAction func handleLogIn(_ sender: UIButton)
    {
        hideKeyboard()
        spinner.startAnimating()
        loginButton.status(enable: false, hidden: true)
        
        guard let email = emailField.text else {return}
        guard let pass = passwordField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: pass) { (user: AuthDataResult?, error: Error?) in
            if user != nil
            {
                let bookingRef = Database.database().reference()
                
                let bookingPath = bookingRef.child("users").child(email.getEncodedEmail()).child("booking")
                
                bookingPath.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                    
                    let bookingObject = snapshot.value as! String
                    if bookingObject.contains("interpreter0")
                    {
                        self.loginButton.status(enable: true, hidden: false)
                        self.spinner.stopAnimating()
                        
                        self.performSegue(withIdentifier: "userLogInSegue", sender: self)
                    }
                    else
                    {
                        self.loginButton.status(enable: true, hidden: false)
                        self.spinner.stopAnimating()
                        self.performSegue(withIdentifier: "userDashboardSegue", sender: self)
                    }
                }
            }
            else
            {
                self.lblError.isHidden = false
                self.lblError.text = error!.localizedDescription
                
                self.loginButton.status(enable: true, hidden: false)
                self.spinner.stopAnimating()
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
