//
//  SlideUpMenuCollectionViewCell.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 22/09/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import UIKit

class SlideUpMenuCollectionViewCell: UICollectionViewCell {
    
    override var isHighlighted: Bool{
        didSet{
            backgroundColor = isHighlighted ? UIColor.darkGray : UIColor.white
            
            menuItemLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            
            menuImageView.tintColor = isHighlighted ? UIColor.white : UIColor.darkGray
        }
    }
    

    
    var menuOption: menuOption?{
        didSet{
            menuItemLabel.text = menuOption?.optionName
            if let imageName = menuOption?.imageNamed{
            //alwaysTemplate so we can change color dependant on highlighted state
            menuImageView.image = UIImage(named: imageName)//.withRenderingMode(.alwaysTemplate)
            //menuImageView.tintColor = UIColor.darkGray
            }
        }
    }
    
    let menuItemLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let menuImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews(){
        
        addSubview(menuItemLabel)
        addSubview(menuImageView)
        
        menuItemLabel.translatesAutoresizingMaskIntoConstraints = false
        menuImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[v0(20)]-8-[v1]|", options: [], metrics: nil, views: ["v1": menuItemLabel, "v0": menuImageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics: nil, views: ["v0": menuItemLabel]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(20)]", options: [], metrics: nil, views: ["v0": menuImageView]))
        //center vertically menu image icon in cell
        addConstraint(NSLayoutConstraint(item: menuImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
