//
//  TopicsCV.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 01/07/2019.
//  Copyright © 2019 Luca Sarif-Kattan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
//import NVActivityIndicatorView

class TopicsCV: UIViewController, AddUserToTopicDelegate, TitleCVCSearchbarDelegate {
    
    func searchTopics(searchTerm: String) {
        
        subtitleText = "Search"
        searchQueries = []
        queryIndex = 0
        freeToRepeat = false
        lastQuery = nil
        
        collectionView.reloadSections([0])
        
        let terms = searchTerm.formattedString(spaces: true)
        if terms.formattedString(spaces: false) == "" { return }
        let keywordsToSearch: [String] = terms.components(separatedBy: " ")
        print(keywordsToSearch)
        for keyword in keywordsToSearch{
            searchQueries.append(Database.db.collection("topics").whereField("keywords", arrayContains: keyword).limit(to: limitingDocumentsTo))
        }
        topics = []
        //  collectionView.reloadSections([1])
        getSearchedTopics()
        
    }
    
    func getSearchedTopics(){
        
        returnSpecificTopics(query: searchQueries[queryIndex]) { (newTopics) in
            
            self.topics.append(contentsOf: newTopics)
            print(newTopics.count)
            
            
            
            if self.topics.count == self.limitingDocumentsTo || self.queryIndex >= self.searchQueries.count - 1{
                self.collectionView.numberOfItems(inSection: 1)
                self.collectionView.reloadSections([1, 2])
                return
            }
            
            if newTopics.count < self.limitingDocumentsTo{
                //move onto the next query kewyord if we ran out of topics 4 dis kewyord
                self.queryIndex += 1
                self.getSearchedTopics()
                
            }
            
            
        }
    }
    
    func updateTopic(forIndex: Int, topic: Topic) {
        topics[forIndex] = topic
        
        collectionView.reloadItems(at: [IndexPath(row: forIndex, section: 1)])
        
    }
    
    let queries: [String:Query] = [
        
        "majority for": Database.db.collection("topics").order(by: FieldNamesFor.numUsersTotal, descending: true),
        "majority against": Database.db.collection("topics").order(by: FieldNamesAgainst.numUsersTotal, descending: true),
        "recent": Database.db.collection("topics").order(by: "timeCreated", descending: true),
        "controversial": Database.db.collection("topics").order(by: "controversiality", descending: true),
        "your topics": Database.db.collection("topics").whereField("userWhoCreated", isEqualTo: User.details.username)
        
    ]
    
    @IBOutlet weak var collectionView: CustomCV!
    
    //for titleCell
    var subtitleText: String = ""
    
    //querying
    var lastQuery: Query!
    var lastDocument: DocumentSnapshot?
    lazy var queryValues = Array(queries.values)
    lazy var queryNames = Array(queries.keys)
    let limitingDocumentsTo: Int = 10
    //search bar querying
    var queryIndex = 0
    var searchQueries: [Query]!
    var freeToRepeat: Bool = false
    let blackView = UIView()
    let topicInfoImageView = UIImageView()
    var listener: ListenerRegistration!
    
