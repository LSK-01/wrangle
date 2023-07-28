//
//  GlobalConstants.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 24/10/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

struct CellConstants{
    static let fontType: UIFont = UIFont.systemFont(ofSize: 21, weight: .medium)
    static let largeLabelProportion: CGFloat = 0.9
    static let cellToViewProportionWidth:  CGFloat = 0.9
    static let cellToViewProportionHeight: CGFloat = 0.35
    static let cellHeightLarge: CGFloat = 145
    static let cellHeightDefault: CGFloat = 100
    
    static let cellHeightTitle: CGFloat = 170
    
    static let textBubbleViewLineHeight: CGFloat = 36.7
    static let topPadding: CGFloat = 7
}

//class GoogleCreds{
//    static let signInConfig = GIDConfiguration.init(clientID: "50365616318-18o15dv0i6cpluh9dcg9olkomf017b0m.apps.googleusercontent.com")
//}

struct FirebaseConstants{
    static let limitingDocumentsTo: Int = 8
    static let limitingTopicsTo: Int = 7
}

struct TimeConstants{
    static let publicArgLengthMins: Float = 180.0
}

struct DateConstants{
    static let oneDayInSeconds: Int = 86400
    static let oneHourInMinutes: Int = 60
}

struct DesignConstants{
    static let cornerRadius: CGFloat = 12
    
    static let orangeGradientColors: [CGColor] = [UIColor(red:0.95, green:0.54, blue:0.69, alpha:1.0).cgColor, UIColor(red:0.96, green:0.74, blue:0.53, alpha:1.0).cgColor]
    
    static let blueGradientColors: [CGColor] = [UIColor(red:0.80, green:0.67, blue:0.98, alpha:1.0).cgColor, UIColor(red:0.49, green:0.91, blue:0.91, alpha:1.0).cgColor]
    
    static let mainRed: UIColor = UIColor(red:0.96, green:0.58, blue:0.65, alpha:1.0)
    
    static let mainBlue: UIColor = UIColor(red:0.57, green:0.84, blue:0.92, alpha:1.0)

    static let accentBlue: UIColor = UIColor(red:0.63, green:0.80, blue:0.91, alpha:1.0)
    
    static let mainPurple: UIColor = UIColor(red:0.75, green:0.69, blue:0.84, alpha:1.0)
    
    static let accentOrange: UIColor = UIColor(red:0.96, green:0.69, blue:0.58, alpha:1.00)
    static let smallFontSize: CGFloat = 14
    static let defaultFontSize: CGFloat = 17
    static let largeFontSize: CGFloat = 30
}

struct SegueConstants{
    static let settingsSegue: String = "toSettings"
    static let messagingSegue: String = "toMessaging"
    static let homescreenFromSignUpSegue: String = "toHomeScreenFromSignup"
    static let homescreenFromLoginSegue: String = "toHomeScreen"
    static let toCreateTopic: String = "toCreateTopic"
    static let toPublicArgs: String = "toPublicArgFromHomescreen"
}

struct ActivityIndicator{
   static let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
   // static let indicator: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2, width: 20, height: 20), type: .circleStrokeSpin, color: UIColor.white)
}


