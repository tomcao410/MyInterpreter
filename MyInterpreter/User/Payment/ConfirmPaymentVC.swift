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
    @IBOutlet var cardNumberTxtFlield: UITextField!;
    @IBOutlet weak var expDateTxtField: UITextField!
    @IBOutlet weak var cvcTxtField: UITextField!
    
    @IBOutlet weak var interpreterImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    // Remember to add "/charge"
    let backendBaseURL: String = "https://my-interpreter.herokuapp.com/charge"
    
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
        hideKeyboard()
        nameLbl.text = ListInterpretersVC.selectedInterpreter.getName()
        priceLbl.text = "$\(Float(PaymentVC.price) / 100)"
        
        expDateTxtField.delegate = self
        cvcTxtField.delegate = self
        
        DispatchQueue.global().async
            {
                let url = URL(string: ListInterpretersVC.selectedInterpreter.getProfileImageURL())
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
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (dissmissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dissmissKeyboard()
    {
        view.endEditing(true)
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
        let comps = expDateTxtField.text?.components(separatedBy: "/")
        let f = UInt(comps!.first!)
        let l = UInt(comps!.last!)
        
        let cardParams =  STPCardParams()
        cardParams.number = cardNumberTxtFlield.text!
        cardParams.expMonth = f!
        cardParams.expYear = l!
        cardParams.cvc = cvcTxtField.text!
        
        STPAPIClient.shared().createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
            
            if token == nil
            {
                self.alertAction(title: "Incorrect", message: "Your card is invalid! Please check again!")
                return
            }
            let amount = PaymentVC.price
            let params: [String: Any] = [
                "token": (token?.tokenId)!,
                "amount": amount,
                "currency": "usd",
                "description": "User: \((Auth.auth().currentUser?.email)!) BOOKED Interpreter: \(ListInterpretersVC.selectedInterpreter.getEmail())"
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
                    databaseRef.child("users/\(self.emailEncoded(email: (Auth.auth().currentUser?.email)!))/booking").setValue("\(self.emailEncoded(email: ListInterpretersVC.selectedInterpreter.getEmail()))")
                    
                    self.performSegue(withIdentifier: "userDashboardSegue", sender: nil)
                }
                else
                {
                    self.alertAction(title: "Error", message: "Something happened to the web server! (code = \(code))")
                }
            }
        }
    }
    
    // MARK: --------ALERT--------
    private func alertAction(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


// MARK: Delegate: --------TEXT FIELD--------
extension ConfirmPaymentVC: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == expDateTxtField
        {
            if string == "" {
                return true
            }
            
            let currentText = textField.text! as NSString
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            
            textField.text = updatedText
            let numberOfCharacters = updatedText.count
            if numberOfCharacters == 2 {
                textField.text?.append("/")
            }
            if numberOfCharacters > 5
            {
                textField.text?.removeLast()
            }
            return false
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

