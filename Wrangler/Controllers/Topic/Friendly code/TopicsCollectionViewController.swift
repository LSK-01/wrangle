//
//  TopicsCV.swift
//  Test
//
//  Created by LucaSarif on 14/01/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import NVActivityIndicatorView



class TopicsCV: UIViewController, NVActivityIndicatorViewable, UISearchBarDelegate {
    
    enum SortingBy: String{
        case mainlyFor = "mainly for"
        case mainlyAgainst = "mainly against"
        case recent = "recent"
        case controversial = "controversial"
    }
    
    //tableview outlet
    @IBOutlet weak var collectionView: CollectionView!
    @IBOutlet weak var searchBar: SearchBar!
    @IBOutlet weak var backTap: UIButton!
    @IBOutlet weak var sideMenu: UIButton!
    @IBOutlet weak var backToTop: UIButton!
    @IBOutlet weak var changeCellSizes: UIButton!
    @IBOutlet weak var searchTitle: UILabel!
    
    @IBAction func backTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // To store array of topics
    var topics: [Topic] = []
    var invitingThisUser: Opponent?
    //for collection view
    var itemsPerRow: CGFloat = 2
    var canLoadMore: Bool = false
    //for pagination
    var lastDocument: DocumentSnapshot!
    var lastQuery: Query!
    //so we know which query to use for pagination
    var queryBeingUsed: Query!
    // for getting searched topics
    var keywords: [String]!
    //currentQueryKeywords changes for each keyword searching
    var sortingBy: SortingBy = .controversial
    var currentQueryKeywords: Query!
    var atKeyword = 0
    var newQueryKeywords: Bool = true
    var zoomedOut: Bool = false
    var topicTitleWidthAsProportionOfCellWidth: CGFloat = 0.9 //make sure you change the multiplier in the storyboard to match this.
    //so if usersRegd value shouldve changed user can swipe to reload
    lazy var refresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshArguments(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    // edit tableviewcell after clicking cell
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        //if let index = self.collectionView.indexPathsForSelectedItems{
        //  collectionView.deselectItem(at: index[0], animated: true)
        //}
        
        //if tab bar is showing they cant go back anyway and we want to show the side menu again
        if tabBarController?.tabBar.isHidden ?? true{
            print("tab bar is hidden")
            backTap.isHidden = false
            //sideMenu.isHidden = true
        }
        else{
            backTap.isHidden = true
            //sideMenu.isHidden = false
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //collection view setup
        //collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refresh
        } else {
            collectionView.addSubview(refresh)
        }
        
        searchBar.delegate = self
        //so nibbas can swipe down
        collectionView.keyboardDismissMode = .interactive
        
        
        searchTitle.text = "Popular"
        startAnimating(message: "Loading Popular Topics", type: NVActivityIndicatorType(rawValue: 32))
        
        queryBeingUsed = vars.db.collection("topics").order(by: "controversiality", descending: true).limit(to: 8)
        lastQuery = queryBeingUsed
        
        returnSpecificTopics(baseQuery: queryBeingUsed, query: queryBeingUsed) { (newTopics) in
            
            self.topics.append(contentsOf: newTopics)
            self.stopAnimating()
            DispatchQueue.main.async{
                self.collectionView.reloadData()
                self.canLoadMore = true
            }
        }
    }// View did load
    
