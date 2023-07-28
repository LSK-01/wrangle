//
//  LandingViewController.swift
//  Test
//
//  Created by LucaSarif on 23/12/2017.
//  Copyright © 2017 LucaSarif. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import NVActivityIndicatorView

class LoginViewController: UIViewController, GIDSignInUIDelegate, NVActivityIndicatorViewable {
    
    //var tabBarValue: String!
    
    //@IBOutlet weak var googleSignIn: GIDSignInButton!
    
    
    @IBAction func googleButton(_ sender: Any) {
         GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func testFunc(_ sender: Any) {
    }
    
    
    @IBOutlet weak var emailTextField: ShakeField!
    @IBOutlet weak var passwordTextField: ShakeField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        User.user.isFromLogin = true
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "toHomeScreen", sender: self)
        }
        
        view.setGradientColours()
        
        // FOR DEV PURPOSES - REMEMBER TO DELETE
        passwordTextField.text = "xxxxxx"
        emailTextField.text = "test@gmail.com"
        
        // Do any additional setup after loading the view.
        passwordTextField.animateSlide(in: self)
        emailTextField.animateSlide(in: self)

    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        
        view.endEditing(true)
        
        startAnimating(message: "Logging In", type: NVActivityIndicatorType(rawValue: 32))
        
        // Check if fields are filled in
        guard let email = emailTextField.text else {
            stopAnimating()
            emailTextField.shake()
            return
        }
        
        guard let password = passwordTextField.text else {
            stopAnimating()
            passwordTextField.shake()
            return
        }
        
        // Try signing in with displayname/username in future
        Auth.auth().signIn(withEmail: email, password: password){ user, err in
            self.stopAnimating()
            
            if let err = err {
                
                Alert.alert(userTitle: " ", userMessage: err.localizedDescription, userOptions: "Alright", in: self)
                return
            }
            
            if user != nil {
                self.performSegue(withIdentifier: "toHomeScreenFromLogin", sender: self)
            }
            
            
        }// if error is nil
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    var ReeArray:[String] = ["I Believe Single-sex Schools Are Good For Education",
                             "We Should Ban Animal Testing",
                             "We Should Ban Homework",
                             "I Support The Death Penalty",
                             "I Believe Reality Television Does More Harm Than Good",
                             "I Believe University Education Should Be Free",
                             "I Believe The Internet Brings More Harm Than Good",
                             "We Should Raise The Legal Driving Age To 18",
                             "We Should Ban School Uniforms - Junior",
                             "I Believe That Assisted Suicide Should Be Legalized",
                             "I Believe Wild Animals Should Not Be Kept In Captivity",
                             "We Should Ban Cosmetic Surgery",
                             "I Believe That Children Should Be Allowed To Own And Use Mobile Phones  ",
                             "I Believe Mothers Should Stay At Home And Look After Their Children  ",
                             "We Should Legalize The Sale Of Human Organs",
                             "I Believe Science Is A Threat To Humanity",
                             "We Should Ban Junk Food From Schools  ",
                             "I Believe That Advertising Is Harmful",
                             "We Should Censor The Internet",
                             "I Believe That Cannabis Should Be Legalised",
                             "I Believe That Capitalism Is Better Than Socialism",
                             "We Should Ban Beauty Contests",
                             "I Believe Parents Should Be Able To Choose The Sex Of Their Children",
                             "I Believe Homosexuals Should Be Able To Adopt",
                             "I Believe Terrorism Can Be Justified",
                             "We Should Ban The Sale Of Violent Video Game",
                             "We Should Ban Human Cloning  ",
                             "We Should Ban Smoking In Public Spaces",
                             "We Should Ban Boxing  ",
                             "I Believe Criminal Justice Should Focus More On Rehabilitation  ",
                             "We Should Allow Gay Couples To Marry",
                             "We Should Lower The Drinking Age",
                             "We Should Make Voting Compulsory",
                             "I Believe All Nations Have A Right To Nuclear Weapons",
                             "I Believe Extra-curricular Activities In Schools Should Be Formally Recognised  ",
                             "I Believe That The United Nations Has Failed",
                             "We Should Allow Prisoners To Vote",
                             "We Should Permit The Use Of Performance Enhancing Drugs In Professional Sports",
                             "I Believe That Marriage Is An Outdated Institution",
                             "We Should Make Physical Education Compulsory",
                             "We Should Restrict Advertising Aimed At Children",
                             "We Should Arm Teachers",
                             "We Should Legalise Prostitution",
                             "We Should Implement A Fat Tax",
                             "I Support Home Schooling",
                             "We Should Ban Gambling",
                             "We Should Reintroduce Corporal Punishment In Schools",
                             "I Believe That Religion Does More Harm Than Good",
                             "We Should Go Vegetarian",
                             "I Believe That Hosting The Olympics Is A Good Investment",
                             "We Should Introduce Child Curfews",
                             "I Believe That Internet Access Is A Human Right",
                             "We Should Ban Music Containing Lyrics That Glorify Violent And Criminal Lifestyles",
                             "We Should Legalize Polygamy",
                             "We Should Limit The Right To Bear Arms",
                             "I Believe People Should Not Keep Pets",
                             "We Should Ban Child Performers",
                             "We Should Ban Teachers From Interacting With Students Via Social Networking Websites  ",
                             "I Believe That Animals Have Rights  ",
                             "I Believe That It Is Sometimes Right For The Government To Restrict Freedom Of Speech",
                             "We Should Use Torture To Obtain Information From Suspected Terrorists  ",
                             "We Should Arm The Police",
                             "We Should Give Illegal Immigrants Drivers Licenses",
                             "We Should Make All Parents Attend Parenting Classes",
                             "I Believe Social Deprivation Causes Crime  ",
                             "We Should Ban Alcohol",
                             "We Should Ban The Development Of Genetically Modified Organisms",
                             "We Should Make Sex Education Mandatory In Schools",
                             "We Should Go Nuclear",
                             "I Believe That Newspapers Are A Thing Of The Past",
                             "We Should Ban The Use Of Animals As Objects Of Sport And Entertainment",
                             "I Believe In The Woman's Right To Choose",
                             "We Should Force Feed Sufferers Of Anorexia Nervosa",
                             "I Believe We're Too Late On Global Climate Change",
                             "We Should Ban Religious Symbols In Public Buildings",
                             "I Believe That Music That Glorifies Violence Against Women Should Be Banned  ",
                             "I Believe That Bribery Is Sometimes Acceptable",
                             "I Believe The Internet Encourages Democracy",
                             "We Should Ban Smacking",
                             "We Should Distribute Condoms In Schools",
                             "I Believe That The United States Should Be Isolationist",
                             "We Should Further Restrict Smoking",
                             "I Believe That Downloading Music Without Permission Is Morally Equivalent To Theft",
                             "We Should Abolish Nuclear Weapons",
                             "We Should Explore The Universe",
                             "I Believe That Endangered Species Should Be Protected",
                             "We Should Abolish The Monarchy",
                             "We Should Promote Safe Sex Through Education At Schools",
                             "We Should As The United States Ban Assault Weapons",
                             "We Should Impose Democracy"
    ]
    var batchArray: [Any] = []
    @IBAction func reeeButton(_ sender: Any) {

         let batch = Firestore.firestore().batch()

        for string in ReeArray{
            let stringArr = string.components(separatedBy: " ")
            var keywordsObj: [String:Bool] = [:]

            for keyword in stringArr{
                if vars.commonWords.contains(keyword.createComparableString(noSpaces: true)) || keyword.createComparableString(noSpaces: true) == ""{
                    print("in arr")
                }
                else{
                keywordsObj[keyword.lowercased()] = true
                print(keywordsObj)
                }
            }
            
            keywordsObj["test"] =  true
            
            let data: [String:Any] = [
                "timeCreated": FieldValue.serverTimestamp(), //class FieldValue : NSObject
                "usersRegisteredAgainst": 0,
                "usersRegisteredFor": 0,
                "usersRegistered" : 0,
                "userWhoCreated": "Wrangler",
                "searchableName": string.createComparableString(noSpaces: true),
                "keywords": keywordsObj
            ]
            
            
            let document = Firestore.firestore().collection("topics").document(string.createComparableString(noSpaces: false).capitalized)
            batch.setData(data,
                          forDocument: document)
            
            // Commit the batch
            print(string)
        }
        
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
        
        
        }
        
    
        
        
        
    }



