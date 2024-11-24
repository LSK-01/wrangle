//
//  MessagingViewController.swift
//  Wrangler
//
//  Created by LucaSarif on 24/06/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//
//this is disgustingly innefficient i want to throw up looking at this file kmn
// NEED SOME SORT OF WAY TO CANCEL/RETRY SENDING A "FAILED MESSAGE" - WHAT CONSTITUTES AS A FAILED MESSAGES THOUGH?
//ADD TIME BEFORE ENTERING PUB ARGS TO THEACTUAL ARGUMENT CELL
//MAYBE SPLIT THE MESSAGES INTO ONE COLLECTION OF OPPONENT MESSAGES ONE COLLECITON OF USER MESSAGES
//THEN WE JUST NEED TO LISTEN TO THAT AND SAVE A CALL EVERY TIME A MESSAGE IS SENT FROM OUR SIDE - CUS RIGHT NOW NO MATTER WHOSE ADDED THE DOCUMENT THE LISTENER RUNS
import UIKit
import Firebase
//import NVActivityIndicatorView
import SwiftMessages

class MessagingViewController: UIViewController, UITextViewDelegate, ZoomImageDelegate, UIGestureRecognizerDelegate {
    
    
    @IBAction func popMessages(_ sender: Any) {
        
        let batch = Firestore.firestore().batch()
        
        for i in 1...45 {
            sleep(UInt32(1))
            let messageId = Messages.randomString(length: 10)
            
            let data: [String: Any] = [
                "message": String(i),
                "sentBy": User.details.uid,
                "recievedBy": argumentInfo.opponentUid,
                "timeSent": Date.getCurrentMillis(),
                "messageType": "text",
                "status": "sending",
                "id": messageId
            ]
            
            let document = Firestore.firestore().collection("arguments/\(argumentInfo.argumentId)/messages").document(messageId)
            
            batch.setData(data, forDocument: document)
        }
        batch.commit()
        
    }
    
    
    func zoomStartImage(startImage: UIImageView){
        
        //get frame of start image
        startingFrame = startImage.superview?.convert(startImage.frame, to: nil)
        
        let zoomingImage = UIImageView(frame: startingFrame!)
        zoomingImage.backgroundColor = UIColor.gray
        zoomingImage.image = startImage.image
        zoomingImage.isUserInteractionEnabled = true
        zoomingImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomImageTapped(sender:))))
        
        if let keywindow = UIApplication.shared.keyWindow{
            blackBackground = UIView(frame: keywindow.frame)
            blackBackground?.backgroundColor = UIColor.black
            blackBackground?.alpha = 0
            
            keywindow.addSubview(blackBackground!)
            keywindow.addSubview(zoomingImage)
            
            //animate zoomingImage to become larger
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                //want to fill up full width of view whilst keeping aspect ratio
                let height = self.startingFrame!.height / self.startingFrame!.width * keywindow.frame.width
                zoomingImage.frame = CGRect(x: 0, y: 0, width: keywindow.frame.width, height: height)
                zoomingImage.center = keywindow.center
                
                self.blackBackground?.alpha = 1
                
            }, completion: nil)
            
        }
    }
    
    
    var argumentInfo: Argument!
    //we only need docsnaps for the doc id but cant we just sub that into argumentInfo?
    var messages: [Message] = []
    var oldestDocument: DocumentSnapshot!
    var listener: ListenerRegistration!
    var firstTimeRunning: Bool = true
    //sending images
    let picker = UIImagePickerController()
    var isPickingImage: Bool = false
    let fixedWidthFloat: Float = 200
    let fixedWidth: CGFloat = 200
    //zooming images
    var startingFrame: CGRect?
    var blackBackground: UIView?
    
    var showHasSeen: Bool = false
    
    @IBOutlet weak var opponentImageView: ProfileImage!
    @IBOutlet weak var messagingStackView: UIStackView!
    @IBOutlet weak var arguingWith: UILabel!
    @IBOutlet weak var topicTitle: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var timeTillEnding: UILabel!
    @IBOutlet weak var topDesign: UIImageView!
    
    var isScrolling: Bool = true
    
    //in case some fucking autist decides to type more than 50000 characters
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 50000
    }
    
