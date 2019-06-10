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

    static var isInterpreter: Bool = false;
    static var isUser: Bool = false;
    
    // MARK: To do
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()

        setInitVC()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARL: Work place
    private func setUI()
    {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func setInitVC()
    {
        if Auth.auth().currentUser != nil
        {
            // Create a reference to the the appropriate storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if (Auth.auth().currentUser?.email?.contains("interpreter"))!
            {
                let controller = storyboard.instantiateViewController(withIdentifier: "ListUsersVC")
                navigationController?.pushViewController(controller, animated: false)
            }
            else
            {
                let controller = storyboard.instantiateViewController(withIdentifier: "ListInterpretersVC")
                navigationController?.pushViewController(controller, animated: false)
            }
        }
    }
    
    @IBAction func userButtonPressed(_ sender: UIButton) {
        
    }

    @IBAction func interpreterButtonPressed(_ sender: UIButton) {
        
    }
    
}

