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
//            NotificationCenter.default.addObserver(self, selector: #selector(updateViewsWithNotification), name: UserController.userReadyStateChanged, object: nil)
        }
    }
    
//    func updateViewsWithNotification() {
//        guard let topic = TopicController.shared.currentTopic else { return }
//        TopicController.shared.fetchUsersForTopic(topic: topic) { 
//            DispatchQueue.main.async {
//                self.updateViews()
//            }
//        }
//        
//    }
    
    func updateViews() {
        guard let user = user else { return }
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        if user.readyCheck {
            readyCheckImageView.image = #imageLiteral(resourceName: "GreenButton2x")
        } else {
            readyCheckImageView.image = #imageLiteral(resourceName: "RedButton2x")
        }
    }
    
    // notification observer that will change the image of readyCheckImageView

}
