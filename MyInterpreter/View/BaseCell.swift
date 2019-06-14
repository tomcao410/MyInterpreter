//
//  BaseCell.swift
//  MyInterpreter
//
//  Created by Tom on 6/12/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

class BaseCell: UITableViewCell {

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
    }

}
