//
//  NavigationBar-Extension.swift
//  MyInterpreter
//
//  Created by Tom on 6/7/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

extension UINavigationItem
{
    func setCustomNavBar(title: String)
    {
        self.title = title
        self.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
