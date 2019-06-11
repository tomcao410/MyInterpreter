//
//  UserEditProfileVC.swift
//  MyInterpreter
//
//  Created by Tom on 6/9/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Firebase


class UserEditProfileVC: UIViewController {

    // MARK: UI elements
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordStack: UIStackView!
    @IBOutlet weak var motherLanguageTextField: UITextField!
    @IBOutlet weak var secondLanguageTextField: UITextField!
    @IBOutlet weak var imageSpinner: UIActivityIndicatorView!
    @IBOutlet weak var saveSpinner: UIActivityIndicatorView!
    @IBOutlet weak var errorPasswordLbl: UILabel!
    
    // MARK: Params
    var languagesPicker = UIPickerView()
    var languages: [String] = []
    {
        didSet{
            languagesPicker.reloadAllComponents()
        }
    }

    var cache = NSCache<AnyObject, AnyObject>()
    var isPasswordChange: Bool = false
    
    typealias Completion = (Error?) -> Void
    
    // Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    // MARK: Work place
    private func setUI()
    {
        imageSpinner.startAnimating()
        
        hideKeyboard()
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonClicked)), animated: true)
        
        // Profile Image UI
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoPickerController)))
        profileImage.isUserInteractionEnabled = true
        
        nameTextField.text = UserInfoVC.user.name
        motherLanguageTextField.text = UserInfoVC.user.motherLanguage
        secondLanguageTextField.text = UserInfoVC.user.secondLanguage
        
        if let img = self.cache.object(forKey: "editImageURL" as AnyObject)
        {
            profileImage.image = img as? UIImage
        }
        else
        {
            let url = URL(string: UserInfoVC.user.profileImageURL)
            
            guard let data = NSData(contentsOf: url!)
                else {
                    self.customAlertAction(title: "Error!", message: "Something wrong with your profile image!")
                    return
            }
            DispatchQueue.main.async
                {
                    
                    self.profileImage.image = UIImage(data: data as Data)
                    self.cache.setObject(self.profileImage.image!, forKey: "editImageURL" as AnyObject)
                    
                    self.imageSpinner.stopAnimating()
            }
        }
        
        createPickerView()
        

        passwordStack.isHidden = true
    }
    
    func changePassword(email: String, currentPassword: String, newPassword: String) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        let user = Auth.auth().currentUser
        user?.reauthenticate(with: credential, completion: { (error) in
            if error == nil {
                user?.updatePassword(to: newPassword) { (errror) in
                    DispatchQueue.main.async {
                        self.customAlertAction(title: "Notice!", message: "Update info success!")
                        self.saveSpinner.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.errorPasswordLbl.isHidden = true
                        self.dismiss(animated: true)
                    }
                }
            } else {
                self.customAlertAction(title: "Error!", message: "Update password failed!")
                self.errorPasswordLbl.text = "Wrong password input"
                self.errorPasswordLbl.isHidden = false
                self.saveSpinner.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        })
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
    
    // MARK: ---PickerView
    func createPickerView()
    {
        // UI
        languagesPicker.delegate = self
        
        motherLanguageTextField.inputView = languagesPicker
        secondLanguageTextField.inputView = languagesPicker
        
        motherLanguageTextField.addDoneCancelToolbar()
        secondLanguageTextField.addDoneCancelToolbar()
        
        languagesPicker.backgroundColor = UIColor.white
        
        // Data
        DispatchQueue.global(qos: .userInteractive).async {
            let databaseRef = Database.database().reference().child("languages")
            
            databaseRef.observe(.childAdded, with: { (snapshot: DataSnapshot) in
                
                let language = snapshot.value as? String
                if let actualLanguage = language {
                    self.languages.append(actualLanguage)
                }
            })
        }
    }
    
    // MARK: ---BUTTON---
    @IBAction func changePasswordBtnClicked(_ sender: Any) {
        passwordStack.isHidden = false
        isPasswordChange = true
    }
    
    @objc func saveButtonClicked()
    {
        // Display input error
        if nameTextField.text == "" || isPasswordChange
        {
            if nameTextField.text == ""
            {
                nameTextField.layer.borderWidth = 1
                nameTextField.layer.borderColor = UIColor(red: 186, green: 0, blue: 0, alpha: 1).cgColor
            }
            if !isPasswordChange
            {
                return
            }
        }
        if isPasswordChange
        {
            if currentPasswordTextField.text == ""
            {
                currentPasswordTextField.layer.borderWidth = 1
                currentPasswordTextField.layer.borderColor = UIColor(red: 186, green: 0, blue: 0, alpha: 1).cgColor
                return
            }
            
            if newPasswordTextField.text != confirmPasswordTextField.text ||
                (newPasswordTextField.text?.isEmpty)! ||
                (confirmPasswordTextField.text?.isEmpty)!
            {
                errorPasswordLbl.text = "Password and confirm password does not match"
                errorPasswordLbl.isHidden = false
                return
            }
        }
        
        saveSpinner.startAnimating()
        self.view.isUserInteractionEnabled = false
        nameTextField.layer.borderColor = UIColor(red: 204, green: 204, blue: 204, alpha
            : 1).cgColor
        currentPasswordTextField.layer.borderColor = UIColor(red: 204, green: 204, blue: 204, alpha
            : 1).cgColor
        
        // Update info to firebase
        DispatchQueue.global(qos: .userInteractive).async {
            let userEmail = Auth.auth().currentUser?.email
            
            // STORAGE
            let storageRef = Storage.storage().reference().child("users_profile_images").child("\((userEmail?.getEncodedEmail())!).png") // Upload file to storage need a name for that file
            
            DispatchQueue.main.async {
                if let uploadData = self.profileImage.image!.pngData()
                {
                    DispatchQueue.global().async {
                        storageRef.putData(uploadData, metadata: nil) { (metaData: StorageMetadata?, error: Error?) in
                            if error != nil
                            {
                                self.customAlertAction(title: "Error", message: "Uploading image failed!")
                                self.saveSpinner.stopAnimating()
                                self.view.isUserInteractionEnabled = true
                            }
                            else
                            {
                                storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                                    if error != nil
                                    {
                                        self.customAlertAction(title: "Uploading image failed!", message: String(describing: error))
                                        self.saveSpinner.stopAnimating()
                                        self.view.isUserInteractionEnabled = true
                                    }
                                    else
                                    {
                                        // DATABASE
                                        let userRef = Database.database().reference().child("users").child((userEmail?.getEncodedEmail())!)
                                        
                                        if let name = self.nameTextField.text,
                                            let motherLang = self.motherLanguageTextField.text,
                                            let secondLang = self.secondLanguageTextField.text
                                        {
                                            userRef.setValue(["name": name, "motherLanguage": motherLang, "secondLanguage": secondLang, "profileImageURL": (url?.absoluteString)!, "email": userEmail, "booking": UserInfoVC.user.booking])
                                        }
                                        if self.isPasswordChange
                                        {
                                            self.changePassword(email: userEmail!, currentPassword: self.currentPasswordTextField.text!, newPassword: self.newPasswordTextField.text!)
                                        }
                                        else
                                        {
                                            DispatchQueue.main.async {
                                                self.customAlertAction(title: "Notice!", message: "Update info success!")
                                                self.saveSpinner.stopAnimating()
                                                self.view.isUserInteractionEnabled = true
                                                self.navigationController?.popViewController(animated: true)
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: Delegate --------PICKER VIEW--------
extension UserEditProfileVC: UIPickerViewDelegate, UIPickerViewDataSource
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
        if motherLanguageTextField.isFirstResponder
        {
            motherLanguageTextField.text = languages[row]
        }
        else if secondLanguageTextField.isFirstResponder
        {
            secondLanguageTextField.text = languages[row]
        }
    }
}

// MARK: Delegate --------TEXTFIELD--------
extension UserEditProfileVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField {
        case currentPasswordTextField:
            currentPasswordTextField.resignFirstResponder()
            newPasswordTextField.becomeFirstResponder()
            break
        case newPasswordTextField:
            newPasswordTextField.resignFirstResponder()
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            confirmPasswordTextField.resignFirstResponder()
            hideKeyboard()
        default:
            break
        }
        return true
    }
}

// MARK: Delegate --------UIPICKER IMAGE - NAVIGATIONCONTROLLER--------
extension UserEditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage
        {
            self.profileImage.image = editedImage
        }
        else
        {
            if let image = info[.originalImage] as? UIImage
            {
                self.profileImage.image = image
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
