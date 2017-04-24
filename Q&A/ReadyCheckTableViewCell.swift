//
//  ReadyCheckTableViewCell.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/11/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class ReadyCheckTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var readyCheckImageView: UIImageView!
    
    var user: User? {
        didSet {
            updateViews()
            NotificationCenter.default.addObserver(self, selector: #selector(updateViewsWithNotification), name: UserController.userReadyStateChanged, object: nil)
        }
    }
    
    func updateViewsWithNotification() {
        guard let topic = TopicController.shared.currentTopic else { return }
        TopicController.shared.fetchUsersForTopic(topic: topic) {
            
            self.updateViews()
            
        }
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            guard let user = self.user else { return }
            self.nameLabel.text = "\(user.firstName) \(user.lastName)"
            if user.readyCheck{
                self.readyCheckImageView.image = #imageLiteral(resourceName: "GreenButton2x")
            } else {
                self.readyCheckImageView.image = #imageLiteral(resourceName: "RedButton2x")
            }
        }
    }
}
