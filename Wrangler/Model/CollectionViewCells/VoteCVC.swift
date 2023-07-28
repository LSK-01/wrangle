//
//  VoteCVC.swift
//  Wrangler
//
//  Created by god on 03/04/2020.
//  Copyright © 2020 Luca Sarif-Kattan. All rights reserved.
//

import UIKit

protocol VoteCVCDelegate: VoteModel{
    func incrementVoteNumbers(forArgument: PublicArgument, forSide: UserSideStates, wasSuccessful: @escaping(Bool) -> Void)
}

protocol VoteCVCUpdateDelegate: PublicArgumentsCV{
    func updatePubArgument(pubArg: PublicArgument)
    
}

class VoteCVC: UICollectionViewCell {
    
    weak var buttonDelegate: VoteCVCDelegate?
    weak var updateDelegate: VoteCVCUpdateDelegate?
    
    var cellIndex: Int!
    var argumentInfo: PublicArgument!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var usernameFor: UILabel!
    @IBOutlet weak var usernameAgainst: UILabel!
    @IBOutlet weak var upvoteAgainstButton: UIButton!
    @IBOutlet weak var upvoteForButton: UIButton!
    @IBOutlet weak var timeEndingInfo: UILabel!
    
    @IBOutlet weak var voteWhoWonLabel: UILabel!
    func setVoteCell(argument: PublicArgument, index: Int, hiddenStatus: Bool){
        
        isHidden = hiddenStatus
        
        backgroundColor = DesignConstants.mainPurple.withAlphaComponent(0.6)
        layer.masksToBounds = true
        clipsToBounds = true
        layer.cornerRadius = DesignConstants.cornerRadius
        argumentInfo = argument
        usernameFor.text = argument.userForInfo["username"]
        usernameAgainst.text = argument.userAgainstInfo["username"]
        
        progressBar.progressTintColor = DesignConstants.accentBlue
        
        cellIndex = index
        
        let secondsTillEnding = argumentInfo.endingAt - Date.getCurrentSeconds()
        let minutesTillEnding: Float = Float(secondsTillEnding/60)
        progressBar.progress = (TimeConstants.publicArgLengthMins-minutesTillEnding)/TimeConstants.publicArgLengthMins
        progressBar.progressTintColor = DesignConstants.accentBlue
        //progressBar.backgroundColor = DesignConstants.accentBlue.withAlphaComponent(0.3)
        
        if !argument.archived{
            timeEndingInfo.text = "Winner decided in \(secondsTillEnding/60) minutes"
            
        }
        else {
            if let winner = argument.winner{
                timeEndingInfo.text = "\(winner) won this argument"
            }
        }
        
        upvoteForButton.setTitleColor(DesignConstants.mainBlue, for: .normal)
        upvoteForButton.setTitleColor(DesignConstants.mainBlue.withAlphaComponent(0.3), for: .highlighted)
        upvoteForButton.setTitleColor(UIColor.gray, for: .disabled)
        
        upvoteAgainstButton.setTitleColor(DesignConstants.mainRed, for: .normal)
        upvoteAgainstButton.setTitleColor(DesignConstants.mainRed.withAlphaComponent(0.3), for: .highlighted)
        upvoteAgainstButton.setTitleColor(UIColor.gray, for: .disabled)
        
        
        self.upvoteForButton.isEnabled = false
        self.upvoteAgainstButton.isEnabled = false
        
        if argument.thisUserSide == .isNeutral && !argument.archived{
            self.upvoteForButton.isEnabled = true
            self.upvoteAgainstButton.isEnabled = true
            
        }
        
        if argument.thisUserSide == .isFor{
            voteWhoWonLabel.text = "You voted for \(argument.userForInfo["username"]!)"
        }
        else if argument.thisUserSide == .isAgainst{
            voteWhoWonLabel.text = "You voted for \(argument.userAgainstInfo["username"]!)"
        }
        
    }
    
    @IBAction func voteFor(_ sender: Any) {
        buttonDelegate?.incrementVoteNumbers(forArgument: argumentInfo, forSide: .isFor, wasSuccessful: { (wasSuccessful) in
            if wasSuccessful{
                self.argumentInfo.thisUserSide = .isFor
                self.argumentInfo.upvotesFor += 1
                self.updateDelegate?.updatePubArgument(pubArg: self.argumentInfo)
                
                
            }
            else{
                return
            }
        })
    }
    
    
    @IBAction func voteAgainst(_ sender: Any) {
        buttonDelegate?.incrementVoteNumbers(forArgument: argumentInfo, forSide: .isAgainst, wasSuccessful: { (wasSuccessful) in
            if wasSuccessful{
                self.argumentInfo.thisUserSide = .isAgainst
                self.argumentInfo.upvotesAgainst += 1
                self.updateDelegate?.updatePubArgument(pubArg: self.argumentInfo)
                
            }
            else{
                return
            }
        })
    }
    
    
}
