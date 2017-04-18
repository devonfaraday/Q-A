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
    var holderView = HolderView(frame: CGRect.zero)
    
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
    
    func animateLabel() {
        // 1
        holderView.removeFromSuperview()
        view.backgroundColor = UIColor.blue
        
        // 2
        let label: UILabel = UILabel(frame: view.frame)
        label.textColor = UIColor.white
        label.font = UIFont(name: "cochin", size: 170.0)
        label.textAlignment = NSTextAlignment.center
        label.text = "Q"
        label.transform = label.transform.scaledBy(x: 0.25, y: 0.25)
        view.addSubview(label)
        
        // 3
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseInOut, animations: ({ label.transform = label.transform.scaledBy(x: 4.0, y: 4.0) }), completion: { finished in
        })
    }

}
