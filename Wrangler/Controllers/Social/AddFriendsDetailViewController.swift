//
//  RequestsDetailViewController.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 18/07/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class RequestsDetailViewController: UIViewController, NVActivityIndicatorViewable {
    
    var userObj: Opponent!
    var argumentObj: Argument!
    var friendRequest: Bool = false
    var argumentRequest: Bool = false
    var uids: [String:Int] = [:]
    //if from argumentRequests
    var argumentRequestDocument: DocumentSnapshot!
    
    @IBOutlet weak var friendUsername: UILabel!
    @IBOutlet weak var friendBio: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var topicTitle: UILabel!
    
    @IBAction func backTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func checkIfAlreadyRequested(completion: @escaping() -> Void){
        startAnimating(message: "", type: NVActivityIndicatorType(rawValue: 32))
        Database.returnDocument(path: "users/\(User.user.uid)/friends/\(userObj.uid)") { (document, err) in
            if let err = err {
                self.stopAnimating()
                guard let nav = self.navigationController, let top = nav.topViewController else {
                    return
                }
                
                nav.popViewController(animated: true)
                Alert.errorAlert(error: err, in: top)
                
                return
            }
            
            if let document = document{
                self.actionButton.isEnabled = false
                if document["isRequesting"] as! Bool == false{
                    self.actionButton.setTitle("This user is already a friend", for: .normal)
                }
                else{
                    self.actionButton.setTitle("This user has already requested you", for: .normal)
                }
                completion()
            }
            else{
                print("no doc found in users own requests subcoll")
                Database.returnDocument(path: "users/\(self.userObj.uid)/friends/\(User.user.uid)", completion: { (document, err) in
                    
                    if let err = err {
                        self.stopAnimating()
                        guard let nav = self.navigationController, let top = nav.topViewController else {
                            return
                        }
                        
                        nav.popViewController(animated: true)
                        Alert.errorAlert(error: err, in: top)
                        
                        return
                    }
                    
                    if let document = document{
                        print("doc was found in other users subcoll - this user has already sent a request")
                        self.actionButton.isEnabled = false
                        if document["isRequesting"] as! Bool == false{
                            self.actionButton.setTitle("This user is already a friend", for: .normal)
                        }
                        else{
                            self.actionButton.setTitle("You have already requested this user", for: .normal)
                        }
                        completion()
                    }
                        
                    else if err == nil {
                        completion()
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setGradientColours()
        
        if argumentRequest{
            
            //set data now so we can change uids depending on who is for/againts
            friendBio.text = argumentObj.bio
            friendUsername.text = argumentObj.username
            
            //userSide is the side the inviting user is on
            let userSide = argumentRequestDocument.data()!["userSide"] as! String
            if userSide == "For"{
                //this user is side against if they accept
                uids[User.user.uid] = 2
                uids[argumentObj.uid] = 1
                actionButton.setTitle("accept argument request - your friend is inviting you to argue against the topic", for: .normal)
                
            }
            else{
                uids[User.user.uid] = 1
                uids[argumentObj.uid] = 2
                actionButton.setTitle("accept argument request your friend is inviting you to argue for the topic", for: .normal)
            }
            declineButton.setTitle("decline this argument request ur friend willb alerted (mb?)(dontreallyneedtotbhatthenedifneeded)", for: .normal)
            topicTitle.text = argumentObj.topicTitle
        }
        else if friendRequest{
            
            friendBio.text = userObj.bio
            friendUsername.text = userObj.username
            actionButton.setTitle("accept your friend request", for: .normal)
            declineButton.setTitle("decline this friend request ur friend willb alerted (mb?)(dontreallyneedtotbhatthenedifneeded)", for: .normal)
        }
        else{
            declineButton.setTitle("", for: .normal)
            friendBio.text = userObj.bio
            friendUsername.text = userObj.username
            checkIfAlreadyRequested {
                self.stopAnimating()
            }
        }
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        startAnimating(message: "", type: NVActivityIndicatorType(rawValue: 32))
        //if they click 'accept argument request'
        if argumentRequest{
            //change accepted to true and create a chat document with a field "friendly" as true
            let inviteId = argumentRequestDocument.documentID
            
            var userInfo: [String:String] = [:]
            userInfo["profileImageUrl"] = User.user.profileImageUrl
            userInfo["username"] = User.user.username
            userInfo["bio"] = User.user.bio
            
            
            //MAKE THIS A FUNC LKE "GETUSERSINFO" WHICH COMPLETES BACK 2 OBJECTS
            var opponentInfo: [String:String] = [:]
            Database.returnDocument(path: "users/\(argumentObj.uid)", completion: { (document, err) in
                
                if let err = err {
                    Alert.errorAlert(error: err , in: self)
                    
                    self.stopAnimating()
                    return
                }
                
                if let document = document{
                    opponentInfo["profileImageUrl"] = document["profileImageUrl"] as? String
                    opponentInfo["username"] = document["username"] as? String
                    opponentInfo["bio"] = document["bio"] as? String
                    
                    
                    let data: [String:Any] = [
                        //user ids for or against, 1 or 2 - set earlier in viewDidLead
                        User.user.uid: userInfo,
                        self.argumentObj.uid: opponentInfo,
                        "uids": self.uids,
                        "whoCreated": User.user.uid,
                        "uid2": self.argumentObj.uid,
                        "topicTitle" : self.argumentObj.topicTitle,
                        "timeCreated" : FieldValue.serverTimestamp(),
                        "friendly": true
                    ]
                    
                    Database.addDocumentErrorHandling(path: "arguments", data: data) { (err) in
                        if let err = err {
                            Alert.errorAlert(error: err , in: self)
                            
                            self.stopAnimating()
                            return
                        }
                        else{
                            Database.deleteDocument(path: "users/\(User.user.uid)/argumentInvites/\(self.argumentRequestDocument.documentID)") { (err) in
                                if let err = err{
                                    Alert.errorAlert(error: err, in: self)
                                    self.stopAnimating()
                                    return
                                }
                                else{
                                    self.performSegue(withIdentifier: "unwindFromArgumentRequest", sender: self)
                                    self.stopAnimating()
                                }
                            }
                        }
                    }
                }
            })
        }
            //if they click "accept friend request"
        else if friendRequest{

            var data: [String: Any] = ["isRequesting" : false,
                                       "username": userObj.username,
                                       "bio": userObj.bio,
                                       "uid": userObj.uid,
                                       "profileImageUrl": userObj.profileImageUrl,
                                       "usernameSearchable": userObj.username.createComparableString(noSpaces: true).components(separatedBy: CharacterSet.decimalDigits).joined()]
            
            Database.writeToDocumentErrorHandling(path: "users/\(User.user.uid)/friends/\(userObj.uid)", data: data, merge: false) { (err) in
                if let err = err {
                    Alert.errorAlert(error: err , in: self)
                    self.stopAnimating()
                    
                }
                else{
                    
                    print("second write")
                    data = ["isRequesting" : false,
                            "username": User.user.username,
                            "bio": User.user.bio,
                            "uid": User.user.uid,
                            "profileImageUrl": User.user.profileImageUrl,
                            "usernameSearchable": User.user.username.createComparableString(noSpaces: true).components(separatedBy: CharacterSet.decimalDigits).joined()]
                    //update accepted users friends subcoll
                    Database.writeToDocumentErrorHandling(path: "users/\(self.userObj.uid)/friends/\(User.user.uid)", data: data, merge: false){ (err) in
                        if let err = err {
                            Alert.errorAlert(error: err , in: self)
                            self.stopAnimating()
                        }
                        else{
                            self.performSegue(withIdentifier: "unwindFromFriendRequest", sender: self)
                            self.stopAnimating()
                        }
                    }
                }
            }
        }
            //they are clicking "send a friend request"
        else{
            let data: [String: Any] = ["isRequesting" : true,
                                       "username": User.user.username,
                                       "bio": User.user.bio,
                                       "uid": User.user.uid,
                                       "profileImageUrl": User.user.profileImageUrl]
            Database.writeToDocumentErrorHandling(path: "users/\(userObj.uid)/friends/\(User.user.uid)", data: data, merge: false) { (err) in
                if let err = err {
                    Alert.errorAlert(error: err , in: self)
                    self.stopAnimating()
                }
                else{
                    
                    Alert.alert(userTitle: "Friend request has been sent", userMessage: "You will be notified if they accept your request", userOptions: "Alright", in: self)
                    self.stopAnimating()
                }
            }
        }
    }
    
    
    @IBAction func declineButton(_ sender: Any) {
        if argumentRequest{
            Database.deleteDocument(path: "users/\(User.user.uid)/argumentInvites/\(argumentRequestDocument.documentID)") { (err) in
                if let err = err{
                    Alert.errorAlert(error: err, in: self)
                }
                else{
                    self.performSegue(withIdentifier: "unwindFromFriendDetailViewDecline", sender: self)
                }
            }
        }
        if friendRequest{
            Database.deleteDocument(path: "users/\(User.user.uid)/friends/\(userObj.uid)") { (err) in
                if let err = err{
                    Alert.errorAlert(error: err, in: self)
                }
                else{
                    self.performSegue(withIdentifier: "unwindFromFriendDetailViewDecline", sender: self)
                }
            }
        }
    }
}
