//
//  FullImageViewController.swift
//  MyInterpreter
//
//  Created by Macbook on 6/17/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

enum imageType {
    case landscape
    case fortrait
    case none
}

class FullImageViewController: UIViewController {

    var image: UIImage?
    
    let blackView: UIView = {
        let view = UIView()
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    
    func getImageType() -> imageType {
        if let image = image {
            if (image.size.width > image.size.height) {
                return imageType.landscape
            } else {
                return imageType.fortrait
            }
        }
        return imageType.none
    }

}
