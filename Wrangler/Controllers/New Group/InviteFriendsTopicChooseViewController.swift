//
//  InviteFriendsTopicChooseViewController.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 26/07/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class InviteFriendsTopicChooseViewController: UIViewController, NVActivityIndicatorViewable {
    
    
    @IBAction func backTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatorDisp.text = topic.creator
        validityChecks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear running")
        
        
    }
    
    var invitingThisUser: Opponent!
    var topic: Topic!
    var inviteDocumentId: String!
    
    @IBOutlet weak var topicTitleDisp: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var userSideDisp: UILabel!
    @IBOutlet weak var againstBtn: UIButton!
    @IBOutlet weak var forBtn: UIButton!
    @IBOutlet weak var creatorDisp: UILabel!
    @IBOutlet weak var cancelInvite: UIButton!
    
    func validityChecks(){
        //check if their friend already has an invitation/is in a chat with them
        //then check if this user has an invite/is in a chat with them for the same topic
        Queues.fastQueueC.async{
            Database.returnDocumentsQuery(query: Database.db.collection("users/\(self.invitingThisUser.uid)/argumentInvites").whereField("topicTitle", isEqualTo: self.topic.topicTitle).whereField("uid", isEqualTo: User.user.uid)) { (documents, err) in
                if let err = err {
                    print(err)
                    self.navigationController?.popViewController(animated: true)
                }
                if let documents = documents{
                    //there should only ever be 1 document inside the documents snapshot - the user being invited can only ever have 1 chat with a specific user/topics match
                    for document in documents{
                        self.inviteDocumentId = document.documentID
                        
                        DispatchQueue.main.async{
                            self.userSideDisp.text = document["userSide"] as? String
                            self.forBtn.isEnabled = false
                            self.againstBtn.isEnabled = false
                        }
                        
                        if document["accepted"] as! Bool == true{
                            DispatchQueue.main.async{
                                self.infoLabel.text = "You already have a chat with this user on this topic"
                                self.cancelInvite.isEnabled = false
                            }
                        }
                        else{
                            DispatchQueue.main.async{
                                self.infoLabel.text = "You have already sent an invite on this topic to this user"
                                self.cancelInvite.isEnabled = true
                            }
                        }
                    }
                }
                else{
                    Database.returnDocumentsQuery(query: Database.db.collection("users/\(User.user.uid)/argumentInvites").whereField("topicTitle", isEqualTo: self.topic.topicTitle).whereField("uid", isEqualTo: self.invitingThisUser.uid), completion: { (documents, err) in
                        if let documents = documents{
                            for document in documents{
                                self.inviteDocumentId = document.documentID
                                
                                DispatchQueue.main.async{
                                    
                                    self.forBtn.isEnabled = false
                                    self.againstBtn.isEnabled = false
                                    self.cancelInvite.isEnabled = false
                                }
                                
                                if document["accepted"] as! Bool == true{
                                    DispatchQueue.main.async{
                                        self.infoLabel.text = "You already have a chat with this user on this topic"
                                    }
                                    //the userside field is the side the user who sent the invite is on
                                    if document["userSide"] as! String == "For"{
                                        DispatchQueue.main.async{
                                            self.userSideDisp.text = "Against"
                                        }
                                    }
                                    else{
                                        DispatchQueue.main.async{
                                            self.userSideDisp.text = "For"
                                        }
                                    }
                                }
                                else{
                                    DispatchQueue.main.async {
                                        self.infoLabel.text = "You have already been sent an invite by this user on this topic - you can find this request in argument requests on your home profile"
                                        //cant cancel invite cus it wasnt sent by them
                                        self.cancelInvite.isEnabled = false
                                    }
                                }
                            }
                        }
                        else{
                            //they have no invite sent either way/a private chat with the user
                            print("no invite has already been sent from either side")
                            DispatchQueue.main.async {
                                self.forBtn.isEnabled = true
                                self.againstBtn.isEnabled = true
                                self.cancelInvite.isEnabled = false
                                
                                self.infoLabel.text = ""
                            }
                            
                        }
                    })
                }
            }
        }
    }
    
    
    
    
    @IBAction func forTapped(_ sender: Any) {
        validityChecks()
        
        var userInfo: [String:String] = [:]
        userInfo["profileImageUrl"] = User.user.profileImageUrl
        userInfo["username"] = User.user.username
        
        let data: [String:Any] = [
            "userSide": "For",
            "uid": User.user.uid,
            User.user.uid: userInfo,
            "accepted": false,
            "topicTitle": self.topic.topicTitle
        ]
        
        //to get document id if cancel invite is tapped
        
        Database.addDocumentErrorHandling(path: "users/\(invitingThisUser.uid)/argumentInvites", data: data){ (err, documentID) in
            if let err = err{
                Alert.errorAlert(error: err)
                return
            }
            if let id = documentID{
                self.inviteDocumentId = id
            }
        }
    }
    
    @IBAction func againstTapped(_ sender: Any) {
        validityChecks()
        
        var userInfo: [String:String] = [:]
        userInfo["profileImageUrl"] = User.user.profileImageUrl
        userInfo["username"] = User.user.username
        
        let data: [String:Any] = [
            "userSide": "Against",
            "uid": User.user.uid,
            User.user.uid: userInfo,
            "accepted": false,
            "topicTitle": self.topic.topicTitle
        ]
        
        Database.addDocumentErrorHandling(path: "users/\(invitingThisUser.uid)/argumentInvites", data: data){ (err, documentID) in
            if let err = err{
                Alert.errorAlert(error: err)
            }
            if let id = documentID{
                self.inviteDocumentId = id
            }
        }
    }
    
    @IBAction func cancelInvite(_ sender: Any) {
        print("cancel invite tapped", inviteDocumentId)
        
        Database.deleteDocument(path: "users/\(invitingThisUser.uid)/argumentInvites/\(inviteDocumentId!)") { (err) in
            if let err = err {
                Alert.errorAlert(error: err)
            }
            else{
                print("running validity checks")
                self.validityChecks()
            }
        }
    }
}

