//
//  ListInterpretersVC.swift
//  MyInterpreter
//
//  Created by Tom on 4/24/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Firebase

class ListInterpretersVC: UIViewController {

    // MARK: UI elements
    @IBOutlet weak var listInterpretersTableView: UITableView!

    // MARK: Parameters
    var totalInterpreters = Int()
    var listInterpreters = [Interpreter]()
    {
        didSet
        {
            listInterpretersTableView.reloadData()
        }
    }
    
    static var selectedInterpreter = Interpreter()
    var cache = NSCache<AnyObject, AnyObject>()
    
    // MARK: views
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get total interpreters from database
        getInterpreterInfo()
        
        setUI()

    }
    
    
    // MARK: Work place
    private func setUI()
    {
        let userButton = UIBarButtonItem(image: #imageLiteral(resourceName: "userIcon"), style: .plain, target: self, action: #selector(userButtonClicked))
        
        navigationItem.rightBarButtonItem = userButton
        navigationItem.hidesBackButton = true
        navigationItem.setCustomNavBar(title: "Interpreters")
        
        listInterpretersTableView.tableFooterView = UIView()
        
        listInterpretersTableView.delegate = self
        listInterpretersTableView.dataSource = self
    }
    
    @objc func userButtonClicked()
    {
        performSegue(withIdentifier: "userInfoSegue", sender: nil)
    }
    
    // MARK: ---Get interpreter info from database---
    private func getInterpreterInfo()
    {
        DispatchQueue.global(qos: .userInteractive).async {
            let ref = Database.database().reference().child("interpreters")
            
            ref.observe(.value) { (snapshot: DataSnapshot) in
                if snapshot.childrenCount > 0
                {
                    self.listInterpreters.removeAll()
                    self.totalInterpreters = Int(snapshot.childrenCount)
                    
                    DispatchQueue.main.async {
                        self.listInterpretersTableView.reloadData()
                    }
                    
                    for object in snapshot.children.allObjects as![DataSnapshot]
                    {
                        let artistObject = object.value as? [String: Any]
                        
                        let email = artistObject?["email"]
                        let name = artistObject?["name"]
                        let motherLanguage = artistObject?["motherLanguage"]
                        let secondLanguage = artistObject?["secondLanguage"]
                        let imageURL = artistObject?["profileImageURL"]
                        
                        let artist = Interpreter(email: email as! String, name: name as! String, motherLanguage: motherLanguage as! String, secondLanguage: secondLanguage as! String, profileImageURL: imageURL as! String)
                        
                        self.listInterpreters.append(artist)

                    }
                    
                }
            }
        }
    }

}


// MARK: --------Table View--------
extension ListInterpretersVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalInterpreters
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "interpreterCell") as! ListInterpretersCell

        // MARK: THREAD ERROR HERE!!!!
        cell.nameLbl.text = listInterpreters[indexPath.row].getName()
        cell.languagesLbl.text = listInterpreters[indexPath.row].getMotherLanguage() + " - " + listInterpreters[indexPath.row].getSecondLanguage()
        
        // Save data in cache (prevent from lagging)
        if let img = cache.object(forKey: self.listInterpreters[indexPath.row].email as AnyObject)
        {
            cell.interpreterImage.image = img as? UIImage
        }
        else
        {
            DispatchQueue.global().async
            {
                let url = URL(string: self.listInterpreters[indexPath.row].getProfileImageURL())
                let data = NSData(contentsOf: url!)
                DispatchQueue.main.async
                {
                    cell.interpreterImage.image = UIImage(data: data! as Data)
                    self.cache.setObject(cell.interpreterImage.image!, forKey: self.listInterpreters[indexPath.row].email as AnyObject)
                    cell.spinner.stopAnimating()
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ListInterpretersVC.selectedInterpreter = listInterpreters[indexPath.row]
        performSegue(withIdentifier: "paymentSegue", sender: nil)
    }
}
