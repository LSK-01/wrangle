//
//  PublicArgumentsDetailVC.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 05/10/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import UIKit
//import NVActivityIndicatorView
import Firebase

class PublicArgumentsDetailVC: UIViewController, ZoomImageDelegate, UIGestureRecognizerDelegate {
    
    func zoomStartImage(startImage: UIImageView) {
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
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var opponentForImage: ProfileImage!
    @IBOutlet weak var opponentAgainstImage: ProfileImage!
    @IBOutlet weak var titleText: UILabel!
    
    var argumentInfo: PublicArgument!
    var listener: ListenerRegistration!
    var userSide: String!
    //conversation coll view
    var messages: [Message] = []
    var lastDocument: DocumentSnapshot!
    //zooming images
    var startingFrame: CGRect?
    var blackBackground: UIView?
    let fixedWidthFloat: Float = 200
    let fixedWidth: CGFloat = 200
    
    var hiddenStatus: Bool = true
    
    var parentVC: PublicArgumentsCV!
    
    var isPaginating: Bool = false
    var voteHandler: VoteModel!
    var messagesQuery: Query!
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        titleText.text = argumentInfo.topicTitle
        
        opponentForImage.layer.borderColor = DesignConstants.mainBlue.cgColor
        opponentAgainstImage.layer.borderColor = DesignConstants.mainRed.cgColor
        
        if let url = argumentInfo.userAgainstInfo["profileImageUrl"]{
            opponentAgainstImage.getCachedImage(urlString: url) { (image, err) in
                if let im = image{
                    DispatchQueue.main.async {
                        self.opponentAgainstImage.image = im

                    }
                }
            }
        }
        
        if let url = argumentInfo.userForInfo["profileImageUrl"]{
            opponentForImage.getCachedImage(urlString: url) { (image, err) in
                if let im = image{
                    DispatchQueue.main.async {
                        self.opponentForImage.image = im
                    }
                }
            }
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MessageCVC.self, forCellWithReuseIdentifier: "messageCell")
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        voteHandler = VoteModel()
        
        messagesQuery = Database.db.collection("arguments/\(argumentInfo.argumentId)/messages").order(by: "timeSent", descending: false).limit(to: 40)
        
        getMessages { (newMessages) in
            self.messages.append(contentsOf: newMessages)
            self.hiddenStatus = false
            DispatchQueue.main.async{
                self.collectionView.reloadSections([0,1])
            }
        }

        let hrs = Date.minutesToHours(minutes: argumentInfo.endingAt - Date.getCurrentMinutes())
        
    }
    func getMessages(completion: @escaping(_ messages: [Message]) -> Void){
        var newMessages: [Message] = []
        var query: Query = messagesQuery
        //ordering by timeSent, biggest to smallest. the biggest timeSent is the latest one. latest - earliest. HOWEVER the last document is the latest one AFTER the earliest document we have loaded up. As user scrolls up, we add this new array of messages to self.messages
        //we end up with (from top of collection view) earliest mesasges - later messages - self.messages current
        
        if lastDocument != nil{
            query = messagesQuery.start(afterDocument: lastDocument)
        }
        
        Database.returnDocumentsQuery(query: query) { (documents, err) in
            if let err = err {
                Alert.errorAlert(error: err.localizedCapitalized)
            }
            
            if let documents = documents{
                self.lastDocument = documents.last
                for message in documents{
                    
                    let messageObj = Messages.createMessageObjectFromDoc(message: message)
                    newMessages.append(messageObj)
                    
                    
                    if message == documents.last{
                        completion(newMessages)
                        return
                    }
                }
            }
            else{
                //no more documents
                self.collectionView.reloadSections([1])
                self.collectionView.isUserInteractionEnabled = true
                return
            }
        }
    }
}

extension PublicArgumentsDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return messages.count
            
        }
        else{
            return 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets(top: 15.0, left: 0, bottom: 15.0, right: 0)
        }
        else{
            return UIEdgeInsets.zero
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
                    
                    if message.sentBy == argumentInfo.userForInfo["uid"]{
                        cell.textLabel.frame = CGRect(x: 0, y: 0, width: width, height: estimatedFrame.height + 20)
                        cell.textBubbleView.frame = CGRect(x: 10, y: 0, width: width + 24 , height: estimatedFrame.height + 20)

                        cell.textBubbleView.applyGradient(colors: DesignConstants.blueGradientColors)

                    }
                    else{
                        cell.textLabel.frame = CGRect(x: 0, y: 0, width: width, height: estimatedFrame.height + 20)
                        cell.textBubbleView.frame = CGRect(x: view.frame.width - width - 24 - 10, y: 0, width: width + 24 , height: estimatedFrame.height + 20)

                        cell.textBubbleView.applyGradient(colors: DesignConstants.orangeGradientColors)

                    }
                    
                    cell.textLabel.center = cell.textBubbleView.center
                    
                    cell.textBubbleView.layer.cornerRadius = CellConstants.textBubbleViewLineHeight/2
                    
                case .image:
                    
                    let originalImageWidth = message.imageDimensions!["width"]!.floatValue
                    let originalImageHeight = message.imageDimensions!["height"]!.floatValue
                    //make height correct depending on our fixed width value
                    let height = CGFloat(originalImageHeight / originalImageWidth * fixedWidthFloat)
                    
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "voteCell", for: indexPath as IndexPath) as! VoteCVC
            cell.setVoteCell(argument: argumentInfo, index: indexPath.item, hiddenStatus: hiddenStatus)
            cell.buttonDelegate = voteHandler
            cell.updateDelegate = parentVC
            if argumentInfo.archived{
                cell.upvoteForButton.isUserInteractionEnabled = false
                cell.upvoteAgainstButton.isUserInteractionEnabled = false
            }
            return cell
        }
        
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
                return  CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
                
            case .image:
                
                let originalImageWidth = message.imageDimensions!["width"]!.floatValue
                let originalImageHeight = message.imageDimensions!["height"]!.floatValue
                //make height correct depending on our fixed width value
                let height = CGFloat(originalImageHeight / originalImageWidth * fixedWidthFloat)
                
                return CGSize(width: view.frame.width, height: height)
                
            case .video:
                break
            }
            return  CGSize(width: view.frame.width, height: 100)
        }
        else{
            return  CGSize(width: collectionView.frame.width * 0.9, height: CellConstants.cellHeightTitle - 10)
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        
        if indexPath.row + 10 == messages.count && !isPaginating{
            
            isPaginating = true
            getMessages { (newMessages) in

                self.collectionView?.performBatchUpdates({
                    var startOfNewElements = self.messages.count
                    self.messages.append(contentsOf: newMessages)
                    var endOfNewElements = self.messages.count - 1
                    
                    let indexPaths = Array(startOfNewElements...endOfNewElements).map { IndexPath(item: $0, section: 0) }
                    collectionView.insertItems(at: indexPaths)
                }, completion: nil)
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
