//
//  User.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 12/07/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit

class User{
    
    static func getUserDetails(uid: String, completion: @escaping([String:String]) -> Void){
        var userDeets: [String:String] = [:]
        
        Database.returnDocument(path: "users/\(uid)", completion: { (document, err) in
            if let err = err{
                
                return
            }
            if let document = document{
                userDeets["username"] = document["username"] as! String
                userDeets["deviceToken"] = document["deviceToken"] as! String
                if document["profileImageUrl"] != nil{
                    userDeets["profileImageUrl"] = document["profileImageUrl"] as? String
                }
                completion(userDeets)
                return
            }
        })
    }
    
    static var details = User.init(username: " ", uid: " ", email: " ", profileImageUrl: nil, isFromLogin: true, wrangles: 0, wins: 0, topics: 0, firstTime: false, deviceToken: " ")
    
    var username: String
    var uid: String
    var profileImageUrl: String?
    var email: String
    var isFromLogin: Bool
    var wrangles: Int
    var wins: Int
    var topics: Int
    var firstTime: Bool
    var deviceToken: String
    
    private init(username: String, uid: String, email: String, profileImageUrl: String?, isFromLogin: Bool, wrangles: Int, wins: Int, topics: Int, firstTime: Bool, deviceToken: String) {
        self.username = username
        self.uid = uid
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.isFromLogin = isFromLogin
        self.wrangles = wrangles
        self.wins = wins
        self.topics = topics
        self.firstTime = firstTime
        //no need for this
        self.deviceToken = deviceToken
    }
    
}
