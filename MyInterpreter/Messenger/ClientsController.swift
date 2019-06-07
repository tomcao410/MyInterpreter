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
    
    let tableView = UITableView()
    private let cellID = "cellID"
    
    var usersId: [String] = [] {
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
        
        loadUsers()
//        observeUserChange()
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            tableView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
            tableView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        }
        tableView.register(MessageCell.self, forCellReuseIdentifier: cellID)
        //        setupData()
    }
    
//    func observeUserChange() {
//        Database.database().reference().child("")
//    }
    func loadUsers() {
        var newUsersAndBookingID = [String]()
        Database.database().reference().child("bookings").observe(.value, with: { (snapshot) in
            self.usersId = []
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                if let dataChange = rest.value as? NSDictionary {
                    let encodedEmail = self.interpreterEmail.getEncodedEmail()
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+7:00")
                    let stringDate = dateFormatter.string(from: date)
                    if ((dataChange["interpreter"] as! String) == encodedEmail && (dataChange["timeEnd"] as! String) > stringDate && (dataChange["timeStart"] as! String) < stringDate) {
                        if (dataChange["confirm"] as! Bool == true) {
                            DispatchQueue.main.async {
                                self.usersId.append(dataChange["user"] as! String)
                            }
                        } else {
                            DispatchQueue.main.async {
                                newUsersAndBookingID.append(dataChange["user"] as! String + " " + rest.key)
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                for item in newUsersAndBookingID {
                    var arr = item.split(separator: " ")
                    let newUser: String = String(arr[0])
                    let newBooking: String? = arr.count > 1 ? String(arr[1]) : nil
                    let blurEffect = UIBlurEffect(style: .dark)
                    let visualEffectView = UIVisualEffectView(effect: blurEffect)
                    self.view.addSubview(visualEffectView)
                    visualEffectView.translatesAutoresizingMaskIntoConstraints = false
                    
                    visualEffectView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                    visualEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                    visualEffectView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
                    visualEffectView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true

                    let newUserRef = Database.database().reference().child("users").child(newUser)
                    newUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dataChange = snapshot.value as? NSDictionary {
                            let user = User(email: dataChange.value(forKey: "email") as! String, name: dataChange.value(forKey: "name") as! String, motherLanguage: dataChange.value(forKey: "motherLanguage") as! String, secondLanguage: dataChange.value(forKey: "secondLanguage") as! String, profileImageURL: dataChange.value(forKey: "profileImageURL") as! String, booking:  dataChange.value(forKey: "booking") as! String)
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "New booking to you", message: user.email, preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
                                    Database.database().reference().child("bookings").child(newBooking!).updateChildValues(["confirm": true])
                                    visualEffectView.isHidden = true
                                    }))

                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in                  print("cancel")
                                    visualEffectView.isHidden = true
                                    }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MessageCell
        cell.userId = usersId[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = ChatLogController()
        controller.interpreterEmail = interpreterEmail
        controller.userId = usersId[indexPath.row]
        
        Database.database().reference().child("messages").queryOrdered(byChild: "user").queryEqual(toValue: usersId[indexPath.row]).observe(.value) { (snapshot) in
            if let messages = snapshot.value as? NSDictionary {
                let keyEnumulator = messages.keyEnumerator()
                while let key = keyEnumulator.nextObject() {
                    let message = messages.value(forKey: key as! String) as? NSDictionary
                    let encodedEmail = self.interpreterEmail.getEncodedEmail()
                    if (message?.value(forKey: "interpreter") as! String == encodedEmail) {
                        controller.messages.append(Message(sender: message?.value(forKey: "sender") as! String, text: message?.value(forKey: "text") as! String, user: message?.value(forKey: "user") as! String, interpreter: message?.value(forKey: "interpreter") as! String, time: message?.value(forKey: "time") as! String))
                    }
                }
            }
            controller.messages.sort(by: {$0.time < $1.time})
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

class MessageCell: BaseCell {
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundColor = highlighted ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        nameLabel.textColor = highlighted ? .white : .black
        timeLabel.textColor = highlighted ? .white : .black
        messageLabel.textColor = highlighted ? .white : .darkGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
    
    var messages: Array<String>? {
        didSet {
            
        }
    }
    
    var userId: String? {
        didSet {
            //get user from database
            Database.database().reference().child("users").child(self.userId!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dataChange = snapshot.value as? NSDictionary {
                    let user = User(email: dataChange.value(forKey: "email") as! String, name: dataChange.value(forKey: "name") as! String, motherLanguage: dataChange.value(forKey: "motherLanguage") as! String, secondLanguage: dataChange.value(forKey: "secondLanguage") as! String, profileImageURL: dataChange.value(forKey: "profileImageURL") as! String, booking:  dataChange.value(forKey: "booking") as! String)
                    self.nameLabel.text = user.getName()
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

                    DispatchQueue.global().async {
                        let imageURL = URL(string: user.profileImageURL)
                        let data = NSData(contentsOf: imageURL!)
                        DispatchQueue.main.async {
                            guard let data = data else {
                                return
                            }
                            self.profileImageView.image = UIImage(data: data as Data)
                            self.seenImage.image = UIImage(data: data as Data)
                        }
                        
                    }
                }
            })
            //get messages from database
            
        }
    }
    
    //    var message: Message? {
    //        didSet {
    //            nameLabel.text = self.message?.friend?.name
    //            if let imageName = self.message?.friend?.profileImageName {
    //                profileImageView.image = UIImage(named: imageName)
    //                seenImage.image = UIImage(named: imageName)
    //            }
    //
    //
    //        }
    //    }
    
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
