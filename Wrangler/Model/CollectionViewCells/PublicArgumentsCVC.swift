//
//  PublicArgumentCVC.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 29/09/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import UIKit

class PublicArgumentCVC: UICollectionViewCell {
    
    
    @IBOutlet weak var topicTitle: UILabel!
    @IBOutlet weak var voteInfoLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAgainstImage: ProfileImage!
    @IBOutlet weak var upvoteDisp: UILabel!
    @IBOutlet weak var userForImage: ProfileImage!
    
    func setPublicArgumentCell(argument:  PublicArgument){
        
        backgroundColor = DesignConstants.mainPurple.withAlphaComponent(0.6)
        layer.masksToBounds = true
        layer.cornerRadius = DesignConstants.cornerRadius
        
        topicTitle.text = argument.topicTitle
        
        let secondsTillEnding = argument.endingAt - Date.getCurrentSeconds()
   
        voteInfoLabel.adjustsFontSizeToFitWidth = true
        if secondsTillEnding < 0{
            voteInfoLabel.text = "Won by \(argument.winner!)"
        }
        else if argument.thisUserSide != .isNeutral {
            voteInfoLabel.text = "Voted"
        }
        else{
            voteInfoLabel.text = "Winner in \(secondsTillEnding/60) mins"
        }
   
        voteInfoLabel.backgroundColor = DesignConstants.accentBlue
        voteInfoLabel.layer.masksToBounds = true
        voteInfoLabel.layer.cornerRadius = DesignConstants.cornerRadius
        voteInfoLabel.layer.borderWidth = 3
        voteInfoLabel.layer.borderColor = DesignConstants.accentBlue.cgColor
        
        usernameLabel.textColor = UIColor.white
        topicTitle.textColor = UIColor.white
        upvoteDisp.textColor = UIColor.white
        
        let usernameLabelString = "\(argument.userAgainstInfo["username"]!) against \(argument.userForInfo["username"]!)"
        var usernameLabelEdited = NSMutableAttributedString(string: usernameLabelString, attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 14, weight: .semibold)])
        usernameLabelEdited.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location:0,length:argument.userAgainstInfo["username"]!.count))
        usernameLabelEdited.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location:argument.userAgainstInfo["username"]!.count + 9, length:argument.userForInfo["username"]!.count))
        
        usernameLabel.attributedText = usernameLabelEdited

        var tenseString: String = "is winning by"
        
        if(argument.archived){
            tenseString = "has won by"
        }
        
        if argument.upvotesFor > argument.upvotesAgainst{
            upvoteDisp.text = "\(argument.userForInfo["username"]!) \(tenseString) \(argument.upvotesFor - argument.upvotesAgainst)"

        }
        else if argument.upvotesFor < argument.upvotesAgainst{
            upvoteDisp.text = "\(argument.userAgainstInfo["username"]!) \(tenseString) \(argument.upvotesAgainst - argument.upvotesFor)"
        }
        else if !argument.archived{
            upvoteDisp.text = "Neither winning - vote now"
        }
        
        userForImage.layer.borderColor = DesignConstants.mainBlue.cgColor
        
        //image fetching
        if let url = argument.userForInfo["profileImageUrl"]{
            userForImage.getCachedImage(urlString: url) { (image, err) in
                if let err = err {
                    print(err)
                    return
                }
                if let image = image{
                    DispatchQueue.main.async{
                        UIView.transition(with: self.userForImage,
                                          duration:0.5,
                                          options: UIView.AnimationOptions.transitionCrossDissolve,
                                          animations: { self.userForImage.image = image },
                                          completion: nil)
                    }}
            }
        }
        
        userAgainstImage.layer.borderColor = DesignConstants.mainRed.cgColor
        if let url = argument.userAgainstInfo["profileImageUrl"]{
            userAgainstImage.getCachedImage(urlString: url) { (image, err) in
                if let err = err {
                    print(err)
                    return
                }
                if let image = image{
                    DispatchQueue.main.async{
                        UIView.transition(with: self.userAgainstImage,
                                          duration:0.5,
                                          options: UIView.AnimationOptions.transitionCrossDissolve,
                                          animations: { self.userAgainstImage.image = image },
                                          completion: nil)
                    }}
            }
        }
    }
}