//override func viewDidDisappear(_ animated: Bool) {
//
//    if let text = messages.last?.text{
//
//        if text == ""{
//            argumentInfo.latestMessage = "Image"
//        }
//        else{
//            argumentInfo.latestMessage = text
//        }
//
//        NotificationCenter.default.post(name: .argumentUpdate, object: nil, userInfo: [0: argumentInfo!])
//
//        Database.writeToDocument(path: "arguments/\(argumentInfo.argumentId)", data: ["latestMessage": argumentInfo.latestMessage], merge: true)
//    }
//
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        if let url = argumentInfo.opponentProfileImageUrl{
            opponentImageView.getCachedImage(urlString: url) { (image, error) in
                if let image = image{
                    DispatchQueue.main.async {
                        self.opponentImageView.image = image
                    }
                }
            }
        }
        
        messageTextView.isScrollEnabled = false
        
        topicTitle.font = UIFont.systemFont(ofSize: DesignConstants.defaultFontSize, weight: .semibold)
        arguingWith.font = UIFont.systemFont(ofSize: DesignConstants.smallFontSize, weight: .semibold)
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        if argumentInfo.goingPublicAt < Date.getCurrentSeconds(){
            timeTillEnding.text = "This argument is finished"
        }
        else{
            timeTillEnding.text = "This argument finishes in \(Int(argumentInfo.goingPublicAt / 60 - Date.getCurrentMinutes())) minutes"
        }
        
        
        let initialSize: CGSize = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let frameOfSingleLineMessage = NSString(string: ".").boundingRect(with: initialSize, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
        let heightOfSingleLineMessage = frameOfSingleLineMessage.height + 20
        //messagingViewHeight.constant = heightOfSingleLineMessage > 35 ? heightOfSingleLineMessage : 35
        
        messageTextView.delegate = self
        //messagingUsername.text = argumentInfo.username
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MessageCVC.self, forCellWithReuseIdentifier: "messageCell")
        picker.delegate = self
        
        //    textViewBottomConstraint.constant = 5
        
        messageTextView.clipsToBounds = true
        messageTextView.layer.cornerRadius = CellConstants.textBubbleViewLineHeight/2
        messagingStackView.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        messagingStackView.backgroundColor = UIColor.clear
        
        //so we can scroll to bottom when keyboard shown and push up textview
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardToggle(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardToggle(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        view.backgroundColor = UIColor.white
        collectionView.backgroundColor = UIColor.clear
        
        
        topicTitle.text = argumentInfo.topicTitle
        arguingWith.text = "Arguing with: \(argumentInfo.opponentUsername)"
        
        
         if argumentInfo.isPublic{
         messageTextView.isSelectable = false
         sendButton.isEnabled = false
         imageButton.isEnabled = false
         }
        
        if argumentInfo.userSide == .isFor{
            messageTextView.backgroundColor = DesignConstants.mainBlue
            imageButton.tintColor = DesignConstants.mainBlue
            sendButton.tintColor = DesignConstants.mainBlue
            topDesign.image = UIImage(named: "blueTopDesignRect")?.alpha(1)
        }
        else{
            messageTextView.backgroundColor = DesignConstants.accentOrange
            imageButton.tintColor = DesignConstants.accentOrange
            sendButton.tintColor = DesignConstants.accentOrange
            topDesign.image = UIImage(named: "redTopDesignRect")?.alpha(1)
        }
        
        listener = Database.db.collection("arguments/\(argumentInfo.argumentId)/messages").order(by: "timeSent", descending: true).limit(to: 20).addSnapshotListener { querySnapshot, err in
            
            if let err = err {
                Alert.errorAlert(error: err.localizedDescription)
                return
            }
            else if let snapshot = querySnapshot{
                //starting w latest message in the collection of doc changes returned
                for docChange in snapshot.documentChanges{
                    if docChange.type == .added{
                        let sentBy = docChange.document["sentBy"] as! String
                        if sentBy != User.details.uid{
                            // if message not sent by me and it is in the db and has loaded up on my screen, which it will be if this listener runs, then i can change it to .read
                            let status = docChange.document["status"] as! String
                            
                            self.showHasSeen = false

                            if status != "read"{
                                Database.writeToDocument(path: "arguments/\(self.argumentInfo.argumentId)/messages/\(docChange.document.documentID)", data: ["status" : "read"], merge: true)
                            }
                            
                            
                        }
                        break
                    }
                }
                
                self.oldestDocument = snapshot.documentChanges.last?.document
                
                snapshot.documentChanges.forEach { change in
                    
                    switch change.type{
                    case .added:
                        
                        let messageToAdd = Messages.createMessageObjectFromDoc(message: change.document)
                        if self.firstTimeRunning{
                            //if latest message is read
                            if change.newIndex == 0 && messageToAdd.status == .read{
                                self.showHasSeen = true
                            }
                            else {
                                self.showHasSeen = false
                            }
                            
                            self.messages.append(messageToAdd)
                            
                        }
                        else if messageToAdd.sentBy != User.details.uid{
                            self.showHasSeen = false
                            
                            DispatchQueue.main.async {
                                self.messages.append(messageToAdd)
                                
                                let indexPath = IndexPath(item: self.messages.count - 1, section: 0) 
                                self.collectionView.insertItems(at: [indexPath])
                                self.scrollToBottom()
                            }
                        }
                        
                    case .modified:
                        let modifiedMessage = Messages.createMessageObjectFromDoc(message: change.document)
                        
                        print(modifiedMessage.status, modifiedMessage.id, self.messages.last?.id, self.messages.first?.id, change.document.documentID, modifiedMessage.sentBy)
                        //check the modified message is a) this users message, b) has been read by the opponent and c) is the latest message which has been sent - if all these cases are true we show the hasSeen label
                        if modifiedMessage.status == .read && modifiedMessage.id == self.messages.last?.id && modifiedMessage.sentBy == User.details.uid{
                            self.showHasSeen = true
                        
                            
                        }
                        break
                        
                    default:
                        break
                    }
                }
                
                
                print("sorting messages and reloading collectionview")
                if self.firstTimeRunning{
                    print("first time running")
                    
                    if self.messages.first?.status == .read{
                        self.showHasSeen = true
                    }
                    //if we want the freshest message first we have to reverse if this is the first time running
                   self.messages = self.messages.reversed()
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.scrollToBottom()
                    }
                    self.firstTimeRunning = false
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        if let listener = listener{
            if  !isPickingImage{
                print("removing listener")
                listener.remove()
            }
        }
    }
    
    
    
    func getMessages(completion: @escaping(_ messages: [Message]) -> Void){
        var messages: [Message] = []
        
        //ordering by timeSent, biggest to smallest. the biggest timeSent is the latest one. latest - earliest. HOWEVER the last document is the latest one AFTER the earliest document we have loaded up. As user scrolls up, we add this new array of messages to self.messages
        //we end up with (from top of collection view) earliest mesasges - later messages - self.messages current
        let query = Database.db.collection("arguments/\(argumentInfo.argumentId)/messages").order(by: "timeSent", descending: true).limit(to: 30).start(afterDocument: oldestDocument)
        
        Database.returnDocumentsQuery(query: query) { (documents, err) in
            if let err = err {
                Alert.errorAlert(error: err.localizedCapitalized)
            }
            
            if let documents = documents{
                self.oldestDocument = documents.last
                for message in documents{
                    
                    let messageObj = Messages.createMessageObjectFromDoc(message: message)
                    messages.append(messageObj)
                    
                    
                    if message == documents.last{
                        completion(messages.reversed())
                        return
                    }
                }
            }
            else{
                //no more documents
                
                self.collectionView.isUserInteractionEnabled = true
                return
            }
        }
    }
    
    func scrollToBottom() {
        
        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .bottom, animated: true)
        
        /* if !self.messages.isEmpty{
         
         let lastItemIndex = IndexPath(item: self.messages.count - 1, section: 0)
         self.collectionView?.scrollToItem(at: lastItemIndex, at: .bottom, animated: true)
         }
         else{
         return
         }*/
    }
    
    @objc func keyboardToggle(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            
            //if isKeyboardShowing is true, keyboardFrame.height will be used, if not 0 will be used
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            textViewBottomConstraint?.constant = isKeyboardShowing ? keyboardFrame!.height + 10 : 10
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
                self.scrollToBottom()
                self.collectionView.layoutIfNeeded()
                self.collectionView.reloadData()
                
            }) { (completed) in
                
            }
        }
    }
    
    @IBAction func messageInfo(_ sender: Any) {
        
        let transition: CATransition = CATransition()
        // transition.duration = 0.5
        //transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = convertToCATransitionType(kCATransition)
        transition.subtype = CATransitionSubtype.fromTop
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messageInfoVC = storyboard.instantiateViewController(withIdentifier: "MessagingInfoVC") as! MessagingInfoVC
        messageInfoVC.argumentInfo = argumentInfo
        messageInfoVC.opponentImageUrl = argumentInfo.opponentProfileImageUrl
        self.navigationController?.pushViewController(messageInfoVC, animated: false)
        
    }
    
    var isPaginating: Bool = false
    
    /*func scrollViewDidScroll(_ scrollView: UIScrollView) {
     //dont want to run multiple paginations at the same time and want to wait for everything to init first
     if !firstTimeRunning && oldestDocument != nil{
     
     if !isPaginating && scrollView.contentOffset.y < 70{
     // collectionView.isUserInteractionEnabled = false
     print("paginating")
     isPaginating = true
     collectionView.isUserInteractionEnabled = false
     
     getMessages { (earlyMessages) in
     
     
     let currentMessages = self.messages
     
     let currentlyDisplayedMessageIndex = self.collectionView.indexPathsForVisibleItems.last!
     
     self.messages = []
     self.messages = earlyMessages.reversed() + currentMessages
     let indexPathToScrollTo = IndexPath(row: currentlyDisplayedMessageIndex.row + earlyMessages.count, section: 0)
     
     DispatchQueue.main.async {
     progressHUD.hide()()
     self.collectionView.reloadData()
     self.collectionView.scrollToItem(at: indexPathToScrollTo, at: .centeredVertically, animated: false)
     print("setting is paginating to false")
     self.isPaginating = false
     self.collectionView.isUserInteractionEnabled = true
     }
     
     }
     
     }
     }
     }*/
    
    @IBAction func sendMessage(_ sender: Any) {
        
        firstTimeRunning = false
        if messageTextView.text.formattedString(spaces:  false) != ""{
            
            let messageId = Messages.randomString(length: 10)
            let message = messageTextView.text!
            messageTextView.text = ""
            
            var data: [String: Any] = [
                "message": message,
                "sentBy": User.details.uid,
                "recievedBy": argumentInfo.opponentUid,
                "timeSent": Date.getCurrentMillis(),
                "messageType": "text",
                "status": "sending",
                "id": messageId
            ]
            
            messages.append(Messages.createMessageObjectFromDict(data: data))
            self.showHasSeen = false

            DispatchQueue.main.async {
                /*
                 let indexPath = IndexPath(item: self.messages.count - 1, section: 0) //at some index
                 self.collectionView.insertItems(at: [indexPath])
                 */
                self.collectionView.performBatchUpdates {
                    self.collectionView.reloadSections([1])
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView.insertItems(at: [indexPath])
                }

                self.scrollToBottom()
            }
            
            //before we write to db
            data["status"] = "written"
            
            Database.addDocumentErrorHandling(path: "arguments/\(argumentInfo.argumentId)/messages", data: data) { (err, id) in
                if let err = err {
                    //actually doesnt produce an error if no internet connection - in that case firebase handles offline caching and resend later on when network connectivity is restored.
                    Alert.errorAlert(error: err.localizedCapitalized)
                    //show retry or delete message buttons - have a status .failed
                    //or delete the message from messages and just reload the collection view?
                    
                    //get message which weve already appended and change its status to failed
                    
                    data["status"] = "failed"
                    //search for temporaryId of the message we just wrote (add temporary ids for messageobjectfomdict) and then update the status to failed, or if it doesnt fail update it to written below, then we need to make sure we not adding again when the listener triggers when we write to the db
                    for (index, message)  in self.messages.reversed().enumerated(){
                        if message.id == messageId{
                            self.messages[index].status = .failed
                            break
                        }
                    }
                    self.collectionView.reloadData()
                    
                    return
                }
                
                for (index, message) in self.messages.reversed().enumerated(){
                    if message.id == messageId{
                        //the index given is the message from the top - its as if we were going through the normal self.messages array as far as the for loop is concerned but weve reversed it
                        let trueIndex = (self.messages.count - 1) - index
                        self.messages[trueIndex].status = .written
                        break
                    }
                }
                
                //send notif
                let notifHelper = PushNotificationSender()
                notifHelper.sendPushNotification(to: self.argumentInfo.opponentDeviceToken, title: "Message in \(self.argumentInfo.topicTitle)", body: message)
                
            }
            
        }
        
        else{
            messageTextView.text = ""
        }
    }
}

