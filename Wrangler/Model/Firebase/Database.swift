//
//  Database.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 23/07/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

class Database{

//    static func create
    
    static func returnDocument(path: String, completion: @escaping(_ document: DocumentSnapshot?, _ error: String?) -> Void){
        
        
        db.document(path).getDocument { (document, err) in
            if let err = err {
                completion(nil, err.localizedDescription)
                return
            }
            if let document = document, document.exists {
                completion(document, nil)
                return
            }
            else{
                completion(nil, nil)
                return
            }
        }
    }
    
    static func returnDocuments(path: String, completion: @escaping(_ documents: [DocumentSnapshot]?, _ error: String?) -> Void){
        db.collection(path).getDocuments { (snapshot, err) in
            if let err = err {
                completion(nil, err.localizedDescription)
                return
            }
            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                let documents = snapshot.documents
                completion(documents, nil)
                return
            }
            else{
                completion(nil, nil)
                return
            }
        }
    }
    
    static func writeToDocumentErrorHandling(path: String, data: [String: Any], merge: Bool, completion: @escaping (_ error: String?) -> Void){
        
        if merge{
            db.document(path).setData(data, merge: true) { (err) in
                if let err = err {
                    completion(err.localizedDescription)
                    return
                } else {
                    completion(nil)
                    return
                }
            }
        }
        else{
            db.document(path).setData(data) { (err) in
                if let err = err {
                    completion(err.localizedDescription)
                    return
                } else {
                    completion(nil)
                    return
                }
            }
        }
    }
    
    static func writeToDocument(path: String, data: [String: Any], merge: Bool){
        
        if merge{
            db.document(path).setData(data, merge: true) { (err) in
                if let err = err {
                    print(err.localizedDescription)
                }
            }
        }
        else{
            db.document(path).setData(data) { (err) in
                if let err = err {
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    static func addDocumentErrorHandling(path: String, data: [String: Any], completion: @escaping (_ error: String?, _ documentID: String?) -> Void){
        var documentRef: DocumentReference!
        
        documentRef = db.collection(path).addDocument(data: data) { (err) in
            if let err = err {
                completion(err.localizedDescription,nil)
                return
            } else {
                completion(nil,documentRef.documentID)
                return
            }
        }
    }
    
    static func returnDocumentsQuery(query: Query, completion: @escaping (_ documents: [DocumentSnapshot]?, _ error: String?) -> Void){
        
        query.getDocuments { (snapshot, err) in
            if let err = err {
                completion(nil, err.localizedDescription)
                return
            }
            if let snapshot = snapshot, !snapshot.documents.isEmpty{
                completion(snapshot.documents, nil)
                return
            }
            else{
                completion(nil, nil)
                return
            }
        }
    }
    
    static func deleteDocument(path: String, completion: @escaping(_ error: String?) -> Void){
        db.document(path).delete(){err in
            if let err = err{
                completion(err.localizedDescription)
                return
            }
            else{
                completion(nil)
                return
            }
        }
    }
    
    static func updateDocumentErrorHandling(path: String, data: [String: Any], completion: @escaping (_ error: String?) -> Void){
        
        db.document(path).updateData(data) { (err) in
            if let err = err {
                completion(err.localizedDescription)
                return
            } else {
                completion(nil)
                return
            }
        }
    }
    
    static let db = Firestore.firestore()
    static let stdb = Storage.storage().reference()
    static let commonWords: Set<String> =
        ["the",
         "&",
         "/",
         "be",
         "to",
         "of",
         "and",
         "a",
         "in",
         "that",
         "have",
         "i",
         "it",
         "for",
         "not",
         "on",
         "with",
         "he",
         "as",
         "you",
         "do",
         "at",
         "this",
         "but",
         "his",
         "by",
         "from",
         "they",
         "we",
         "say",
         "her",
         "she",
         "or",
         "an",
         "will",
         "my",
         "one",
         "all",
         "would",
         "there",
         "their",
         "what",
         "so",
         "up",
         "out",
         "if",
         "about",
         "who",
         "get",
         "which",
         "go",
         "me",
         "when",
         "make",
         "can",
         "like",
         "time",
         "no",
         "just",
         "him",
         "know",
         "take",
         "people",
         "into",
         "year",
         "your",
         "good",
         "some",
         "could",
         "them",
         "see",
         "other",
         "than",
         "then",
         "now",
         "look",
         "only",
         "come",
         "its",
         "over",
         "think",
         "also",
         "back",
         "after",
         "use",
         "two",
         "how",
         "our",
         "work",
         "first",
         "well",
         "way",
         "even",
         "new",
         "want",
         "because",
         "any",
         "these",
         "give",
         "day",
         "most",
         "us",
         "believe",
         "think",
         "should"]
}
