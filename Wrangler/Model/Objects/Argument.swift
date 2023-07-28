//
//  Argument.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 29/07/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import Foundation
import Firebase

struct Argument{
    
    var opponentUsername: String
    var opponentUid: String
    var opponentProfileImageUrl: String?
    var opponentUserSide: UserSideStates
    var topicTitle: String
    var argumentId: String
    var goingPublicAt:  Int
    var isPublic: Bool
    var userSide: UserSideStates
    var matcher: String
    var opponentDeviceToken: String
    var archived: Bool
    
    
    init(opponentUsername: String, opponentUid: String, opponentProfileImageUrl: String?, topicTitle: String, argumentId: String, goingPublicAt: Int, isPublic: Bool, userSide: UserSideStates, opponentUserSide: UserSideStates, matcher: String, opponentDeviceToken: String, archived: Bool) {
        self.opponentUsername = opponentUsername
        self.opponentUid = opponentUid
        self.opponentProfileImageUrl = opponentProfileImageUrl
        self.topicTitle = topicTitle
        self.argumentId = argumentId
        self.goingPublicAt = goingPublicAt
        self.isPublic = isPublic
        self.userSide = userSide
        self.opponentUserSide = opponentUserSide
        self.matcher = matcher
        self.opponentDeviceToken = opponentDeviceToken
        self.archived = archived
    }
}

class ArgumentFunctions{
    
    static func calculateCellSize(collectionViewHeight: CGFloat) -> CGFloat {
        
        var heightOfRecentMatchCells = (collectionViewHeight * CellConstants.cellToViewProportionHeight)
        
        //make big enough to fit all labels and small enough to still look good
        heightOfRecentMatchCells = heightOfRecentMatchCells.clamped(to: 70...135)
        
        return heightOfRecentMatchCells
    }
    
    static func createArgument(argument: DocumentSnapshot) -> Argument{

        let uids = argument["uids"] as! [String:String]
        let userSideString: String = uids.someKey(forValue: User.details.uid)!
        var topicTitle = argument["topicTitle"] as! String
        
        var opponentUid: String!
        var opponentUserSide: UserSideStates!
        for (userSideString, uid) in uids{
            if uid != User.details.uid{
                opponentUid = uid
                opponentUserSide = UserSideStates(rawValue: userSideString) ?? .isNeutral
            }
        }
        
        var isPublic: Bool = false
        if let isPublicU = argument["isPublic"] {
            isPublic = isPublicU as! Bool
        }
        


        var opponentImageUrl: String?

        let uidsForQuerying = argument["uidsForQuerying"] as! [String: Bool]
        let archived = uidsForQuerying.values.first!
        
            
            var opponentDetails = argument[opponentUid] as! [String:String]
            
            if opponentDetails["profileImageUrl"] != nil {
                opponentImageUrl = opponentDetails["profileImageUrl"] as! String
            }
                        
            let argumentObj = Argument(
                opponentUsername: opponentDetails["username"]!,
                opponentUid: opponentUid,
                opponentProfileImageUrl: opponentImageUrl,
                topicTitle: topicTitle,
                argumentId: argument.documentID,
                goingPublicAt: argument["goingPublicAt"] as! Int,
                isPublic: isPublic,
                userSide: UserSideStates(rawValue: userSideString) ?? .isNeutral,
                opponentUserSide: opponentUserSide,
                matcher: argument["matcher"] as! String,
                opponentDeviceToken: opponentDetails["deviceToken"] ?? " ",
                archived: archived
            )
            
            return argumentObj
            
        

        
    }
}