//image sending
extension MessagingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrolling = false
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // Table view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return messages.count
            
        }
        else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0{
            let message = messages[indexPath.item]
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath as IndexPath) as! MessageCVC
            
            //cell setup - change some stuff if viewing differently
            cell.setMessageCell(message: message)
            
            switch message.type{
            case .text:
                let initialSize: CGSize = CGSize(width: 250, height: 1000)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: message.text!).boundingRect(with: initialSize, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
                
                var width: CGFloat!
                if estimatedFrame.width < 15{
                    width = 15
                }
                else{
                    width = estimatedFrame.width
                }
                
                if message.sentBy == User.details.uid{
                    cell.textLabel.frame = CGRect(x: 0, y: 0, width: width, height: estimatedFrame.height + 20)
                    cell.textBubbleView.frame = CGRect(x: view.frame.width - width - 24 - 10, y: 0, width: width + 24 , height: estimatedFrame.height + 20)
                    if argumentInfo.opponentUserSide == UserSideStates.isFor{
                        cell.textBubbleView.applyGradient(colors: DesignConstants.orangeGradientColors)
                        
                    }
                    else{
                        cell.textBubbleView.applyGradient(colors: DesignConstants.blueGradientColors)
                        
                    }
                }
                else{
                    cell.textLabel.frame = CGRect(x: 0, y: 0, width: width, height: estimatedFrame.height + 20)
                    cell.textBubbleView.frame = CGRect(x: 10, y: 0, width: width + 24 , height: estimatedFrame.height + 20)
                    if argumentInfo.opponentUserSide == UserSideStates.isFor{
                        cell.textBubbleView.applyGradient(colors: DesignConstants.blueGradientColors)
                        
                    }
                    else{
                        cell.textBubbleView.applyGradient(colors: DesignConstants.orangeGradientColors)
                        
                    }
                }
                
                cell.textLabel.center = cell.textBubbleView.center

                cell.textBubbleView.layer.cornerRadius = CellConstants.textBubbleViewLineHeight/2
                
            case .image:
                
                let originalImageWidth = message.imageDimensions!["width"]!.floatValue
                let originalImageHeight = message.imageDimensions!["height"]!.floatValue
                //make height correct depending on our fixed width value
                let height = CGFloat(originalImageHeight / originalImageWidth * fixedWidthFloat)
                print("making image height calc: ", height)
                
                if message.sentBy == User.details.uid{
                    cell.textBubbleView.frame = CGRect(x: view.frame.width - fixedWidth - 5, y: 0, width: fixedWidth , height: height)
                }
                else{
                    cell.textBubbleView.frame = CGRect(x: 5, y: 0, width: fixedWidth , height: height)
                }
                cell.textBubbleView.backgroundColor = UIColor.clear
                cell.delegate = self
            case.video:
                break
            }
            
            switch message.status{
            case .sending:
                cell.alpha = 0.7
                print("sending MESSAGE")
            case .failed:
                cell.alpha = 0.5
                print("failed MESSAGE")
            case .written:
                cell.alpha = 1
            case .read:
                break
            }
            
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! UICollectionViewCell
            cell.isHidden = !showHasSeen
            return cell
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showHasSeen = false
        return true
    }   
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        messageTextView.endEditing(true)
        
        // let messageSelected = messages[indexPath.item]
        
        //show some info idk
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0{
            let message = messages[indexPath.item]
            
            switch message.type{
            case .text:
                
                let initialSize: CGSize = CGSize(width: 250, height: 1000)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: message.text!).boundingRect(with: initialSize, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
                
                //need to account for padding of collection view so we need - 11
                return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
                
            case .image:
                
                let originalImageWidth = message.imageDimensions!["width"]!.floatValue
                let originalImageHeight = message.imageDimensions!["height"]!.floatValue
                //make height correct depending on our fixed width value
                let height = CGFloat(originalImageHeight / originalImageWidth * fixedWidthFloat)
                
                return CGSize(width: view.frame.width, height: height)
                
            case .video:
                break
            }
            return CGSize(width: view.frame.width, height: 100)
        }
        else{
            return CGSize(width: collectionView.frame.width, height: 15)
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            if indexPath.row - 15 == 0 && !firstTimeRunning && !isPaginating{
                isPaginating = true
                
                getMessages { (newMessages) in
                    self.messages.insert(contentsOf: newMessages, at: 0)
                    let amount = newMessages.count
                    let section = 0
                    let contentHeight = self.collectionView.contentSize.height
                    let offsetY = self.collectionView.contentOffset.y
                    let bottomOffset = contentHeight - offsetY
                    
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    
                    self.collectionView.performBatchUpdates({
                        var indexPaths = [NSIndexPath]()
                        for i in 0..<amount {
                            let index = 0 + i
                            indexPaths.append(NSIndexPath(item: index, section: section))
                        }
                        if indexPaths.count > 0 {
                            
                            
                            self.collectionView.insertItems(at: indexPaths as [IndexPath])
                        }
                    }, completion: {
                        finished in
                        print("completed loading of new stuff, animating")
                        self.collectionView.contentOffset = CGPoint(x: 0, y: self.collectionView.contentSize.height - bottomOffset)
                        CATransaction.commit()
                        self.isPaginating = false
                        
                    })
                }
            }
        }
        
    }
    
    @objc func zoomImageTapped(sender: UITapGestureRecognizer){
        
        if let zoomOutImage = sender.view as? UIImageView{
            //animate zoomingImage to become smaller
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                zoomOutImage.frame = self.startingFrame!
                
                self.blackBackground?.alpha = 0
                
            }, completion: { (completed: Bool) in
                zoomOutImage.removeFromSuperview()
            }
            )
        }
    }
}

