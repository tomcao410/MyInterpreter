//
//  SignUpStage2VC.swift
//  MyInterpreter
//
//  Created by Tom on 3/29/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
class SignUpStage2VC: UIViewController {

    // MARK: UI elements
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPWField: UITextField!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    // MARK: views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        emailField.delegate = self
        passwordField.delegate = self
        confirmPWField.delegate = self
    }
    
    // MARK: Work place
    // MARK: ---Functions---
    
    private func setUI()
    {
        keyboardEvents()
        hideKeyboard() // hide keyboard when tap anywhere outside the textfield
        
        lblError.isHidden = true // Error UI
        
        // Profile Image UI
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoPickerController)))
        userImage.isUserInteractionEnabled = true
    }
    
    
    // MARK: ---Create user info in Firebase
    private func saveUserInfo(user: User)
    {
        // STORAGE
        let storageRef = Storage.storage().reference().child("users_profile_images").child("\(user.getEncodedEmail()).png") // Upload file to storage need a name for that file
        
        if let uploadData = self.userImage.image!.pngData()
        {
            storageRef.putData(uploadData, metadata: nil) { (metaData: StorageMetadata?, error: Error?) in
                if error != nil
                {
                    self.alertAction(title: "Uploading image failed!", message: String(describing: error))
                }
                else
                {
                    storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                        if error != nil
                        {
                            self.alertAction(title: "Uploading image failed!", message: String(describing: error))
                        }
                        else
                        {
                            // DATABASE
                            user.setProfileImageURL(imageURL: (url?.absoluteString)!)
                            
                            let databaseRef = Database.database().reference()
                            
                            let childPath = "users/" + user.getEncodedEmail()
                            
                            databaseRef.child(childPath).setValue(["email": user.email, "name": user.name, "motherLanguage": user.motherLanguage, "secondLanguage": user.secondLanguage, "profileImageURL": user.profileImageURL])
                            
                            // Update users booking status (default: "interpreter0" - means the user hasn't booked anyone yet)
                            databaseRef.child("users/\(user.getEncodedEmail())/booking").setValue("interpreter0")
                        }
                    })
                }
            }
        }
    }
    
    // Image Tap Handler
    @objc private func photoPickerController()
    {
        let myPickerController = UIImagePickerController()
        myPickerController.allowsEditing = true
        myPickerController.delegate = self
        myPickerController.sourceType = .photoLibrary
        self.present(myPickerController, animated: true)
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
    
    // MARK: --------ALERT--------
    private func alertAction(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        self.present(alert, animated: true, completion: nil)
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

// MARK: Delegate --------UIPICKER IMAGE - NAVIGATIONCONTROLLER--------
extension SignUpStage2VC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage
        {
            self.userImage.image = editedImage
        }
        else
        {
            if let image = info[.originalImage] as? UIImage
            {
                self.userImage.image = image
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
