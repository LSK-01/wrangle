//
//  HomescreenVC.swift
//
//
//  Created by LucaSarif on 24/12/2017.
//  Copyright © 2017 LucaSarif. All rights reserved.
//

import UIKit
import Firebase
//import NVActivityIndicatorView


class HomescreenVC: UIViewController, UITextViewDelegate, updateUserDetailsDelegate, UITabBarControllerDelegate{
    
    
    func updateImage(newImage: UIImage) {
        DispatchQueue.main.async {
            self.userImage.image = newImage
        }
        
        if let uploadData = newImage.jpegData(compressionQuality: 3.0) {
            
            Database.stdb.child("profile_image/\(User.details.uid)").putData(uploadData, metadata: nil, completion: { (metadata, err) in
                
                
                Database.stdb.child("profile_image/\(User.details.uid)").downloadURL(completion: { (url, err) in
                    
                    if let err = err {
                        Alert.errorAlert(error: err.localizedDescription)
                        self.userImage.image = UIImage(named: "defaultProfileIcon")
                        return
                    }
                    
                    guard let downloadURL = url else {
                        return
                    }
                    let profileImageUrl = downloadURL.absoluteString
                    self.progressHUD.hide()
                    
                    Database.writeToDocument(path: "users/\(User.details.uid)", data: ["profileImageUrl": profileImageUrl], merge: true)
                    User.details.profileImageUrl = profileImageUrl
                })
            })
            
        }
    }
    
    @IBOutlet weak var settings: UIButton!
    @IBOutlet weak var winsTitleLabel: UILabel!
    @IBOutlet weak var argumentsTitleLabel: UILabel!
    //    @IBOutlet weak var wranglesTitleLabel: UILabel!
    //@IBOutlet weak var argumentsTitle: UILabel!
    @IBOutlet weak var argumentsLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    //    @IBOutlet weak var wranglesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImage: ProfileImage!
    @IBOutlet weak var argumentsCV: CustomCV!
    var lastSelectedIndex: Int?
    var firstTimeRunning: Bool = true
    
    var arguments: [Argument] = []
    let query: Query = Database.db.collection("arguments").whereField("uidsForQuerying.\(User.details.uid)", isEqualTo: false)
    var listener: ListenerRegistration!
    let progressHUD = ProgressHUD(text: "Saving Photo")
    
