//
//  Alert-Extension.swift
//  MyInterpreter
//
//  Created by Tom on 6/9/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

extension UIAlertController
{
    func customAlertAction(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
