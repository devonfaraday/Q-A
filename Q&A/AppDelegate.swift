//
//  AppDelegate.swift
//  Q&A
//
//  Created by Christian McMullin on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error with fetching recordID. \(error.localizedDescription)")
                return
            }
            guard let recordID = recordID else { return }
            UserController.shared.appleUserRecordID = recordID
        }

        
        return true
    }

  

}

