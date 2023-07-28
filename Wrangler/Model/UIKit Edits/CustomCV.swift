//
//  CustomCV.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 15/08/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import Foundation
import UIKit

class CustomCV: UICollectionView{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.showsVerticalScrollIndicator = false
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
    
}
