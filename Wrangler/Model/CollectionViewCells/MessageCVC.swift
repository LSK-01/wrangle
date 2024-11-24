//
//  MessageCVC.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 29/08/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import Foundation
import UIKit

protocol ZoomImageDelegate: class{
    func zoomStartImage(startImage: UIImageView)
    
}
class MessageCVC: UICollectionViewCell {
    
    weak var delegate: ZoomImageDelegate?
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        view.alpha = 0.8
      
        view.clipsToBounds = true
        return view
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0

        return label
    }()
    
   lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.darkGray
        imageView.image = nil
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    @objc func imageTapped(sender: UITapGestureRecognizer){
        if let startImage = sender.view as? UIImageView{
            if delegate != nil{
            delegate?.zoomStartImage(startImage: startImage)
            }
        }
    }
    
    func setMessageCell(message: Message){

        addSubview(textBubbleView)
        addSubview(imageView)
        addSubview(textLabel)
        sendSubviewToBack(textBubbleView)
        
        switch message.type{
            
        case .text:
            
            imageView.removeFromSuperview()
            
            textLabel.text = message.text
            
        case .image:
            imageView.backgroundColor = UIColor.darkGray
            imageView.image = nil
            //remove any recos already on it we only want 1
            for recognizer in imageView.gestureRecognizers ?? [] {
                imageView.removeGestureRecognizer(recognizer)
            }
            
            //add gesture recognizer
            let imageTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
            imageTapRecognizer.addTarget(self, action: #selector(imageTapped(sender:)))
            imageView.gestureRecognizers = [imageTapRecognizer]
            
            //make sure textLabel is send to back
            sendSubviewToBack(textLabel)
            imageView.image = nil
            //constraint imageview to textBubbleView
            imageView.leftAnchor.constraint(equalTo: textBubbleView.leftAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: textBubbleView.topAnchor).isActive = true
            imageView.heightAnchor.constraint(equalTo: textBubbleView.heightAnchor).isActive = true
            imageView.widthAnchor.constraint(equalTo: textBubbleView.widthAnchor).isActive = true
            
            imageView.getCachedImage(urlString: message.imageUrl!) { (image, err) in
                if err != nil{
                    //so even if it fails at least the bubble doesnt look shit
                    DispatchQueue.main.async {
                        self.textLabel.text = "           "
                    }
                    return
                }
                
                if let image = image{
                    DispatchQueue.main.async{
                    self.imageView.image = image
                    }
                }
            }
            
        case .video:
            imageView.removeFromSuperview()
            break
        }
        
        //if u wanna decide to use soft hyphens again
        /*
        if let text = message.text{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        
        let hyphenAttribute = [
            NSAttributedStringKey.paragraphStyle : paragraphStyle,
            ] as [NSAttributedStringKey : Any]
        
        let attributedString = NSMutableAttributedString(string: text, attributes: hyphenAttribute)
        self.textLabel.attributedText = attributedString
        }*/
        
        
        
        
        //textLabel.sizeToFit()
    }
    

    
}
