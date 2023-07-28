//
//  ArgumentsViewController.swift
//  Wrangler
//
//  Created by LucaSarif on 24/06/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
//import NVActivityIndicatorView
//cornerradius /frame 2
// uu can tel when message has been sent wen the fnction completes
class ArgumentsViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: CustomCV!
    @IBOutlet weak var toTop: UIButton!
    
    var arguments: [Argument] = []
    let query: Query = Database.db.collection("arguments").whereField("uidsForQuerying.\(User.details.uid)", isGreaterThan: 0).whereField("archived", isEqualTo: false)
    var listener: ListenerRegistration!
    //collection view
    var subtitleText: String = "Recent"
    var lastDocument: DocumentSnapshot!
    var lastQuery: Query!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    collectionView.delegate = self
    collectionView.dataSource = self
        
    listener = query.addSnapshotListener { (snapshot, err) in
        
            if let err = err {
                Alert.errorAlert(error: err.localizedDescription)
                return
            }
            if let snapshot = snapshot{
                var tempArgs: [Argument] = []
                
                snapshot.documentChanges.forEach({ (change) in
                    
                    switch change.type {
                    case .added:
                        let argument = ArgumentFunctions.createArgument(argument: change.document)
                        tempArgs.append(argument)
                        
                        if tempArgs.count == snapshot.documentChanges.count {
                            self.lastDocument = snapshot.documents.last
                            
                               /* DispatchQueue.main.async {
                                    self.collectionView?.performBatchUpdates({
                                        let startOfNewElements = 0
                                        self.arguments.append(contentsOf: tempArgs)
                                        let endOfNewElements = tempArgs.count - 1
                                        
                                        let indexPaths = Array(startOfNewElements...endOfNewElements).map { IndexPath(item: $0, section: 1) }
                                        self.collectionView.insertItems(at: indexPaths)
                                    }, completion: nil)
                                }*/
                            
                         
                                self.collectionView?.performBatchUpdates({
                                    tempArgs = tempArgs.reversed()
                                    self.arguments.insert(contentsOf: tempArgs, at: 0)
                                   print("tempArgs: ", tempArgs)

                                    let indexPaths = Array(0...tempArgs.count-1).map { IndexPath(item: $0, section: 1) }
                                    self.collectionView.insertItems(at: indexPaths)
                                }, completion: nil)
                            
                            
                            return
                        }
                    default:
                        return
                    }
                })
            }
        }
        
        
        /*
        returnSpecificArguments(query: queries["recent"]!) { (newArguments) in
            self.arguments.append(contentsOf: newArguments)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.topItem?.title = "Arguments"
        self.tabBarController?.navigationItem.hidesBackButton = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    func returnSpecificArguments(completion: @escaping(_ arguments: [Argument]) -> Void){
        
        var newArguments: [Argument] = []
        var editedQuery: Query = query
            
        if let startingAtDoc = lastDocument{
            editedQuery = query.start(afterDocument: startingAtDoc)
        }
            
            Database.returnDocumentsQuery(query: editedQuery) { (documents, err) in
     
                if let err = err {
                    Alert.errorAlert(error: err)
                    return
                }
                if let documents = documents{
                    //for pagination
                    self.lastDocument = documents.last
                    
                    for document in documents{
                        
                        let argument = ArgumentFunctions.createArgument(argument: document)
                        newArguments.append(argument)
                        
                    }
                    completion(newArguments)
                    return
                }
                else{
                    //if no  document have been returned at all for query
                    if self.lastDocument == nil{
                        completion([])
                        return
                    }
                    else{
                        //no more documents
                        print("no more documents")
                    }
                    return
                }
            }
        
    }
    
    lazy var slideUpMenu: SlideUpCV = {
        let menu = SlideUpCV()
        return menu
    }()
    
  /*  @objc func showSlideUpOptions() {
        let menuOptions: [menuOption] = slideUpMenu.createMenuOptions(optionNames: queryNames)
        
        slideUpMenu.slideUp(options: menuOptions)
    }
    
    
    @objc func fetchSortingBy(){
        
        guard let valueFromSlideUp = slideUpMenu.valueFromSlideUp?.lowercased() else { return }
        subtitleText = valueFromSlideUp.capitalized
        collectionView.reloadSections([0])
        
        guard let query = queries[valueFromSlideUp] else {
            print("query for key \(valueFromSlideUp) does not exist in dictionary")
            return
        }
        guard query != lastQuery else {
            print("query is equal to the last query queried")
            return
        }
        
        returnSpecificArguments(query: query) { (newArguments) in
            
            self.arguments = newArguments
            
            print("arguments array: ", self.arguments)
            
            DispatchQueue.main.async{
                print("reloading section 1")
                self.collectionView.reloadSections([1])
            }
        }
        
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == SegueConstants.messagingSegue{
            let destVC: MessagingViewController = segue.destination as! MessagingViewController
            destVC.argumentInfo = sender as! Argument
            destVC.firstTimeRunning = true
        }
    }
}

extension ArgumentsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else{
            return arguments.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "titleCell", for: indexPath as IndexPath) as! TitleCVC
            cell.title.text = "Arguments"
           // cell.subtitle.text = subtitleText
           // cell.button.addTarget(self, action: #selector(showSlideUpOptions), for: .touchUpInside)
            cell.button.tintColor = UIColor.white
            cell.secondaryButton.tintColor = UIColor.white
            return cell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "argumentCell", for: indexPath as IndexPath) as! ArgumentCollectionViewCell
            cell.setArgumentCell(argument: arguments[indexPath.item])
            
            return cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{
            //searchbar height is 44 + 10 up from bottom
            return CGSize(width: collectionView.frame.width - 20, height: CellConstants.cellHeightTitle)
        }
        else{
            return CGSize(width: collectionView.frame.width * CellConstants.cellToViewProportionWidth, height: CellConstants.cellHeightLarge)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueConstants.messagingSegue, sender: arguments[indexPath.item])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2.5, left: 1.0, bottom: 0, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        
    /*   if indexPath.row + 5 == arguments.count{
            returnSpecificArguments() { (newArguments) in
                if !newArguments.isEmpty{
                    self.collectionView?.performBatchUpdates({
                        let startOfNewElements = self.arguments.count
                        self.arguments.append(contentsOf: newArguments)
                        let endOfNewElements = self.arguments.count - 1
                        
                        let indexPaths = Array(startOfNewElements...endOfNewElements).map { IndexPath(item: $0, section: 1) }
                        collectionView.insertItems(at: indexPaths)
                    }, completion: nil)
                    
                }
            }
        }*/
    }
    
    func button(onCell: TopicCVC, buttonType: TopicCVCButtonStatus) {
        print("topic name: ", onCell.topicTitle)
        print("button type: ", buttonType)
    }
}
