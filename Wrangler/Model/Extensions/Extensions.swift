//
//  Extensions.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 15/07/2018.
//  Copyright © 2018 LucaSarif. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString,UIImage>()

extension UIImageView{

    func getCachedImage(urlString: String, completion: @escaping (_ image: UIImage?, _ error: Error? ) -> Void) {
        
        //check cached for image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            print("got cached image")
            completion(cachedImage, nil)
        } else {
            let url = NSURL(string: urlString)
            URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                print("in url session data task")
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                else if let data = data, let downloadedImage = UIImage(data: data) {
                    print("poo")
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    print("pee")
                    completion(downloadedImage, nil)
                    return
                }
            }).resume()//URLSession

        }
    }
}

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension String{
    
  
    
    func formattedString(spaces: Bool) -> String{
        if !spaces{
        let editedString = self.replacingOccurrences(of: "\\s", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces).lowercased()
            return editedString
        }
        else{
        let editedString = self.trimmingCharacters(in: .whitespaces).lowercased()
            return editedString
        }
        
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> (CGFloat, CGFloat) {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return (ceil(boundingBox.height), ceil(boundingBox.height + 60))
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> (CGFloat, CGFloat) {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return (ceil(boundingBox.width), ceil(boundingBox.width + 60))
    }
}

//background grad
extension UIView {
    
    func applyGradient(colors: [CGColor])
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.zPosition  = -1
        self.layer.addSublayer(gradientLayer)
    }
}

extension UILabel{
    //ETHANS HARD WORK  SWEAT AND TEARS WHICH WERE NOT USING NOW LMAO FUCK UUU BROOOOOOO
    
    func wrapCellLabelText(cell: UICollectionViewCell, labelProportionOfCellWidth: CGFloat, storyboardFont: UIFont){
        
        // -NOTE - change no.of lines on storyboards if topic names get longer but we should set a limit on them anyway
        //change to proportional constraint so we 100% know the topicLabel width is correct so we can scale the font properly
        //make sure maximumStoryboadFont is, well, actually the font set on the storyboard to the maximum you want
        self.widthAnchor.constraint(equalTo: cell.widthAnchor, multiplier: labelProportionOfCellWidth).isActive = true
        
        var storyboardFontSize = storyboardFont.pointSize
        self.font = self.font.withSize(storyboardFontSize)
        
        let labelWidth = labelProportionOfCellWidth * cell.bounds.width
        
        for word in self.text!.components(separatedBy: " "){
            
            var wordWidth = (word as NSString).size(withAttributes: [NSAttributedString.Key.font: self.font]).width
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            while wordWidth > labelWidth{
                storyboardFontSize -= 0.5
                self.font = self.font.withSize(storyboardFontSize)
                
                wordWidth = (word as NSString).size(withAttributes: [NSAttributedString.Key.font: self.font]).width
            }
        }
        

        //<<<<<<<<
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat){
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: label.frame.height)
    }
    
    func fitFontToLabelHeight(maxSize: CGFloat, ofType: UIFont.Weight)
    {
      
        var tempFont:UIFont!
        var tempMax: CGFloat = maxSize
        var tempMin: CGFloat = 10

        
        while (ceil(tempMin) != ceil(tempMax)){
            let testedSize = (tempMax + tempMin) / 2
            
            tempFont = UIFont.systemFont(ofSize: testedSize)
            let attributedString = NSAttributedString(string: self.text!, attributes: [NSAttributedString.Key.font : tempFont])
            
            let textFrame = attributedString.boundingRect(with: CGSize(width: self.bounds.size.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin , context: nil)
            
            let difference = self.frame.height - textFrame.height
             if(difference > 0){
                tempMin = testedSize
            }else{
                tempMax = testedSize
            }
        }
        
        
        //returning the size -1 (to have enought space right and left)
        self.font = UIFont.systemFont(ofSize: tempMin - 1, weight: ofType)
    }
}

extension Date{
    
    static let minutesInADay: Int = 1440
    
    static func getCurrentMillis()->Int {
        return Int(Date().timeIntervalSince1970 * 1000)
    }
    
    static func getCurrentDate()->String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    static func getCurrentMinutes()->Int {
        return Int((Date().timeIntervalSince1970)/60)
    }
    
    static func getCurrentHours()->Int {
        return Int((Date().timeIntervalSince1970)/3600)
    }
    
    static func getCurrentSeconds()->Int {
        return Int(Date().timeIntervalSince1970)
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    static func minutesToHours (minutes: Int) -> (Int) {
        return (minutes / 60)
    }
    
    static func inXHoursInSeconds(inHours: Int) -> Int {
        return (Int((Date().timeIntervalSince1970 / 3600.0).rounded(.down)) + inHours) * 3600
    }
    
    static func startOfNextHourInSeconds() -> Int{
        let currentMinutes = Date.getCurrentMinutes()
        let startOfHour = currentMinutes + (60 - (currentMinutes % 60))
        return startOfHour
    }
}


extension UICollectionView {
    
    func isValidIndex(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfItems(inSection: indexPath.section)
    }
    
    func reloadWithAnimation(){
        
        DispatchQueue.main.async{
            UIView.transition(with: self, duration: 1, options: .curveEaseOut, animations: {
                self.reloadData()
                self.alpha = 1
            }, completion: { (completed) in
                
            })
        }
    }
}

extension Notification.Name{
    static let slideUpMenu = Notification.Name("slideUpMenu")
    static let topicMatch = Notification.Name("topicMatch")
    static let argumentUpdate = Notification.Name("argumentUpdate")
}

extension UIImage {
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
}

extension UITextView{
    
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }

   
}
