//
//  TableViewFunctions.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 29/07/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import Foundation
import Firebase

class CollectionViewFuncs{

    static func goToTop(collectionView: UICollectionView,completion: @escaping() -> Void){
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                    at: .top,
                                    animated: true)
        completion()
    }
    
    static func goToBottom(CollectionViewFuncs: UICollectionView, completion: @escaping() -> Void){
        
        let lastSectionIndex = (CollectionViewFuncs.numberOfSections) - 1
        let lastItemIndex = (CollectionViewFuncs.numberOfItems(inSection: lastSectionIndex)) //- 1
        let indexPath = NSIndexPath(item: lastItemIndex, section: lastSectionIndex)
        
        CollectionViewFuncs.scrollToItem(at: indexPath as IndexPath, at: UICollectionView.ScrollPosition.bottom, animated: false)
        
        completion()
    }
}
