//
//  UserDashboardVC.swift
//  MyInterpreter
//
//  Created by Tom on 5/26/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

class UserDashboardVC: UIViewController {

    
    // MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    // MARK: Work place
    private func setUI()
    {
        let userButton = UIBarButtonItem(image: #imageLiteral(resourceName: "userIcon"), style: .plain, target: self, action: #selector(userButtonClicked))
        navigationItem.rightBarButtonItem = userButton
        
        navigationItem.setCustomNavBar(title: "Dashboard")
        navigationItem.hidesBackButton = true
    }
    
    @objc func userButtonClicked()
    {
        performSegue(withIdentifier: "userInfoSegue", sender: nil)
    }
}
