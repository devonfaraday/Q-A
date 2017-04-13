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
    var users = [User]() {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        
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
        dismiss(animated: true, completion: nil)
    }

}
