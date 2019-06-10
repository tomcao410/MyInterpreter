//
//  UserEditProfileVC.swift
//  MyInterpreter
//
//  Created by Tom on 6/9/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

class UserEditProfileVC: UIViewController {

    // MARK: UI elements
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordStack: UIStackView!
    
    
    // MARK: Params
    var user = User()
    
    // Views
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    // MARK: Work place
    private func setUI()
    {
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonClicked)), animated: true)
    }
    
    @objc func saveButtonClicked()
    {
        
    }
    
    // MARK: --------BUTTON--------
    @IBAction func changePasswordBtnClicked(_ sender: Any) {
        
    }
    
}

// MARK: Delegate --------PICKER VIEW--------
extension UserEditProfileVC: UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    
}
