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

        if Auth.auth().currentUser != nil
        {
            print("There is user!!!!")
            try! Auth.auth().signOut()
        }
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
    @IBAction func userButtonPressed(_ sender: UIButton) {
        sender.pulsate()
    }

    @IBAction func interpreterButtonPressed(_ sender: UIButton) {
        sender.pulsate()
    }
    
}

