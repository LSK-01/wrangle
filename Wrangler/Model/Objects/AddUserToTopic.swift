//
//  AddUserToTopic.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 04/07/2019.
//  Copyright © 2019 Luca Sarif-Kattan. All rights reserved.
//

import Foundation
import Firebase

//to pass new userside data to the topics array in the collectionview
protocol AddUserToTopicDelegate: AnyObject{
    func updateTopic(forIndex: Int, topic: Topic)
    
}

class AddUserToTopic: TopicCVCDelegate {
    
    func matchNowButtonPressed(forTopic: Topic) {
        //if we want to we can include functionality for a button istead of instant match
        
    }
    
    var sideChosen: TopicCVCButtonStatus!
    
    var topic: Topic!
    var wasAdded: Bool = false
    
    
    weak var delegate: AddUserToTopicDelegate?
    
    func sideButtonPressed(forTopic: Topic, index: Int, buttonStatus: TopicCVCButtonStatus, completionSideButton: @escaping() -> Void) {
        
        topic = forTopic
       
        var toSide: UserSideStates!
        
        switch buttonStatus {
            
        case .clickedAgainst:
            toSide = .isAgainst
            
            self.userChangingSides(toSide: toSide, completion: {
                
                self.topic.userSide = toSide
                TopicFunctions.matchUser(forTopic: self.topic) { (wasMatchSuccess) in
                    
                    self.topic.isMatched = wasMatchSuccess
                    if wasMatchSuccess{
                        //self.topic.numUsersForTotal += 1

                    }
                    self.delegate?.updateTopic(forIndex: index, topic: self.topic)
                    completionSideButton()
                }
            })
            
        case .clickedFor:
            
            toSide = .isFor
            
            self.userChangingSides(toSide: toSide, completion: {
                
                self.topic.userSide = toSide
                TopicFunctions.matchUser(forTopic: self.topic) { (wasMatchSuccess) in
                    self.topic.isMatched = wasMatchSuccess
                    
                    if wasMatchSuccess{
                        //self.topic.numUsersAgainstTotal += 1

                    }
                    
                    self.delegate?.updateTopic(forIndex: index, topic: self.topic)
                    completionSideButton()
                }
                
            })
            
        case .clickedLeave:
            //alert YOU WERE REMOVED
            toSide = .isNeutral
            
            userChangingSides(toSide: toSide) {
                self.topic.userSide = toSide
                
                self.delegate?.updateTopic(forIndex: index, topic: self.topic)
                completionSideButton()
            }
        }
    }
    
    //removes and adds user in one call -everything handled
    func userChangingSides(toSide: UserSideStates, completion: @escaping(() -> Void)){
        
        var data: [String: Any] = [:]
        var topicsIncrementer: Int64 = 0
        //if they want to be removed but are already neutral nothing to do
        if toSide == .isNeutral && topic.userSide == .isNeutral{
            completion()
            return
        }
        
        //if user is currently not neutral we need to also remove them from their current side
        if self.topic.userSide != .isNeutral {
            let currentSideFieldNames = TopicFunctions.getFieldNames(forSide: self.topic.userSide)!
            
            data["\(currentSideFieldNames.users)." + User.details.uid] = FieldValue.delete()
            data[currentSideFieldNames.numUsersPendingMatch] = FieldValue.increment(Int64(-1))
            data[currentSideFieldNames.numUsersTotal] = FieldValue.increment(Int64(-1))
            topicsIncrementer = -1
            
            //artificially update topic just for user satisfaction - the db has the actual value so its fine
            if self.topic.userSide == .isFor{
                self.topic.numUsersForTotal -= 1
                self.topic.numUsersForPendingMatch -= 1
            }
            else{
                self.topic.numUsersAgainstTotal -= 1
                self.topic.numUsersAgainstPendingMatch -= 1
            }
        }
        
        //if "toSide" is .isNeutral then theywant to be removed so we skip this bit
        if toSide != .isNeutral{
            
            topicsIncrementer += 1
            
            let newSideFieldNames = TopicFunctions.getFieldNames(forSide: toSide)!
            
            data[newSideFieldNames.users + "." + User.details.uid] = "isNotMatched"
            data[newSideFieldNames.numUsersPendingMatch] = FieldValue.increment(Int64(1))
            data[newSideFieldNames.numUsersTotal] = FieldValue.increment(Int64(1))
            
            //artificially update topic just for user satisfaction - the db has the actual value so its fine
            if toSide == .isFor{
                self.topic.numUsersForTotal += 1
                self.topic.numUsersForPendingMatch += 1
            }
            else{
                self.topic.numUsersAgainstTotal += 1
                self.topic.numUsersAgainstPendingMatch += 1
            }
        }
        
        
        //update controversiality score - were using old values (stuff might have changed since the user loaded up this topic) but it doesnt need to be so precise
        var calculatingControv = topic.numUsersAgainstTotal - topic.numUsersForTotal
        //ensure value is positive
        calculatingControv = abs(calculatingControv)
        //subtract total users
        calculatingControv -= (topic.numUsersAgainstTotal + topic.numUsersForTotal)
        //ensure value is positive again - now a larger controv score will mean the topic is more controv
        let controv = abs(calculatingControv)
        data["controversiality"] = controv
        
        
        Database.updateDocumentErrorHandling(path: "users/\(User.details.uid)", data: ["topics": FieldValue.increment(topicsIncrementer)]) { err in
            if let err = err{
                return
             }
            else {
                User.details.topics += Int(topicsIncrementer)
            }
        }
        
        Database.updateDocumentErrorHandling(path: "topics/\(self.topic.topicTitle)", data: data, completion: { err in
            if let err = err {
                print(err)
                return
            }
            else {
                completion()
                return
            }
        })
        

    }
}

