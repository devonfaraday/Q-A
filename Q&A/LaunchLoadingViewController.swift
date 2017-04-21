//
//  LaunchLoadingViewController.swift
//  Q&A
//
//  Created by Christian McMullin on 4/11/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class LaunchLoadingViewController: UIViewController, HolderViewDelegate {
    
    var cloudKitManager = CloudKitManager()
    var holderView = HolderView(frame: CGRect.zero)
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHolderView()
        cloudKitManager.fetchCurrentUser { (user) in
            DispatchQueue.main.async {
                self.user = user
                self.holtForASec()
            }
        }
    }
    
    func segueToProfile() {
        if user != nil {
            UserController.shared.loggedInUser = user
            if user?.firstName != nil && user?.lastName != nil && user?.profileImage != nil {
    
            self.performSegue(withIdentifier: "toProfilePage", sender: self)
            } else {
                // Show onboarding views
//                self.performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
            }
        } else {
            self.performSegue(withIdentifier: "toProfilePage", sender: self)
        }
    }
    
    func holtForASec() {
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(LaunchLoadingViewController.segueToProfile), userInfo: nil, repeats: false)
    }
    
    func addHolderView() {
        let boxSize: CGFloat = 100.0
        holderView.frame = CGRect(x: view.bounds.width / 2 - boxSize / 2,
                                  y: view.bounds.height / 2 - boxSize / 2,
                                  width: boxSize,
                                  height: boxSize)
        holderView.parentFrame = view.frame
        holderView.delegate = self
        view.addSubview(holderView)
        holderView.expandView()
    }
    
    func animateLabel() {
        holderView.removeFromSuperview()
        view.backgroundColor = UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1)
        let label: UILabel = UILabel(frame: view.frame)
        label.textColor = UIColor.white
        label.font = UIFont(name: "cochin", size: 170.0)
        label.textAlignment = NSTextAlignment.center
        label.text = "Q"
        label.transform = label.transform.scaledBy(x: 0.25, y: 0.25)
        view.addSubview(label)
        UIView.animate(withDuration: 0.9, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveLinear, animations: ({ label.transform = label.transform.scaledBy(x: 4.0, y: 4.0) }), completion: { finished in
        })
    }
}
