//
//  SettingsViewController.swift
//  MyInterpreter
//
//  Created by Tom on 5/22/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Stripe

struct Settings {
    let theme: STPTheme
    let additionalPaymentOptions: STPPaymentOptionType
    let requiredBillingAddressFields: STPBillingAddressFields
    let requiredShippingAddressFields: Set<STPContactField>
    let shippingType: STPShippingType
}


class SettingsViewController: UIViewController {
    
    var settings: Settings {
        return Settings(theme: self.theme.stpTheme,
                        additionalPaymentOptions: self.applePay.enabled ? .all : STPPaymentOptionType(),
                        requiredBillingAddressFields: self.requiredBillingAddressFields.stpBillingAddressFields,
                        requiredShippingAddressFields: self.requiredShippingAddressFields.stpContactFields,
                        shippingType: self.shippingType.stpShippingType)
    }
    
    private var theme: Theme = .Default
    private var applePay: Switch = .Enabled
    private var requiredBillingAddressFields: RequiredBillingAddressFields = .None
    private var requiredShippingAddressFields: RequiredShippingAddressFields = .PostalAddressPhone
    private var shippingType: ShippingType = .Shipping
    
    fileprivate enum Section: String {
        case Theme = "Theme"
        case ApplePay = "Apple Pay"
        case RequiredBillingAddressFields = "Required Billing Address Fields"
        case RequiredShippingAddressFields = "Required Shipping Address Fields"
        case ShippingType = "Shipping Type"
        case Session = "Session"
        
        init(section: Int) {
            switch section {
            case 0: self = .Theme
            case 1: self = .ApplePay
            case 2: self = .RequiredBillingAddressFields
            case 3: self = .RequiredShippingAddressFields
            case 4: self = .ShippingType
            default: self = .Session
            }
        }
    }
    
    fileprivate enum Theme: String {
        case Default = "Default"
        case CustomLight = "Custom – Light"
        case CustomDark = "Custom – Dark"
        
        init(row: Int) {
            switch row {
            case 0: self = .Default
            case 1: self = .CustomLight
            default: self = .CustomDark
            }
        }
        
        var stpTheme: STPTheme {
            switch self {
            case .Default:
                return STPTheme.default()
            case .CustomLight:
                let theme = STPTheme()
                theme.primaryBackgroundColor = UIColor(red:0.96, green:0.96, blue:0.95, alpha:1.00)
                theme.secondaryBackgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
                theme.primaryForegroundColor = UIColor(red:0.35, green:0.35, blue:0.35, alpha:1.00)
                theme.secondaryForegroundColor = UIColor(red:0.66, green:0.66, blue:0.66, alpha:1.00)
                theme.accentColor = UIColor(red:0.09, green:0.81, blue:0.51, alpha:1.00)
                theme.errorColor = UIColor(red:0.87, green:0.18, blue:0.20, alpha:1.00)
                theme.font = UIFont(name: "ChalkboardSE-Light", size: 17)
                theme.emphasisFont = UIFont(name: "ChalkboardSE-Bold", size: 17)
                return theme
            case .CustomDark:
                let theme = STPTheme()
                theme.primaryBackgroundColor = UIColor(red:0.16, green:0.23, blue:0.31, alpha:1.00)
                theme.secondaryBackgroundColor = UIColor(red:0.22, green:0.29, blue:0.38, alpha:1.00)
                theme.primaryForegroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
                theme.secondaryForegroundColor = UIColor(red:0.60, green:0.64, blue:0.71, alpha:1.00)
                theme.accentColor = UIColor(red:0.98, green:0.80, blue:0.00, alpha:1.00)
                theme.errorColor = UIColor(red:0.85, green:0.48, blue:0.48, alpha:1.00)
                theme.font = UIFont(name: "GillSans", size: 17)
                theme.emphasisFont = UIFont(name: "GillSans", size: 17)
                return theme
            }
        }
    }
    
    fileprivate enum Switch: String {
        case Enabled = "Enabled"
        case Disabled = "Disabled"
        
        init(row: Int) {
            self = (row == 0) ? .Enabled : .Disabled
        }
        
        var enabled: Bool {
            return self == .Enabled
        }
    }
    
    fileprivate enum RequiredBillingAddressFields: String {
        case None = "None"
        case Zip = "Zip"
        case Name = "Name"
        case Full = "Full"
        
        init(row: Int) {
            switch row {
            case 0: self = .None
            case 1: self = .Zip
            case 2: self = .Name
            default: self = .Full
            }
        }
        
        var stpBillingAddressFields: STPBillingAddressFields {
            switch self {
            case .None: return .none
            case .Zip: return .zip
            case .Name: return .name
            case .Full: return .full
            }
        }
    }
    
    private enum RequiredShippingAddressFields: String {
        case None = "None"
        case Email = "Email"
        case PostalAddressPhone = "(PostalAddress|Phone)"
        case All = "All"
        
        init(row: Int) {
            switch row {
            case 0: self = .None
            case 1: self = .Email
            case 2: self = .PostalAddressPhone
            default: self = .All
            }
        }
        
        var stpContactFields: Set<STPContactField> {
            switch self {
            case .None: return []
            case .Email: return [.emailAddress]
            case .PostalAddressPhone: return [.postalAddress, .phoneNumber]
            case .All: return [.postalAddress, .phoneNumber, .emailAddress, .name]
            }
        }
    }
    
    private enum ShippingType: String {
        case Shipping = "Shipping"
        case Delivery = "Delivery"
        
        init(row: Int) {
            switch row {
            case 0: self = .Shipping
            default: self = .Delivery
            }
        }
        
        var stpShippingType: STPShippingType {
            switch self {
            case .Shipping: return .shipping
            case .Delivery: return .delivery
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss as () -> Void))
    }
    
    @objc func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    
    
}