    @objc func switchToTopics(){
        self.tabBarController?.selectedIndex = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
//    @objc func updateArgument(notification: Notification){
//        if let argument = notification.userInfo?[0] as? Argument, let index = lastSelectedIndex{
//            arguments[index].latestMessage = argument.latestMessage
//            argumentsCV.reloadItems(at: [IndexPath(row: index, section: 0)])
//        }
//    }
//    
    var refresher:UIRefreshControl!
    
    @objc func loadData() {
        self.argumentsCV!.refreshControl!.beginRefreshing()
        //code to execute during refresher
        argumentsCV.reloadData()
        
        stopRefresher()
    }
    
    func stopRefresher() {
        self.argumentsCV!.refreshControl!.endRefreshing()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.refresher = UIRefreshControl()
        argumentsCV.refreshControl = refresher
        self.argumentsCV!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.gray
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.argumentsCV!.addSubview(refresher)
        
        argumentsLabel.text = String(arguments.count)
        
        settings.tintColor = DesignConstants.accentBlue
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        //NotificationCenter.default.addObserver(self, selector: #selector(updateArgument(notification:)), name: .argumentUpdate, object: nil)
        
        progressHUD.hide()
        self.view.addSubview(progressHUD)
        //clear all displays -image view etc. etc.
        self.userImage.image = nil
        self.argumentsCV.dataSource = self
        self.argumentsCV.delegate = self
        
        usernameLabel.text = User.details.username
        //usernameLabel.fitFontToLabelHeight(maxSize: 35)
        if usernameLabel.font.pointSize < 30 {
            usernameLabel.font = UIFont.systemFont(ofSize: DesignConstants.largeFontSize, weight: .bold)
        }
        
        
        if listener == nil {
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
                            DispatchQueue.main.async {
                                self.argumentsLabel.text = String(self.arguments.count)
                            }
                            
                            let argument = ArgumentFunctions.createArgument(argument: change.document)
                            
                            if argument.matcher != User.details.uid && (!self.firstTimeRunning || self.arguments.isEmpty){
                                NotificationCenter.default.post(name: .topicMatch, object: nil, userInfo: [0:argument])
                            }
                            
                            tempArgs.append(argument)
                            
                            if tempArgs.count == snapshot.documentChanges.count {
                                
                       
                                    tempArgs = tempArgs.reversed()
                                    self.arguments.insert(contentsOf: tempArgs, at: 0)
                                    
                                    let indexPaths = Array(0...tempArgs.count-1).map { IndexPath(item: $0, section: 0) }
                                    self.argumentsCV.reloadData()
                     
                                self.firstTimeRunning = false
                                
                                
                                return
                            }
                            //                            case .modified:
                            //                                let argument = ArgumentFunctions.createArgument(argument: change.document)
                            //                                if argument.archived{
                            //                                    let index = self.arguments.firstIndex(where: {$0.argumentId == argument.argumentId})
                            //                                    if let archivedIndex = index{
                            //                                        self.arguments.remove(at: archivedIndex)
                            //                                        self.argumentsCV.reloadData()
                            //                                    }
                            //                                }
                            
                        default:
                            return
                        }
                    })
                }
            }
        }
        //listener for if user matches whilst in app
        
        
        
        Queues.fastQueue.sync {
            
            if User.details.firstTime{
                let pushManager = PushNotificationManager()
                pushManager.registerForPushNotifications()
                
                
                let data: [String: Any] = [
                    "username": User.details.username,
                    "usernameSearchable": User.details.username.formattedString(spaces: false),
                    "email": User.details.email,
                    "wrangles": 0,
                    "wins": 0                                     ]
                Database.writeToDocumentErrorHandling(path: "users/\(User.details.uid)", data: data, merge: false, completion: { (err) in
                    if let err = err {
                        self.navigationController?.popViewController(animated: true)
                        self.progressHUD.hide()
                        Alert.errorAlert(error: err)
                        return
                    }
                    if User.details.firstTime{
                        let pushManager = PushNotificationManager()
                        pushManager.registerForPushNotifications()
                    }
                })
            }
            else{
                Database.returnDocument(path: "users/\(User.details.uid)", completion: { (document, err) in
                    if let err = err{
                        self.navigationController?.popViewController(animated: true)
                        Alert.errorAlert(error: err)
                        return
                    }
                    
                    if let document = document{
                        if let wrangles = document["wrangles"]{
                            User.details.wrangles = wrangles as! Int
                        }
                        
                        if let wins = document["wins"]{
                            User.details.wins = wins as! Int
                        }
                        if let topics = document["topics"]{
                            User.details.topics = topics as! Int
                        }
                        
                        if let token = document["deviceToken"]{
                            User.details.deviceToken = token as! String
                        }
                        
                        if let imageUrl = document["profileImageUrl"]{
                            //may not need profileImageUrl value if using delegate for settings
                            let url = imageUrl as! String
                            
                            self.userImage.getCachedImage(urlString: url, completion: { (image, err) in
                                if let err = err {
                                    return
                                }
                                if let image = image{
                                    
                                    DispatchQueue.main.async {
                                        UIView.transition(with: self.userImage, duration: 0.1, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                                            self.userImage.image = image
                                        }, completion: nil)
                                    }
                                }
                            })
                        }
                    }
                })
            }

        }
        
        argumentsLabel.textColor = DesignConstants.accentBlue
        //        argumentsLabel.fitFontToLabelHeight(maxSize: 100, ofType: .semibold)
        //        argumentsTitleLabel.fitFontToLabelHeight(maxSize: 15, ofType: .medium)
        argumentsTitleLabel.textColor = DesignConstants.accentBlue
        
        winsLabel.text = "\(User.details.wins)"
        winsLabel.textColor = DesignConstants.accentBlue
        //        winsLabel.font = argumentsLabel.font
        //        winsTitleLabel.font = argumentsTitleLabel.font
        winsTitleLabel.textColor = DesignConstants.accentBlue
        
        //        wranglesLabel.text = "\(User.details.wrangles)"
        //        wranglesLabel.font = argumentsLabel.font
        //        wranglesTitleLabel.font = argumentsTitleLabel.font
        //        wranglesTitleLabel.textColor = DesignConstants.accentBlue
        
        usernameLabel.textColor = DesignConstants.accentBlue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueConstants.settingsSegue{
            let destVC: SettingsViewController = segue.destination as! SettingsViewController
            destVC.delegate = self
            destVC.imageFromHomescreen = userImage.image
        }
        
        if segue.identifier == SegueConstants.messagingSegue{
            let destVC: MessagingViewController = segue.destination as! MessagingViewController
            destVC.argumentInfo = sender as! Argument
            destVC.firstTimeRunning = true
        }
    }
}

extension HomescreenVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return arguments.count
        }
        else if !arguments.isEmpty{
            return 0
        }
        else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 && !arguments[indexPath.item].archived{
            
            if !arguments[indexPath.item].isPublic{
                lastSelectedIndex = indexPath.row
                performSegue(withIdentifier: SegueConstants.messagingSegue, sender: arguments[indexPath.item])
            }
            
        }
        else{
            switchToTopics()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0{
            let argumentCell = collectionView.dequeueReusableCell(withReuseIdentifier: "argumentCell", for: indexPath as IndexPath) as! ArgumentCollectionViewCell
            argumentCell.setArgumentCell(argument: arguments[indexPath.item])
            return argumentCell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "titleCell", for: indexPath as IndexPath) as! TitleCVC
            cell.title.text = "Join topics"
            cell.button.isUserInteractionEnabled = false
            cell.title.font = UIFont.systemFont(ofSize: DesignConstants.defaultFontSize, weight: .semibold)
            cell.layer.addBorder(edge: .all, color: DesignConstants.accentBlue, thickness: 10)
            cell.subtitle.font = UIFont.systemFont(ofSize: DesignConstants.smallFontSize, weight: .regular)
            cell.subtitle.text = "Find more people to argue with"
            cell.button.imageView?.contentMode = . scaleAspectFit
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{
            let width: CGFloat = collectionView.frame.width * CellConstants.cellToViewProportionWidth
            let height: CGFloat = CellConstants.cellHeightDefault + 30
            return CGSize(width: width, height: height)
        }
        else{
            let width: CGFloat = collectionView.frame.width * CellConstants.cellToViewProportionWidth
            return CGSize(width: width, height: CellConstants.cellHeightDefault - 20)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
        } else {
            return UIEdgeInsets(top: CellConstants.topPadding, left: 0, bottom: 0, right: 0)
        }
    }
    
    
}



