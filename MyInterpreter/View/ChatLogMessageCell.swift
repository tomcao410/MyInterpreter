//
//  ChatLogMessageCell.swift
//  MyInterpreter
//
//  Created by Macbook on 6/16/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

enum messageContent {
    case none
    case text(content: String, viewWidth: CGFloat, side: messageSide)
    case video
    case image(content: UIImage, viewWidth: CGFloat, viewHeight: CGFloat, side: messageSide)
    case audio
}

enum messageSide {
    case left
    case right
}

class ChatLogMessageCell: BaseCell {
    
    override func prepareForReuse() {
        imageContentView.image = nil
        messageTextView.text = nil
        messageTextView.textColor = nil
        imageContentView.isHidden = true
        textBubbleView.isHidden = true
        spinner.isHidden = true
        spinner.stopAnimating()
    }
    
    var messageContent:messageContent = .none {
        didSet {
            adjustLayout(with: self.messageContent)
        }
    }
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.isHidden = true
        return spinner
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    let imageContentView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textAlignment = .left
        textView.backgroundColor = .clear
        return textView
    }()
    
    var TextCellProfileImageAnchor: NSLayoutConstraint?
    
    var ImageCellProfileImageAnchor: NSLayoutConstraint?
    
    override func setupViews() {
        super.setupViews()
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        addSubview(imageContentView)
        addSubview(spinner)
        profileImageView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        TextCellProfileImageAnchor = profileImageView.bottomAnchor.constraint(equalTo: textBubbleView.bottomAnchor)
        ImageCellProfileImageAnchor = profileImageView.bottomAnchor.constraint(equalTo: imageContentView.bottomAnchor)
    }
    
    func adjustLayout(with messageContent: messageContent) {
        switch messageContent {
        case .text(let content, let viewWidth, let cellSide):
            ImageCellProfileImageAnchor?.isActive = false
            TextCellProfileImageAnchor?.isActive = true
            textBubbleView.isHidden = false
            
            messageTextView.text = content
            
            let sizeToFit = CGSize(width: viewWidth * 2 / 3, height: CGFloat.greatestFiniteMagnitude)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: content).boundingRect(with: sizeToFit, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
            
            switch cellSide {
            case .left:
                messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                textBubbleView.frame = CGRect(x: 48 , y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                messageTextView.textColor = .black
                profileImageView.isHidden = false
                textBubbleView.backgroundColor = .lightGray
            case .right:
                messageTextView.frame = CGRect(x: viewWidth - estimatedFrame.width - 16 - 16, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                textBubbleView.frame = CGRect(x: viewWidth - estimatedFrame.width - 16 - 8 - 16, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                profileImageView.isHidden = true
                messageTextView.textColor = .white
                textBubbleView.backgroundColor = .black
            }
            
        case .image(let image, let viewWidth, let viewHeight, let cellSide):
            TextCellProfileImageAnchor?.isActive = false
            ImageCellProfileImageAnchor?.isActive = true
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            
            let ratio = image.size.width / image.size.height
            let maxWidth = viewWidth / 3 * 2
            let maxHeight = viewHeight / 3
            
            imageContentView.image = image
            imageContentView.isHidden = false
            
            switch cellSide {
            case .left:
                profileImageView.isHidden = false
                
                if ratio > 1.0 { //landscape image
                    imageContentView.frame = CGRect(x: 48, y: 0, width: maxWidth, height: maxWidth / ratio)
                } else {
                    imageContentView.frame = CGRect(x: 48, y: 0, width: maxHeight * ratio, height: maxHeight)
                }
            case .right:
                profileImageView.isHidden = true
                
                if ratio > 1.0 {
                    imageContentView.frame = CGRect(x: viewWidth - maxWidth - 16, y: 0, width: maxWidth, height: maxWidth / ratio)
                } else {
                    imageContentView.frame = CGRect(x: viewWidth - maxHeight * ratio, y: 0, width: maxHeight * ratio, height: maxHeight)
                }
            }
        case .none:
            spinner.isHidden = false
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            spinner.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            spinner.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            spinner.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            spinner.startAnimating()
        default:
            print("message cell is constructing")
        }
    }
}

