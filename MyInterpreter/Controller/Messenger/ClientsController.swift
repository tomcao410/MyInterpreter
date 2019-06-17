//
//  ViewController.swift
//  ChatApp
//
//  Created by Macbook on 4/14/19.
//  Copyright © 2019 Spiritofthecore. All rights reserved.
//

import UIKit
import Firebase

class ClientsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var ref: DatabaseReference!
    
    var cached = NSCache<AnyObject, AnyObject>()
    let tableView = UITableView()
    var visualEffectView = UIVisualEffectView()
    let popUpView = UIView()
    var WorkingOnBookingID: String = ""
    var WorkingOnUser: User = User()
    var workingMode: Bool = true
    private let cellID = "cellID"
    var listUser: [User] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var listBooking: [Booking] = []
    var interpreterEmail: String = ""
    var timer = Timer()
    var newUsersAndBookingID: [String] = [] {
        didSet {
            for item in self.newUsersAndBookingID {
                
                var arr = item.split(separator: " ")
                let newUserId: String = String(arr[0])
                let newBookingId: String? = arr.count > 1 ? String(arr[1]) : nil
                getBookingInfo(from: newBookingId!) { (newBooking) in
                    self.getUser(from: newUserId) { (newUser) in
                        self.downloadUserProfileImage(from: newUserId, completion: { (image) in
                            DispatchQueue.main.async {
                                self.WorkingOnBookingID = newBookingId!
                                self.WorkingOnUser = newUser
                                self.setPopUpViews(newUser: newUser, newBooking: newBooking, profileImage: image)
                            }
                        })
                        
                    }
                }
            }
            self.newUsersAndBookingID.removeAll()
        }
    }
    
    func setPopUpViews(newUser: User, newBooking: Booking, profileImage: UIImage) {
        let goldenDecimal: CGFloat = 1.618
        
        let blurEffect = UIBlurEffect(style: .dark)
        visualEffectView.effect = blurEffect
        visualEffectView.isHidden = false
        visualEffectView.frame = view.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(visualEffectView)
        
        popUpView.backgroundColor = .white
        self.view.addSubview(popUpView)
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        popUpView.layer.cornerRadius = 10
        
        popUpView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        popUpView.widthAnchor.constraint(equalToConstant: 200 * goldenDecimal).isActive = true
        popUpView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        popUpView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        let profileImageView = UIImageView()
        profileImageView.layer.cornerRadius = 40
        profileImageView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        profileImageView.image = profileImage
        profileImageView.clipsToBounds = true
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 1.5
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        
        popUpView.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: -40).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = newUser.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 30)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        popUpView.addSubview(nameLabel)
        
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        let messageLabel = UILabel()
        messageLabel.textColor = .gray
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.text = "Book you from " + newBooking.timeStart + " to " + newBooking.timeEnd + " with a price " + newBooking.price
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        popUpView.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        messageLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        messageLabel.widthAnchor.constraint(equalToConstant: 200 * goldenDecimal - 10).isActive = true
        
        let confirmButton = UIButton()
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmBooking), for: .touchUpInside)
        
        popUpView.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        confirmButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5).isActive = true
        confirmButton.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    @objc func confirmBooking() {
        let bookingRef = Database.database().reference().child("bookings").child(WorkingOnBookingID)
        bookingRef.updateChildValues(["confirm": true])
        bookingRef.observeSingleEvent(of: .value) { (snapshot) in
            if let confirmedBooking = snapshot.value as? NSDictionary {
                self.listBooking.append(Booking(dic: confirmedBooking))
            }
        }
        self.listUser.append(WorkingOnUser)
        self.visualEffectView.isHidden = true
        self.popUpView.isHidden = true
        
    }
    
    func getBookingInfo(from id: String, completion: @escaping (Booking) -> ()) {
        let bookingRef = Database.database().reference().child("bookings").child(id)
        
        bookingRef.observeSingleEvent(of: .value) { (snapshot) in
            if let booking = snapshot.value as? NSDictionary {
                completion(Booking(dic: booking))
            }
        }
    }
    
    func getUser(from id: String, completion: @escaping (User) -> ()) {
        let userRef = Database.database().reference().child("users").child(id)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let newUser = snapshot.value as? NSDictionary else {
                return
            }
            
            let user = User(email: newUser.value(forKey: "email") as! String, name: newUser.value(forKey: "name") as! String, motherLanguage: newUser.value(forKey: "motherLanguage") as! String, secondLanguage: newUser.value(forKey: "secondLanguage") as! String, profileImageURL: newUser.value(forKey: "profileImageURL") as! String, booking:  newUser.value(forKey: "booking") as! String)
            
            completion(user)
            
        })
    }
    
    func downloadUserProfileImage(from id: String, completion: @escaping (UIImage) -> ()) {
        let userProfileImageRef = Database.database().reference().child("users").child(id).child("profileImageURL")
        
        userProfileImageRef.observe(.value, with: { (snapshot) in
            if let info = snapshot.value as? String {
                DispatchQueue.global().async {
                    let imageURL = URL(string: info)
                    let data = NSData(contentsOf: imageURL!)
                    DispatchQueue.main.async {
                        guard let data = data else {
                            return
                        }
                        completion(UIImage(data: data as Data)!)
                    }
                }
            }
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Recent"
        view.addSubview(tableView)
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tableView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.tintColor = .black
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkUserExpired), userInfo: nil, repeats: true)
        
        observeUsers()
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            tableView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
            tableView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        }
        tableView.register(MessageCell.self, forCellReuseIdentifier: cellID)
        
        observeInterpreterMode { (working) in
            if working == true {
                self.navigationItem.setRightBarButtonItems([UIBarButtonItem(image: #imageLiteral(resourceName: "Log-Out-Icon"), style: .plain, target: self, action: #selector(self.logOutButtonClicked)), UIBarButtonItem(title: "Sleep", style: .plain, target: self, action: #selector(self.sleepModeOn))], animated: true)
            } else {
                self.navigationItem.setRightBarButtonItems([UIBarButtonItem(image: #imageLiteral(resourceName: "Log-Out-Icon"), style: .plain, target: self, action: #selector(self.logOutButtonClicked)), UIBarButtonItem(title: "Work", style: .plain, target: self, action: #selector(self.workModeOn))], animated: true)
            }
        }
    }
    
    @objc func checkUserExpired() {
        var bookingIndexExpired = -1
        for (index, item) in self.listBooking.enumerated() {
            let intEndDate = item.timeEnd.cutPMAMTail().stringDateToInt(with: "yyyy-MM-dd HH:mm:ss")
            let intNowDate = Date().getString(with: "yyyy-MM-dd HH:mm:ss").stringDateToInt(with: "yyyy-MM-dd HH:mm:ss")
            if intEndDate < intNowDate {
                let alert = UIAlertController(title: "Notice", message: "A booking to you just expired", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    alert.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(cancelAction)
                bookingIndexExpired = index
                self.present(alert, animated: true, completion: nil)
            }
        }
        if bookingIndexExpired != -1 {
            self.listBooking.remove(at: bookingIndexExpired)
            self.listUser.remove(at: bookingIndexExpired)
        }
    }
    
    func observeInterpreterMode(completion: @escaping (Bool) -> ()) {
        let interpreterStatusRef = Database.database().reference().child("interpreters").child(interpreterEmail.getEncodedEmail()).child("status")
        interpreterStatusRef.observe(.value) { (snapshot) in
            completion(snapshot.value as! Bool)
        }
    }
    
    @objc func sleepModeOn() {
        let interpreterStatusRef = Database.database().reference().child("interpreters").child(interpreterEmail.getEncodedEmail()).child("status")
        interpreterStatusRef.setValue(false)
    }
    
    @objc func workModeOn() {
        let interpreterStatusRef = Database.database().reference().child("interpreters").child(interpreterEmail.getEncodedEmail()).child("status")
        interpreterStatusRef.setValue(true)
    }
    @objc func logOutButtonClicked()
    {
        try! Auth.auth().signOut()
        
        navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func observeUsers() {
        Database.database().reference().child("bookings").observe(.childAdded, with: { (snapshot) in
            
            guard let newBooking = snapshot.value as? NSDictionary else {
                return
            }
            let encodedEmail = self.interpreterEmail.getEncodedEmail()
            let intDate = Date().getString(with: "yyyy-MM-dd HH:mm:ss").stringDateToInt(with: "yyyy-MM-dd HH:mm:ss")
            let intTimeEnd = (newBooking["timeEnd"] as! String).cutPMAMTail().stringDateToInt(with: "yyyy-MM-dd HH:mm:ss")
            let intTimeStart = (newBooking["timeStart"] as! String).cutPMAMTail().stringDateToInt(with: "yyyy-MM-dd HH:mm:ss")
            if ((newBooking["interpreter"] as! String) == encodedEmail && intDate > intTimeStart && intDate < intTimeEnd) {
                if (newBooking["confirm"] as! Bool == true) {
                    self.getUser(from: newBooking["user"] as! String, completion: { (user) in
                        self.listBooking.append(Booking(dic: newBooking))
                        self.listUser.append(user)
                    })
                } else {
                    self.newUsersAndBookingID.append(newBooking["user"] as! String + " " + snapshot.key)
                }
            }
        })
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MessageCell
        
        let userID = listUser[indexPath.row].email.getEncodedEmail()
        cell.user = listUser[indexPath.row]
        
        if let cachedImage = cached.object(forKey: userID as AnyObject) {
            cell.profileImageView.image = cachedImage as? UIImage
            cell.seenImage.image = cachedImage as? UIImage
        } else {
            downloadUserProfileImage(from: userID) { (profileImage) in
                cell.profileImageView.image = profileImage
                cell.seenImage.image = profileImage
                self.cached.setObject(profileImage, forKey: userID as AnyObject)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = ChatLogController()
        controller.interpreterEmail = interpreterEmail
        controller.userId = listUser[indexPath.row].email.getEncodedEmail()
        controller.chatter = "interpreter"
        if let cachedImage = cached.object(forKey: listUser[indexPath.row].email.getEncodedEmail() as AnyObject) {
            controller.leftCellProfileImage = (cachedImage as! UIImage)
        } else {
            downloadUserProfileImage(from: listUser[indexPath.row].email.getEncodedEmail()) { (image) in
                controller.leftCellProfileImage = image
            }
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

