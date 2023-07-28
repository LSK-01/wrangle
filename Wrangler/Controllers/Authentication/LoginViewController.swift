//
//  LoginViewController.swiftCustomTextField
//  Test
//
//  Created by LucaSarif on 23/12/2017.
//  Copyright © 2017 LucaSarif. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
//import NVActivityIndicatorView
import SwiftMessages

class LoginViewController: UIViewController{
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    
    @IBAction func googleButton(_ sender: Any) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                // ...
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { authRes, error in
                if let error = error {
                    print(error)
                    return
                    //                  let authError = error as NSError
                    //                  if isMFAEnabled, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    //                    // The user is a multi-factor user. Second factor challenge is required.
                    //                    let resolver = authError
                    //                      .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    //                    var displayNameString = ""
                    //                    for tmpFactorInfo in resolver.hints {
                    //                      displayNameString += tmpFactorInfo.displayName ?? ""
                    //                      displayNameString += " "
                    //                    }
                    //                    self.showTextInputPrompt(
                    //                      withMessage: "Select factor to sign in\n\(displayNameString)",
                    //                      completionBlock: { userPressedOK, displayName in
                    //                        var selectedHint: PhoneMultiFactorInfo?
                    //                        for tmpFactorInfo in resolver.hints {
                    //                          if displayName == tmpFactorInfo.displayName {
                    //                            selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                    //                          }
                    //                        }
                    //                        PhoneAuthProvider.provider()
                    //                          .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                    //                                             multiFactorSession: resolver
                    //                                               .session) { verificationID, error in
                    //                            if error != nil {
                    //                              print(
                    //                                "Multi factor start sign in failed. Error: \(error.debugDescription)"
                    //                              )
                    //                            } else {
                    //                              self.showTextInputPrompt(
                    //                                withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                    //                                completionBlock: { userPressedOK, verificationCode in
                    //                                  let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                    //                                    .credential(withVerificationID: verificationID!,
                    //                                                verificationCode: verificationCode!)
                    //                                  let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                    //                                    .assertion(with: credential!)
                    //                                  resolver.resolveSignIn(with: assertion!) { authResult, error in
                    //                                    if error != nil {
                    //                                      print(
                    //                                        "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                    //                                      )
                    //                                    } else {
                    //                                      self.navigationController?.popViewController(animated: true)
                    //                                    }
                    //                                  }
                    //                                }
                    //                              )
                    //                            }
                    //                          }
                    //                      }
                    //                    )
                    //                  } else {
                    //                    self.showMessagePrompt(error.localizedDescription)
                    //                    return
                    //                  }
                    //                  // ...
                    //                  return
                }
                
                if let userAuth = Auth.auth().currentUser {
                    User.details.uid = userAuth.uid
                    User.details.email = userAuth.email!
                    User.details.username = userAuth.displayName!
                    User.details.firstTime = true
                    
                    performSegue(withIdentifier: SegueConstants.homescreenFromLoginSegue, sender: self)
                }
                
                
            }
        }
        
    }
    
    let notifHelper = PushNotificationSender()
    
    @IBAction func notif(_ sender: Any) {
        
        notifHelper.sendPushNotification(to: "cI5fQBKYBkVhjXXBfZL9UE:APA91bF8LMPDq4xu-_Bb-hRBTJ1TFchXypVpTBHj2n7OwGtcc53TMo38_S-hcuIiw-x-P_Zhk6TgalQigvSD3AUIQF4qZ65xARMhR2QxNu_3nJfmi9dh7PXu2XVYwiVFlNHmC8_VpRQn", title: "Notification title", body: "Notification body")
    }
    
    @IBOutlet weak var emailTextField: BlueTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var login: BlueCustomBtn!
    @IBOutlet weak var googleSignin: RedCustomBtn!
    @IBOutlet weak var getStarted: RedCustomBtn!
    let progressHUD = ProgressHUD(text: "Saving Photo")
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBOutlet weak var forgotPassword: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleSignin.imageView?.tintColor = UIColor.white
        googleSignin.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .highlighted)
        progressHUD.text = "Logging in"
        progressHUD.hide()
        self.view.addSubview(progressHUD)
        
        
        forgotPassword.backgroundColor = DesignConstants.mainPurple
        forgotPassword.layer.cornerRadius = forgotPassword.frame.height/2
        
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        if let userAuth = Auth.auth().currentUser {
            performSegue(withIdentifier: SegueConstants.homescreenFromLoginSegue, sender: self)
        }
        
        googleSignin.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 30)
        googleSignin.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 10)
        
        
    }
    
    @IBAction func loginButton(_ sender: Any) {
        view.endEditing(true)
        progressHUD.show()
        // Check if fields are filled in
        guard let email = emailTextField.text else {
            emailTextField.shake()
            return
        }
        
        guard let password = passwordTextField.text else {
            passwordTextField.shake()
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password){ user, err in
            self.progressHUD.hide()
            
            if let err = err as NSError?{
                let errCode = AuthErrorCode(_nsError: err)
                
                switch errCode {
                case AuthErrorCode.networkError:
                    Alert.errorAlert(error: "Please connect to internet!")
                    
                case AuthErrorCode.tooManyRequests:
                    Alert.errorAlert(error: "We're getting too much traffic at the moment!")
                    
                case AuthErrorCode.invalidEmail:
                    Alert.errorAlert(error: "This email is invalid")
                    
                case AuthErrorCode.userNotFound:
                    Alert.errorAlert(error: "This user doesn't have an account yet - Please sign up")
                case AuthErrorCode.wrongPassword:
                    Alert.errorAlert(error: "Wrong password")
                    
                default:
                    print(err)
                    Alert.errorAlert(error: "We cannot log you in")
                }//errCode
                
            }
            
            if let user = Auth.auth().currentUser {
                User.details.uid = user.uid
                User.details.email = user.email!
                User.details.username = user.displayName!
                
                User.details.firstTime = true
                
                self.performSegue(withIdentifier: "toHomeScreen", sender: self)
            }
        }
    }
    
    //REMEMBER TO DELETE
    @IBAction func repopTopics(_ sender: Any) {
        addtopics.addtopics()
    }
}



