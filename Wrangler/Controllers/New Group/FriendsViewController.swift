//
//  FriendsViewController.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 17/07/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class FriendsViewController: UIViewController, NVActivityIndicatorViewable, UISearchBarDelegate {
    
    
    @IBAction func backTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //super.touchesBegan(touches, with: event)
        self.searchBar.endEditing(true)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionTitle: UILabel!
    
    var userCells: [Opponent] = []
    var friendRequest: Bool = true
    var username: String!
    var collectionTitleText: String!
    var shouldRemoveCell: Bool = false
    //pagination
    var lastDocument: DocumentSnapshot!
    var query: Query!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        //check if this works
        if let index = self.collectionView.indexPathsForSelectedItems{
            //dont need to remove the cell if theyre sending a friend requ only if theyre clicking on one
           
            
            if let lastIndex = index.last, shouldRemoveCell && friendRequest{
                print("index: ", lastIndex.row)
                userCells.remove(at: lastIndex.row)
                //made true if they accpet/decline the friend requ
                shouldRemoveCell = false
                
                if userCells.isEmpty{
                    navigationController?.popViewController(animated: true)
                }
                else{
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
         
        
        //FIRST RUN USING THE CollectionView CLASS - TEST THIS TO SEE IF IT WORKS AND THEN REPLACE THE REST
        
        if friendRequest{
            Queues.fastQueueS.async{
                DispatchQueue.main.async{
                    self.collectionTitle.text = "Friend Requests"
                    self.searchBar.isHidden = true
                }
                self.getFriendRequs { (friendRequs) in
                    self.userCells.append(contentsOf: friendRequs)
                    print("userCells:", self.userCells)
                    self.stopAnimating()
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func getFriendRequs(completion: @escaping([Opponent]) -> Void){
        
        if lastDocument == nil{
            print("last document is nil")
            query = Database.db.collection("users/\(User.user.uid)/friends").whereField("isRequesting", isEqualTo: true).limit(to: 5)
        }
        else{
            query = Database.db.collection("users/\(User.user.uid)/friends").whereField("isRequesting", isEqualTo: true).start(afterDocument: lastDocument).limit(to: 5)
        }
        
        OpponentFunctions.fetchOpponents(query: query) { (friends, lastDocumentR, err) in
            if let err = err{
                Alert.errorAlert(error: err)
                self.stopAnimating()
            }
            if let friends = friends{
                print(friends)
                self.lastDocument = lastDocumentR
                completion(friends)
            }
            else{
                //no documents
                print("at end")
                self.stopAnimating()
                return
            }
        }
    }

    
    

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        username = searchBar.text
        if username?.formattedString(spaces:  true) == nil{
            self.searchBar.endEditing(true)
        }
        else{
            userCells = []
            lastDocument = nil
            username = username!.formattedString(spaces:  false).components(separatedBy: CharacterSet.decimalDigits).joined()
            print("looking for users with usernameSearchable val: ", username)
            startAnimating(message: "", type: NVActivityIndicatorType.circleStrokeSpin)

            
            getSearchedUsers { (users) in
                print("val of users:", users)
                self.userCells.append(contentsOf: users)
                self.stopAnimating()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func getSearchedUsers(completion: @escaping([Opponent]) -> Void){
        //first time running
        if lastDocument == nil{
            //create query without startAt cus we have nothing to start at
            query = Database.db.collection("users").whereField("usernameSearchable", isEqualTo: username)
        }
        else{
            query = Database.db.collection("users").whereField("usernameSearchable", isEqualTo: username).start(afterDocument: lastDocument)
        }
         
        OpponentFunctions.fetchOpponents(query: query) { (users, lastDocumentR, err) in
            if let err = err {
                Alert.errorAlert(error: err)
            }
            if let users = users{
                completion(users)
                self.lastDocument = lastDocumentR
            }
            else{
                print("at end")
                self.stopAnimating()
                return
            }
        }
    }
    

    
    
    @IBAction func addFriendsTapped(_ sender: Any) {
        if friendRequest{
            //have recommended users - //have like mutual friends (friends of the their friends if we can make it efficient enough)
            DispatchQueue.main.async{
                self.collectionTitle.text = "Add Friends"
                self.searchBar.isHidden = false
                self.userCells = []
                self.collectionView.reloadData()
            }
            lastDocument = nil
            friendRequest = false
        }
    }
    
    @IBAction func friendRequestsTapped(_ sender: Any) {
        if !friendRequest{
            DispatchQueue.main.async{
                self.collectionTitle.text = "Friend Requests"
                self.searchBar.isHidden = true
                self.userCells = []
                self.collectionView.reloadData()
            }
            
            
            
            getFriendRequs { (friendRequs) in
                self.userCells.append(contentsOf: friendRequs)
                self.stopAnimating()
                DispatchQueue.main.async{
                    self.collectionView.reloadData()
                }
            }
        }
        
    }
    
    @IBAction func unwindFromFriendDetail(segue:UIStoryboardSegue) {
    }
}




extension FriendsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return userCells.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let userCell = userCells[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendCell", for: indexPath) as! UserCollectionViewCell
        
        cell.setUserCell(opponent: userCell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar.endEditing(true)
        let userCellSelected = userCells[indexPath.row]
        
        performSegue(withIdentifier: "toFriendDetailView", sender: userCellSelected)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = (collectionView.frame.height * 0.45)
        let width = (collectionView.frame.width * 0.95)
        
        return  CGSize(width: width, height: height)
    }
    
    // Segue for detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toFriendDetailView" {
            let destVC = segue.destination as! RequestsDetailViewController
            destVC.userObj = sender as! Opponent
            if friendRequest{
                destVC.friendRequest = true
            }
        }
    }
}
