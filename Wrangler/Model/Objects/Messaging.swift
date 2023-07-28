//
//  File.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 28/08/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct Message{
    var text: String?
    var imageUrl: String?
    //need to use nsnumber so we can get the float val of the number
    var imageDimensions: [String: NSNumber]?
    var videoUrl: String?
    var sentBy: String
    var timeSent: Int
    var type: MessageType
    var status: MessageStatus
    var id: String
    
    
    init(text: String = "", imageUrl: String = "", imageDimensions: [String: NSNumber] = [:], videoUrl: String = "", sentBy: String, timeSent: Int, type: MessageType, status: MessageStatus, id: String){
        self.text = text
        self.imageUrl = imageUrl
        self.imageDimensions = imageDimensions
        self.videoUrl = videoUrl
        self.sentBy = sentBy
        self.timeSent = timeSent
        self.type = type
        self.status = status
        self.id = id
    }
}

enum MessageType:String{
    case text = "text"
    case image = "image"
    case video = "video"
}

enum MessageStatus:String{
    case read = "read"
    case written = "written"
    case failed = "failed"
    case sending = "sending"
}

class Messages{
    
    static func createMessageObjectFromDoc(message: DocumentSnapshot?) -> Message{
        
        var messageId: String!
        var messageObj: Message!
        
        if let message = message{
            
            messageId = message["id"] as! String
            
            let statusFromDB = message["status"] as! String
            var status: MessageStatus = MessageStatus(rawValue: statusFromDB) ?? .failed
            
            
            let messageTypeRaw = message["messageType"] as! String
            var type: MessageType = MessageType(rawValue: messageTypeRaw) ?? .text
            
            messageObj = Message(
                sentBy: message["sentBy"] as! String,
                timeSent: message["timeSent"] as! Int,
                type: type,
                status: status,
                id: messageId)
            
            switch type{
            case .text:
                messageObj.text = message["message"] as! String
            case .image:
                messageObj.imageUrl = message["imageUrl"] as! String
                messageObj.imageDimensions = message["imageDimensions"] as! [String: NSNumber]
                messageObj.text = "Image"
            case .video:
                messageObj.videoUrl = message["videoUrl"] as! String
            }
            
            
        }
        return messageObj
        
        
    }
    
    static func createMessageObjectFromDict(data: [String: Any]) -> Message{
        
        let message = data
        let statusFromDB = message["status"] as! String
        var status: MessageStatus = MessageStatus(rawValue: statusFromDB) ?? .failed
          
          
          let messageTypeRaw = message["messageType"] as! String
          var type: MessageType = MessageType(rawValue: messageTypeRaw) ?? .text
          
          var messageObj = Message(
              sentBy: message["sentBy"] as! String,
              timeSent: message["timeSent"] as! Int,
              type: type,
              status: status,
              id: message["id"] as! String)
          
          switch type{
          case .text:
              messageObj.text = message["message"] as! String
          case .image:
              messageObj.imageUrl = message["imageUrl"] as! String
              messageObj.imageDimensions = message["imageDimensions"] as! [String: NSNumber]
              messageObj.text = "Image"
          case .video:
              messageObj.videoUrl = message["videoUrl"] as! String
          }
          
         return messageObj
        
    }
    
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
