//
//  PublicArgument.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 29/09/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//
import Foundation
import Firebase

struct PublicArgument{
    
    var userForInfo: [String:String]
    var userAgainstInfo: [String:String]
    var topicTitle: String
    var argumentId: String
    var wentPublicAt: Int
    var upvotesFor: Int
    var upvotesAgainst: Int
    var endingAt: Int
    var thisUserSide: UserSideStates
    var archived: Bool
    var winner: String?
    
    init(userForInfo: [String:String], userAgainstInfo: [String:String] = [:], topicTitle: String, argumentId: String, wentPublicAt: Int, upvotesFor: Int, upvotesAgainst: Int, endingAt: Int, thisUserSide: UserSideStates, archived: Bool, winner: String?) {
        self.userForInfo = userForInfo
        self.userAgainstInfo = userAgainstInfo
        self.topicTitle = topicTitle
        self.argumentId = argumentId
        self.wentPublicAt = wentPublicAt
        self.upvotesFor = upvotesFor
        self.upvotesAgainst = upvotesAgainst
        self.endingAt = endingAt
        self.thisUserSide = thisUserSide
        self.archived = archived
        self.winner = winner
    }
}

class PublicArgumentFunctions{
    
    static func createPublicArg(argument: DocumentSnapshot) -> PublicArgument{
        
        let topicTitle = argument["topicTitle"] as! String
        
        let upvotesFor: Int = argument["upvotesFor"] as! Int
        let upvotesAgainst: Int = argument["upvotesAgainst"] as! Int
        let uids: [String:String] = argument["uids"] as! [String:String]
        let wentPublicAt: Int = argument["goingPublicAt"] as! Int
        let endingAt: Int = argument["endingAt"] as! Int
        let usersFor: [String] = argument["for"] as! [String]
        let usersAgainst: [String] = argument["against"] as! [String]
        let uidsForQuerying: [String: Bool] = argument["uidsForQuerying"] as! [String: Bool]
        
        var thisUserSide: UserSideStates!
        if usersFor.contains(User.details.uid){
            thisUserSide = UserSideStates.isFor
        }
        else if usersAgainst.contains(User.details.uid){
            thisUserSide = UserSideStates.isAgainst
        }
        else{
            thisUserSide = UserSideStates.isNeutral
        }
        
        var userForInfo: [String:String] = argument[uids["for"]] as! [String:String]
        var userAgainstInfo: [String:String] = argument[uids["against"]] as! [String:String]
        
        userForInfo["uid"] = uids["for"]
        userAgainstInfo["uid"] = uids["against"]
        let tempArgumentObj = PublicArgument(userForInfo: userForInfo, userAgainstInfo: userAgainstInfo, topicTitle: topicTitle, argumentId: argument.documentID, wentPublicAt: wentPublicAt, upvotesFor: upvotesFor, upvotesAgainst: upvotesAgainst, endingAt: endingAt, thisUserSide: thisUserSide, archived: uidsForQuerying.values.first!, winner: argument["winner"] as? String)
        
        return tempArgumentObj
    }
    
    static func fetchPublicArguments(query: Query, completion: @escaping(_ arguments: [PublicArgument]?, _ lastDocument: DocumentSnapshot?, _ error: String?) -> Void){

        var arguments: [PublicArgument] = []
        var lastDocument: DocumentSnapshot!

        Database.returnDocumentsQuery(query: query){ (documents, err) in
            
            if let err = err {
                completion(nil,nil,err)
                print(err)
                return
            }
            
            if let documents = documents, !documents.isEmpty {
                lastDocument = documents.last
                
                for argument in documents{
                    
                   let tempArg = createPublicArg(argument: argument)
                    arguments.append(tempArg)
                    if argument == documents.last{
                        completion(arguments, lastDocument, nil)
                        return
                    }
                }
            }
            else{
                completion(nil,nil,nil)
                return
            }
        }
    }
}


class VoteModel: VoteCVCDelegate{
    func incrementVoteNumbers(forArgument: PublicArgument, forSide: UserSideStates, wasSuccessful: @escaping (Bool) -> Void) {
        var data: [String: Any] = [:]
        
        switch forSide{
        case .isAgainst:
            data["upvotesAgainst"] = FieldValue.increment(Int64(1))
        case .isFor:
            data["upvotesFor"] = FieldValue.increment(Int64(1))
        case .isNeutral:
            return
        }
        
        data["totalUpvotes"] = FieldValue.increment(Int64(1))
    
        Database.updateDocumentErrorHandling(path: "arguments/\(forArgument.argumentId)", data: data) { (err) in
            if let err = err {
                print(err)
            }
            else{
                wasSuccessful(true)
                return
            }
        }
    }
}

