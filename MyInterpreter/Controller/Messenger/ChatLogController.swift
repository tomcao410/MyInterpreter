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

enum recordState {
    case beforeRecord
    case recording(url: URL)
    case recorded(url: URL)
    case recordFail
}

class ChatLogController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    
    
    
    // MARK: declare area
    var chatter: String = ""
    var interpreterEmail: String = ""
    var userId: String = ""
    var messages: [Message] = []
    var leftCellProfileImage: UIImage?
    static var cache = NSCache<AnyObject, AnyObject>()
    var doneCellCount: Int = 0
    var audioRecorder: AVAudioRecorder!
    var messageInputBottomAnchor: NSLayoutConstraint?
    var messageInputActivateBottomAnchor: NSLayoutConstraint?
    var isPlaying: Bool = false
    var audioPlayer: AVAudioPlayer!
    private let cellID = "cellID"
    let tableView = UITableView()
    var isShowRecordView: Bool = false {
        didSet {
            if self.isShowRecordView {
                recordView.isHidden = false
            } else {
                recordView.isHidden = true
            }
        }
    }
    var recordState: recordState = .beforeRecord {
        didSet {
            switch self.recordState {
            case .beforeRecord:
                recordButton.image = #imageLiteral(resourceName: "record").withRenderingMode(.alwaysTemplate)
                recordButton.tintColor = .red
                recordTitle.text = "Tap to record"
            case .recording:
                recordButton.image = #imageLiteral(resourceName: "stop").withRenderingMode(.alwaysTemplate)
                recordButton.tintColor = .red
                recordTitle.text = "Recording..."
            case .recorded:
                recordButton.image = #imageLiteral(resourceName: "send").withRenderingMode(.alwaysTemplate)
                recordButton.tintColor = .blue
                recordTitle.text = "Send"
            case .recordFail:
                recordButton.image = #imageLiteral(resourceName: "alert").withRenderingMode(.alwaysTemplate)
                recordButton.tintColor = .red
                recordTitle.text = "Your voice was not recorded"
            }
        }
    }
    
    
    
    // MARK: set up views area
    
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
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
    
    let recordButton: UIImageView = {
        let imageView = UIImageView()
        
        imageView.backgroundColor = .clear
        
        return imageView
    }()
    
    let recordView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let recordTitle: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    
    
    
    // MARK: image handler feature
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage) -> ()) {
        if let cachedImage = ChatLogController.cache.object(forKey: urlString as AnyObject) {
            completion(cachedImage as! UIImage)
        } else {
            DispatchQueue.global().async {
                let imageURL = URL(string: urlString)
                let data = NSData(contentsOf: imageURL!)
                DispatchQueue.main.async {
                    guard let data = data else {
                        return
                    }
                    ChatLogController.cache.setObject(UIImage(data: data as Data)!, forKey: urlString as AnyObject)
                    completion(UIImage(data: data as Data)!)
                }
            }
        }
    }
    
    func uploadMessageToFirebase(using messageImage: UIImage) {
        let stringDate = Date().getString(with: "yyyy-MM-dd HH:mm:ss")
        
        
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
        let stringDate = Date().getString(with: "yyyy-MM-dd HH:mm:ss")
        let messageRef = Database.database().reference().child("messages").childByAutoId()
        messageRef.updateChildValues(["sender": chatter, "image": urlString, "user": self.userId, "interpreter": self.interpreterEmail.getEncodedEmail(), "time": stringDate])
    }
    
    func setUpImageTapGesture(cell: ChatLogMessageCell) {
        cell.imageContentView.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(imageTapDetected(sender:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        cell.imageContentView.addGestureRecognizer(singleTap)
    }
    
    func sendImageButtonTouched() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func imageTapDetected(sender: UITapGestureRecognizer) {
        let imageView = sender.view as? UIImageView
        let controller = FullImageViewController()
        controller.image = imageView?.image
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    
    
    
    // MARK: handler message
    
    func getInterpreterInfo(with id: String, completion: @escaping (Interpreter) -> ()) {
        let interpreterRef = Database.database().reference().child("interpreters").child(interpreterEmail.getEncodedEmail())
        
        interpreterRef.observeSingleEvent(of: .value) { (snapshot) in
            let interpreterDic = snapshot.value as! NSDictionary
            
            completion(Interpreter(dic: interpreterDic))
        }
    }
    
    func observeMessage(completion: @escaping (Message) -> ()) {
        Database.database().reference().child("messages").queryOrdered(byChild: "user").queryEqual(toValue: userId).observe(.childAdded) { (snapshot) in
            
            guard let newMessage = snapshot.value as? NSDictionary else {
                return
            }
            
            let encodedEmail = self.interpreterEmail.getEncodedEmail()
            if (newMessage.value(forKey: "interpreter") as? String == encodedEmail) {
                let message = Message(dic: newMessage)
                self.messages.append(message)
                completion(message)
            }
        }
    }
    
    @objc func sendMessage() {
        if (inputTextField.text != "") {
            let stringDate = Date().getString(with: "yyyy-MM-dd HH:mm:ss")
            let messageRef = Database.database().reference().child("messages").childByAutoId()
            messageRef.updateChildValues(["sender": chatter, "text": inputTextField.text!, "user": self.userId, "interpreter": self.interpreterEmail.getEncodedEmail(), "time": stringDate])
            self.inputTextField.text = ""
            
        }
    }

    
    
    
    
    
    
    // MARK: record handler
    
    func addRecordButtonGesture() {
        self.recordButton.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(recordButtonTap))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.recordButton.addGestureRecognizer(tapGesture)
    }
    
    @objc func recordButtonTap() {
        
        
        switch recordState {
        case .beforeRecord:
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            
            do {
                let audioFileURL = getAudioPath()
                audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                recordState = .recording(url: audioFileURL)
            } catch {
                recordState = .recordFail
            }
        case .recorded(let url):
            uploadAudioToFirebase(with: url)
        case .recording(let url):
            audioRecorder.stop()
            recordState = .recorded(url: url)
        case .recordFail:
            break
        }
    }
    
    func sendAudioButtonTouched() {
        if !isShowRecordView {
            self.view.endEditing(true)
            showRecordView()
        }
    }
    
    func getAudioPath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent(".m4a")
    }
    
    func uploadAudioToFirebase(with url: URL) {
        let stringDate = Date().getString(with: "yyyy-MM-dd HH:mm:ss")
        
        
        let storageRef = Storage.storage().reference().child("message_audios").child(userId + interpreterEmail.getEncodedEmail() + stringDate + ".m4a")
        
        storageRef.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil {
                self.alertAction(title: "Uploading audio failed!", message: String(describing: error))
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    self.alertAction(title: "Uploading audio failed!", message: String(describing: error))
                    return
                }
                if let urlString = url?.absoluteString {
                    self.sendAudio(with: urlString)
                }
            })
        }
    }
    
    func sendAudio(with urlString: String) {
        let stringDate = Date().getString(with: "yyyy-MM-dd HH:mm:ss")
        let messageRef = Database.database().reference().child("messages").childByAutoId()
        messageRef.updateChildValues(["sender": chatter, "audio": urlString, "user": self.userId, "interpreter": self.interpreterEmail.getEncodedEmail(), "time": stringDate])
    }
    
    func downloadAudio(from urlString: String, completion: @escaping (Data) -> ()) {
        if let cachedAudio = ChatLogController.cache.object(forKey: urlString as AnyObject) {
            completion(cachedAudio as! Data)
        } else {
            guard let url = URL(string: urlString) else {
                return
            }
            URLSession.shared.dataTask(with: url) { (data, res, err) in
                if (err != nil) {
                    self.alertAction(title: "Message error", message: "Audio message not download correctly")
                    return
                }
                if let data = data, let res = res as? HTTPURLResponse, res.statusCode == 200 {
                    DispatchQueue.main.async {
                        ChatLogController.cache.setObject(data as AnyObject, forKey: urlString as AnyObject)
                        completion(data)
                    }
                }
            }.resume()
        }
    }
    
    @objc func playButtonTouched(sender: UIButton) {
        
        if isPlaying == false {
            if let data = ChatLogController.cache.object(forKey: messages[sender.tag].audioURL as AnyObject) as? Data {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    self.audioPlayer = try AVAudioPlayer(data: data)
                    self.audioPlayer.delegate = self
                    self.audioPlayer.prepareToPlay()
                    self.audioPlayer.play()
                    self.isPlaying = true
                    sender.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
                    sender.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                } catch let error {
                    self.alertAction(title: "Audio Problem", message: error.localizedDescription)
                }
            }
        } else if let audioPlayer = self.audioPlayer {
            sender.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
            sender.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            audioPlayer.pause()
            self.isPlaying = false
        }
    }
    
    @objc func stopButtonTouched() {
        guard let audioPlayer = self.audioPlayer else { return }
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }
    }
    
    @objc func replayButtonTouched() {
        guard let audioPlayer = self.audioPlayer else { return }
        if audioPlayer.isPlaying {
            audioPlayer.currentTime = 0
            audioPlayer.play()
        } else {
            audioPlayer.play()
        }
    }

    
    
    
    //MARK: plus button handler
    
    @objc func plusButtonTouch() {
        
        guard !isShowRecordView else {
            hideRecordView()
            return
        }
        
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
            self.sendAudioButtonTouched()
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
    
    
    
    
    
    
    
    // MARK: set up chat log table view
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.doneCellCount - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (messages.count == 0) {
            tableView.setEmptyView(title: "Chat log is empty", message: "Your conversation here")
        } else {
            tableView.restore()
        }
        return messages.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChatLogMessageCell
        
        let cellSide: messageSide
        
        if (self.messages[indexPath.row].sender != chatter) {
            cell.profileImageView.image = leftCellProfileImage
            cellSide = .left
        } else {
            cellSide = .right
        }
        
        if messages[indexPath.row].imageURL != "" {
            if let cachedImage = ChatLogController.cache.object(forKey: messages[indexPath.row].imageURL as AnyObject) as? UIImage {
                cell.messageContent = .image(content: cachedImage, viewWidth: self.view.frame.width, viewHeight:
                    self.view.frame.height, side: cellSide)
                setUpImageTapGesture(cell: cell)
            } else {
                cell.messageContent = .downloading(side: cellSide, viewWidth: self.view.frame.width)
            }
        } else if messages[indexPath.row].text != "" {
            cell.messageContent = .text(content: self.messages[indexPath.row].text, viewWidth: self.view.frame.width, side: cellSide)
        } else if messages[indexPath.row].audioURL != "" {
            if let cachedAudio = ChatLogController.cache.object(forKey: messages[indexPath.row].audioURL as AnyObject) as? Data {
                cell.playButton.tag = indexPath.row
                cell.messageContent = .audio(content: cachedAudio, viewWidth: self.view.frame.width, side: cellSide)
            } else {
                cell.messageContent = .downloading(side: cellSide, viewWidth: self.view.frame.width)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if messages[indexPath.row].imageURL != "" {
            return calculateImageCellHeight(indexPath: indexPath)
        } else if messages[indexPath.row].text != "" {
            return calculateTextCellHeight(indexPath: indexPath)
        } else if messages[indexPath.row].audioURL != "" {
            return calculateAudioCellHeight(indexPath: indexPath)
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
        
        if let cachedImage = ChatLogController.cache.object(forKey: messages[indexPath.row].imageURL as AnyObject) as? UIImage {
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
    
    func calculateAudioCellHeight(indexPath: IndexPath) -> CGFloat {
        return 60 + 20
    }
    
    func calculateDownloadingCellHeight(indexPath: IndexPath) -> CGFloat {
        return 40 + 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 8)
        return headerView
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let guide = view.safeAreaLayoutGuide
        view.backgroundColor = .white
        let backgroundView = UIImageView()
        backgroundView.image = #imageLiteral(resourceName: "background")
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundView)
        backgroundView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        
        
        hideKeyboard()
        addRecordButtonGesture()
        
        tabBarController?.tabBar.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.293557363)
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
            } else if message.audioURL != "" {
                self.downloadAudio(from: message.audioURL, completion: { _ in
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
        
        view.addSubview(inputContainerView)
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(messageInputContainerView)
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        messageInputBottomAnchor = messageInputContainerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0)
        messageInputBottomAnchor?.isActive = true
        messageInputActivateBottomAnchor = messageInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        messageInputActivateBottomAnchor?.isActive = false
        messageInputContainerView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        messageInputContainerView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        inputContainerView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        inputContainerView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        inputContainerView.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor).isActive = true
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: messageInputContainerView.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        
        
        view.addSubview(recordView)
        recordView.translatesAutoresizingMaskIntoConstraints = false
        
        recordView.topAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor).isActive = true
        recordView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        recordView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        recordView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        recordView.isHidden = true
        
        setUpInputComponent()
        
        setUpRecordViews()
        recordState = .beforeRecord
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    
    
    
    
    // MARK: image picker set up
    
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
    
    
    
    // MARK: set up alert
    
    private func alertAction(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    // MARK: set up animations
    
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
            }, completion: nil)
        }
    }
    
    func showRecordView() {
        messageInputActivateBottomAnchor?.constant = -recordView.frame.height
        messageInputBottomAnchor?.isActive = false
        messageInputActivateBottomAnchor?.isActive = true
        
        plusButton.setImage(#imageLiteral(resourceName: "X"), for: .normal)
        isShowRecordView = true
        recordTitle.text = "Tap to record"
        recordView.transform = CGAffineTransform(translationX: 0, y: 100)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.recordView.transform = .identity
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func hideRecordView() {
        messageInputBottomAnchor?.isActive = true
        messageInputActivateBottomAnchor?.isActive = false
        
        plusButton.setImage(#imageLiteral(resourceName: "plus"), for: .normal)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.recordView.transform = CGAffineTransform(translationX: 0, y: 100)
            self.view.layoutIfNeeded()
        }, completion: {done in
            if done {
                self.isShowRecordView = false
                self.recordView.transform = .identity
                self.recordState = .beforeRecord
            }
        })
    }

    
    
    
    
    
    // MARK: set up inner views constrains
    
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
    
    private func setUpRecordViews() {
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordView.addSubview(recordButton)
        
        recordButton.centerXAnchor.constraint(equalTo: recordView.centerXAnchor).isActive = true
        recordButton.topAnchor.constraint(equalTo: recordView.topAnchor).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        recordTitle.translatesAutoresizingMaskIntoConstraints = false
        recordView.addSubview(recordTitle)
        
        recordTitle.topAnchor.constraint(equalTo: recordButton.bottomAnchor).isActive = true
        recordTitle.leftAnchor.constraint(equalTo: recordView.leftAnchor).isActive = true
        recordTitle.rightAnchor.constraint(equalTo: recordView.rightAnchor).isActive = true
        recordTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
}
