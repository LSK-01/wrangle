//
//  Opponent.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 17/07/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import Foundation
import Firebase

struct Opponent{
    
    var username: String
    var uid: String
    var profileImageUrl: String?
    
    init(username: String, uid: String, profileImageUrl: String?) {
        self.username = username
        self.uid = uid
        self.profileImageUrl = profileImageUrl
    }
    
    
}

class OpponentFunctions{
    
    static func fetchOpponents(query: Query, completion: @escaping(_ opponents: [Opponent]?, _ lastDocument: DocumentSnapshot?, _ error: String?) -> Void){
        var userCells: [Opponent] = []
        var lastDocument: DocumentSnapshot!
        
        Database.returnDocumentsQuery(query: query) { (documents, err) in
            
            if let err = err {
                completion(nil, nil, err)
                return
            }
            
            if let documents = documents{
                lastDocument = documents.last
                for user in documents{
                    
                    var imageUrl: String?
                    var usernameFromDoc: String!
                    
                    Database.returnDocument(path: "users/\(user.documentID)", completion: { (document, err) in
                        if let err = err{
                            //should alert user cus there should always be a user doc so its gotta be a client side err
                            
                            print(err)
                            completion(nil, nil, err)
                            return
                        }
                        
                        if let document = document{
                            if document["profileImageUrl"] != nil{
                                imageUrl = document["profileImageUrl"] as? String
                            }

                            usernameFromDoc = document["username"] as? String
                            
                            
                            let tempOpponentObj = Opponent(
                                username: usernameFromDoc,
                                uid: user.documentID,
                                profileImageUrl: imageUrl)
                            
                            userCells.append(tempOpponentObj)
                            
                            if user == documents.last{
                                print("completing: ", userCells.count, documents.count)
                                completion(userCells, lastDocument, nil)
                                return
                            }
                        }
                    })
                }
            }
            else{
                //no documents left to return
                completion(nil, nil, nil)
                return
            }
        }
    }
}
