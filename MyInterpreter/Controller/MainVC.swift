//
//  ViewController.swift
//  MyInterpreter
//
//  Created by Tom on 3/23/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Firebase

class MainVC: UIViewController {

    
    // MARK: To do
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        if Auth.auth().currentUser != nil
        {
            print("There is user!!!!")
            try! Auth.auth().signOut()
        }
    }
    
    // MARK: Work place
    private func setUI()
    {
        navigationItem.setCustomNavBar(title: "MyInterpreter")
    }
}

extension UINavigationItem
{
    func setCustomNavBar(title: String)
    {
        self.title = title
        self.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
