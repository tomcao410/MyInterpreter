//
//  ListUsersVC.swift
//  MyInterpreter
//
//  Created by Tom on 5/26/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Firebase

class ListUsersVC: UIViewController {

    @IBOutlet weak var listUsersTableView: UITableView!
    
    var totalUsers: Int = 0
    var listUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: ---Get users info from database---
    private func getInterpreterInfo()
    {
        DispatchQueue.global(qos: .userInteractive).async {
            let ref = Database.database().reference().child("users")
            
            ref.observe(.value) { (snapshot: DataSnapshot) in
                if snapshot.childrenCount > 0
                {
                    self.listUsers.removeAll()
                    self.totalUsers = Int(snapshot.childrenCount)
                    
                    for artists in snapshot.children.allObjects as![DataSnapshot]
                    {
                        let artistObject = artists.value as? [String: Any]
                        
                        let booking = artistObject?["booking"] as! String
                        if booking == (Auth.auth().currentUser?.email)!.replacingOccurrences(of: "@gmail.com", with: "")
                        {
                            let email = artistObject?["email"]
                            let name = artistObject?["name"]
                            let motherLanguage = artistObject?["motherLanguage"]
                            let secondLanguage = artistObject?["secondLanguage"]
                            let imageURL = artistObject?["profileImageURL"]
                            let artist = User(email: email as! String, name: name as! String, motherLanguage: motherLanguage as! String, secondLanguage: secondLanguage as! String, profileImageURL: imageURL as! String, booking: booking)
                            
                            self.listUsers.append(artist)
                            
                            DispatchQueue.main.async {
                                self.listUsersTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
}

// MARK: Delegate: --------TABLE VIEW--------
extension ListUsersVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! ListUsersCell

        return cell
    }
    
    
}