    var topics: [Topic] = []
    //handle adding users to topics when they click the buttons in each cell
    var addUserHandler: AddUserToTopic!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    @objc func dismissMenu(){
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.topicInfoImageView.alpha = 0
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        if User.details.firstTime{
        //        if true{
        //
        //            blackView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))
        //            blackView.frame = view.frame
        //            blackView.alpha = 0
        //
        //            let image = UIImage(named: "googleIcon")
        //            topicInfoImageView.image = image
        //            topicInfoImageView.contentMode = .scaleAspectFit
        //            topicInfoImageView.alpha = 0
        //            topicInfoImageView.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2, width: 100, height: 200)
        //
        //            view.addSubview(blackView)
        //            view.addSubview(topicInfoImageView)
        //
        //            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
        //
        //                self.blackView.alpha = 1
        //                self.topicInfoImageView.alpha = 1
        //
        //            })
        //
        //
        //        }
        //
        
        
        //idk why we need this ...
        
       /* listener = Database.db.collection("arguments").whereField("uidsForQuerying.\(User.details.uid)", isEqualTo: true).addSnapshotListener({ snapshot, err in
            
            //if this runs, user will be neutral so just update topic accordingly
            if let err = err {
                
            }
            if let snapshot = snapshot{
                snapshot.documentChanges.forEach { change in
                    switch change.type{
                    case .modified:
                        let document = change.document
                        let title = document["topicTitle"] as! String
                        
                        let index = self.topics.firstIndex(where: {$0.topicTitle == title})!
                        
                        self.topics.remove(at: index)
                        
                        
                        
                        Database.returnDocument(path: "topics/\(title)") { snapshot, err in
                            
                            if let document = snapshot{
                                let updatedTopic = TopicFunctions.createTopic(topic: document)
                                self.topics.insert(updatedTopic, at: index)
                                DispatchQueue.main.async {
                                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 1)])
                                }
                                
                            }
                        }
                        
                    default:
                        return
                    }
                }
            }
        })*/
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        //setup slidemenu listener
        NotificationCenter.default.addObserver(self, selector: #selector(fetchSortingBy(_:)), name: .slideUpMenu, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(topicMatched(notification:)), name: .topicMatch, object: nil)
        
        //handle adding/removing users to topics
        addUserHandler = AddUserToTopic()
        addUserHandler.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        returnSpecificTopics(query: queries["controversial"]!) { (newTopics) in
            self.topics = newTopics
            DispatchQueue.main.async{
                self.collectionView.reloadSections([1])
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    @objc func createTopicTapped(_ sender: Any){
        performSegue(withIdentifier: "toCreateTopic", sender: self)
    }
    
    func returnSpecificTopics(query: Query, completion: @escaping([Topic]) -> Void){
        
        var newTopics: [Topic] = []
        var editedQuery: Query!
        
        if lastQuery == query {
            guard let document = lastDocument else { return }
            editedQuery = query.start(afterDocument: document)
        }
        else{
            editedQuery = query
            lastDocument = nil
            if subtitleText != "Search"{
                topics = []
            }
            
        }
        
        Database.returnDocumentsQuery(query: editedQuery) { (documents, err) in
            if let err = err{
                
                Alert.errorAlert(error: err)
                return
                
            }
            
            if let documents = documents{
                self.lastQuery = query
                
                //for pagination
                self.lastDocument = documents.last
                
                for document in documents{
                    
                    let topic = TopicFunctions.createTopic(topic: document)
                    newTopics.append(topic)
                    
                }
                completion(newTopics)
                return
            }
            else{
                //if no  document have been returned at all for query
                if self.lastDocument == nil{
                    completion([])
                    return
                }
                else{
                    return
                }
                
            }
        }
    }
    
    lazy var slideUpMenu: SlideUpCV = {
        let menu = SlideUpCV()
        return menu
    }()
    
    @objc func showSlideUpOptions() {
        let menuOptions: [menuOption] = slideUpMenu.createMenuOptions(optionNames: queryNames)
        
        slideUpMenu.slideUp(options: menuOptions)
    }
    
    //ADD BYCATEGORY  SORTING MODE - dont worry about the  user not knowing what topic sthey are in as  we have "pending topics" in arguments so they can roughly gauge with the arguments they are already in and the topics which are pending what is going on
    //or  put backw hat y ou were  going to do in homescreenVc where they acn acces the topic from there tehre was jjust a glitch last time
    @objc func fetchSortingBy(_ notification: Notification){
        
        guard let valueFromSlideUp = slideUpMenu.valueFromSlideUp?.lowercased() else { return }
        subtitleText = valueFromSlideUp.capitalized
        
        guard let query = queries[valueFromSlideUp] else {
            print("query for key \(valueFromSlideUp) does not exist in dictionary")
            return
        }
        guard query != lastQuery else {
            print("query is equal to the last query queried")
            return
        }
        
        returnSpecificTopics(query: query) { (newTopics) in
            
            self.topics = newTopics
            
            DispatchQueue.main.async{
                self.collectionView.reloadData()
            }
        }
    }
    
    let notifHelper = PushNotificationSender()
    
    @objc func topicMatched(notification: Notification){
        if let argument = notification.userInfo?[0] as? Argument{
            if let index = topics.firstIndex(where: {$0.topicTitle == argument.topicTitle}){
                
                
                switch argument.userSide{
                case .isFor:
                    
                    if topics[index].numUsersAgainstTotal == 0{
                        topics[index].numUsersAgainstTotal += 1
                        
                    }
                case .isAgainst:
                    
                    if topics[index].numUsersForTotal == 0{
                        topics[index].numUsersForTotal += 1
                        
                    }
                case .isNeutral:
                    return
                }
                
                Alert.alert(message: "in topic \(topics[index].topicTitle)", title: "Matched!")
                notifHelper.sendPushNotification(to: argument.opponentDeviceToken, title: "You've been matched!", body: "Come start your new argument.")
                
                topics[index].isMatched = true
                
                
                
                collectionView.reloadItems(at: [IndexPath(row: index, section: 1)])
            }
            
        }
    }
}

extension TopicsCV: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else if section == 1{
            return topics.count
        }
        else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "titleCell", for: indexPath as IndexPath) as! TitleCVC
            cell.title.text = "Topics"
            cell.backgroundColor = UIColor.clear
            cell.subtitle.text = subtitleText
            cell.subtitle.isHidden = false
            cell.button.addTarget(self, action: #selector(showSlideUpOptions), for: .touchUpInside)
            cell.button.tintColor = UIColor.white
            cell.secondaryButton.tintColor = UIColor.white
            cell.searchbarDelegate = self
            
            cell.initSearchbar()
            return cell
        }
        else if indexPath.section == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath as IndexPath) as! TopicCVC
            cell.buttonDelegate = addUserHandler
            cell.setTopic(topic: topics[indexPath.item], index: indexPath.item)
            
            cell.matchInfoLabel.isHidden = topics[indexPath.item].userSide == .isNeutral
            
            if topics[indexPath.item].isMatched{
                cell.matchInfoLabel.text = "Matched"
            }
            else{
                cell.matchInfoLabel.text = "Pending Match"
            }
            return cell
            
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "createTopicCell", for: indexPath as IndexPath) as! TitleCVC
            cell.isHidden = true
            cell.button.isUserInteractionEnabled = false
            cell.title.font = UIFont.systemFont(ofSize: DesignConstants.defaultFontSize, weight: .semibold)
            cell.subtitle.font = UIFont.systemFont(ofSize: DesignConstants.smallFontSize, weight: .regular)
            DispatchQueue.main.async {
                cell.button.setImage(UIImage(named: "createTopicIcon"), for: .normal)
                
            }
            
            if !topics.isEmpty || subtitleText == "Your Topics"{
                
                cell.title.text = "Can't find a topic?"
                cell.subtitle.text = "Create your own"
                
                
                
            }
            else if subtitleText == "Search"{
                cell.title.text = "No topics could be found with those keywords"
                cell.subtitle.text = "Create your own"
                
                
            }
            
            if !topics.isEmpty{
                cell.isHidden = false
            }
            return cell
            
            
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 2{
            performSegue(withIdentifier: SegueConstants.toCreateTopic, sender: nil)
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{
            //searchbar height is 44 + 10 up from bottom
            return CGSize(width: collectionView.frame.width - 20, height: CellConstants.cellHeightTitle)
        }
        else if indexPath.section == 1{
            //            var height = CellConstants.cellHeightLarge
            
            var height = CellConstants.cellHeightLarge
            
            
            return CGSize(width: collectionView.frame.width * CellConstants.cellToViewProportionWidth, height: height)
        }
        else{
            let width: CGFloat = collectionView.frame.width * CellConstants.cellToViewProportionWidth
            return CGSize(width: width, height: CellConstants.cellHeightDefault)
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: CellConstants.topPadding, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        if indexPath.row + 5 == topics.count{
            
            if subtitleText == "Search" && self.queryIndex <= self.searchQueries.count - 1{
                returnSpecificTopics(query: searchQueries[queryIndex]) { (newTopics) in
                    
                    self.collectionView?.performBatchUpdates({
                        var startOfNewElements = self.topics.count
                        self.topics.append(contentsOf: newTopics)
                        var endOfNewElements = self.topics.count - 1
                        
                        let indexPaths = Array(startOfNewElements...endOfNewElements).map { IndexPath(item: $0, section: 1) }
                        collectionView.insertItems(at: indexPaths)
                    }, completion: nil)
                    
                    if newTopics.count < self.limitingDocumentsTo{
                        //move onto the next query kewyord ffor if they paginate
                        self.queryIndex += 1
                    }
                }
            }
            else{
                returnSpecificTopics(query: lastQuery) { (newTopics) in
                    self.collectionView?.performBatchUpdates({
                        var startOfNewElements = self.topics.count
                        self.topics.append(contentsOf: newTopics)
                        var endOfNewElements = self.topics.count - 1
                        
                        let indexPaths = Array(startOfNewElements...endOfNewElements).map { IndexPath(item: $0, section: 1) }
                        collectionView.insertItems(at: indexPaths)
                    }, completion: nil)
                }
            }
        }
    }
    
    func button(onCell: TopicCVC, buttonType: TopicCVCButtonStatus) {
        print("topic name: ", onCell.topicTitle)
        print("button type: ", buttonType)
    }
    
}
