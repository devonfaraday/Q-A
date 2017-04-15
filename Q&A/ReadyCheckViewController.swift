//
//  ReadyCheckViewController.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/11/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit
import NotificationCenter

class ReadyCheckViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var readyLabel: UILabel!
    @IBOutlet weak var notReadyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var readyUsers = 0
    var notReadyUsers = TopicController.shared.TopicUsers.count
    
    
    override func viewDidLoad() {
        notReadyLabel.text = "\(notReadyUsers)"
        readyLabel.text = "0"
        NotificationCenter.default.addObserver(self, selector: #selector(performUpdate), name: UserController.userReadyStateChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        users = TopicController.shared.TopicUsers
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "readyCheckCell", for: indexPath) as? ReadyCheckTableViewCell else { return ReadyCheckTableViewCell() }
        let user = users[indexPath.row]
        
        cell.user = user
        
        return cell
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        UserController.shared.setAllUsersReadyCheckToFalse {
        }
        guard let topic = TopicController.shared.currentTopic else { return }
        TopicController.shared.toggleIsReadyCheck(topic: topic) { 
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func performUpdate() {
        guard let topic = TopicController.shared.currentTopic else { return }
        TopicController.shared.fetchUsersForTopic(topic: topic ) {
            self.readyUsers = 0
            self.notReadyUsers = TopicController.shared.TopicUsers.count
            for user in self.users {
                if user.readyCheck {
                    self.readyUsers += 1
                    self.notReadyUsers -= 1
               }
                
                DispatchQueue.main.async {
                    self.users = TopicController.shared.TopicUsers
                    self.readyLabel.text = "\(self.readyUsers)"
                    self.notReadyLabel.text = "\(self.notReadyUsers)"
                    self.tableView.reloadData()
                    self.view.layoutSubviews()
                }
            }
            
        }
    }
    
}
