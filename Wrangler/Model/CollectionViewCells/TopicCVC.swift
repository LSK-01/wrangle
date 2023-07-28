//
//  TopicCVC.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 03/07/2019.
//  Copyright © 2019 Luca Sarif-Kattan. All rights reserved.
//

import UIKit

protocol TopicCVCDelegate: AddUserToTopic {
    func sideButtonPressed(forTopic: Topic, index: Int, buttonStatus: TopicCVCButtonStatus, completionSideButton: @escaping() -> Void)
    
    func matchNowButtonPressed(forTopic: Topic)
}

//i think we can just use this enum for everything and get rid of the ones below
enum TopicCVCButtonStatus {
    case clickedFor
    case clickedAgainst
    case clickedLeave
}

class TopicCVC: UICollectionViewCell {
    weak var buttonDelegate: TopicCVCDelegate?
    
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var topicTitle: UILabel!
    @IBOutlet weak var numberOfUsersLabel: UILabel!
    @IBOutlet weak var joinAgainstButton: UIButton!
    @IBOutlet weak var joinForButton: UIButton!
    
    @IBOutlet weak var matchInfoLabel: UILabel!
    
    var cellTopic: Topic!
    var topicIndex: Int!
    
    var forButtonAdd: Bool = true
    var againstButtonAdd: Bool = true
    
    func setTopic(topic: Topic, index: Int){

        joinForButton.tintColor = DesignConstants.mainBlue
        joinAgainstButton.tintColor = DesignConstants.mainRed
        
        self.matchInfoLabel.text = "Pending match"
        layer.cornerRadius = 10
        layer.masksToBounds = true
        topicTitle.textColor = UIColor.white
        numberOfUsersLabel.textColor = UIColor.white
        category.textColor = UIColor.white
        
        matchInfoLabel.layer.masksToBounds = true
        matchInfoLabel.layer.cornerRadius = DesignConstants.cornerRadius
        matchInfoLabel.layer.borderWidth = 3
        matchInfoLabel.layer.borderColor = DesignConstants.accentBlue.cgColor
        matchInfoLabel.backgroundColor = DesignConstants.accentBlue
        matchInfoLabel.textColor = UIColor.white

        self.backgroundColor = DesignConstants.mainPurple.withAlphaComponent(0.6)
        
        category.text = "By \(topic.creator)"
        topicIndex = index
        cellTopic = topic
        topicTitle.text = topic.topicTitle
        topicTitle.adjustsFontSizeToFitWidth = true
        
        numberOfUsersLabel.text = "For: \(topic.numUsersForTotal)  Against: \(topic.numUsersAgainstTotal)"
        
        if topic.userSide == .isFor {
            self.joinForButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
            self.joinAgainstButton.transform = .identity
            forButtonAdd = false
            againstButtonAdd = true
            
            
            matchInfoLabel.isHidden = false
            
        }
        if topic.userSide == .isAgainst {
            
            self.joinAgainstButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
            self.joinForButton.transform = .identity
            againstButtonAdd = false
            forButtonAdd = true
            matchInfoLabel.isHidden = false
            
        }
        if topic.userSide == .isNeutral{
            self.joinForButton.transform = .identity
            self.joinAgainstButton.transform = .identity
            
            forButtonAdd = true
            againstButtonAdd = true
            
            if topic.numUsersAgainstPendingMatch - topic.numUsersForPendingMatch != 0 {
                matchInfoLabel.text = "Matchers waiting"
            }
            else{
            matchInfoLabel.isHidden = true
            }
            
        }
        
        if topic.isMatched{
            matchInfoLabel.text = "Matched"
            matchInfoLabel.isHidden = false
        }
        
    }
    
    //rename to for tapped and against tapped
    //maybe have a time limiter or check for when each action has been completed until they can press another button otheriwse it might spazz out the system
    //maybe just have it load when a button is tapped until it is finished
    //jjust a small loading icon
    @IBAction func joinForTapped(_ sender: Any) {
        self.joinForButton.isUserInteractionEnabled = false
        self.joinAgainstButton.isUserInteractionEnabled = false

        guard !cellTopic.isMatched else {
            Alert.errorAlert(error: "You are matched on this topic. Finish your argument first.")
            return
        }
        
        if forButtonAdd{

            guard User.details.topics < FirebaseConstants.limitingTopicsTo else {
                 Alert.errorAlert(error: "You are in too many topics already. Wait for matches and finish arguments.")
                 return
             }
            
            UIView.animate(withDuration: 0.25, animations: {
                self.joinForButton.transform  = CGAffineTransform(rotationAngle: CGFloat(Double.pi/4))
            })
            if !self.againstButtonAdd{
                                   UIView.animate(withDuration: 0.25, animations: {
                                       self.joinAgainstButton.transform  = .identity
                                   })
                                   self.againstButtonAdd = true
                               }
            
            buttonDelegate?.sideButtonPressed(forTopic: cellTopic, index: topicIndex, buttonStatus: .clickedFor){
                
                    self.joinForButton.isUserInteractionEnabled = true
                    self.joinAgainstButton.isUserInteractionEnabled = true
                      
                    self.forButtonAdd = !self.forButtonAdd
 
            }
        }
        else {
      
            
            buttonDelegate?.sideButtonPressed(forTopic: cellTopic, index: topicIndex, buttonStatus: .clickedLeave){
                
              UIView.animate(withDuration: 0.25, animations: {
                             self.joinForButton.transform  = .identity
                         })
                         
                    self.joinForButton.isUserInteractionEnabled = true
                    self.joinAgainstButton.isUserInteractionEnabled = true

                    self.forButtonAdd = !self.forButtonAdd

            }
        }
    }
    
    
    @IBAction func joinAgainstTapped(_ sender: Any) {
        joinAgainstButton.isUserInteractionEnabled = false
        joinForButton.isUserInteractionEnabled = false
 
        
        guard !cellTopic.isMatched else {
            Alert.errorAlert(error: "You are matched on this topic. Finish your argument first.")
            return
        }
        
        if againstButtonAdd{
            
            guard User.details.topics < FirebaseConstants.limitingTopicsTo else {
                 Alert.errorAlert(error: "You are in too many topics already. Wait for matches and finish arguments.")
                 return
             }
            
            UIView.animate(withDuration: 0.25, animations: {
                self.joinAgainstButton.transform  = CGAffineTransform(rotationAngle: CGFloat(Double.pi/4))
            })
            
            if !self.forButtonAdd{
                       UIView.animate(withDuration: 0.25, animations: {
                           self.joinForButton.transform  = .identity
                       })
                       self.forButtonAdd = true
                       
                   }
            
            buttonDelegate?.sideButtonPressed(forTopic: cellTopic,index: topicIndex, buttonStatus: .clickedAgainst){
                
                self.joinAgainstButton.isUserInteractionEnabled = true
                self.joinForButton.isUserInteractionEnabled = true
                
                self.againstButtonAdd = !self.againstButtonAdd
                
            }
        }
        else {
            
           
            
            buttonDelegate?.sideButtonPressed(forTopic: cellTopic, index:topicIndex, buttonStatus: .clickedLeave){
               
                UIView.animate(withDuration: 0.25, animations: {
                    self.joinAgainstButton.transform  = .identity
                })
                
                    self.joinAgainstButton.isUserInteractionEnabled = true
                    self.joinForButton.isUserInteractionEnabled = true
                    
                    self.againstButtonAdd = !self.againstButtonAdd

            }
        }
    }
}

