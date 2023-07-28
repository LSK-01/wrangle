//
//UserCollectionViewCell.swift
//  Wrangler
//
//  Created by LucaSarif on 24/06/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userProfileImage: ProfileImage!
    
    func setUserCell(opponent: Opponent){
        self.layer.cornerRadius = 7
        self.backgroundColor = UIColor(red:0.99, green:0.99, blue:0.99, alpha:1.0).withAlphaComponent(0.3)
        
        username.text = opponent.username
        if let url = opponent.profileImageUrl{
            
            userProfileImage.getCachedImage(urlString: url) { (returnedImage, err) in
                if let err = err {
                    print(err)
                    return
                }
                if let returnedImage = returnedImage{
                    
                    DispatchQueue.main.async{
                        self.userProfileImage.image = returnedImage
                    }
                }
            }
        }
    }
}
