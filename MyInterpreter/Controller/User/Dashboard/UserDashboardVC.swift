//
//  UserDashboardVC.swift
//  MyInterpreter
//
//  Created by Tom on 5/26/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

class UserDashboardVC: UIViewController {

    // MARK: UI elements
    @IBOutlet weak var interpreterProfileImage: UIImageView!
    
    // Params
    
    
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
        
        interpreterProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoPickerController)))
        interpreterProfileImage.isUserInteractionEnabled = true
        
    }
    
    
    // MARK: ---BUTTON---
    @objc func photoPickerController()
    {
        // CHỖ NÀY ĐỂ PUSH TỚI CÁI VIEW CHAT NHA
    }
    
    @objc func userButtonClicked()
    {
        performSegue(withIdentifier: "userInfoSegue", sender: nil)
    }
}
