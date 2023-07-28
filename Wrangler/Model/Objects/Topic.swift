//
//  Topic.swift
//  Test
//
//  Created by LucaSarif on 24/01/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import Foundation
import Firebase

enum UserSideStates: String{
    case isFor = "for"
    case isAgainst = "against"
    case isNeutral = "neutral"
}


struct FieldNames {
    var numUsersPendingMatch: String
    var numUsersTotal: String
    var users: String
    
    init(numUsersPendingMatch: String, users: String, numUsersTotal: String) {
        self.numUsersPendingMatch = numUsersPendingMatch
        self.users = users
        self.numUsersTotal = numUsersTotal
    }
    
}

let FieldNamesFor: FieldNames = FieldNames(numUsersPendingMatch: "numUsersForPendingMatch", users: "usersFor", numUsersTotal: "numUsersForTotal")
let FieldNamesAgainst: FieldNames = FieldNames(numUsersPendingMatch: "numUsersAgainstPendingMatch", users: "usersAgainst", numUsersTotal: "numUsersAgainstTotal")

struct Topic: Equatable {
    
    var numUsersForPendingMatch: Int
    var numUsersAgainstPendingMatch: Int
    var numUsersForTotal: Int
    var numUsersAgainstTotal: Int
    var timeCreated: NSObject
    var creator: String
    var topicTitle: String
    var userSide: UserSideStates
    var isMatched: Bool
    //var controversiality: Int
    
    init(numUsersForPendingMatch: Int, numUsersAgainstPendingMatch: Int, timeCreated: NSObject, creator: String, topicTitle: String, userSide: UserSideStates, isMatched: Bool, numUsersForTotal: Int, numUsersAgainstTotal: Int) {
        self.numUsersForTotal = numUsersForTotal
        self.numUsersAgainstTotal = numUsersAgainstTotal
        self.numUsersForPendingMatch = numUsersForPendingMatch
        self.numUsersAgainstPendingMatch = numUsersAgainstPendingMatch
        self.timeCreated = timeCreated
        self.creator = creator
        self.topicTitle = topicTitle
        self.userSide = userSide
        self.isMatched = isMatched
        //self.controversiality = controversiality
    }
    
}

class TopicFunctions{
    static func createTopic(topic: DocumentSnapshot) -> Topic{
        
        var usersFor: [String:String] = topic[FieldNamesFor.users] as! [String:String]
        var usersAgainst: [String:String] = topic[FieldNamesAgainst.users] as! [String:String]
        
        var isMatched: Bool = false
        var userSide: UserSideStates!
        
        if usersFor[User.details.uid] == "isMatched" ||  usersFor[User.details.uid] == "isNotMatched"{
            userSide = .isFor
            
            if usersFor[User.details.uid] == "isMatched"{
                isMatched = true
            }
        }
        else if usersAgainst[User.details.uid] != nil{
            userSide = .isAgainst
            
            if usersAgainst[User.details.uid] == "isMatched"{
                isMatched = true
            }
        }
        else {
            userSide = .isNeutral
        }
        
        
        
        let topicObj = Topic(
            numUsersForPendingMatch: topic[FieldNamesFor.numUsersPendingMatch] as! Int,
            numUsersAgainstPendingMatch: topic[FieldNamesAgainst.numUsersPendingMatch] as! Int,
            timeCreated: topic["timeCreated"] as! NSObject,
            creator: topic["userWhoCreated"] as! String,
            topicTitle: topic.documentID,
            userSide: userSide,
            isMatched: isMatched,
            numUsersForTotal: topic[FieldNamesFor.numUsersTotal] as! Int,
            numUsersAgainstTotal: topic[FieldNamesAgainst.numUsersTotal] as! Int)
        
        return topicObj
    }
    
    static func createTopicDataObjForDB(timeCreatedInSeconds: Int, createdBy: String, topicName: String, category: String, keywords: [String]) -> [String: Any] {
        
        let data: [String:Any] = [
            "timeCreated": timeCreatedInSeconds,
            FieldNamesAgainst.numUsersPendingMatch: 0,
            FieldNamesFor.numUsersPendingMatch: 0,
            FieldNamesFor.numUsersTotal: 0,
            FieldNamesAgainst.numUsersTotal: 0,
            "userWhoCreated": createdBy,
            "searchableName": topicName.formattedString(spaces: false),
            "keywords": keywords,
            "category": category,
            "controversiality": 0,
            "latestUser": ["uid": nil, "userSide": nil],
            FieldNamesAgainst.users: [:],
            FieldNamesFor.users: [:]
        ]
        
        return data
    }
    
    static func createUsersInfoString(uid: String, topic: String, isPublic: Bool) -> String{
        return "\(uid + topic + isPublic.description)"
    }
    
