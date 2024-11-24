//
//  SignUpViewController.swift
//  Test
//
//  Created by LucaSarif on 24/12/2017.
//  Copyright © 2017 LucaSarif. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
//import NVActivityIndicatorView

class SignUpViewController: UIViewController, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    // @IBOutlet weak var passwordRepeatTextField: CustomTextField!
    @IBOutlet weak var continueBtn: BlueCustomBtn!
    
    //    let dbUsers = Firestore.firestore().collection("users")
    let progressHUD = ProgressHUD(text: "Signing Up")
    
    var snapshotVar: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        
        /* // FOR DEV PURPOSES - REMEMBER TO DELETE
         emailTextField.text = "test@gmail.com"
         usernameTextField.text = "test"
         passwordTextField.text = "xxxxxx"*/
        
        progressHUD.hide()
        self.view.addSubview(progressHUD)
        titleLabel.font = UIFont.systemFont(ofSize: DesignConstants.largeFontSize, weight: .semibold)
        titleLabel.textColor = UIColor.white
    }
    
    
    func authenticate(email: String!, password: String!, username: String!){
        // Create user - creates a user object and generates an error in the case of one
        Auth.auth().createUser(withEmail: email, password: password) { user, err in
            
            if err == nil && user != nil {
                
                //set username as display name
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { error in
                    
                    if let error = error {
                        self.progressHUD.hide()
                        Alert.errorAlert(error: error.localizedDescription)
                        //delete created user
                        if let user = Auth.auth().currentUser{
                            user.delete()
                        }
                        return
                    }
                    else{
                        self.progressHUD.hide()
                        
                        if let user = user{
                            User.details.uid = user.user.uid
                            User.details.email = user.user.email!
                            User.details.username = user.user.displayName!
                        }
                        
                        User.details.firstTime = true
                        
                        let data: [String: Any] = [
                            "username": User.details.username,
                            "usernameSearchable": User.details.username.formattedString(spaces: false),
                            "email": User.details.email,
                            "wrangles": 0,
                            "wins": 0,
                            "arguments": 0
                        ]
                        
                        Database.writeToDocumentErrorHandling(path: "users/\(User.details.uid)", data: data, merge: false) { err in
                            if let err = err {
                                Alert.errorAlert(error: err)
                                self.navigationController?.popViewController(animated: true)
                            }
                            else{
                                self.performSegue(withIdentifier: "toHomeScreenFromSignup", sender: self)
                            }
                        }
                        
                        
                    }
                }
                
            }
            if let err = err as NSError?{
                let errCode = AuthErrorCode(rawValue: err.code)!
                
                    switch errCode{
                    case AuthErrorCode.emailAlreadyInUse:
                        self.progressHUD.hide()
                        Alert.errorAlert(error: "This email is already in use!")
                        
                    case AuthErrorCode.tooManyRequests:
                        self.progressHUD.hide()
                        Alert.errorAlert(error: "We're getting too much traffic at the moment")
                        
                    default:
                        self.progressHUD.hide()
                        Alert.errorAlert(error: err.localizedDescription)
                    
                }
            }
        }
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        view.endEditing(true)
        progressHUD.show()
        
        // Check all fields are filled
        guard let email = emailTextField.text else {
            progressHUD.hide()
            emailTextField.shake()
            return
        }
        guard let username = usernameTextField.text else {
            progressHUD.hide()
            usernameTextField.shake()
            return
        }
        guard let password = passwordTextField.text else {
            progressHUD.hide()
            passwordTextField.shake()
            return
        }
        
        func fieldChecks(completionHandler: @escaping() -> Void){
            
            /*
             // Check passwords match up
             if (passwordRepeat != password) {
             progressHUD.hide()
             passwordRepeatTextField.shake()
             Alert.errorAlert(error: "Password fields don't match")
             return
             }*/
            
            if (username.count > 15) {
                progressHUD.hide()
                usernameTextField.shake()
                Alert.errorAlert(error: "Username is too long")
                return
            }
            //
            //            self.dbUsers.whereField("username", isEqualTo: username).getDocuments { (snapshot, err) in
            //                if snapshot != nil{
            //                    //dunt think this wurks mb itdoes try it out tho
            //                    self.progressHUD.hide()
            //                    self.usernameTextField.shake()
            //                    Alert.errorAlert(error: "Username is already in use")
            //                }
            //                completionHandler()
            //            }
            
            completionHandler()
            return
        }
        
        //check fields and then create user
        fieldChecks {
            User.details.email = email
            User.details.username = username
            self.authenticate(email: email, password: password, username: username)
        }
    }// Sign up button
    
    var shouldShowPassword = true
    func handleShowPassword(){
        if shouldShowPassword {
            passwordTextField.isSecureTextEntry = false
            shouldShowPassword = false
        }
        else{
            passwordTextField.isSecureTextEntry = true
            shouldShowPassword = true
        }
    }
}


