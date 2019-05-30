//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Macbook on 4/21/19.
//  Copyright © 2019 Spiritofthecore. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var interpreterEmail: String = ""
    var userId: String = ""
    var messages: [Message] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChatLogMessageCell
        
        Database.database().reference().child("users").child(self.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let info = snapshot.value as? NSDictionary {
                let user = User(email: info.value(forKey: "email") as! String, name: info.value(forKey: "name") as! String, motherLanguage: info.value(forKey: "motherLanguage") as! String, secondLanguage: info.value(forKey: "secondLanguage") as! String, profileImageURL: info.value(forKey: "profileImageURL") as! String, booking: info.value(forKey: "booking") as! String)
                let imageURL = URL(string: user.profileImageURL)
                do {
                    let imageData = try Data(contentsOf: imageURL!)
                    cell.profileImageView.image = UIImage(data: imageData)
                } catch let error {
                    print(error)
                }
                cell.messageTextView.text = self.messages[indexPath.row].text
                let sizeToFit = CGSize(width: self.view.frame.width * 2 / 3, height: CGFloat.greatestFiniteMagnitude)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: self.messages[indexPath.row].text).boundingRect(with: sizeToFit, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
                if (self.messages[indexPath.row].sender == "user") {
                    cell.messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                    cell.textBubbleView.frame = CGRect(x: 48 , y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                    cell.profileImageView.isHidden = false
                } else {
                    cell.messageTextView.frame = CGRect(x: self.view.frame.width - estimatedFrame.width - 16 - 16, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                    cell.textBubbleView.frame = CGRect(x: self.view.frame.width - estimatedFrame.width - 16 - 8 - 16, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                    cell.profileImageView.isHidden = true
                    
                    cell.textBubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 255/255, alpha: 1)
                }
            }
        })
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text = messages[indexPath.row].text
        let sizeToFit = CGSize(width: view.frame.width * 2 / 3, height: CGFloat.greatestFiniteMagnitude)

        return text.getTextViewRect(sizeToFit: sizeToFit, font: UIFont.systemFont(ofSize: 16), startPoint: CGPoint(x: 0, y: 0)).height + 20
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()

        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 8)
        return headerView
    }


    private let cellID = "cellID"
    let tableView = UITableView()
//    var friend: Friend? {
//        didSet{
//            navigationItem.title = friend?.name
//
//            messages = friend?.messages?.allObjects as? [Message]
//            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
//        }
//    }

    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        return view
    }()

    let inputTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "Enter Message..."
        textField.backgroundColor = UIColor.lightGray
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        tabBarController?.tabBar.isHidden = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tableView.register(ChatLogMessageCell.self, forCellReuseIdentifier: cellID)
        tableView.separatorColor = .clear

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        tableView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true

        view.addSubview(messageInputContainerView)
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageInputContainerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        messageInputContainerView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        messageInputContainerView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        setUpInputComponent()

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc func handleKeyboardNotification(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            print(keyboardRectangle.height)
        }
    }

    private func setUpInputComponent() {
        messageInputContainerView.addSubview(inputTextField)
        inputTextField.translatesAutoresizingMaskIntoConstraints = false

        inputTextField.leftAnchor.constraint(equalTo: messageInputContainerView.leftAnchor).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: messageInputContainerView.heightAnchor, multiplier: 1).isActive = true
        inputTextField.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
}


class ChatLogMessageCell: BaseCell {

    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true

        return view
    }()

    let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()

    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textAlignment = .left
        textView.backgroundColor = .clear
        return textView
    }()

//    let imageBubbleView: UIImageView = {
//        let bubbleView = UIImageView()
//        bubbleView.image = UIImage(named: "bubble1")?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 25, bottom: 23, right: 42)).withRenderingMode(.alwaysTemplate)
//        //bubbleView.tintColor = UIColor(white: 0.95, alpha: 1)
//        return bubbleView
//    }()

    override func setupViews() {
        super.setupViews()
        addSubview(textBubbleView)
        addSubview(messageTextView)
//        messageTextView.translatesAutoresizingMaskIntoConstraints = false
//        textBubbleView.translatesAutoresizingMaskIntoConstraints = false
//
//        textBubbleView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        textBubbleView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        textBubbleView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 2/3).isActive = true
//        textBubbleView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1, constant: -20).isActive = true
//
//        messageTextView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        messageTextView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        messageTextView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 2/3).isActive = true
//        messageTextView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1, constant: -20).isActive = true
        addSubview(profileImageView)
        profileImageView.backgroundColor = #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: textBubbleView.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true

//        textBubbleView.addSubview(imageBubbleView)
//        imageBubbleView.translatesAutoresizingMaskIntoConstraints = false
//        imageBubbleView.widthAnchor.constraint(equalTo: textBubbleView.widthAnchor, multiplier: 1).isActive = true
//        imageBubbleView.heightAnchor.constraint(equalTo: textBubbleView.heightAnchor, multiplier: 1).isActive = true
//        imageBubbleView.centerXAnchor.constraint(equalToSystemSpacingAfter: textBubbleView.centerXAnchor, multiplier: 1).isActive = true
//        imageBubbleView.centerYAnchor.constraint(equalToSystemSpacingBelow: textBubbleView.centerYAnchor, multiplier: 1).isActive = true
    }
}

extension String {
    func getTextViewRect(sizeToFit: CGSize, font: UIFont, startPoint: CGPoint) -> CGRect {
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: self).boundingRect(with: sizeToFit, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
        return CGRect(x: startPoint.x, y: startPoint.y, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
    }
}
