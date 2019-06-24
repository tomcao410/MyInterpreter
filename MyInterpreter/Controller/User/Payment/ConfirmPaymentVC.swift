//
//  ConfirmPaymentVC.swift
//  MyInterpreter
//
//  Created by Tom on 5/24/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Stripe
import Alamofire
import Firebase

class ConfirmPaymentVC: UIViewController {
    
    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
    @IBOutlet var cardNumberTxtFlield: UITextField!
    @IBOutlet weak var expDateTxtField: UITextField!
    @IBOutlet weak var cvcTxtField: UITextField!
    @IBOutlet weak var interpreterImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var bookButton: UIButton!
    
    // Remember to add "/charge"
    let backendBaseURL: String = "https://my-interpreter.herokuapp.com/charge"
    let today = Date()
    
    
    // MARK: ---Views---
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Work place
    // MARK: --------Functions--------
    
    private func setUI()
    {
        keyboardEvents()
        hideKeyboard()
        
        navigationItem.setCustomNavBar(title: "Payment")
        
        nameLbl.text = ListInterpretersVC.selectedInterpreter.name
        priceLbl.text = "$\(Float(PaymentVC.price) / 100)"
        
        cardNumberTxtFlield.addDoneCancelToolbar()
        expDateTxtField.addDoneCancelToolbar()
        cvcTxtField.addDoneCancelToolbar()
        
        expDateTxtField.delegate = self
        cvcTxtField.delegate = self
        
        DispatchQueue.global().async
            {
                let url = URL(string: ListInterpretersVC.selectedInterpreter.profileImageURL)
                let data = NSData(contentsOf: url!)
                DispatchQueue.main.async
                    {
                        self.interpreterImage.image = UIImage(data: data! as Data)
                }
        }
        
        cardNumberTxtFlield.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
    }
    
    private func emailEncoded(email: String) -> String
    {
        return email.replacingOccurrences(of: "@gmail.com", with: "")
    }
    
    // MARK: --------KEYBOARD--------
    func keyboardEvents()
    {
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification)
    {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else
        {
            return
        }
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification
        {
            
            view.frame.origin.y = -0.5 * keyboardRect.height
        }
        else
        {
            view.frame.origin.y = 0
        }
    }
    
