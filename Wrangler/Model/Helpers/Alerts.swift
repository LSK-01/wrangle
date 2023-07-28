//
//  AlertFunction.swift
//  Test
//
//  Created by LucaSarif on 27/12/2017.
//  Copyright © 2017 LucaSarif. All rights reserved.
//

import Foundation
import SwiftMessages

class Alert {
    
//    class func stockAlert(userTitle: String?, userMessage: String, userOptions: String, in vc: UIViewController) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: userTitle, message: userMessage, preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: userOptions, style: UIAlertAction.Style.default, handler: nil))
//            vc.present(alert, animated: true, completion: nil)
//        }
//    }
//
    static func alert(message: String, title: String){
        SwiftMessages.hideAll()
        
        let view = MessageView.viewFromNib(layout: .cardView)
        // Theme message elements with the warning style.
        view.configureTheme(.success)
        // Add a drop shadow.
        view.configureDropShadow()
        
        let seconds = Double(message.count) * 0.1
        
        view.buttonTapHandler = { _ in SwiftMessages.hide() }
        view.configureContent(title: title, body: message)
        view.button?.isHidden = true
        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        
        // Show the message.
        SwiftMessages.show(view: view)
        
    }
    
    static func errorAlert(error: String){
        SwiftMessages.hideAll()
        
        let view = MessageView.viewFromNib(layout: .cardView)
        // Theme message elements with the warning style.
        view.configureTheme(.error)
        
        // Add a drop shadow.
        view.configureDropShadow()
        
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        view.configureContent(title: "Hol' up", body: error)
        view.button?.isHidden = true

        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        
        // Show the message.
        SwiftMessages.show(view: view)
    }
    
    static func statusLineAlert(message: String){

        SwiftMessages.hideAll()
        let view = MessageView.viewFromNib(layout: .statusLine)
        
        // Theme message elements with the warning style.
        view.configureTheme(.info)

        // Add a drop shadow.
        view.configureDropShadow()
        
        view.configureContent(title: "Warning", body: message)
        
        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        
        // Show the message.
        SwiftMessages.show(view: view)
    }
}
