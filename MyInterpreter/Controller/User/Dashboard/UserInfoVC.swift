//
//  UserInfoVC.swift
//  MyInterpreter
//
//  Created by Tom on 6/4/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Firebase

class UserInfoVC: UIViewController {
    
    // MARK: UI elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: Params
    private let tableHeaderHeight: CGFloat = 450.0
    private let tableHeaderCutAway: CGFloat = 40.0
    
    let screenSize = UIScreen.main.bounds
    var header: DetailHeaderView!
    var headerMaskLayer: CAShapeLayer!
    var infoSection: [String] = ["Name", "1st language", "2nd language","Email", "Status"]
    var interpreter = Interpreter()
    
    static var objectID: String = ""
    static var user = User()
    
    
    // MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if UserInfoVC.objectID.contains("interpreter")
        {
            getInterpreterData()
        }
        else
        {
            getUserData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
    }
    // MARK: Work place
    private func setUI()
    {
        customNavigationBar()
        
        customTableView()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func customNavigationBar()
    {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.setCustomNavBar(title: "")
        
        if !UserInfoVC.objectID.contains("interpreter")
        {
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonClicked)), animated: true)
        }
    }
    
    // MARK: perform segue to edit profile view
    @objc func editButtonClicked()
    {
        performSegue(withIdentifier: "editProfileSegue", sender: nil)
    }
    
    // MARK: get user data from Firebase
    func getUserData()
    {
        spinner.startAnimating()
        
        DispatchQueue.global().async {
            let dataRef = Database.database().reference().child("users").child(UserInfoVC.objectID)
            
            dataRef.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                
                guard let object = snapshot.value as? NSDictionary else
                {
                    self.customAlertAction(title: "Error!", message: "Can't observe user info from database")
                    return
                }
                
                var imageURL = URL(string: "")
                
                if let name = object["name"] as? String,
                    let email = object["email"] as? String,
                    let motherLanguage = object["motherLanguage"] as? String,
                    let secondLanguage = object["secondLanguage"] as? String,
                    let profileImageURL = object["profileImageURL"] as? String,
                    let booking = object["booking"] as? String
                {
                    UserInfoVC.user.name = name
                    UserInfoVC.user.email = email
                    UserInfoVC.user.booking = booking
                    UserInfoVC.user.motherLanguage = motherLanguage
                    UserInfoVC.user.secondLanguage = secondLanguage
                    UserInfoVC.user.profileImageURL = profileImageURL
                    
                    imageURL = URL(string: UserInfoVC.user.profileImageURL)
                }
                
                // Set image view
                guard let data = NSData(contentsOf: imageURL!)
                    else {
                        self.customAlertAction(title: "Error!", message: "Something wrong with your profile image!")
                        return
                }
                DispatchQueue.main.async
                    {
                        
                        self.headerImage.image = UIImage(data: data as Data)
                        
                        self.spinner.stopAnimating()
                        
                        self.tableView.reloadData()
                }
            })
        }
    }
    
    // MARK: get interpreter data
    func getInterpreterData()
    {
        spinner.startAnimating()
        
        DispatchQueue.global().async {
            let dataRef = Database.database().reference().child("interpreters").child(UserInfoVC.objectID)
            
            dataRef.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                
                guard let object = snapshot.value as? NSDictionary else
                {
                    self.customAlertAction(title: "Error!", message: "Can't observe user info from database")
                    return
                }
                
                var imageURL = URL(string: "")
                
                if let name = object["name"] as? String,
                    let email = object["email"] as? String,
                    let motherLanguage = object["motherLanguage"] as? String,
                    let secondLanguage = object["secondLanguage"] as? String,
                    let profileImageURL = object["profileImageURL"] as? String,
                    let status = object["status"] as? Bool
                {
                    self.interpreter.name = name
                    self.interpreter.email = email
                    self.interpreter.status = status
                    self.interpreter.motherLanguage = motherLanguage
                    self.interpreter.secondLanguage = secondLanguage
                    self.interpreter.profileImageURL = profileImageURL
                    
                    imageURL = URL(string: self.interpreter.profileImageURL)
                }
                
                // Set image view
                guard let data = NSData(contentsOf: imageURL!)
                    else {
                        self.customAlertAction(title: "Error!", message: "Something wrong with your profile image!")
                        return
                }
                DispatchQueue.main.async
                    {
                        
                        self.headerImage.image = UIImage(data: data as Data)
                        
                        self.spinner.stopAnimating()
                        
                        self.tableView.reloadData()
                }
            })
        }
    }
    
    // MARK: ---Custom TableView---
    func customTableView()
    {
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        header = tableView.tableHeaderView as? DetailHeaderView
        
        tableView.tableHeaderView = nil
        tableView.addSubview(header)
        
        tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight + 64)
        
        // cut away header view
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.black.cgColor
        header.layer.mask = headerMaskLayer
        
        let effectiveHeight = tableHeaderHeight - tableHeaderCutAway/2
        tableView.contentInset = UIEdgeInsets(top: effectiveHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -effectiveHeight)
        
        updateHeaderView()
    }
    
    func updateHeaderView()
    {
        let effectiveHeight = tableHeaderHeight - tableHeaderCutAway/2
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: tableHeaderHeight)
        
        if tableView.contentOffset.y < -effectiveHeight
        {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y + tableHeaderCutAway/2
        }
        
        header.frame = headerRect
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: headerRect.height))
        //path.addLine(to: CGPoint(x: headerRect.width/2, y: headerRect.height))
        path.addLine(to: CGPoint(x: 0, y: headerRect.height - tableHeaderCutAway))
        
        headerMaskLayer.path = path.cgPath
    }
    
    // MARK: --------BUTTON--------
    @IBAction func logOutButtonClicked(_ sender: Any) {
        try! Auth.auth().signOut()
        
        navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Delegate --------TABLEVIEW--------
extension UserInfoVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoSection.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userInfoCell") as! UserInfoCell
        
        cell.titleLbl.text = infoSection[indexPath.row]
        
        var context = ""
        
        if UserInfoVC.objectID.contains("interpreter")
        {
            switch indexPath.row {
            case 0:
                context = interpreter.name
                break
            case 1:
                context = interpreter.motherLanguage
                break
            case 2:
                context = interpreter.secondLanguage
                break
            case 3:
                context = interpreter.email
                break
            case 4:
                if interpreter.status
                {
                    context = "Working"
                }
                else
                {
                    context = "Not working"
                }
                break
            default:
                self.customAlertAction(title: "Error!", message: "Something wrong with your profile!")
                break
            }
        }
        else
        {
            switch indexPath.row {
            case 0:
                context = UserInfoVC.user.name
                break
            case 1:
                context = UserInfoVC.user.motherLanguage
                break
            case 2:
                context = UserInfoVC.user.secondLanguage
                break
            case 3:
                context = UserInfoVC.user.email
                break
            case 4:
                context = UserInfoVC.user.booking
                break
            default:
                self.customAlertAction(title: "Error!", message: "Something wrong with your profile!")
                break
            }
        }
        
        
        cell.infoLbl.text = context
        
        return cell
    }
}

