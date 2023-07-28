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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableTitle: UILabel!
    
    var userCells: [Opponent] = []
    var friendRequest: Bool = true
    var username: String?
    var tableTitleText: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
            
        }
        /*
        DispatchQueue.main.async{
        self.tableView.reloadData()
        }*/
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = 135
        searchBar.delegate = self
        
        //FIRST RUN USING THE TABLEVIEWFUNCS CLASS - TEST THIS TO SEE IF IT WORKS AND THEN REPLACE THE REST
        
        if friendRequest{
            Queues.fastQueueS.async{
            DispatchQueue.main.async{
            self.tableTitle.text = "Friend Requests"
            self.searchBar.isHidden = true
            }
            TableViewFuncs.fetchUsers(query: vars.db.collection("users/\(User.user.uid)/friends").whereField("isRequesting", isEqualTo: true)) { (opponents, err) in
                if let err = err{
                    Alert.errorAlert(error: err , in: self)
                    self.stopAnimating()
                }
                if let opponents = opponents{
                    self.userCells = opponents
                    self.stopAnimating()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        }
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        userCells = []
        username = searchBar.text
        if username?.createComparableString(noSpaces: false) == nil{
            self.searchBar.endEditing(true)
        }
        else{
            username = username!.createComparableString(noSpaces: true).components(separatedBy: CharacterSet.decimalDigits).joined()
            startAnimating(message: "Searching users", type: NVActivityIndicatorType(rawValue: 32))
            TableViewFuncs.fetchUsers(query: vars.db.collection("users").whereField("usernameSearchable", isEqualTo: username)) { (opponents, err) in
                if let err = err {
                    Alert.errorAlert(error: err , in: self)
                    return
                }
                if let opponents = opponents{
                    self.userCells = opponents
                    self.stopAnimating()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    @IBAction func friendRequestsTapped(_ sender: Any) {
        if !friendRequest{
        DispatchQueue.main.async{
            self.tableTitle.text = "Friend Requests"
            self.searchBar.isHidden = true
            self.userCells = []
            self.tableView.reloadData()
        }
            friendRequest = true
            TableViewFuncs.fetchUsers(query: vars.db.collection("users/\(User.user.uid)/friends").whereField("isRequesting", isEqualTo: true)) { (opponents, err) in
                if let err = err{
                    Alert.errorAlert(error: err , in: self)
                    self.stopAnimating()
                }
                if let opponents = opponents{
                    self.userCells = opponents
                    self.stopAnimating()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func addFriendsTapped(_ sender: Any) {
        if friendRequest{
        DispatchQueue.main.async{
            self.tableTitle.text = "Add Friends"
            self.searchBar.isHidden = false
            self.userCells = []
            self.tableView.reloadData()
        }
        friendRequest = false
        }
    }
    
    @IBAction func unwindFromFriendRequest(segue:UIStoryboardSegue) {
        
        Alert.alert(userTitle: "You now have a private argument with this friend", userMessage: "You can view your arguments with friends along with public arguments in the arguments tab", userOptions: "Alright", in: self)
    }
    
    @IBAction func unwindFromFriendDetailViewDecline(segue:UIStoryboardSegue) {
        
    }
}




extension AddFriendsViewController: UITableViewDelegate, UITableViewDataSource{
    // Table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userCell = userCells[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell") as! UserTableViewCell
        
        cell.setUserCell(opponent: userCell)
        
        return cell
    }
    
    
    // To pass info to the detail view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let userCellSelected = userCells[indexPath.row]
        
        performSegue(withIdentifier: "toFriendDetailView", sender: userCellSelected)
    }
    
    // Segue for detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toFriendDetailView" {
            let destVC = segue.destination as! AddFriendsDetailViewController
            destVC.userObj = sender as! Opponent
            if friendRequest{
                destVC.friendRequest = true
                
            }
        }
        
        
    }
    
}
