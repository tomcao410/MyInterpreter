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
    private let tableHeaderHeight: CGFloat = 400.0
    private let tableHeaderCutAway: CGFloat = 60.0
    
    var header: DetailHeaderView!
    var headerMaskLayer: CAShapeLayer!
    var userInfoSection: [String] = ["Name", "1st language", "2nd language","Email", "Booking status"]
    var user = User()
    var cache = NSCache<AnyObject, AnyObject>()
    
    var alertAction: UIAlertController!
    
    // MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()

        getUserData()
        
        
        setUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
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
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonClicked)), animated: true)
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
        
        let userId = (Auth.auth().currentUser?.email?.getEncodedEmail())!
        DispatchQueue.global().async {
            let userRef = Database.database().reference().child("users").child(userId)

            userRef.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                
                guard let userObject = snapshot.value as? NSDictionary else
                {
                    self.alertAction.customAlertAction(title: "Error!", message: "Can't observe data from database")
                    return
                }
                
                self.user.name = userObject["name"] as! String
                self.user.email = userObject["email"] as! String
                self.user.booking = userObject["booking"] as! String
                self.user.motherLanguage = userObject["motherLanguage"] as! String
                self.user.secondLanguage = userObject["secondLanguage"] as! String
                self.user.profileImageURL = userObject["profileImageURL"] as! String

                // Save image into cache
                if let img = self.cache.object(forKey: self.user.email as AnyObject)
                {
                    self.headerImage.image = img as? UIImage
                }
                else
                {
                    let url = URL(string: self.user.profileImageURL)
                    
                    guard let data = NSData(contentsOf: url!)
                        else {
                            return
                    }
                    DispatchQueue.main.async
                        {
                            self.headerImage.image = UIImage(data: data as Data)
                            self.cache.setObject(self.headerImage.image!, forKey: self.user.email as AnyObject)
                            
                            self.spinner.stopAnimating()
                            
                            self.tableView.reloadData()
                    }
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
        return userInfoSection.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userInfoCell") as! UserInfoCell
        
        cell.titleLbl.text = userInfoSection[indexPath.row]
        
        var context = ""
        
        switch indexPath.row {
        case 0:
            context = user.name
            break
        case 1:
            context = user.motherLanguage
            break
        case 2:
            context = user.secondLanguage
            break
        case 3:
            context = user.email
            break
        case 4:
            context = user.booking
            break
        default:
            alertAction.customAlertAction(title: "Error!", message: "Something wrong with your profile!")
            break
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
