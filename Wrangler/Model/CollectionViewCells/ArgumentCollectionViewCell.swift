//
//  ArgumentCollectionViewCell.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 29/07/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ArgumentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var latestMessage: UILabel!
    @IBOutlet weak var userProfileImage: ProfileImage!
    @IBOutlet weak var topicTitle: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var endingIn: UILabel!
    @IBOutlet weak var goToImage: UIImageView!
    
    func setArgumentCell(argument: Argument){
        topicTitle.sizeToFit()
        
        goToImage.isHidden = true

        goToImage.tintColor = DesignConstants.accentBlue
        endingIn.layer.masksToBounds = true
        endingIn.layer.cornerRadius = DesignConstants.cornerRadius
        endingIn.layer.borderWidth = 3
        endingIn.layer.borderColor = DesignConstants.accentBlue.cgColor
        endingIn.backgroundColor = DesignConstants.accentBlue
        endingIn.textColor = UIColor.white
        
        latestMessage.textColor = UIColor.white
        topicTitle.textColor = UIColor.white
        usernameLabel.textColor = UIColor.white
        
        latestMessage.text = "Start Arguing!"
        //add listener here - then get rid of viewdisapear functionality on messaging view - get latest message from listener
        if(!argument.isPublic){
            Database.db.collection("arguments").document("\(argument.argumentId)").collection("messages").order(by: "timeSent", descending: true).limit(to: 1).addSnapshotListener { snapshot, err in
                if let err = err {
                    Alert.errorAlert(error: err.localizedDescription)
                    return
                }
                else if let snapshot = snapshot{
                    //starting w latest message in the collection of doc changes returned
                    for docChange in snapshot.documentChanges{
                        if docChange.type == .added{
                            let message = Messages.createMessageObjectFromDoc(message: docChange.document)
                            self.latestMessage.text = message.text
                            
                            if(message.sentBy != User.details.uid && message.status != .read){
                                self.goToImage.isHidden = false
                            }
                        }
                        if docChange.type == .modified{
                            let message = Messages.createMessageObjectFromDoc(message: docChange.document)
                            
                            if(message.status == .read){
                                self.goToImage.isHidden = true
                            }
                        }
                    }
                }
            }
        }
        
        
        if !argument.isPublic && argument.goingPublicAt > Date.getCurrentSeconds(){
            endingIn.text = "Live: \(Int(argument.goingPublicAt / 60 - Date.getCurrentMinutes())) mins to go!"
        }
        else {
            endingIn.text = "Public"
        } 
        
        self.layer.cornerRadius = DesignConstants.cornerRadius
        self.backgroundColor = DesignConstants.mainPurple.withAlphaComponent(0.6)
        
        topicTitle.text = argument.topicTitle

        
        if argument.opponentUserSide == .isFor{
            userProfileImage.layer.borderColor = DesignConstants.mainBlue.cgColor
            usernameLabel.text = "Arguing Against"
        }
        else{
            usernameLabel.text = "Arguing For"
            userProfileImage.layer.borderColor = DesignConstants.mainRed.cgColor
        }
        
        if let url = argument.opponentProfileImageUrl{
            userProfileImage.getCachedImage(urlString: url) { (returnedImage, err) in
                if let err = err {
                    print(err)
                    return
                }
                if let returnedImage = returnedImage{
                    print("url getting for \(argument.topicTitle)")
                    DispatchQueue.main.async{
                        self.userProfileImage.image = returnedImage
                        
                    }
                }
            }
        }
        
    }
}

class RecentMatchesCVC: UICollectionViewCell{
    
    @IBOutlet weak var containerImageView: UIImageView!
    @IBOutlet weak var userProfileImage: ProfileImage!
    @IBOutlet weak var topicTitle: UILabel!
    
    func setArgumentCell(argument: Argument){
        self.layer.cornerRadius = DesignConstants.cornerRadius
        self.backgroundColor = DesignConstants.mainPurple.withAlphaComponent(0.3)
        
        topicTitle.text = argument.topicTitle
        topicTitle.sizeToFit()

        if argument.opponentUserSide == .isFor{
            containerImageView.tintColor = DesignConstants.mainBlue
            
        }
        else{
            containerImageView.tintColor = DesignConstants.accentOrange
            
        }
        if let url = argument.opponentProfileImageUrl{
            
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
        if argument.isPublic{
            self.backgroundColor = UIColor.purple
        }
        
    }
}
