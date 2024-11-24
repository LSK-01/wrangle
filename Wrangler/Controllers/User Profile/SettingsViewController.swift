//
//  SettingsViewController.swift
//  Test
//
//  Created by LucaSarif on 22/01/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn
import FirebaseAuth
//import NVActivityIndicatorView

protocol updateUserDetailsDelegate: HomescreenVC{
    func updateImage(newImage: UIImage)
}

class SettingsViewController: UITableViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    weak var delegate: updateUserDetailsDelegate?
    var imageFromHomescreen: UIImage?
    var newImage: UIImage?
    let progressHUD = ProgressHUD(text: "Saving Photo")

    @IBAction func logoutTap(_ sender: Any) {
        try! Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        performSegue(withIdentifier: "logout", sender: self)
    }
    
    
    @IBAction func changePhoto(_ sender: Any) {
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var pushNotifsSwitch: UISwitch!
    
    @IBAction func pushNotifs(_ sender: Any) {
        if pushNotifsSwitch.isOn{
            //turnt on
        }
        else{
            //turnt off
        }
    }
    
    @IBOutlet weak var userImage: ProfileImage!
    let picker = UIImagePickerController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let image = newImage{
            delegate?.updateImage(newImage: image)

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        progressHUD.hide()
          self.view.addSubview(progressHUD)
       // userImage.layer.cornerRadius = userImage.frame.height / 2
        self.tableView.contentInset = UIEdgeInsets(top: 10,left: 0,bottom: 0,right: 0)
        tableView.rowHeight = 55
        picker.delegate = self
        
        DispatchQueue.main.async{
            self.userImage.image = self.imageFromHomescreen
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logout"{
            User.details.email = " "
            User.details.profileImageUrl = nil
            User.details.uid = " "
            User.details.username = " "
        }
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        var selectedImageFromPicker: UIImage?
        
        // Use the edited image if available
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        } // Get image value
        
        // Unwrap
        if let selectedImage = selectedImageFromPicker {
            newImage = selectedImage
         
            
            DispatchQueue.main.async{
               self.dismiss(animated: true, completion: nil)
                self.userImage.image = selectedImage
            }
            

        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

/*>>>>>>>>>Bio code
 lazy var bioTextView: UITextView = {
 let tv = UITextView()
 return tv
 }()
 
 var bioPlaceholder: String = "Bio"
 //just to avoid extra calls
 var prevBioText: String!
 
 //bio stuff
 func textViewDidBeginEditing(_ textView: UITextView) {
 if bioTextView.textColor == UIColor.lightGray {
 bioTextView.text = nil
 bioTextView.textColor = UIColor.black
 }
 prevBioText = bioTextView.text
 }
 
 func textViewDidEndEditing(_ textView: UITextView) {
 if bioTextView.text.isEmpty{
 print("prevBioText: ", prevBioText)
 bioTextView.text = bioPlaceholder
 bioTextView.textColor = UIColor.lightGray
 //Database.writeToDocument(path: "users/\(User.details.uid)", data: [ "bio": "" ], merge: true)
 }
 else{
 print("prevBioText: ", prevBioText)
 User.details.bio = bioTextView.text
 
 }
 }
 
 func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
 let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
 return newText.count < 150
 }
 
 override func viewWillDisappear(_ animated: Bool) {
 super.viewWillDisappear(animated)
 
 if prevBioText != bioTextView.text{
 Database.writeToDocument(path: "users/\(User.details.uid)", data: [ "bio": bioTextView.text ], merge: true)
 }
 }
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 bioTextView.delegate = self
 
 
 
 }
 

 */ //<<<<Bio code





// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