extension MessagingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func sendImage(_ sender: Any) {
        picker.allowsEditing = true
        isPickingImage = true
        present(picker, animated: true, completion: nil)
        
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        var selectedImageFromPicker: UIImage?
        
        // Use the edited image if available
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        } // Get image value
        
        // Unwrap
        if let selectedImage = selectedImageFromPicker {
            if let uploadData = selectedImage.jpegData(compressionQuality: 3.0){
                
                let currentTimeAsString = "\(Date.getCurrentMillis())"
                Database.stdb.child("chatMedia").child(argumentInfo.argumentId).child(currentTimeAsString).putData(uploadData, metadata: nil, completion: { (metadata, err) in
                    
                    if let err = err {
                        Alert.errorAlert(error: err.localizedDescription)
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                    else{
                        
                        
                        // unwrap image url as a string
                        Database.stdb.child("chatMedia").child(self.argumentInfo.argumentId).child(currentTimeAsString).downloadURL(completion: { (url, err) in
                            guard let downloadURL = url else {
                                return
                            }
                            
                            let messageId = Messages.randomString(length: 10)
                            var data: [String: Any] = [
                                "imageUrl": downloadURL.absoluteString,
                                "imageDimensions": ["height": selectedImage.size.height, "width": selectedImage.size.width],
                                "sentBy": User.details.uid,
                                "recievedBy": self.argumentInfo.opponentUid,
                                "timeSent": Date.getCurrentMillis(),
                                "messageType": "image",
                                "status": "sending",
                                "id": messageId
                            ]
                            
                            self.messages.append(Messages.createMessageObjectFromDict(data: data))
                            
                            DispatchQueue.main.async {
                                /*
                                 let indexPath = IndexPath(item: self.messages.count - 1, section: 0) //at some index
                                 self.collectionView.insertItems(at: [indexPath])
                                 */
                                self.showHasSeen = false
                                
                                self.collectionView.reloadData()
                                self.scrollToBottom()
                                
                                
                            }
                            
                            data["status"] = "written"
                            
                            self.dismiss(animated: true, completion: nil)
                            
                            Database.addDocumentErrorHandling(path: "arguments/\(self.argumentInfo.argumentId)/messages", data: data) { (err, id) in
                                self.sendButton.isUserInteractionEnabled = true
                                self.isPickingImage = false
                                
                                if let err = err {
                                    Alert.errorAlert(error: err)
                                    data["status"] = "failed"
                                    //search for temporaryId of the message we just wrote (add temporary ids for messageobjectfomdict) and then update the status to failed, or if it doesnt fail update it to written below, then we need to make sure we not adding again when the listener triggers when we write to the db
                                    for (index, message)  in self.messages.reversed().enumerated(){
                                        print("looknig for message which has failed")
                                        if message.id == messageId{
                                            print("message found, changing status")
                                            self.messages[index].status = .failed
                                            break
                                        }
                                    }
                                    self.collectionView.reloadData()
                                    
                                    return
                                }
                                for (index, message) in self.messages.reversed().enumerated(){
                                    print("looknig for message which has been written")
                                    if message.id == messageId{
                                        //the index given is the message from the top - its as if we were going through the normal self.messages array as far as the for loop is concerned but weve reversed it
                                        let trueIndex = (self.messages.count - 1) - index
                                        print("message \(messageId) found, changing status to written from sending for local user: ", self.messages[trueIndex] )
                                        self.messages[trueIndex].status = .written
                                        print("messages eeeee: ", self.messages)
                                        self.collectionView.reloadData()
                                        break
                                    }
                                }
                                
                            }
                            
                        })
                    }
                })
            }
        }
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        isPickingImage = false
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCATransitionType(_ input: String) -> CATransitionType {
    return CATransitionType(rawValue: input)
}
