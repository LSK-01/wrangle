//
//  AppDelegate.swift
//  Test
//
//  Created by LucaSarif on 23/12/2017.
//  Copyright © 2017 LucaSarif. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import GoogleSignIn
import FirebaseFunctions
//import PayPalCheckout
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    @available(iOS 9.0, *)
    
    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      var handled: Bool

      handled = GIDSignIn.sharedInstance.handle(url)
      if handled {
        return true
      }

      // Handle other custom URL types.

      // If not handled by this app, return false.
      return false
    }
    
    

    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        if error != nil{
            print(error)
            return
        }
    }
    
    var hasAlreadyLaunched :Bool!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    

        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        


        

        UITabBar.appearance().tintColor = DesignConstants.accentBlue
        UITabBar.appearance().unselectedItemTintColor = DesignConstants.mainPurple
        UITabBar.appearance().backgroundColor = UIColor.white
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
          if error != nil || user == nil {
            // Show the app's signed-out state.
          }
        }

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(MessagingViewController.self)
        
        if let user = Auth.auth().currentUser{
            User.details.uid = user.uid
            User.details.email = user.email!
            User.details.username = user.displayName!

            
            self.window?.rootViewController!.performSegue(withIdentifier: "toHomeFromNav", sender: nil)
        }
        
        


        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationdidenterbackground")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("applicationwillterminate")
        
    }
    
    
    
    
    
    
    
    
    
    
//    func registerForPushNotifications() {
//        UNUserNotificationCenter.current()
//          .requestAuthorization(
//            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
//            print("Permission granted: \(granted)")
//            guard granted else { return }
//            self?.getNotificationSettings()
//          }
//
//    }
//
//    func getNotificationSettings() {
//      UNUserNotificationCenter.current().getNotificationSettings { settings in
//        print("Notification settings: \(settings)")
//        guard settings.authorizationStatus == .authorized else { return }
//        DispatchQueue.main.async {
//          UIApplication.shared.registerForRemoteNotifications()
//        }
//      }
//    }
//
//    func application(
//      _ application: UIApplication,
//      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
//    ) {
//      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
//      let token = tokenParts.joined()
//      print("Device Token: \(token)")
//        User.details.deviceToken = token
//        Database.writeToDocument(path: "users/\(User.details.uid)", data: ["deviceToken": token], merge: true)
//
//    }
//
//    func application(
//      _ application: UIApplication,
//      didFailToRegisterForRemoteNotificationsWithError error: Error
//    ) {
//      print("Failed to register: \(error)")
//    }
}

