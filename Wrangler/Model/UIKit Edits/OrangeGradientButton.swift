//
//  CustomButtons.swift
//  Test
//
//  Created by LucaSarif on 23/12/2017.
//  Copyright © 2017 LucaSarif. All rights reserved.
//


import Foundation
import UIKit

class OrangeGradientButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.black.cgColor
        clipsToBounds = true
        layer.borderWidth = 0.25/UIScreen.main.nativeScale
        titleEdgeInsets = UIEdgeInsetsMake(0,5,0,5)
        self.applyGradient(colors: [UIColor(red:0.95, green:0.54, blue:0.69, alpha:1.0).cgColor, UIColor(red:0.96, green:0.74, blue:0.53, alpha:1.0).cgColor])
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height/2
    }
}