    // MARK: ---Text Field UI---
    @objc func reformatAsCardNumber(textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }
        
        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = self.removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }
        
        if cardNumberWithoutSpaces.count > 19 {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        }
        
        let cardNumberWithSpaces = self.insertCreditCardSpaces(cardNumberWithoutSpaces, preserveCursorPosition: &targetCursorPosition)
        textField.text = cardNumberWithSpaces
        
        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
    }
    
    func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition
        
        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            }
            else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }
        
        return digitsOnlyString
    }
    
    func insertCreditCardSpaces(_ string: String, preserveCursorPosition cursorPosition: inout Int) -> String {
        // Mapping of card prefix to pattern is taken from
        // https://baymard.com/checkout-usability/credit-card-patterns
        
        // UATP cards have 4-5-6 (XXXX-XXXXX-XXXXXX) format
        let is456 = string.hasPrefix("1")
        
        // These prefixes reliably indicate either a 4-6-5 or 4-6-4 card. We treat all these
        // as 4-6-5-4 to err on the side of always letting the user type more digits.
        let is465 = [
            // Amex
            "34", "37",
            
            // Diners Club
            "300", "301", "302", "303", "304", "305", "309", "36", "38", "39"
            ].contains { string.hasPrefix($0) }
        
        // In all other cases, assume 4-4-4-4-3.
        // This won't always be correct; for instance, Maestro has 4-4-5 cards according
        // to https://baymard.com/checkout-usability/credit-card-patterns, but I don't
        // know what prefixes identify particular formats.
        let is4444 = !(is456 || is465)
        
        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition
        
        for i in 0..<string.count {
            let needs465Spacing = (is465 && (i == 4 || i == 10 || i == 15))
            let needs456Spacing = (is456 && (i == 4 || i == 9 || i == 15))
            let needs4444Spacing = (is4444 && i > 0 && (i % 4) == 0)
            
            if needs465Spacing || needs456Spacing || needs4444Spacing {
                stringWithAddedSpaces.append(" ")
                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
            
            let characterToAdd = string[string.index(string.startIndex, offsetBy:i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        
        return stringWithAddedSpaces
    }
    
    // MARK: --------BUTTON--------
    @IBAction func bookBtnClicked(_ sender: Any)
    {
        hideKeyboard()
        spinner.startAnimating()
        bookButton.status(enable: false, hidden: true)
        
        if (expDateTxtField.text?.isEmpty)!
            && (cardNumberTxtFlield.text?.isEmpty)!
            && (cvcTxtField.text?.isEmpty)!
        {
            self.customAlertAction(title: "Error", message: "Wrong card input!")
            return
        }
        let comps = expDateTxtField.text?.components(separatedBy: "/")
        let f = UInt(comps!.first!)
        let l = UInt(comps!.last!)
        
        let cardParams =  STPCardParams()
        guard case cardParams.number = cardNumberTxtFlield.text! else {
            self.customAlertAction(title: "Error!", message: "Some information are missing!")
            self.spinner.stopAnimating()
            self.bookButton.status(enable: true, hidden: false)
            return
        }
        guard case cardParams.expMonth = f! else {
            self.customAlertAction(title: "Error!", message: "Some information are missing!")
            self.spinner.stopAnimating()
            self.bookButton.status(enable: true, hidden: false)
            return
        }
        guard case cardParams.expYear = l! else {
            self.customAlertAction(title: "Error!", message: "Some information are missing!")
            self.spinner.stopAnimating()
            self.bookButton.status(enable: true, hidden: false)
            return
        }
        guard case cardParams.cvc = cvcTxtField.text! else {
            self.customAlertAction(title: "Error!", message: "Some information are missing!")
            self.spinner.stopAnimating()
            self.bookButton.status(enable: true, hidden: false)
            return
        }
        
        STPAPIClient.shared().createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
            
            if token == nil
            {
                self.spinner.stopAnimating()
                self.bookButton.status(enable: true, hidden: false)
                
                self.customAlertAction(title: "Incorrect", message: "Your card is invalid! Please check again!")
                return
            }
            let amount = PaymentVC.price
            let params: [String: Any] = [
                "token": (token?.tokenId)!,
                "amount": amount,
                "currency": "usd",
                "description": "User: \((Auth.auth().currentUser?.email)!) BOOKED Interpreter: \(ListInterpretersVC.selectedInterpreter.email)"
            ]
            
            Alamofire.request(self.backendBaseURL, method: .post, parameters: params).validate(statusCode: 200..<300).responseJSON{
                response in
                
                let json = response.result.value as? [String: Any]
                let code = json!["code"] as! Int
                
                if (code == 1)
                {
                    // Do something
                    let databaseRef = Database.database().reference()
                    
                    // Update users booking status (default: "interpreter0" - means the user hasn't booked anyone yet)
                    //databaseRef.child("users/\(self.emailEncoded(email: (Auth.auth().currentUser?.email)!))/booking").setValue("\(self.emailEncoded(email: ListInterpretersVC.selectedInterpreter.getEmail()))")
                    let bookingsRef = databaseRef.child("bookings")
                    bookingsRef.childByAutoId().setValue(["interpreter": ListInterpretersVC.selectedInterpreter.email.getEncodedEmail(), "price": "$\(Double(PaymentVC.price) / 100)", "user": (Auth.auth().currentUser?.email?.getEncodedEmail())!, "timeStart": self.today.toDate(), "timeEnd": Calendar.current.date(byAdding: .day, value: PaymentVC.numberOfDays, to: self.today)?.toDate() as Any, "confirm": false])
                    
                    
                    
                    // Update users booking status (default: "interpreter0" - means the user hasn't booked anyone yet)
                    let queryRef = bookingsRef.queryOrdered(byChild: "user").queryEqual(toValue: (Auth.auth().currentUser?.email?.getEncodedEmail())!)
                    queryRef.observe(.value, with: { (snapshot: DataSnapshot) in
                        for snap in snapshot.children
                        {
                            let bookingSnap = snap as! DataSnapshot
                            let bookingID = bookingSnap.key
                            
                            databaseRef.child("users/\(Auth.auth().currentUser!.email!.getEncodedEmail())/booking").setValue(bookingID)
                        }
                    })
                    
                    self.spinner.stopAnimating()
                    self.bookButton.status(enable: true, hidden: false)
                    
                    self.performSegue(withIdentifier: "userDashboardSegue", sender: nil)
                }
                else
                {
                    self.spinner.stopAnimating()
                    self.bookButton.status(enable: true, hidden: false)
                    
                    self.customAlertAction(title: "Error", message: "Something happened to the web server! (code = \(code))")
                }
            }
        }
    }
    
}


// MARK: Delegate: --------TEXT FIELD--------
extension ConfirmPaymentVC: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == expDateTxtField {
            
            // check the chars length MM --> 2
            if (textField.text?.count == 2) {
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    textField.text = (textField.text)! + "/"
                }
            }
            // check the condition not exceed 7 chars
            
            return !(textField.text!.count > 6 && (string.count) > range.length)
        }
        
        if textField == cvcTxtField
        {
            if string == "" {
                return true
            }
            
            let currentText = textField.text! as NSString
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            
            textField.text = updatedText
            let numberOfCharacters = updatedText.count
            
            if numberOfCharacters > 3
            {
                textField.text?.removeLast()
            }
            return false
        }
        
        previousTextFieldContent = textField.text;
        previousSelection = textField.selectedTextRange;
        return true
    }
}


