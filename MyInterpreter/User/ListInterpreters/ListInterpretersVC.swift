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
    @IBOutlet weak var listInterpreters: UITableView!
    
    var totalInterpreters = Int()
    var interpreters = [Interpreter]()
    
    // MARK: views
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get total interpreters from database
        getTotalInterpreters()

        
        listInterpreters.delegate = self
        listInterpreters.dataSource = self
    }
    
    // MARK: Work place
    
    // Get total interpreters from database
    private func getTotalInterpreters()
    {
        DispatchQueue.global(qos: .userInteractive).async
            {
                let ref = Database.database().reference()
                
                ref.child("interpreters/total").observeSingleEvent(of: .value) { (snapshot) in
                    self.totalInterpreters = snapshot.value as! Int
                    
                    // Get all interpreters info
                    self.getInterpreterInfo()
                    
                    DispatchQueue.main.async {
                        self.listInterpreters.reloadData()
                    }
                }
        }
    }
    
    // Get interpreter info from database
    private func getInterpreterInfo()
    {
        DispatchQueue.global(qos: .userInteractive).async
            {
                var path = "interpreters/interpreter"
                let namePath = "name"
                let motherLanguagePath = "motherLanguage"
                let secondLanguagePath = "secondLanguage"
                
                var childPath = ""
                for i in 1...self.totalInterpreters
                {
                    path += String(i)
                    
                    let ref = Database.database().reference()
                    
                    // Name
                    childPath = path + namePath
                    ref.child(childPath).observeSingleEvent(of: .value) { (snapshot) in
                        self.interpreters[i].setName(name: snapshot.value as! String)
                    }
                    
                    // Mother language
                    childPath = path + motherLanguagePath
                    ref.child(childPath).observeSingleEvent(of: .value) { (snapshot) in
                        self.interpreters[i].setMotherLanguage(motherLanguage: snapshot.value as! String)
                    }
                    
                    // Second language
                    childPath = path + secondLanguagePath
                    ref.child(childPath).observeSingleEvent(of: .value) { (snapshot) in
                        self.interpreters[i].setSecondLanguage(secondLanguage: snapshot.value as! String)
                    }
                    
                    // Refresh tableview
                    DispatchQueue.main.async {
                        self.listInterpreters.reloadData()
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
        cell.nameLbl.text = interpreters[indexPath.row].getName()
        cell.languagesLbl.text = interpreters[indexPath.row].getMotherLanguage() + " - " + interpreters[indexPath.row].getSecondLanguage()
        
        return cell
    }
    
    
}
