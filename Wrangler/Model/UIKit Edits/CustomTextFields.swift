//
//  IBAddTextFieldIcon.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 17/08/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    func shake(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 4, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 4, y: self.center.y))
        // Only changing X axis - moving 4 every time - reversing every time
        
        self.layer.add(animation, forKey: "position")
        
    }


   let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clearButtonMode = .whileEditing
        self.font = UIFont.systemFont(ofSize: DesignConstants.defaultFontSize, weight: .medium)
        self.textColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
           
           
       }
       
       override init(frame: CGRect) {
           super.init(frame: frame)
       }

}

class BlueTextField: CustomTextField{
       override func awakeFromNib() {
         
        self.backgroundColor = DesignConstants.mainBlue.withAlphaComponent(0.7)
        self.layer.cornerRadius = self.frame.height/2
        
     }
}

class RedTextField: CustomTextField{
    override func awakeFromNib() {
        self.backgroundColor = DesignConstants.accentOrange.withAlphaComponent(0.7)
        self.layer.cornerRadius = DesignConstants.cornerRadius

    }
}
