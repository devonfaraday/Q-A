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
    @IBOutlet weak var voteDownButton: UIButton!
    @IBOutlet weak var voteUpButton: UIButton!
    weak var delegate: VoteQueueTableViewCellDelegate?
    var question: Question? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        guard let question = question else {return}
        questionLabel.text = question.question
        ownerLabel.text = question.questionOwner
        voteCountLabel.text = "\(question.vote)"
    }

    @IBAction func voteUpButtonTapped(_ sender: Any) {
        delegate?.completeVoteChanged(sender: self, vote: true)
    }
    
    @IBAction func voteDownButtonTapped(_ sender: Any) {
        delegate?.completeVoteChanged(sender: self, vote: false)
    }
}

protocol VoteQueueTableViewCellDelegate: class {
    func completeVoteChanged(sender: QueueTableViewCell, vote: Bool)
}