// MARK: Delegate --------SCROLL VIEW--------
extension UserInfoVC: UIScrollViewDelegate
{
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tableView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
        
        // MARK: Changing color of NavBar when scroll the tableview
        //        var offset = (scrollView.contentOffset.y + 370) / 15
        //        print(offset)
        //        if offset > 1
        //        {
        //            // Scroll UP
        //            offset = 1
        //            let color = UIColor.init(red: 1, green: 1, blue: 1, alpha: offset)
        //            let navColor = UIColor.init(hue: 0, saturation: offset, brightness: 0, alpha: 1)
        //
        //            self.navigationController?.navigationBar.tintColor = navColor
        //            self.navigationController?.navigationBar.backgroundColor = color
        //            UIApplication.shared.statusBarView?.backgroundColor = color
        //        }
        //        else
        //        {
        //            // Scroll DOWN
        //            let color = UIColor.init(red: 1, green: 1, blue: 1, alpha: offset)
        //            let navColor = UIColor.init(hue: 1, saturation: offset, brightness: 1, alpha: 1)
        //
        //            self.navigationController?.navigationBar.tintColor = navColor
        //
        //            self.navigationController?.navigationBar.backgroundColor = color
        //            UIApplication.shared.statusBarView?.backgroundColor = color
        //        }
    }
}
