//
//  PaymentVC.swift
//  MyInterpreter
//
//  Created by Tom on 5/12/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

class PaymentVC: UIViewController {


    @IBOutlet weak var pickerPaymentMethod: UIPickerView!
    @IBOutlet weak var btnAboutPayment: UIButton!
    @IBOutlet weak var txtFieldNumberOfDays: UITextField!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var txtFieldCardName: UITextField!
    @IBOutlet weak var txtFieldCardNumber: UITextField!
    @IBOutlet weak var txtFieldExpDate: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

}
