//
//  HighlightingButton.swift
//  MyInterpreter
//
//  Created by Tom on 5/22/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Stripe

class HighlightingButton: UIButton {

    var highlightColor = UIColor(white: 0, alpha: 0.05)
    
    convenience init(highlightColor: UIColor) {
        self.init()
        self.highlightColor = highlightColor
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = self.highlightColor
            } else {
                self.backgroundColor = UIColor.clear
            }
        }
    }
}

class ConfirmButton: HighlightingButton {
    var disabledColor = UIColor.lightGray
    var enabledColor = UIColor(red:0.22, green:0.65, blue:0.91, alpha:1.00)
    
    override var isEnabled: Bool {
        didSet {
            let color = isEnabled ? enabledColor : disabledColor
            self.setTitleColor(color, for: UIControl.State())
            self.layer.borderColor = color.cgColor
            self.highlightColor = color.withAlphaComponent(0.5)
        }
    }
    
    convenience init(enabled: Bool, theme: STPTheme) {
        self.init()
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 10
        self.setTitle("Confirm", for: UIControl.State())
        self.disabledColor = theme.secondaryForegroundColor
        self.enabledColor = theme.accentColor
        self.isEnabled = enabled
    }

}
