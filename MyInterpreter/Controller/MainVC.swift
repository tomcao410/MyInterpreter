//
//  ViewController.swift
//  MyInterpreter
//
//  Created by Tom on 3/23/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

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
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func setInitVC()
    {
        if Auth.auth().currentUser != nil
        {
            // Create a reference to the the appropriate storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let userEmail = Auth.auth().currentUser?.email
            
            if (userEmail?.contains("interpreter"))!
            {
                let clientsController = ClientsController()
                clientsController.interpreterEmail = userEmail!
                self.navigationController?.pushViewController(clientsController, animated: false)
            }
            else
            {
                let bookingRef = Database.database().reference()
                
                let bookingPath = bookingRef.child("users").child((userEmail?.getEncodedEmail())!).child("booking")
                
                bookingPath.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                    
                    let bookingObject = snapshot.value as! String
                    if bookingObject.contains("interpreter0")
                    {
                        let listInterpreterVC = storyboard.instantiateViewController(withIdentifier: "ListInterpretersVC")
                        self.navigationController?.pushViewController(listInterpreterVC, animated: false)
                    }
                    else
                    {
                        let userDashboardVC = storyboard.instantiateViewController(withIdentifier: "UserDashboardVC")
                        self.navigationController?.pushViewController(userDashboardVC, animated: false)
                    }
                }
            }
        }
    }
    
    @IBAction func userButtonPressed(_ sender: UIButton) {
        
    }

    @IBAction func interpreterButtonPressed(_ sender: UIButton) {
        
    }
    
}

