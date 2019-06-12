//
//  ListInterpretersCell.swift
//  MyInterpreter
//
//  Created by Tom on 4/24/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

class ListInterpretersCell: UITableViewCell {

    // MARK: UI elements
    @IBOutlet weak var interpreterImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var languagesLbl: UILabel!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    // MARK: Work place
    override func awakeFromNib() {
        super.awakeFromNib()
        
        spinner.startAnimating()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
