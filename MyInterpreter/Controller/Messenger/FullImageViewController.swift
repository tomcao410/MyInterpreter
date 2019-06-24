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
        view.backgroundColor = .black
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        setUI()
    }
    
    func setUI() {
        blackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blackView)
        
        blackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        blackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        blackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        if let image = image {
            let imageView = UIImageView()
            imageView.image = self.image
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            
            view.addSubview(imageView)
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            let viewRatio = view.frame.width / view.frame.height
            let imageRatio = image.size.width / image.size.height
            if (imageRatio < viewRatio) {
                imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            } else {
                imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            }
        }
        
//        switch getImageType() {
//        case .fortrait:
//
//        case .landscape:
//            rotate90Degree(imageView: imageView)
//            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        case .none:
//            print("image is constructing")
//        }
        
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
    
    func rotate90Degree(imageView: UIImageView) {
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
    }

}
