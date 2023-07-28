//
//  ProfileImage.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 23/09/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import Foundation
import UIKit

class ProfileImage: UIImageView {
    override func awakeFromNib() {
        //or bounds.width/2
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
        layer.borderWidth = 2
        layer.borderColor = DesignConstants.accentBlue.cgColor
        clipsToBounds = true
        backgroundColor = DesignConstants.mainPurple.withAlphaComponent(0.3)
        contentMode = .scaleAspectFit
        //image = UIImage(named: "defaultProfileIcon")
    }
}

