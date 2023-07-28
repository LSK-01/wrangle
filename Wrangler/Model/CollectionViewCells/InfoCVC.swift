//
//  InfoCVC.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 25/10/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import UIKit

class InfoCVC: UICollectionViewCell {
    @IBOutlet weak var mainInfo: UILabel!
    @IBOutlet weak var extraInfo: UILabel!
    
    func setInfo(main: String, extra: String){
        self.layer.cornerRadius = 7
        self.layer.borderWidth = 1/UIScreen.main.nativeScale
        
        if extra == "Wrangles"{
            self.alpha = 1
        }
        else{
        self.alpha = 0.7
        }
        
        extraInfo.layer.cornerRadius = extraInfo.frame.height/2
        mainInfo.text = main
        extraInfo.text = extra
        //mainInfo.alpha = 0.7
    }
}
