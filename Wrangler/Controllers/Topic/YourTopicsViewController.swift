//
//  YourTopicsViewController.swift
//  Wrangler
//
//  Created by LucaSarif on 11/02/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit
import Foundation
import Firebase
//import NVActivityIndicatorView


class YourTopicsViewController: UIViewController, UISearchBarDelegate {
    
    @IBAction func backTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: SearchBar!
    let progressHUD = ProgressHUD(text: "Saving Photo")

    var topics: [Topic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        progressHUD.hide()
          self.view.addSubview(progressHUD)
        // Set datasource and delegate
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        createdTopics { (topics) in
            
            self.progressHUD.hide()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                
            }
        }
    }
    
    func createdTopics(completion: @escaping([Topic]) -> Void){
  progressHUD.show()

        Database.returnDocumentsQuery(query: Database.db.collection("topics").whereField("userWhoCreated", isEqualTo: User.details.username)) { (documents, err) in
            if let err = err{
                self.progressHUD.hide()
                print(err)
            }
            
            if let documents = documents{
                
                for document in documents{
                    let tempTopic = TopicFunctions.createTopic(topic: document)
                    
                    self.topics.append(tempTopic)
                }
                completion(self.topics)
                return
            }
            else{
                print("snapshot is empty")
                self.progressHUD.hide()
                return
            }
        }
        
        
    }
}





extension YourTopicsViewController: UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let topic = topics[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath) as! TopicCVC
        
        //cell.setTopic(topic: topic)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar.endEditing(true)
        let selectedTopic = topics[indexPath.row]
        print(selectedTopic.creator)
        performSegue(withIdentifier: "toDetailView2", sender: selectedTopic)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = (collectionView.frame.height * 0.45)
        let width = (collectionView.frame.width * 0.95)
        
        return  CGSize(width: width, height: height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailView3" {
           // let destVC = segue.destination as! TopicDetailVC
           // destVC.topic = sender as? Topic
        }
    }
    
    
    
    
}
