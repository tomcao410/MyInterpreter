//
//  ChatLogMessageCell.swift
//  MyInterpreter
//
//  Created by Macbook on 6/16/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import AVKit

enum messageContent {
    case downloading(side: messageSide, viewWidth: CGFloat)
    case text(content: String, viewWidth: CGFloat, side: messageSide)
    case image(content: UIImage, viewWidth: CGFloat, viewHeight: CGFloat, side: messageSide)
    case audio(content: Data, viewWidth: CGFloat, side: messageSide)
    case none
}

enum messageSide {
    case left
    case right
}

protocol audioPlayer {
    func playAudio(data: Data)
    func stopAudio()
    func pauseAudio()
    func replayAudio()
}

class ChatLogMessageCell: BaseCell {
    
    var delegate: audioPlayer!
    
    override func prepareForReuse() {
        imageContentView.image = nil
        messageTextView.text = nil
        messageTextView.textColor = nil
        imageContentView.isHidden = true
        textBubbleView.isHidden = true
        audioPlayView.isHidden = true
        indicatorView.isHidden = true
        AudioCellProfileImageAnchor?.isActive = false
        ImageCellProfileImageAnchor?.isActive = false
        TextCellProfileImageAnchor?.isActive = false
        DownloadingCellProfileImageAnchor?.isActive = false
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
    
    let audioPlayView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        return view
    }()
    
    let indicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        return view
    }()
    
    let audioPlayer: AVAudioPlayer! = nil
    
    var TextCellProfileImageAnchor: NSLayoutConstraint?
    var ImageCellProfileImageAnchor: NSLayoutConstraint?
    var AudioCellProfileImageAnchor: NSLayoutConstraint?
    var DownloadingCellProfileImageAnchor: NSLayoutConstraint?
    
    override func setupViews() {
        super.setupViews()
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        addSubview(imageContentView)
        addSubview(audioPlayView)
        addSubview(indicatorView)
        self.backgroundColor = .clear
        profileImageView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        TextCellProfileImageAnchor = profileImageView.bottomAnchor.constraint(equalTo: textBubbleView.bottomAnchor)
        ImageCellProfileImageAnchor = profileImageView.bottomAnchor.constraint(equalTo: imageContentView.bottomAnchor)
        AudioCellProfileImageAnchor = profileImageView.bottomAnchor.constraint(equalTo: audioPlayView.bottomAnchor)
        DownloadingCellProfileImageAnchor = profileImageView.bottomAnchor.constraint(equalTo: indicatorView.bottomAnchor)
    }
    
    func adjustBottomProfileImageAnchor(cellContent: messageContent) {
        switch cellContent {
        case .audio:
            AudioCellProfileImageAnchor?.isActive = true
        case .text:
            TextCellProfileImageAnchor?.isActive = true
        case .image:
            ImageCellProfileImageAnchor?.isActive = true
        case .downloading:
            DownloadingCellProfileImageAnchor?.isActive = true
        default:
            break
        }
    }
    
    func adjustLayout(with messageContent: messageContent) {
        switch messageContent {
        case .text(let content, let viewWidth, let cellSide):
            adjustBottomProfileImageAnchor(cellContent: .text(content: content, viewWidth: viewWidth, side: cellSide))
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
            adjustBottomProfileImageAnchor(cellContent: .image(content: image, viewWidth: viewWidth, viewHeight: viewHeight, side: cellSide))
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
                    imageContentView.frame = CGRect(x: viewWidth - maxHeight * ratio - 16, y: 0, width: maxHeight * ratio, height: maxHeight)
                }
            }
        case .downloading(let cellSide, let viewWidth):
            let maxWidth = viewWidth * 2 / 3
            indicatorView.isHidden = false
            
            switch cellSide {
            case .left:
                profileImageView.isHidden = false
                
                indicatorView.frame = CGRect(x: 48, y: 0, width: maxWidth / 2, height: 40)
                indicatorView.backgroundColor = .lightGray
                
            case .right:
                profileImageView.isHidden = true
                
                indicatorView.frame = CGRect(x: viewWidth - maxWidth / 2 - 16, y: 0, width: maxWidth / 2, height: 40)
                indicatorView.backgroundColor = .black
            }
            
            indicatorView.addSubview(spinner)
            spinner.isHidden = false
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.topAnchor.constraint(equalTo: indicatorView.topAnchor).isActive = true
            spinner.bottomAnchor.constraint(equalTo: indicatorView.bottomAnchor).isActive = true
            spinner.leftAnchor.constraint(equalTo: indicatorView.leftAnchor).isActive = true
            spinner.rightAnchor.constraint(equalTo: indicatorView.rightAnchor).isActive = true
            spinner.startAnimating()
        case .audio(let data, let viewWidth, let cellSide):
            adjustBottomProfileImageAnchor(cellContent: .audio(content: data, viewWidth: viewWidth, side: cellSide))

            let maxWidth = viewWidth / 3 * 2

    //            delegate.playAudio(data: data)
            switch cellSide {
            case .left:
                profileImageView.isHidden = false
                
                audioPlayView.frame = CGRect(x: 48, y: 0, width: maxWidth, height: 60)
                
                
            case .right:
                profileImageView.isHidden = true
                
                audioPlayView.frame = CGRect(x: viewWidth - maxWidth - 16, y: 0, width: maxWidth, height: 60)
            }
        case .none:
            print("nothing")
        }
    }
}

