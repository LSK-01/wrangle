//
//  PublicArgumentsCV.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 29/09/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import UIKit
import Firebase
//import NVActivityIndicatorView

class PublicArgumentsCV: UIViewController, VoteCVCUpdateDelegate {
    
    enum SortingBy: String{
        case topAllTime = "top of all time"
        case new = "new"
    }
    
    @IBOutlet weak var collectionView: CustomCV!
    
    var pubArguments: [PublicArgument] = []
    var opponentImageUrl: String?
    var sortingBy: SortingBy?
    
    var subtitleText: String = "New"

    var query: Query!
    var stockQuery: Query = Database.db.collection("arguments").whereField("isPublic", isEqualTo: true).whereField("archived", isEqualTo: false)
    var lastQuery: Query!
    
    var listener: ListenerRegistration!
    
    let queries: [String:Query] = [
        
        "top of all time": Database.db.collection("arguments").whereField("isPublic", isEqualTo: true).order(by: "totalUpvotes", descending: false),
        "new": Database.db.collection("arguments").whereField("isPublic", isEqualTo: true).order(by: "goingPublicAt", descending: false)
        
    ]
    
    lazy var queryValues = Array(queries.values)
    lazy var queryNames = Array(queries.keys)
    
    var lastDocument: DocumentSnapshot!
    
    var lastIndexSelected: Int!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let lastIndex = lastIndexSelected{
            collectionView.reloadItems(at: [IndexPath(row: lastIndexSelected, section: 1)])
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchSortingBy), name: .slideUpMenu, object: nil)
        
        navigationController?.navigationBar.topItem?.title = User.details.username
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .slideUpMenu, object: nil)
        
    }
    
    func updatePubArgument(pubArg: PublicArgument) {
        
        pubArguments[lastIndexSelected] = pubArg
        
        Database.updateDocumentErrorHandling(path: "arguments/\(pubArguments[lastIndexSelected].argumentId)", data: [pubArg.thisUserSide.rawValue : FieldValue.arrayUnion([User.details.uid])]) { (err) in
            if let err = err{
                print(err)
            }
            self.navigationController?.popViewController(animated: true)
        }
        collectionView.reloadItems(at: [IndexPath(row: lastIndexSelected, section: 1)])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        fetchPublicArguments(query: queries["new"]!) { (newArgs) in
//            self.arguments.append(contentsOf: newArgs)
//
//            DispatchQueue.main.async {
//                self.collectionView.reloadSections([1])
//            }
//        }
        
        if listener == nil {
            listener = queries["new"]!.addSnapshotListener { (snapshot, err) in
                
                    if let err = err {
                        Alert.errorAlert(error: err.localizedDescription)
                        return
                    }
                    if let snapshot = snapshot{
                        var tempArgs: [PublicArgument] = []
                        
                        snapshot.documentChanges.forEach({ (change) in
                            
                            switch change.type {
                            
                            case .added:
                                let argument = PublicArgumentFunctions.createPublicArg(argument: change.document)


                                tempArgs.append(argument)
                                
                                if tempArgs.count == snapshot.documentChanges.count {

                                        self.collectionView?.performBatchUpdates({
                                            tempArgs = tempArgs.reversed()
                                            self.pubArguments.insert(contentsOf: tempArgs, at: 0)
                       
                                            let indexPaths = Array(0...tempArgs.count-1).map { IndexPath(item: $0, section: 1) }
                                            self.collectionView.insertItems(at: indexPaths)
                                        }, completion: nil)
                                    
                                    return
                                }
                            case .modified:
                                let argument = PublicArgumentFunctions.createPublicArg(argument: change.document)
                                
                                if let winner = argument.winner{
                                    let index = self.pubArguments.firstIndex(where: {$0.argumentId == argument.argumentId})
                                    if let index = index{
                                        self.pubArguments.remove(at: index)
                                        DispatchQueue.main.async {
                                            self.collectionView.reloadItems(at: [IndexPath(item: index, section: 1)])
                                        }
                                    }
                                }
                                
                            default:
                                return
                            }
                        })
                    }
                }
        }
    }
    
    func fetchPublicArguments(query: Query, completion: @escaping(_ arguments: [PublicArgument]) -> Void){
        
        var editedQuery: Query = query
        
        if lastQuery == query {
            guard let document = lastDocument else {
                return
                
            }
            editedQuery = query.start(afterDocument: document)
        }
        else{
            editedQuery = query
        }
        
        
        PublicArgumentFunctions.fetchPublicArguments(query: editedQuery.limit(to: 8)) { (newArguments, lastDocument, err) in
            
            if let err = err {
                Alert.errorAlert(error: err)
                return
            }
            
            if let newArguments = newArguments{
                self.lastQuery = query
                
                self.lastDocument = lastDocument
                completion(newArguments)
                return
                
            }
            else{
                
                //Alert.statusLineAlert(message: "No results were returned!")
                completion([])
                return
                
            }
        }//fetch norm docs
    }
    
    lazy var slideUpMenu: SlideUpCV = {
        let menu = SlideUpCV()
        return menu
    }()
    
    @IBAction func showSlideUpOptions(_ sender: Any) {
        //do icons
        let menuOptions: [menuOption] = slideUpMenu.createMenuOptions(optionNames: queryNames)
        
        slideUpMenu.slideUp(options: menuOptions)
    }
    
    //recieve what has been tapped from slide up CV
    var valueFromSlideUp: String = "new"{
        didSet{
            fetchSortingBy()
        }
    }
    
    @objc func fetchSortingBy(){
        
        guard let valueFromSlideUp: String = slideUpMenu.valueFromSlideUp?.lowercased() else { return }
        subtitleText = valueFromSlideUp.capitalized
        
        guard let query = queries[valueFromSlideUp] else {
            print("query for key \(valueFromSlideUp) does not exist in dictionary")
            return
        }
        guard query != lastQuery else {
            print("query is equal to the last query queried")
            return
        }
        
        fetchPublicArguments(query: query) { (newArgs) in
            self.pubArguments = newArgs
            
            DispatchQueue.main.async{
                self.collectionView.reloadSections([0, 1])
            }
        }
    }
}



