//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Macbook on 4/21/19.
//  Copyright © 2019 Spiritofthecore. All rights reserved.
//

import UIKit
import Firebase
import AVKit

class ChatLogController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var chatter: String = ""
    var interpreterEmail: String = ""
    var userId: String = ""
    var messages: [Message] = []
    var notChatterProfileImage: UIImage?
    var cache = NSCache<AnyObject, AnyObject>()
    var doneCellCount:Int = 0
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage) -> ()) {
        if let cachedImage = cache.object(forKey: urlString as AnyObject) {
            completion(cachedImage as! UIImage)
        } else {
            DispatchQueue.global().async {
                let imageURL = URL(string: urlString)
                let data = NSData(contentsOf: imageURL!)
                DispatchQueue.main.async {
                    guard let data = data else {
                        return
                    }
                    self.cache.setObject(UIImage(data: data as Data)!, forKey: urlString as AnyObject)
                    completion(UIImage(data: data as Data)!)
                }
            }
        }
    }
    
    func getInterpreterInfo(with id: String, completion: @escaping (Interpreter) -> ()) {
        let interpreterRef = Database.database().reference().child("interpreters").child(interpreterEmail.getEncodedEmail())
        
        interpreterRef.observeSingleEvent(of: .value) { (snapshot) in
            let interpreterDic = snapshot.value as! NSDictionary
            
            completion(Interpreter(dic: interpreterDic))
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if messages[indexPath.row].imageURL != "" {
            return setUpImageCellViews(indexPath: indexPath)
        } else if messages[indexPath.row].text != "" {
            return setUpTextCellViews(indexPath: indexPath)
        } else if messages[indexPath.row].videoURL != "" {
            return setUpVideoCellViews(indexPath: indexPath)
        }
        return UITableViewCell()
    }
    
    func setUpVideoCellViews(indexPath: IndexPath) -> ChatLogMessageCell {
        return ChatLogMessageCell()
    }
    
    func setUpImageCellViews(indexPath: IndexPath) -> ChatLogMessageCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChatLogMessageCell
        
        cell.messageContent = "image"
        
        cell.textBubbleView.isHidden = true
        cell.imageContentView.isHidden = false
        
        if let cachedImage = cache.object(forKey: messages[indexPath.row].imageURL as AnyObject) as? UIImage {
            let ratio = cachedImage.size.width / cachedImage.size.height
            let maxWidth = self.view.frame.width / 3 * 2
            let maxHeight = self.view.frame.height / 3
            let viewWidth = self.view.frame.width
            
            cell.imageContentView.image = cachedImage
            
            if (self.messages[indexPath.row].sender != chatter) {
                cell.profileImageView.image = self.notChatterProfileImage
                cell.profileImageView.isHidden = false
                
                if ratio > 1.0 { //landscape image
                    cell.imageContentView.frame = CGRect(x: 48, y: 0, width: maxWidth, height: maxWidth / ratio)
                } else {
                    cell.imageContentView.frame = CGRect(x: 48, y: 0, width: maxHeight * ratio, height: maxHeight)
                }
            } else {
                cell.profileImageView.isHidden = true
                
                if ratio > 1.0 {
                    cell.imageContentView.frame = CGRect(x: viewWidth - maxWidth - 16, y: 0, width: maxWidth, height: maxWidth / ratio)
                } else {
                    cell.imageContentView.frame = CGRect(x: viewWidth - maxHeight * ratio, y: 0, width: maxHeight * ratio, height: maxHeight)
                }
            }
        }
        return cell
    }
    
    func setUpTextCellViews(indexPath: IndexPath) -> ChatLogMessageCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChatLogMessageCell
        
        cell.messageContent = "text"
        
        cell.messageTextView.text = self.messages[indexPath.row].text
        
        cell.imageContentView.isHidden = true
        cell.textBubbleView.isHidden = false
        
        let sizeToFit = CGSize(width: self.view.frame.width * 2 / 3, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: self.messages[indexPath.row].text).boundingRect(with: sizeToFit, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
        if (self.messages[indexPath.row].sender != chatter) {
            cell.messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            cell.textBubbleView.frame = CGRect(x: 48 , y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
            cell.profileImageView.image = notChatterProfileImage
            cell.messageTextView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.textBubbleView.backgroundColor = .lightGray
        } else {
            cell.messageTextView.frame = CGRect(x: self.view.frame.width - estimatedFrame.width - 16 - 16, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            cell.textBubbleView.frame = CGRect(x: self.view.frame.width - estimatedFrame.width - 16 - 8 - 16, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
            cell.profileImageView.isHidden = true
            cell.messageTextView.textColor = .white
            cell.textBubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 255/255, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if messages[indexPath.row].imageURL != "" {
            return calculateImageCellHeight(indexPath: indexPath)
        } else if messages[indexPath.row].text != "" {
            return calculateTextCellHeight(indexPath: indexPath)
        } else if messages[indexPath.row].videoURL != "" {
            return calculateVideoCellHeight(indexPath: indexPath)
        }
        return 0
    }
    
    func calculateTextCellHeight(indexPath: IndexPath) -> CGFloat {
        let text = messages[indexPath.row].text
        let sizeToFit = CGSize(width: view.frame.width * 2 / 3, height: CGFloat.greatestFiniteMagnitude)
        
        return text.getTextViewRect(sizeToFit: sizeToFit, font: UIFont.systemFont(ofSize: 16), startPoint: CGPoint(x: 0, y: 0)).height + 20
    }
    
    func calculateImageCellHeight(indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        
        if let cachedImage = cache.object(forKey: messages[indexPath.row].imageURL as AnyObject) as? UIImage {
            let ratio = cachedImage.size.width / cachedImage.size.height
            let maxWidth = self.view.frame.width / 3 * 2
            let maxHeight = self.view.frame.height / 3
            
            if ratio > 1.0 { //landscape image
                height = maxWidth / ratio + 20
            } else {
                height = maxHeight + 20
            }
        }
        
        return height
    }
    
    func calculateVideoCellHeight(indexPath: IndexPath) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 8)
        return headerView
    }
    
    
    private let cellID = "cellID"
    let tableView = UITableView()
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Message..."
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        button.addTarget(self, action: #selector(plusButtonTouch), for: .touchUpInside)
        return button
    }()
    
    
    
    var messageInputBottomAnchor: NSLayoutConstraint?
    var messageInputActivateBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        hideKeyboard()
        
        
        tabBarController?.tabBar.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tableView.register(ChatLogMessageCell.self, forCellReuseIdentifier: cellID)
        tableView.separatorColor = .clear
        tableView.allowsSelection = false
        
        observeMessage { (message) in
            if message.imageURL != "" {
                self.downloadImage(from: message.imageURL, completion: { _ in
                    self.tableView.reloadData()
                    self.doneCellCount = self.doneCellCount + 1
                    self.scrollToBottom()
                })
            } else {
                self.tableView.reloadData()
                self.doneCellCount = self.doneCellCount + 1
                self.scrollToBottom()
            }
        }
        
        let guide = view.safeAreaLayoutGuide
        
        view.addSubview(messageInputContainerView)
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        messageInputBottomAnchor = messageInputContainerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0)
        messageInputBottomAnchor?.isActive = true
        messageInputActivateBottomAnchor = messageInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        messageInputActivateBottomAnchor?.isActive = false
        messageInputContainerView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        messageInputContainerView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: messageInputContainerView.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        
        
        
        setUpInputComponent()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.doneCellCount - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func observeMessage(completion: @escaping (Message) -> ()) {
        Database.database().reference().child("messages").queryOrdered(byChild: "user").queryEqual(toValue: userId).observe(.childAdded) { (snapshot) in
            
            guard let newMessage = snapshot.value as? NSDictionary else {
                return
            }
            
            let encodedEmail = self.interpreterEmail.getEncodedEmail()
            if (newMessage.value(forKey: "interpreter") as? String == encodedEmail) {
                if (newMessage.value(forKey: "image") != nil) {
                    let message = Message(sender: newMessage.value(forKey: "sender") as! String, imageURL: newMessage.value(forKey: "image") as! String, user: newMessage.value(forKey: "user") as! String, interpreter: newMessage.value(forKey: "interpreter") as! String, time: newMessage.value(forKey: "time") as! String)
                    self.messages.append(message)
                    completion(message)
                } else if (newMessage.value(forKey: "text") != nil) {
                    let message = Message(sender: newMessage.value(forKey: "sender") as! String, text: newMessage.value(forKey: "text") as! String, user: newMessage.value(forKey: "user") as! String, interpreter: newMessage.value(forKey: "interpreter") as! String, time: newMessage.value(forKey: "time") as! String)
                    self.messages.append(message)
                    completion(message)
                } else if (newMessage.value(forKey: "video") != nil) {
                    let message = Message(sender: newMessage.value(forKey: "sender") as! String, videoURL: newMessage.value(forKey: "video") as! String, user: newMessage.value(forKey: "user") as! String, interpreter: newMessage.value(forKey: "interpreter") as! String, time: newMessage.value(forKey: "time") as! String)
                    self.messages.append(message)
                    completion(message)
                }
            }
        }
    }
    
    @objc func sendMessage() {
        if (inputTextField.text != "") {
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+7:00")
            let stringDate = dateFormatter.string(from: date)
            let messageRef = Database.database().reference().child("messages").childByAutoId()
            messageRef.updateChildValues(["sender": "interpreter", "text": inputTextField.text!, "user": self.userId, "interpreter": self.interpreterEmail.getEncodedEmail(), "time": stringDate])
            self.inputTextField.text = ""
            
        }
    }
    
    @objc func plusButtonTouch() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Create your actions - take a look at different style attributes
        let sendImageAction = UIAlertAction(title: "Send Image", style: .default) { (action) in
            // observe it in the buttons block, what button has been pressed
            self.sendImageButtonTouched()
        }
        
        let sendVideo = UIAlertAction(title: "Send Video", style: .default) { (action) in
            print("didPress send video")
        }
        
        let sendAudio = UIAlertAction(title: "Send Audio", style: .default) { (action) in
            print("didPress send audio")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("didPress cancel")
        }
        
        // Add the actions to your actionSheet
        actionSheet.addAction(sendImageAction)
        actionSheet.addAction(sendVideo)
        actionSheet.addAction(sendAudio)
        actionSheet.addAction(cancelAction)
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func sendImageButtonTouched() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        guard  let image = selectedImage else {
            return
        }
        
        uploadMessageToFirebase(using: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadMessageToFirebase(using messageImage: UIImage) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+7:00")
        let stringDate = dateFormatter.string(from: date)
        
        
        let storageRef = Storage.storage().reference().child("message_images").child(userId + interpreterEmail.getEncodedEmail() + stringDate + ".png")
        
        if let messageImageData = messageImage.pngData()
        {
            storageRef.putData(messageImageData, metadata: nil) { (metaData, error) in
                if error != nil
                {
                    self.alertAction(title: "Uploading image failed!", message: String(describing: error))
                    return
                }
                storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                    if error != nil
                    {
                        self.alertAction(title: "Uploading image failed!", message: String(describing: error))
                        return
                    }
                    let urlString = url?.absoluteString
                    self.sendImage(with: urlString!)
                })
                
            }
        }
    }
    
    func sendImage(with urlString: String) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+7:00")
        let stringDate = dateFormatter.string(from: date)
        let messageRef = Database.database().reference().child("messages").childByAutoId()
        messageRef.updateChildValues(["sender": "interpreter", "image": urlString, "user": self.userId, "interpreter": self.interpreterEmail.getEncodedEmail(), "time": stringDate])
    }
    
    private func alertAction(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleKeyboardNotification(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            if (isKeyboardShowing) {
                messageInputActivateBottomAnchor?.constant = -keyboardRectangle.height
                messageInputBottomAnchor?.isActive = false
                messageInputActivateBottomAnchor?.isActive = true
            } else {
                messageInputActivateBottomAnchor?.isActive = false
                messageInputBottomAnchor?.isActive = true
            }
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                
            }
        }
    }
    
    private func setUpInputComponent() {
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(plusButton)
        
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        plusButton.leadingAnchor.constraint(equalTo: messageInputContainerView.leadingAnchor).isActive = true
        plusButton.heightAnchor.constraint(equalTo: messageInputContainerView.heightAnchor).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        plusButton.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor).isActive = true
        
        inputTextField.leadingAnchor.constraint(equalTo: plusButton.trailingAnchor).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: messageInputContainerView.heightAnchor, multiplier: 1).isActive = true
        inputTextField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 110).isActive = true
        
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.leadingAnchor.constraint(equalTo: inputTextField.trailingAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: messageInputContainerView.heightAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor).isActive = true
    }
}