    @objc func refreshArguments(sender: AnyObject) {
        
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        let finishAfter = DispatchTime.now() + .milliseconds(200)
        DispatchQueue.main.asyncAfter(deadline: finishAfter) {
            self.refresh.endRefreshing()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //super.touchesBegan(touches, with: event)
        self.searchBar.endEditing(true)
    }
    
    func getSearchedTopics(completion: @escaping([Topic]) -> Void){
        var docsReturnedNo = 0
        
        //very first time running function
        if currentQueryKeywords == nil{
            
            print("cleanig topics and newTopics array")
            self.topics = []
            DispatchQueue.main.async{
                self.searchTitle.text = "Searched"
                self.collectionView.reloadData()
            }
        }
        
        //check if first time running new query (w/ new keyword)
        if newQueryKeywords{
            
            currentQueryKeywords = vars.db.collection("topics").whereField("keywords." + keywords[atKeyword], isEqualTo: true).limit(to: 8)
            newQueryKeywords = false
        }
        else{
            //second-> time running
            currentQueryKeywords = vars.db.collection("topics").whereField("keywords." + keywords[atKeyword], isEqualTo: true).limit(to: 8).start(afterDocument: lastDocument)
        }
        
        Database.returnDocumentQuery(query: currentQueryKeywords) { (documents, err) in
            if let err = err{
                self.stopAnimating()
                Alert.errorAlert(error: err)
                print(err)
                return
                
            }
            if let documents = documents{
                self.lastDocument = documents.last
                for document in documents{
                    
                    let tempTopic = TopicFunctions.createTopic(topic: document)
                    
                    self.topics.append(tempTopic)
                    docsReturnedNo = docsReturnedNo + 1
                    print("appended topic \(docsReturnedNo)")
                    
                }
                completion(self.topics)
                print("topic count: ", self.topics.count)
                
            }
            else{
                //if there are still keywords left to query
                //count doesnt start from 0 index hence the + 1
                if self.keywords.count != self.atKeyword + 1{
                    //query next keyword if all documents have been queried for this one
                    print("querying new keyword")
                    self.atKeyword = self.atKeyword + 1
                    self.newQueryKeywords = true
                    //rerun function
                    self.getSearchedTopics(completion: { (topics) in
                        self.stopAnimating()
                        DispatchQueue.main.async{
                            self.collectionView.reloadData()
                            
                        }
                    })
                }
                else{
                    //if topics is still empty ie. nothing was returned
                    if self.topics.isEmpty{
                        //display label or something - "nothing was returned for your search, would you like to make a topic"
                    }
                    self.stopAnimating()
                    return
                }
            }
        }
    }
    
    
    
    //search bar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        var searchText = searchBar.text
        var keywordsArr:[String]!
        
        //put character restriction limit
        if searchText?.createComparableString(noSpaces: true) == ""{
            searchBar.endEditing(true)
            return
        }
        
        searchText = searchText?.createComparableString(noSpaces: false)
        keywordsArr = searchText!.components(separatedBy: " ")
        keywords = keywordsArr
        
        currentQueryKeywords = nil
        searchBar.endEditing(true)
        getSearchedTopics() { (topics) in
            self.stopAnimating()
            DispatchQueue.main.async{
                self.collectionView.reloadData()
                
            }
        }
    }
    
    
    func returnSpecificTopics(baseQuery: Query, query: Query, completion: @escaping([Topic]) -> Void){
        //this is whats returned and then we append this to the main topics array refresh tableview
        var newTopics: [Topic] = []
        // we need to check what the last query was without the added .start(at) when using pagination - we cant check it then because lastDocument constantly changes. if its not the same as the latest query one then we clear topics array because that means were getting different types of topics now
        if lastQuery != baseQuery{
            print("clearing topics array")
            topics = []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        lastQuery = baseQuery
        
        Database.returnDocumentQuery(query: query) { (documents, err) in
            if let err = err{
                self.stopAnimating()
                Alert.errorAlert(error: err)
                return
                
            }
            if let documents = documents{
                //for pagination
                self.lastDocument = documents.last
                print("lastDocument: ", self.lastDocument!)
                for document in documents{
                    
                    let topicContain = TopicFunctions.createTopic(topic: document)
                    
                    print("topicContain: ", topicContain)
                    newTopics.append(topicContain)
                    
                }
                completion(newTopics)
            }
            else{
                //no more documents
                if self.topics.isEmpty{
                    Alert.statusLineAlert(message: "No results were returned!")
                }
                else{
                    Alert.statusLineAlert(message: "No more items!")
                }
                self.stopAnimating()
                return
            }
        }
    }
    //drop down or something with options of each category
    lazy var slideUpMenu: SlideUpCV = {
        let menu = SlideUpCV()
        menu.topicsCV = self
        return menu
    }()
    
    @IBAction func showSlideUpOptions(_ sender: Any) {
        let menuOptions: [menuOption] = [menuOption(optionName: SortingBy.mainlyFor.rawValue, imageNamed: "lockIcon"), menuOption(optionName: SortingBy.mainlyAgainst.rawValue, imageNamed: "lockIcon"), menuOption(optionName: SortingBy.recent.rawValue, imageNamed: "lockIcon"), menuOption(optionName: SortingBy.controversial.rawValue, imageNamed: "lockIcon")]
        
        slideUpMenu.slideUp(options: menuOptions, VC: "publicArgumentsCV")
    }
    
    //recieve what has been tapped from slide up CV
    var valueFromSlideUp: String = "controversial"{
        didSet{
            print("didset valueFromSlideUp")
            fetchSortingBy()
        }
    }
    
    func fetchSortingBy(){
        print("val from slide menu: ", valueFromSlideUp)
        switch valueFromSlideUp{
            
        case "controversial":
            if sortingBy != .controversial{
                
                queryBeingUsed = vars.db.collection("topics").order(by: "controversiality", descending: true).limit(to: 8)
                
                returnSpecificTopics(baseQuery: queryBeingUsed, query: queryBeingUsed) { (newTopics) in
                    
                    self.topics.append(contentsOf: newTopics)
                    self.stopAnimating()
                    
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                    }
                }
                
                searchTitle.text = "Controversial"
                sortingBy = .controversial
            }
            
        case "recent":
            if sortingBy != .recent{
                
                queryBeingUsed = vars.db.collection("topics").order(by: "timeCreated", descending: true).limit(to: 8)
                
                returnSpecificTopics(baseQuery: queryBeingUsed,query: queryBeingUsed) { (newTopics) in
                    
                    self.topics.append(contentsOf: newTopics)
                    self.stopAnimating()
                    
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                    }
                }
                
                searchTitle.text = "Recent"
                sortingBy = .recent
            }
            
        case "mainly against":
            if sortingBy != .mainlyAgainst{
                
                queryBeingUsed = vars.db.collection("topics").order(by: "usersRegisteredAgainst", descending: true).limit(to: 8)
                
                returnSpecificTopics(baseQuery: queryBeingUsed, query: queryBeingUsed) { (newTopics) in
                    
                    self.topics.append(contentsOf: newTopics)
                    self.stopAnimating()
                    
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                    }
                }
                
                searchTitle.text = "Mainly Against"
                sortingBy = .mainlyAgainst
            }
            
