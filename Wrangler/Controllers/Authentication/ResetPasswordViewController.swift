//
//  ResetPasswordViewController.swift
//  Test
//
//  Created by LucaSarif on 26/12/2017.
//  Copyright © 2017 LucaSarif. All rights reserved.
//

import UIKit
import Firebase


class ResetPasswordViewController: UIViewController{
    
    override func viewDidLoad() {
    super.viewDidLoad()
     
    }
    
    @IBOutlet weak var emailTextField: CustomTextField!
    
    @IBAction func resetPassword(_ sender: Any) {
        
        
        guard let email = emailTextField.text else {
           emailTextField.shake()
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { err in
            
            if let err = err {
                Alert.errorAlert(error: err.localizedDescription)
                
            }
            else{
                
                 
                 self.navigationController?.popViewController(animated: true)

                Alert.alert(message: "", title: "Reset email sent")
            }
        }
    }
}

