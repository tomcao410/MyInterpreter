//
//  UserDashboardVC.swift
//  MyInterpreter
//
//  Created by Tom on 5/26/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

class UserDashboardVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "userIcon"), style: .plain, target: self, action: nil)
    }
    
    
}