class ChatLogMessageCell: BaseCell {
    
    override func prepareForReuse() {
        imageContentView.image = nil
        messageTextView.text = nil
        messageTextView.textColor = nil
    }
    
    var messageContent: String = "" {
        didSet {
            adjustLayout(with: self.messageContent)
        }
    }
    
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
    
    let imageContentView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        
        //        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        //        imageView.isUserInteractionEnabled = true
        //        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        return imageView
    }()
    
    //    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    //    {
    //        let tappedImage = tapGestureRecognizer.view as! UIImageView
    //
    //
    //    }
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textAlignment = .left
        textView.backgroundColor = .clear
        return textView
    }()
    
    var TextCellProfileImageAnchor: NSLayoutConstraint?
    
    var ImageCellProfileImageAnchor: NSLayoutConstraint?
    
    override func setupViews() {
        super.setupViews()
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        addSubview(imageContentView)
        profileImageView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        TextCellProfileImageAnchor = profileImageView.bottomAnchor.constraint(equalTo: textBubbleView.bottomAnchor)
        ImageCellProfileImageAnchor = profileImageView.bottomAnchor.constraint(equalTo: imageContentView.bottomAnchor)
    }
    
    func adjustLayout(with messageContent: String) {
        if messageContent == "text" {
            ImageCellProfileImageAnchor?.isActive = false
            TextCellProfileImageAnchor?.isActive = true
        } else if messageContent == "image" {
            TextCellProfileImageAnchor?.isActive = false
            ImageCellProfileImageAnchor?.isActive = true
        }
    }
}

extension String {
    func getTextViewRect(sizeToFit: CGSize, font: UIFont, startPoint: CGPoint) -> CGRect {
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: self).boundingRect(with: sizeToFit, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
        return CGRect(x: startPoint.x, y: startPoint.y, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
    }
}

