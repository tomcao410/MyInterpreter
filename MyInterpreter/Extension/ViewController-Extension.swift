//
//  Keyboard-Extension.swift
//  MyInterpreter
//
//  Created by Tom on 6/7/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController
{
    // MARK: --------KEYBOARD--------
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func customAlertAction(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
