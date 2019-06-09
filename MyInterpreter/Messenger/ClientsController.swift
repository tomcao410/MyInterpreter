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
    var newUsersAndBookingID: [String] = [] {
        didSet {
            for item in self.newUsersAndBookingID {
                
                var arr = item.split(separator: " ")
                let newUserId: String = String(arr[0])
                let newBookingId: String? = arr.count > 1 ? String(arr[1]) : nil
                getUser(from: newUserId) { (newUser) in
                    DispatchQueue.main.async {
                        let alert = self.createAlert(about: newUser, newBookingID: newBookingId!)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            self.newUsersAndBookingID.removeAll()
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
    
    func createAlert(about newUser: User, newBookingID: String) -> UIAlertController {
        let alert = UIAlertController(title: "New booking to you", message: newUser.email, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            Database.database().reference().child("bookings").child(newBookingID).updateChildValues(["confirm": true])
            self.listUser.append(newUser)
            self.visualEffectView.isHidden = true
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            Database.database().reference().child("bookings").child(newBookingID).updateChildValues(["confirm": false])
            self.visualEffectView.isHidden = true
        }))
        
        return alert
    }

    private let cellID = "cellID"
    
    var listUser: [User] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var interpreterEmail: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Recent"
        view.addSubview(tableView)
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tableView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        
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
        setUpPopUpViews()
    }
    
    func observeUsers() {
        Database.database().reference().child("bookings").observe(.childAdded, with: { (snapshot) in
            
            guard let newBooking = snapshot.value as? NSDictionary else {
                return
            }
            
            let encodedEmail = self.interpreterEmail.getEncodedEmail()
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+7:00")
            let stringDate = dateFormatter.string(from: date)
            if ((newBooking["interpreter"] as! String) == encodedEmail && (newBooking["timeEnd"] as! String) > stringDate && (newBooking["timeStart"] as! String) < stringDate) {
                if (newBooking["confirm"] as! Bool == true) {
//                    self.usersId.append(newBooking["user"] as! String)
                    self.getUser(from: newBooking["user"] as! String, completion: { (user) in
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
        controller.userId = listUser[indexPath.row].getEncodedEmail()
        let thisCell = self.tableView.cellForRow(at: indexPath) as? MessageCell
        controller.userProfileImage = thisCell?.profileImageView.image
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func setUpPopUpViews() {
        let blurEffect = UIBlurEffect(style: .dark)
        self.visualEffectView.effect = blurEffect
        self.view.addSubview(visualEffectView)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        visualEffectView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        visualEffectView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        visualEffectView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        
        visualEffectView.isHidden = true
    }
    
}

class MessageCell: BaseCell {
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundColor = highlighted ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        nameLabel.textColor = highlighted ? .white : .black
        timeLabel.textColor = highlighted ? .white : .black
        messageLabel.textColor = highlighted ? .white : .darkGray
    }
    
    var messages: Array<String>? {
        didSet {
            
        }
    }
    
    var user: User? {
        didSet {
            //get user from database
            self.nameLabel.text = user!.getName()
            self.messageLabel.text = "Hello"
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            
            let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
            let secondsInDay: TimeInterval = 60 * 60 * 24
            
            if elapsedTimeInSeconds > secondsInDay {
                dateFormatter.dateFormat = "EEE"
            }
            
            if elapsedTimeInSeconds > 7 * secondsInDay {
                dateFormatter.dateFormat = "MM/dd/YY"
            }
            
            self.timeLabel.text = dateFormatter.string(from: date as Date)
        }
    }

    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    let seenImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setupViews() {
        
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.heightAnchor.constraint(equalToConstant: 68).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 68).isActive = true
        profileImageView.centerYAnchor.constraint(equalToSystemSpacingBelow: self.centerYAnchor, multiplier: 1).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: (90-68)/2).isActive = true
        
        setupContainerView()
    }
    private func setupContainerView() {
        let containerView = UIView()
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 90).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        containerView.addSubview(messageLabel)
        containerView.addSubview(nameLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: containerView.leadingAnchor, multiplier: 1).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40).isActive = true
        messageLabel.heightAnchor.constraint(equalToConstant: 60/2).isActive = true
        messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0).isActive = true
        
        nameLabel.heightAnchor.constraint(equalToConstant: 60/2).isActive = true
        nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        nameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: containerView.leadingAnchor, multiplier: 1).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40).isActive = true
        
        containerView.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor, multiplier: 1).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        timeLabel.centerYAnchor.constraint(equalToSystemSpacingBelow: nameLabel.centerYAnchor, multiplier: 1).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        containerView.addSubview(seenImage)
        seenImage.translatesAutoresizingMaskIntoConstraints = false
        
        seenImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        seenImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
        seenImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
        seenImage.centerYAnchor.constraint(equalToSystemSpacingBelow: messageLabel.centerYAnchor, multiplier: 1).isActive = true
        
    }
}










class BaseCell: UITableViewCell{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
    }
}
