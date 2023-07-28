//
//  TitleCVC.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 04/08/2019.
//  Copyright © 2019 Luca Sarif-Kattan. All rights reserved.
//

import UIKit

protocol TitleCVCSearchbarDelegate{
    func searchTopics(searchTerm: String)
}

class TitleCVC: UICollectionViewCell, UISearchBarDelegate {
    
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var button: UIButton!
   @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var title: UILabel!

    @IBOutlet weak var searchbar: UISearchBar!
    
    var searchbarDelegate: TitleCVCSearchbarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title.font = UIFont.systemFont(ofSize: DesignConstants.largeFontSize, weight: .bold)
        title.textColor = UIColor.white
        subtitle.textColor = UIColor.white
        backgroundColor = DesignConstants.mainPurple.withAlphaComponent(0.4)
        subtitle.font = UIFont.systemFont(ofSize: DesignConstants.defaultFontSize, weight: .medium)
        title.numberOfLines = 0
        subtitle.numberOfLines = 0
        button.tintColor = DesignConstants.accentBlue
        layer.cornerRadius = DesignConstants.cornerRadius
        /*
        title.minimumScaleFactor = 0.1
        subtitle.minimumScaleFactor = 0.1
        
        title.font = UIFont.systemFont(ofSize: 100)
        subtitle.font = UIFont.systemFont(ofSize: 100)
        title.adjustsFontSizeToFitWidth = true
        subtitle.adjustsFontSizeToFitWidth = true*/
        
        
    }
    
    func initSearchbar(){
        searchbar.delegate = self
        searchbar.showsCancelButton = true
        searchbar.tintColor = UIColor.black
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if let searchtext = searchbar.text{
            searchbarDelegate?.searchTopics(searchTerm: searchtext)
            searchbar.text = ""

        }
        
        
    }
    

    
}
