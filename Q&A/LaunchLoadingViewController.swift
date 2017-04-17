//
//  LaunchLoadingViewController.swift
//  Q&A
//
//  Created by Christian McMullin on 4/11/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class LaunchLoadingViewController: UIViewController {
    
    var cloudKitManager = CloudKitManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudKitManager.fetchCurrentUser { (user) in
            if user != nil {
                UserController.shared.loggedInUser = user
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toProfilePage", sender: self)
                }
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toProfilePage", sender: self)
                }
            }
        }
        
    }
}
