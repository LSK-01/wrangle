//
//  RoundedLabel.swift
//  Test
//
//  Created by LucaSarif on 24/12/2017.
//  Copyright © 2017 LucaSarif. All rights reserved.
//

import Foundation
import UIKit

class RoundedLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()// Always call the super class when overriding
        
        layer.borderWidth = 6/UIScreen.main.nativeScale // Gives us exactly x amount of pixels
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16) // Padding between border and button
        
        
        // May want to add a feature to change size with iphone settings size
    }
    override func layoutSubviews(){ // Using layout subviews so corner radius is updated if height is changed
        super.layoutSubviews()
        layer.cornerRadius = 13 // Gives roundness
        layer.borderColor = tintColor.cgColor
    }
}

