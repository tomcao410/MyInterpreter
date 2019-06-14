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
        nameLabel.text = newUser.getName()
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
//        bookingRef.updateChildValues(["timeStart": Date().getString(with: "yyyy-MM-dd HH:mm:ss")])
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
    
//    func createAlert(about newUser: User, newBookingID: String) -> UIAlertController {
//        let alert = UIAlertController(title: "New booking to you", message: newUser.email, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
//
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//            Database.database().reference().child("bookings").child(newBookingID).updateChildValues(["confirm": false])
//            self.visualEffectView.isHidden = true
//        }))
//
//        return alert
//    }

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
        
        observeInterpreterMode { (working) in
            if working == true {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sleep", style: .plain, target: self, action: #selector(self.sleepModeOn))
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Work", style: .plain, target: self, action: #selector(self.workModeOn))
            }
        }
    }
    
    let workingButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Work", style: .plain, target: self, action: #selector(workModeOn))
        return button
    }()
    let sleepButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Sleep", style: .plain, target: self, action: #selector(sleepModeOn))
        return button
    }()
    
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
        if let cachedImage = cached.object(forKey: listUser[indexPath.row].email.getEncodedEmail() as AnyObject) {
            controller.userProfileImage = (cachedImage as! UIImage)
        } else {
            downloadUserProfileImage(from: listUser[indexPath.row].email.getEncodedEmail()) { (image) in
                controller.userProfileImage = image 
            }
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

class MessageCell: BaseCell {
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundColor = highlighted ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        nameLabel.textColor = highlighted ? .white : .black
        timeLabel.textColor = highlighted ? .white : .black
        messageLabel.textColor = highlighted ? .white : .darkGray
    }
    
    func observeMessageAndChangeCellViews(about userId: String) {
        Database.database().reference().child("messages").queryOrdered(byChild: "user").queryEqual(toValue: userId).observe(.childAdded) { (snapshot) in
            
            guard let newMessage = snapshot.value as? NSDictionary else {
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            guard let date = dateFormatter.date(from: newMessage.value(forKey: "time") as! String) else {
                fatalError()
            }
            
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
            
            if (newMessage.value(forKey: "image") != nil) {
                self.messageLabel.text = "Đã gửi một tin nhắn hình ảnh"
            } else if (newMessage.value(forKey: "text") != nil) {
                self.messageLabel.text = (newMessage.value(forKey: "text") as! String)
            } else if (newMessage.value(forKey: "video") != nil) {
                
            }
        }
    }
    
    var user: User? {
        didSet {
            //get user from database
            self.nameLabel.text = user!.getName()
            self.messageLabel.text = "Hello"
            
            observeMessageAndChangeCellViews(about: (self.user?.email.getEncodedEmail())!)
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

extension Date {
    func getString(with formatString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        formatter.timeZone = TimeZone(abbreviation: "GMT+7:00")
        return formatter.string(from: self)
    }
}
