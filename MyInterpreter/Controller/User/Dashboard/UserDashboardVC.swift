//
//  UserDashboardVC.swift
//  MyInterpreter
//
//  Created by Tom on 5/26/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UserDashboardVC: UIViewController {
    
    // MARK: UI elements
    @IBOutlet weak var interpreterProfileImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // Params
    var cache = NSCache<AnyObject, AnyObject>()
    static var interpreter = Interpreter()
    
    // MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getInterpreter()
        
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
        interpreterProfileImage.layer.cornerRadius = interpreterProfileImage.frame.height/2
        
        interpreterProfileImage.layer.borderWidth = 3
        interpreterProfileImage.layer.borderColor = UIColor.blue.cgColor
    }
    
    func getInterpreter()
    {
        spinner.startAnimating()
        
        DispatchQueue.global(qos: .userInteractive).async {
            let dataRef = Database.database().reference()
            
            // Get booking object of current user
            let userBookingRef = dataRef.child("users").child((Auth.auth().currentUser?.email?.getEncodedEmail())!).child("booking")
            
            userBookingRef.observe(.value, with: { (bookingSnapshot: DataSnapshot) in
                
                let bookingObject = bookingSnapshot.value as! String
                
                // Get booked interpreter info
                let interpreterRef = dataRef.child("interpreters").child(bookingObject)
                
                interpreterRef.observe(.value, with: { (interpreterSnapshot: DataSnapshot) in
                    
                    guard let interpreterObject = interpreterSnapshot.value as? NSDictionary else
                    {
                        self.customAlertAction(title: "Error!", message: "Can't observe interpreter info from database")
                        return
                    }
                    
                    if let name = interpreterObject["name"] as? String,
                        let email = interpreterObject["email"] as? String,
                        let status = interpreterObject["status"] as? Bool,
                        let motherLanguage = interpreterObject["motherLanguage"] as? String,
                        let secondLanguage = interpreterObject["secondLanguage"] as? String,
                        let profileImageURL = interpreterObject["profileImageURL"] as? String
                    {
                        UserDashboardVC.interpreter.name = name
                        UserDashboardVC.interpreter.email = email
                        UserDashboardVC.interpreter.status = status
                        UserDashboardVC.interpreter.motherLanguage = motherLanguage
                        UserDashboardVC.interpreter.secondLanguage = secondLanguage
                        UserDashboardVC.interpreter.profileImageURL = profileImageURL
                        
                        if let img = self.cache.object(forKey: "interpreterImageURL" as AnyObject)
                        {
                            self.interpreterProfileImage.image = img as? UIImage
                        }
                        else
                        {
                            let url = URL(string: UserDashboardVC.interpreter.profileImageURL)
                            
                            guard let data = NSData(contentsOf: url!)
                                else {
                                    self.customAlertAction(title: "Error!", message: "Something wrong with your profile image!")
                                    return
                            }
                            DispatchQueue.main.async
                                {
                                    
                                    self.interpreterProfileImage.image = UIImage(data: data as Data)
                                    self.cache.setObject(self.interpreterProfileImage.image!, forKey: "interpreterImageURL" as AnyObject)
                                    
                                    self.spinner.stopAnimating()
                            }
                        }
                    }
                })
            })
        }
    }
    
    
    
    // MARK: ---BUTTON---
    @objc func photoPickerController()
    {
        let controller = ChatLogController()
        controller.userId = ((Auth.auth().currentUser?.email?.getEncodedEmail())!)
        controller.interpreterEmail = UserDashboardVC.interpreter.email
        controller.chatter = "user"
        if let notChatterProfileImage = interpreterProfileImage.image {
            controller.notChatterProfileImage = notChatterProfileImage
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func userButtonClicked()
    {
        UserInfoVC.objectID = (Auth.auth().currentUser?.email?.getEncodedEmail())!
        performSegue(withIdentifier: "userInfoSegue", sender: nil)
    }
}
