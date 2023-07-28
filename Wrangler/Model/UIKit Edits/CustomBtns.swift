//
//  CustomButtons.swift
//  Test
//
//  Created by LucaSarif on 23/12/2017.
//  Copyright © 2017 LucaSarif. All rights reserved.
//


import Foundation
import UIKit

class CustomBtn: UIButton{
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20
        , weight: .semibold)
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height/2
        
        
    }
}

class RedCustomBtn: CustomBtn {
    
    override func awakeFromNib() {
        super.awakeFromNib()
   
        backgroundColor = DesignConstants.mainRed
        self.layoutIfNeeded()
    }

}

class BlueCustomBtn: CustomBtn {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = DesignConstants.mainBlue
        self.layoutIfNeeded()

    }
}

@IBDesignable
class LeftAlignedIconButton: UIButton {
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleRect = super.titleRect(forContentRect: contentRect)
        let imageSize = currentImage?.size ?? .zero
        let availableWidth = contentRect.width - imageEdgeInsets.right - imageSize.width - titleRect.width
        return titleRect.offsetBy(dx: round(availableWidth / 2), dy: 0)
    }
}
