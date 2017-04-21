//
//  QueueTableViewCell.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/11/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class QueueTableViewCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    
    weak var delegate: VoteQueueTableViewCellDelegate?
    var question: Question? {
        didSet {
            updateView()
        }
    }
    var votes = [Vote]()
    
    
    func updateView() {
        guard let question = question else { return }
        guard let recordID = UserController.shared.loggedInUser?.recordID else { return }
        DispatchQueue.main.async {
            if !self.votes.isEmpty {
                for vote in self.votes {
                    if vote.userReference.recordID == recordID {
                        // filled heart
                        self.likeButton.setImage(#imageLiteral(resourceName: "filledHeart"), for: .normal)
                        
                    } else {
                        // empty heart
                        self.likeButton.setImage(#imageLiteral(resourceName: "emptyHeart"), for: .normal)
                    }
                }
            } else {
                
                self.likeButton.setImage(#imageLiteral(resourceName: "emptyHeart"), for: .normal)
                
            }
            
            self.questionLabel.text = question.question
            self.ownerLabel.text = question.questionOwner
            self.voteCountLabel.text = "\(self.votes.count)"
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        delegate?.completeVoteChanged(sender: self)
    
    }
}

protocol VoteQueueTableViewCellDelegate: class {
    func completeVoteChanged(sender: QueueTableViewCell)
}
