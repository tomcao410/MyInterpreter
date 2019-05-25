//
//  PaymentVC.swift
//  MyInterpreter
//
//  Created by Tom on 5/12/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Stripe

class PaymentVC: UIViewController {

    // MARK: ---UI elements---
    @IBOutlet weak var pickerPaymentMethod: UIPickerView!
    @IBOutlet weak var txtFieldNumberOfDays: UITextField!
    @IBOutlet weak var lblNumberOfDays: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblPricePerDay: UILabel!
    
    @IBOutlet var modalPaymentMethod: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    // MARK: ---Parameters---
    var effect: UIVisualEffect! // effect for modal pop-up
    
    var paymenMethods: [String] = []
    var method1: String = "Daily prepaid"
    var method2: String = "Period prepaid"
    
    static var price: Int = 0
    
    // MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        setUI()
        
        hideKeyboard() // hide keyboard when tap anywhere outside the text field
        
        pickerPaymentMethod.delegate = self
    }
    
    // MARK: Work place
    // MARK: --------Functions--------
    func setUI()
    {
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
        
        modalPaymentMethod.layer.cornerRadius = 10
        
        paymenMethods.append(method1)
        paymenMethods.append(method2)
        
        txtFieldNumberOfDays.isEnabled = false
        lblNumberOfDays.textColor = .gray
        lblPricePerDay.textColor = .gray
    }
    
    // Effect for modal to pop in
    func animateIn()
    {
        visualEffectView.isHidden = false
        self.view.addSubview(modalPaymentMethod)
        modalPaymentMethod.center = self.view.center
        modalPaymentMethod.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        modalPaymentMethod.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.modalPaymentMethod.alpha = 1
            self.modalPaymentMethod.transform = CGAffineTransform.identity
        }
    }
    
    // Effect for modal to pop out
    func animateOut()
    {
        UIView.animate(withDuration: 0.4, animations:
            {
                self.modalPaymentMethod.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.modalPaymentMethod.alpha = 0
                
                self.visualEffectView.effect = nil
        }) { (success: Bool) in
            self.modalPaymentMethod.removeFromSuperview()
        }
        visualEffectView.isHidden = true
    }
    
    private func confirmPayment()
    {
        
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
            self.lblPrice.text = "\(price!)"
        }
        else
        {
            alertInputNumberOfDays()
            lblPrice.text = "0.0"
        }
    }
    
    // MARK: --------BUTTON--------
    @IBAction func btnAboutMethodClicked(_ sender: Any)
    {
        animateIn()
    }
    
    @IBAction func btnGotItClicked(_ sender: Any)
    {
        animateOut()
    }
    
    @IBAction func btnNextClicked(_ sender: Any)
    {
        if (lblPrice.text == "0.0")
        {
            alertInputNumberOfDays()
        }
        else
        {
            // MARKK: payment invoice processsing.... STRIPE!!!!!!!
            PaymentVC.price = Int((lblPrice.text! as NSString).floatValue * 100)

            performSegue(withIdentifier: "confirmPaymentSegue", sender: nil)
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
            
            lblPrice.text = "0.99"
        }
        else
        {
            txtFieldNumberOfDays.isEnabled = true
            lblNumberOfDays.textColor = .black
            lblPricePerDay.textColor = .black
            
            txtFieldNumberOfDays.text = "0"
            lblPrice.text = "0.0"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 17.0)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = paymenMethods[row]
        pickerLabel?.textColor = UIColor.black
        
        return pickerLabel!
    }
}


