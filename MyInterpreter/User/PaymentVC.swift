//
//  PaymentVC.swift
//  MyInterpreter
//
//  Created by Tom on 5/12/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

class PaymentVC: UIViewController {

    // MARK: UI elements
    @IBOutlet weak var pickerPaymentMethod: UIPickerView!
    @IBOutlet weak var btnAboutPayment: UIButton!
    @IBOutlet weak var txtFieldNumberOfDays: UITextField!
    @IBOutlet weak var lblNumberOfDays: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblPricePerDay: UILabel!
    
    @IBOutlet weak var txtFieldCardName: UITextField!
    @IBOutlet weak var txtFieldCardNumber: UITextField!
    @IBOutlet weak var txtFieldExpDate: UITextField!
    
    var paymenMethods: [String] = []
    var method1: String = "Daily prepaid"
    var method2: String = "Period prepaid"
    
    // MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        setUI()
        
        hideKeyboard() // hide keyboard when tap anywhere outside the text field
        
        pickerPaymentMethod.delegate = self
    }
    
    // MARK: Work place
    // MARK: --------Set UI--------
    func setUI()
    {
        paymenMethods.append(method1)
        paymenMethods.append(method2)
        
        txtFieldNumberOfDays.isEnabled = false
        lblNumberOfDays.textColor = .gray
        lblPricePerDay.textColor = .gray
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
    
    // MARK: --------TEXT FIELD--------
    @IBAction func numberOfDaysChanged(_ sender: Any) {
        var price = Double(self.txtFieldNumberOfDays.text!)
        if (price != nil)
        {
            price = round(price! * 1.49 * 1000) / 1000
            self.lblPrice.text = "$\(price!)"
        }
        else
        {
            alertInputNumberOfDays()
            lblPrice.text = "$0.0"
        }
    }
    
    // MARK: --------BUTTON--------
    @IBAction func btnBookClicked(_ sender: Any) {
        if (lblPrice.text == "$0.0")
        {
            alertInputNumberOfDays()
        }
        else
        {
            // MARKK: payment invoice processsing.... STRIPE!!!!!!!
        }
    }
    // MARK: --------ALERT--------
    func alertInputNumberOfDays()
    {
        let alert = UIAlertController(title: "Notice!", message: "Please input number of days that you want to book!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

// MARK: --------TEXT FIELD--------
extension PaymentVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case txtFieldNumberOfDays:
            txtFieldNumberOfDays.resignFirstResponder()
            txtFieldCardName.becomeFirstResponder()
            break
        case txtFieldCardName:
            txtFieldCardName.resignFirstResponder()
            txtFieldCardNumber.becomeFirstResponder()
            break
        case txtFieldCardNumber:
            txtFieldCardNumber.resignFirstResponder()
            txtFieldExpDate.becomeFirstResponder()
            hideKeyboard()
            break
        default:
            break
        }
        return true
    }
}

// MARK: --------PICKER VIEW--------
extension PaymentVC: UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return paymenMethods.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return paymenMethods[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (paymenMethods[row] == method1)
        {
            txtFieldNumberOfDays.isEnabled = false
            txtFieldNumberOfDays.text = ""
            lblNumberOfDays.textColor = .gray
            lblPricePerDay.textColor = .gray
            
            lblPrice.text = "$0.99"
        }
        else
        {
            txtFieldNumberOfDays.isEnabled = true
            lblNumberOfDays.textColor = .black
            lblPricePerDay.textColor = .black
            
            txtFieldNumberOfDays.text = "0"
            lblPrice.text = "$0.0"
        }
    }
}
