//
//  InviteFriendsViewController.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 23/07/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase

class InviteFriendsViewController: UIViewController, NVActivityIndicatorViewable, UISearchBarDelegate {

    var invitingToJoin: String!
    var userCells: [Opponent] = []
    var username: String!
    //pagination
    var lastDocument: DocumentSnapshot!
    var query: Query!
    
    @IBOutlet weak var collectionView: CollectionView!
    @IBOutlet weak var searchBar: SearchBar!
    
    @IBAction func backTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
    }
    
    
    func getSearchedFriends(completion: @escaping([Opponent]) -> Void){
        //first time running
        if lastDocument == nil{
            //create query without startAt cus we have nothing to start at
            query = Database.db.collection("users/\(User.user.uid)/friends").whereField("isRequesting", isEqualTo: false).whereField("usernameSearchable", isEqualTo: username).limit(to: 7)
        }
        else{
            query = Database.db.collection("users/\(User.user.uid)/friends").whereField("isRequesting", isEqualTo: false).whereField("usernameSearchable", isEqualTo: username).limit(to: 7).start(afterDocument: lastDocument)
        }
        
        
        OpponentFunctions.fetchOpponents(query: query) { (friends, lastDocumentR, err) in
            if let err = err {
                Alert.errorAlert(error: err)
            }
            if let friends = friends{
                completion(friends)
                self.lastDocument = lastDocumentR
            }
            else{
                print("at end")
                self.stopAnimating()
                return
                
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        username = searchBar.text
        if username?.formattedString(spaces:  false) == nil{
            self.searchBar.endEditing(true)
        }
        else{
            userCells = []
            lastDocument = nil
            print("creating comparable string and querying db")
            username = username!.formattedString(spaces:  false).components(separatedBy: CharacterSet.decimalDigits).joined()
            
            getSearchedFriends { (friends) in
                self.userCells.append(contentsOf: friends)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }   
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom == height {
            print("last cell")
            //mb add a small indicator instead - cleaner
            startAnimating(message: "", type: NVActivityIndicatorType.circleStrokeSpin)
            getSearchedFriends { (friends) in
                self.stopAnimating()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}


extension InviteFriendsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userCells.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let userCell = userCells[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendCell", for: indexPath as IndexPath) as! UserCollectionViewCell
        
        cell.setUserCell(opponent: userCell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar.endEditing(true)
        
        
        let userCellSelected = userCells[indexPath.row]
        
        performSegue(withIdentifier: "toTopics", sender: userCellSelected)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destVC = segue.destination as! TopicsCV
        destVC.invitingThisUser = sender as? Opponent
        
        
    }
    }
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let height = (collectionView.frame.height * 0.45)
    let width = (collectionView.frame.width * 0.95)
    
    return  CGSize(width: width, height: height)
}

    

