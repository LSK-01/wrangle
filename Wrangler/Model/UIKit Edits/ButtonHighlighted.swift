//
//  CustomButton.swift
//  Test
//
//  Created by LucaSarif on 23/12/2017.
//  Copyright © 2017 LucaSarif. All rights reserved.
//


import Foundation
import UIKit

class CustomButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()// Always call the super class when overriding
        
        adjustsImageWhenHighlighted = false
        showsTouchWhenHighlighted = false
        
    }

 
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.4 : 1.0
            
        }
    }
    
    func fadeIn(){
        UIView.animate(withDuration: 1.0, animations: {
            self.alpha = 1.0
        })
    }
    
}


