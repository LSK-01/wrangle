//
//  SearchBar.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 15/08/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import Foundation
import UIKit

class SearchBar: UISearchBar{
    
    override func awakeFromNib() {
        self.isTranslucent = true
        self.alpha = 1
        self.barTintColor = UIColor.clear.withAlphaComponent(0.0)
        self.backgroundColor = UIColor.clear.withAlphaComponent(0.0)
        self.searchBarStyle = .minimal
        let textField = self.value(forKey: "searchField") as? UITextField
        textField?.textColor = UIColor.white
        //DO PLACEHOLDER COLOR
        //textField?.attributedPlaceholder.addAttribute(NSAttributedStringKey.foregroundColor, value:UIColor.white, range:),

        
    }
    
    
}
