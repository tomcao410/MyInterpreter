//
//  UserInfoCell.swift
//  MyInterpreter
//
//  Created by Tom on 6/8/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

class UserInfoCell: UITableViewCell {

    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var contextLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