        case "mainly for":
            if sortingBy != .mainlyFor{
                queryBeingUsed = vars.db.collection("topics").order(by: "usersRegisteredFor", descending: true).limit(to: 8)
                returnSpecificTopics(baseQuery: queryBeingUsed, query: queryBeingUsed) { (newTopics) in
                    self.topics.append(contentsOf: newTopics)
                    self.stopAnimating()
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                    }
                }
                
                searchTitle.text = "Mainly For"
                sortingBy = .mainlyFor
            }
            
        default:
            print("slide up returned uknown sort value")
            break
        }
    }
    
    @IBAction func byCategoryTapped(_ sender: Any) {
        self.searchBar.endEditing(true)
        

       
    }
    
    
    @IBAction func changeCellSizes(_ sender: Any) {
        self.searchBar.endEditing(true)
        print("value of zoomed out: ", zoomedOut)
        if !zoomedOut{
            print("zooming out")
            zoomedOut = true
            animateCollectionChanges()
        }
        else{
            print("zooming in")
            zoomedOut = false
            animateCollectionChanges()
        }
    }
    
    @IBAction func backToTop(_ sender: Any) {
        self.searchBar.endEditing(true)
        CollectionViewFuncs.goToTop(collectionView: collectionView) {
            self.backToTop.isHidden = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if canLoadMore && collectionView.contentOffset.y >= (collectionView.contentSize.height - collectionView.frame.size.height) {
            
            canLoadMore = false
            startAnimating(message: "", type: NVActivityIndicatorType(rawValue: 32))
            if searchTitle.text != "Searched Topics"{
                returnSpecificTopics(baseQuery: queryBeingUsed, query: queryBeingUsed.start(afterDocument: lastDocument)) { (newTopics) in
                    self.topics.append(contentsOf: newTopics)
                    self.stopAnimating()
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                        
                    }
                    self.canLoadMore = true
                }
            }
            else{
                getSearchedTopics { (topics) in
                    self.stopAnimating()
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                        
                    }
                    sleep(1)
                    self.canLoadMore = true
                }
            }
        }
        
        if scrollView.contentOffset.y > 15 {
            backToTop.isHidden = false
        }
        else{
            backToTop.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailView" {
            let destVC = segue.destination as! ChooseTopicsVC
            destVC.topic = sender as! Topic
        }
        
        if segue.identifier == "toInviteFriend"{
            let destVC = segue.destination as! InviteFriendsTopicChooseViewController
            destVC.invitingThisUser = invitingThisUser as! Opponent
            destVC.topic = sender as! Topic
        }
    }
    
    
    func animateCollectionChanges(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.collectionView.alpha = 0
            }, completion: { (nil) in
                self.collectionView.reloadData()
                UIView.animate(withDuration: 0.25, animations: {
                    self.collectionView.alpha = 1
                    self.collectionView.backgroundView?.alpha = 1
                })
            })
        }
    }
}



// Table view extension

extension TopicsCV: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    // Table view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let topic = topics[indexPath.item]
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath as IndexPath) as! TopicsCollectionViewCell
        
        //cell setup - change some stuff if viewing differently
        cell.setTopic(topicLayout: topic)
        
        //get rid of everything except topic title if zoomed out
        if zoomedOut{
            cell.bottomInfo.isHidden = true
            cell.bottomInfoConstraint.isActive = false
        }
        else{
            cell.bottomInfo.isHidden = false
            cell.bottomInfoConstraint.isActive = true
        }
        
        cell.topicName.wrapCellLabelText(cell: cell, labelProportionOfCellWidth: topicTitleWidthAsProportionOfCellWidth, maximumStoryboardFont: 28)
        
        //cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar.endEditing(true)
        
        let topicSelected = topics[indexPath.item]
        print(topicSelected.topicTitle)
        if invitingThisUser != nil {
            performSegue(withIdentifier: "toInviteFriend", sender: topicSelected)
        }
        else{
            performSegue(withIdentifier: "toDetailView", sender: topicSelected)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = (collectionView.frame.height * 0.45)
        var width: CGFloat!
        
        
        if zoomedOut{
            print("changing cell size (zoomed out)")
            width = (collectionView.frame.width * 0.4655)
        }
        else{
            width = (collectionView.frame.width * 0.95)
        }
        //collectionView.setNeedsLayout()
        //collectionView.layoutIfNeeded()
        return  CGSize(width: width, height: height)
    }
    
    @objc func changeCollectionView(sender: UIPinchGestureRecognizer){
        print(sender.velocity)
        print(zoomedOut)
        if sender.velocity < -1.5 {
            if !zoomedOut{
                zoomedOut = true
                DispatchQueue.main.async {
                    
                    self.collectionView.reloadData()
                }
            }
        }
        if sender.velocity > 1.5{
            if zoomedOut{
                zoomedOut = false
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}










