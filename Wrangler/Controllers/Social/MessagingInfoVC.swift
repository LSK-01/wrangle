//
//  MessagingInfoVC.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 23/09/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import UIKit

class MessagingInfoVC: UIViewController {

    @IBOutlet weak var timeUntilLabel: UILabel!
    @IBOutlet weak var goingPublicIn: UILabel!
    @IBOutlet weak var opponentName: UILabel!
    @IBOutlet weak var opponentImageView: UIImageView!
    var argumentInfo: Argument!
    var opponentImageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageUrl = opponentImageUrl{

            opponentImageView.getCachedImage(urlString: imageUrl) { (image, err) in
                if let err = err{
                    print(err)
                    return
                }
                if let image = image {
                    DispatchQueue.main.async{
                    self.opponentImageView.image = image
                    }
                }
            }
        }

        opponentName.text = argumentInfo.opponentUsername
        
        if argumentInfo.isPublic{
            timeUntilLabel.isHidden = true
            goingPublicIn.text = "Your argument is already public! View it: "
        }
        else{
            let secsTillGoingPublic = argumentInfo.goingPublicAt / 3600 - Date.getCurrentMinutes()

        }
        
        
    }
    
    
    
    @IBAction func reportUser(_ sender: Any) {
        
    }

}