extension PublicArgumentsCV: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else if section == 1{
            return pubArguments.count
        }
        else if !pubArguments.isEmpty{
            return 0
        }
        else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "titleCell", for: indexPath as IndexPath) as! TitleCVC
            cell.title.text = "Vote"
            cell.backgroundColor = UIColor.clear
            cell.subtitle.text = subtitleText
            cell.button.addTarget(self, action: #selector(showSlideUpOptions), for: .touchUpInside)
            cell.button.tintColor = UIColor.white
            //cell.secondaryButton.tintColor = UIColor.white
            return cell
        }
        else if indexPath.section == 1{
            
            let argument = pubArguments[indexPath.row]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "publicArgCell", for: indexPath) as! PublicArgumentCVC
            
            cell.setPublicArgumentCell(argument: argument)
            
            return cell
            
        }
        else {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "titleCellInfo", for: indexPath as IndexPath) as! TitleCVC
        cell.title.text = "There are no public arguments to vote on yet"
            cell.button.isHidden = true
        cell.title.font = UIFont.systemFont(ofSize: DesignConstants.defaultFontSize, weight: .semibold)
        cell.layer.addBorder(edge: .all, color: DesignConstants.accentBlue, thickness: 2)
                   cell.subtitle.font = UIFont.systemFont(ofSize: DesignConstants.smallFontSize, weight: .regular)
        cell.subtitle.text = "Arguments go public around 3 hours after a user matches"

        return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{
            return CGSize(width: collectionView.frame.width - 20, height: CellConstants.cellHeightTitle)
        }
        else if indexPath.section == 1{
            return CGSize(width: collectionView.frame.width * CellConstants.cellToViewProportionWidth, height: CellConstants.cellHeightLarge)
        }
        else {
            let width: CGFloat = collectionView.frame.width * CellConstants.cellToViewProportionWidth
            return CGSize(width: width, height: CellConstants.cellHeightDefault + 35)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
//        if indexPath.row + 5 == pubArguments.count{
//
//            fetchPublicArguments(query: lastQuery) { (newArgs) in
//
//                if !newArgs.isEmpty{
//
//                    self.collectionView?.performBatchUpdates({
//                        let startOfNewElements = self.pubArguments.count
//                        self.pubArguments.append(contentsOf: newArgs)
//                        let endOfNewElements = self.pubArguments.count - 1
//
//                        let indexPaths = Array(startOfNewElements...endOfNewElements).map { IndexPath(item: $0, section: 1) }
//                        collectionView.insertItems(at: indexPaths)
//                    }, completion: nil)
//
//                }
//            }
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1{
            performSegue(withIdentifier: "toUpvotingView", sender: indexPath.row)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpvotingView"{
            let destVC = segue.destination as! PublicArgumentsDetailVC
            
            let index = sender as! Int
            destVC.argumentInfo = pubArguments[index]
            lastIndexSelected = index
            destVC.parentVC = self
        }
    }
}
