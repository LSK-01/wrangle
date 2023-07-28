//
//  SlideUpCV.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 22/09/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import Foundation
import UIKit

struct menuOption{
    var optionName: String
    var imageNamed: String
    

    
    init(optionName: String, imageNamed: String){
        self.optionName = optionName.capitalized
        self.imageNamed = imageNamed
    }
}

class SlideUpCV: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    let cellHeight: CGFloat = 50
    var menuOptions: [menuOption] = []
    let blackView = UIView()
    
    //store value from slide up
    var valueFromSlideUp: String?
    
    let slideUpCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    
    func createMenuOptions(optionNames: [String]) -> [menuOption]{
        var menuOptions: [menuOption] = []
        
        for name in optionNames{
            menuOptions.append(menuOption(optionName: name, imageNamed: name))
        }
        
        return menuOptions
    }
    
    func slideUp(options: [menuOption]){
        menuOptions = options
        
        if let window = UIApplication.shared.keyWindow{
            //black view over viewcontroller
            
            blackView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))
            
            window.addSubview(blackView)
            window.addSubview(slideUpCV)
            
            //to make it come from the bottom
            let height: CGFloat = CGFloat(menuOptions.count * 50)
            let yValue = window.frame.height - height
            slideUpCV.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                self.blackView.alpha = 1
                //slide up
                self.slideUpCV.frame = CGRect(x: 0, y: yValue, width: self.slideUpCV.frame.width, height: self.slideUpCV.frame.height)
            })
        }
        else{
            return
        }
    }
    
    @objc func dismissMenu(){
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.slideUpCV.frame = CGRect(x: 0, y: window.frame.height, width: self.slideUpCV.frame.width, height: self.slideUpCV.frame.height)
            }
        }
    }
    
    override init() {
        super.init()
        
        slideUpCV.dataSource = self
        slideUpCV.delegate = self
        
        slideUpCV.register(SlideUpMenuCollectionViewCell.self, forCellWithReuseIdentifier: "menuCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! SlideUpMenuCollectionViewCell
        
        let option = menuOptions[indexPath.item]
        cell.menuOption = option
        cell.menuItemLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        cell.menuItemLabel.textColor = DesignConstants.accentBlue
        cell.menuImageView.tintColor = DesignConstants.mainPurple
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3, animations: {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.slideUpCV.frame = CGRect(x: 0, y: window.frame.height, width: self.slideUpCV.frame.width, height: self.slideUpCV.frame.height)
            }
        }) { (completion) in
            let option = self.menuOptions[indexPath.item]
            
            //set valueFromSlideUp and alert view controller
            self.valueFromSlideUp = option.optionName
            
            DispatchQueue.main.async{
                NotificationCenter.default.post(name: .slideUpMenu, object: nil)
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