    static func getFieldNames(forSide: UserSideStates) -> FieldNames?{
        
        switch forSide{
        case .isFor:
            return FieldNamesFor
        case .isAgainst:
            return FieldNamesAgainst
        case .isNeutral:
            print(".isNeutral was passed into getFieldNames function")
            return nil
        }
    }
    

    
    static func matchUser(forTopic: Topic, wasMatchSuccessful: @escaping(Bool) -> Void){

        let topicTitle = forTopic.topicTitle
        var opponent: String?
        var oppositeUsersSide: UserSideStates!
        var thisUsersSide: UserSideStates!
        
        thisUsersSide = forTopic.userSide
        
        //make sure the user for is 0 in the array
        switch thisUsersSide! {
        case .isFor:
            oppositeUsersSide = .isAgainst
        case .isAgainst:
            oppositeUsersSide = .isFor
        case .isNeutral:
            wasMatchSuccessful(false)
            return
        }
        
        Database.returnDocument(path: "topics/\(forTopic.topicTitle)", completion: { (document, err) in
            if let err = err{
                print(err)
                wasMatchSuccessful(false)
                return
            }
            
            if let document = document{
                
                let fieldNames = TopicFunctions.getFieldNames(forSide: oppositeUsersSide)!
                
                let potentialMatches: [String: String] = document[fieldNames.users] as! [String : String]
                
                if potentialMatches.isEmpty{
                    wasMatchSuccessful(false)
                    return
                }
                //SEE IF FIRESTORE RETURNS DICT IN ORDER (IE. THEY ARE BEING MATCHED WITH THE OLDEST USER) ITS FINE, BUT IF NOT WE NEED TO CHANGE THAT
                for (user, status) in potentialMatches {
                    //if latter fails, assume they just switched from sides too quickly for db to atomically update
                    if status == "isNotMatched" && user != User.details.uid{
                        opponent = user
                        print("opponent which is free has been found")
                        
                        //now create argument document
                        guard let opp = opponent else {
                            wasMatchSuccessful(false)
                            return
                            
                        }
                        print("opponent: ", opp)
                        var uids: [String:String] = [:]
                        var uidsForQuerying: [String:Bool] = [:]
                     //   var areUsersPublic: [String] = []
                        var userDetails: [String:Any] = [:]
                        
                        userDetails["username"] = User.details.username
                        userDetails["deviceToken"] = User.details.deviceToken
                        
                        if let url = User.details.profileImageUrl{
                            userDetails["profileImageUrl"] = url
                        }
                        
                        switch thisUsersSide! {
                        case .isFor:
                            uids["for"] = User.details.uid
                            uids["against"] = opp
                        case .isAgainst:
                            uids["against"] = User.details.uid
                            uids["for"] = opp
                        case .isNeutral:
                            print("this user is neutral: ", forTopic.userSide)
                                            wasMatchSuccessful(false)
                            return

                        }
                        

                        uidsForQuerying[User.details.uid] = false
                        uidsForQuerying[opp] = false
                        
                        User.getUserDetails(uid: opp, completion: { (oppDeets) in
                            
                            let argData: [String:Any] = [
                                "uids": uids,
                                "uidsForQuerying": uidsForQuerying,
                                "topicTitle" : topicTitle,
                                User.details.uid : userDetails,
                                opp: oppDeets,
                                "goingPublicAt" : Date.inXHoursInSeconds(inHours: 3),
                                "matcher": User.details.uid
                            ]
                            // Get new write batch
                            let batch = Database.db.batch()
   
                            let argRef = Database.db.collection("arguments").document()
                            batch.setData(argData, forDocument: argRef)
                            
                            let fieldNamesForThisUser = TopicFunctions.getFieldNames(forSide: thisUsersSide)!
                            let fieldNamesForOpp = TopicFunctions.getFieldNames(forSide: oppositeUsersSide)!
                            
                            var userData: [String:Any] = [:]
                            
                            userData[fieldNamesForThisUser.users + "." + User.details.uid] = "isMatched"
                            userData[fieldNamesForThisUser.numUsersPendingMatch] = FieldValue.increment(Int64(-1))
                            userData[fieldNamesForOpp.users + "." + opp] = "isMatched"
                            userData[fieldNamesForOpp.numUsersPendingMatch] = FieldValue.increment(Int64(-1))
                            
                            let topicRef = Database.db.collection("topics").document(topicTitle)
                            batch.updateData(userData, forDocument: topicRef)
                            
                            // Commit the batch
                            batch.commit() { err in
                                if let err = err {
                                    print("Error writing batch \(err)")
                                    wasMatchSuccessful(false)
                                    return
                                } else {
                                    Alert.alert(message: "in \(topicTitle) - check your arguments", title: "Matched!")
                                    //send notif to opponen
                                    let notifHelper = PushNotificationSender()
                                    notifHelper.sendPushNotification(to: oppDeets["deviceToken"]!, title: "You've been matched!", body: "In the topic: \(topicTitle)")
                                    wasMatchSuccessful(true)
                                    return
                                }
                            }
                        })
                        break
                    }
                }
            }
        })
        //if any of the above failed (no users to match with, etc.)
        wasMatchSuccessful(false)
        return
    }  
}

struct BriefTopic {
    
    var timeCreated: NSObject
    var topicTitle: String
    var userSide: String
    
    init(timeCreated: NSObject, topicTitle: String, userSide: String) {
        self.timeCreated = timeCreated
        self.topicTitle = topicTitle
        self.userSide = userSide
    }
}

class BriefTopicFunctions{
    static func createBriefTopic(topic: DocumentSnapshot) -> BriefTopic{
        
        let topicObj = BriefTopic(timeCreated: topic["timeAdded"] as! NSObject,
                                  topicTitle: topic.documentID,
                                  userSide: topic["userSide"] as! String)
        
        return topicObj
    }
}


