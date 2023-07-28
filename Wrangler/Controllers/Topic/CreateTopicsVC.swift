//
//  CreateTopicsVC.swift
//  Test
//
//  Created by LucaSarif on 18/01/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class CreateTopicsVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var topicTextField: CustomTextField!
    @IBOutlet weak var keywordsTextField: CustomTextField!
    @IBOutlet weak var createTopic: UIButton!
    @IBOutlet weak var selectCategory: UIButton!
    
    var topicTitle: String!
    var keywords: [String] = []
    var defaultSelectCategoryText: String!
//    let progressHUD = ProgressHUD(text: "Creating Topic")

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(categorySelected), name: .slideUpMenu, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        
        topicTextField.font = UIFont.systemFont(ofSize: DesignConstants.defaultFontSize, weight: .semibold)
        topicTextField.textColor = UIColor.white
        defaultSelectCategoryText = selectCategory.titleLabel?.text
        keywordsTextField.delegate = self
        keywordsTextField.tag = 1
        topicTextField.tag = 2
        selectCategory.addTarget(self, action: #selector(showSlideUpOptions), for: .touchUpInside)
//        progressHUD.hide()
//        self.view.addSubview(progressHUD)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .slideUpMenu, object: nil)
    }
    
    var previousTextLength: Int = 0
    var mainTextFieldColor: UIColor = UIColor.white
    var keywordColor: UIColor = UIColor.black
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text ?? ""

        if textField.tag == 2 {
            // attempt to read the range they are trying to change, or exit if we can't
            guard let stringRange = Range(range, in: text) else { return false }

            // add their new text to the existing text
            let updatedText = text.replacingCharacters(in: stringRange, with: string)

            // make sure the result is under 16 characters
            return updatedText.count <= 80
        }
         
        if textField.tag == 1{
            //just so they dont go wild on fucking keywords if they want to for some reason
            if text.components(separatedBy: " ").count > 50 {
                return false
            }
        }
        
        
        
        if textField.tag == 1 && string == " "{
            //if theres only spaces
            guard text.formattedString(spaces: false) != "" else {
                return false
            }
            
            textField.textColor = keywordColor
            text += ","
            let currentKeywords = text.components(separatedBy: " ")
            previousTextLength = text.count
            var latestKeyword = currentKeywords.last
            
            //remove comma
            latestKeyword = String((latestKeyword?.dropLast())!)
            if let k = latestKeyword{
                
                keywords.append(k)
                print(keywords)
            }
            
            //change all text before this point to white
            let rangeForWhite = NSRange(location: 0, length: text.count)
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: DesignConstants.defaultFontSize)])
            
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: mainTextFieldColor, range: rangeForWhite)
            textField.attributedText = attributedString
        }
        
        if textField.tag == 1 && string != " " {
            textField.textColor = keywordColor
            
            let exploded = text.components(separatedBy: " ")
            print(exploded)
            let latestKeywordCount = exploded.last?.count
            
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: DesignConstants.defaultFontSize)])
            
            var storeLength = text.count - (previousTextLength + 1)
            
            if storeLength < 0 {
                storeLength = 0
            }
            let rangeForBlack = NSRange(location: previousTextLength, length: storeLength)
            
            var storeLengthForWhite = text.count - latestKeywordCount! - 1
            if storeLengthForWhite < 0 {
                storeLengthForWhite = 0
            }
            let rangeForWhite = NSRange(location: 0,length: storeLengthForWhite)
            
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: keywordColor, range: rangeForBlack)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: mainTextFieldColor, range: rangeForWhite)
            
            textField.attributedText = attributedString
        }
        
        
        //if they backspace, delete the whole of the last keyword if a space is the last character
        if textField.tag == 1, let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                
                if previousTextLength > text.count{
                    previousTextLength = text.count
                }
                
                let textFieldCharacters = Array(textField.text!)
                if textFieldCharacters.last == " "{
                    //make everything white for meantime - we change it back later
                    textField.textColor = mainTextFieldColor
                    var exploded = textField.text!.trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
                    exploded.removeLast()
                    //rebuild textfield text
                    var newString: String = ""
                    for keyword in exploded{
                        newString += "\(keyword) "
                    }
                    newString += " "
                    textField.text = newString
                    
                    //update keywords array
                    keywords = exploded
                }
            }
        }
        
        return true
    }
    
    @IBAction func createTopicTapped(_ sender: Any) {
        view.endEditing(true)
        
//        progressHUD.show()
        
        
        
        if topicTextField.text?.formattedString(spaces: false) == ""{
//            progressHUD.hide()
            topicTextField.shake()
            return
        }
        topicTitle = topicTextField.text!
        var category: String!
        
        if selectCategory.titleLabel?.text != defaultSelectCategoryText{
            category = selectCategory.titleLabel!.text!
        }
        else{
//            progressHUD.hide()
            Alert.statusLineAlert(message: "Select a category")
            return
        }
        
        let comparableTopicString = topicTitle.formattedString(spaces: false)
        
        //add topic title as keywords
        let topicTitleKeywords = topicTitle.formattedString(spaces: true).components(separatedBy: " ")
        keywords.append(contentsOf: topicTitleKeywords)
        //remove duplicates
        keywords = Array(Set(keywords))
        for k in keywords{
            //get rid of common words which wont help search
            if Database.commonWords.contains(k){
                keywords = keywords.filter { $0 != k }
            }
        }
        keywords = keywords.map {$0.lowercased()}
        
        
        //need to atomocize ya shit! letya nuts hang king!
        
        
        Database.returnDocumentsQuery(query: Database.db.collection("topics").whereField("searchableName", isEqualTo: comparableTopicString)) { (documents, err) in
            if err != nil{
//                self.progressHUD.hide()
                self.navigationController?.popViewController(animated: true)
                return
            }
            if documents != nil{
//                self.progressHUD.hide()
                Alert.errorAlert(error: "A topic by this same name already exists")
                return
            }
            else{
                let data = TopicFunctions.createTopicDataObjForDB(timeCreatedInSeconds: Date.getCurrentSeconds(), createdBy: User.details.username, topicName: self.topicTitle, category: category, keywords: self.keywords)
                
                Database.writeToDocumentErrorHandling(path: "topics/\(self.topicTitle!.capitalized)", data: data, merge: false, completion: { (err) in
                    if let err = err {
//                        self.progressHUD.hide()
                        Alert.errorAlert(error: err)
                    }
                    else{
//                        self.progressHUD.hide()
                        Alert.alert(message: "Users can now see your topic - try searching for it!", title: "Created!")


                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    lazy var slideUpMenu: SlideUpCV = {
        let menu = SlideUpCV()
        return menu
    }()
    
    @objc func showSlideUpOptions() {
        let categoryNames: [String] = ["HEALTH & MEDICINE",  "EDUCATION","POLITICS","SCIENCE & TECHNOLOGY","ELECTIONS & PRESIDENTS","WORLD / INTERNATIONAL", "SEX & GENDER", "ENTERTAINMENT & SPORTS"]
        let formattedCategories = categoryNames.map { $0.capitalized}
        let menuOptions: [menuOption] = slideUpMenu.createMenuOptions(optionNames: formattedCategories)
        
        slideUpMenu.slideUp(options: menuOptions)
    }
    
    
    @objc func categorySelected(){
        guard let valueFromSlideUp = slideUpMenu.valueFromSlideUp else { return }
        selectCategory.setTitle(valueFromSlideUp,for: .normal)
        
        
    }
    
}
