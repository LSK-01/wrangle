//
//  ChosenTopicViewController.swift
//  Wrangler
//
//  Created by LucaSarif on 11/02/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit
import Foundation
import Firebase
//import NVActivityIndicatorView

// NOTE - PUT THIS VC IN ARGUMENTS AND MAKE IT LIKE A PENDING ARGUMENTS VC WHERE THEY CAN SEE THE TOPICS WHICH THEY HAVENT BEEN MATCHED IN YET THAT WAY WE ALSO ONLY NEED TITLES

class ChosenTopicViewController: UIViewController, UISearchBarDelegate {
/*
    @IBAction func backTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: SearchBar!
    
    var topics: [Topic] = []
    var usersTopics: [String] = []
    var topicTitleWidthAsProportionOfCellWidth: CGFloat = 0.9
    
    override func viewDidLoad() {
        super.viewDidLoad()


        
        // Set datasource and delegate
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        chosenTopicsNames { (titles) in
            print("6969696969969696")
            print(titles)
            self.chosenTopics(titles: titles)
            
        }
    }//viewdidload

    
    
    func chosenTopicsNames(completion: @escaping([Topic]) -> Void){
        startAnimating(message: "Loading Topics", type: NVActivityIndicatorType.circleStrokeSpin)
        
        Database.returnDocuments(path: "users/\(User.details.uid)/topics") { (documents, err) in
            if let err = err {
                progressHUD.hide()()
            
                    Alert.errorAlert(error: err)
                
                
            }
            
            if let documents = documents{
                for document in documents {
                    self.usersTopics.append(document.documentID)
                }
                
                completion(self.usersTopics)
            }
            else{
                //ADD LIKE A "DO U WANT TO FIND MORE TOPICS" THING - MAYBE HAVE IT AS A PLUS THING AS WELL INSTEAD OF SEPERATE THING
                //show label or sthing
                progressHUD.hide()()
                
            }
        }
        
        Database.returnDocumentsQuery(query: Database.db.collection("topics"), completion: T##([DocumentSnapshot]?, String?) -> Void)
        
    }
    
    
    //mb make this a closure
    
    func chosenTopics(titles:[String]){
        var tempTopic: Topic!
        //NEED TO TRY THIS OUT WITH DELETED TOPICS - IF SOMEONE DELETES A TOPIC THEY MADE, IT WONT DELETE IN EACH USERS INDIVIDUAL SUBCOLLECTION AND SO THEREFORE THE DOCUMENT IN THIS COMPLETION WILL RETURN NIL - SHOULD WORK JSUT CHECK
        
        for userTopic in titles {
  
            Database.returnDocument(path: "topics/\(userTopic)") { (document, err) in
                if let err = err {
                    progressHUD.hide()()
                    Alert.errorAlert(error: err)
                    return
                }
                if let document = document{
                    tempTopic = TopicFunctions.createTopic(topic: document)
             
                    self.topics.append(tempTopic)
                }
                //i dont think this works lmao YH IT DOESNT IT JUST RELOADS THE COLLECTION VIEW LOADS OF TIMES SO FIX IT
                if tempTopic.topicTitle == titles.last{
                    DispatchQueue.main.async {
                        print("reloading table data")
                        DispatchQueue.main.async{
                        self.collectionView.reloadData()
                        }
                        progressHUD.hide()()
                    }
                }
            }
        }//for
    }
}




extension ChosenTopicViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let topic = topics[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath) as! TopicCVC
        
        cell.setTopic(topic: topic)
        cell.topicName.wrapCellLabelText(cell: cell, labelProportionOfCellWidth: topicTitleWidthAsProportionOfCellWidth, maximumStoryboardFont: 28)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar.endEditing(true)
        let selectedTopic = topics[indexPath.row]
        print(selectedTopic.creator)
        print("selected cell, going to topic detail: ", selectedTopic)
        performSegue(withIdentifier: "toDetailFromChosenTopics", sender: selectedTopic)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = (collectionView.frame.height * 0.45)
        let width = (collectionView.frame.width * 0.95)

        return  CGSize(width: width, height: height)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailFromChosenTopics" {
            let destVC = segue.destination as! TopicDetailVC
            destVC.topic = sender as? Topic
        }
    }
    
    
   
    */
}
