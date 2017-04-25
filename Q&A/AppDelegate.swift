        //
//  AppDelegate.swift
//  Q&A
//
//  Created by Christian McMullin on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error with fetching recordID. \(error.localizedDescription)")
                return
            }
            guard let recordID = recordID else { return }
            UserController.shared.appleUserRecordID = recordID
        }
        let unc = UNUserNotificationCenter.current()
        unc.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if let error = error {
                NSLog("Error requesting authorization for notifications: \(error)")
                return
            }
        }
        
        
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
        
        if cloudKitNotification.subscriptionID == "Topic" {
            
            NotificationCenter.default.post(name: TopicController.shared.topicBoolNotificationName, object: nil)
            NSLog("Notification posted: \(TopicController.shared.topicBoolNotificationName)")
            
        }
        if cloudKitNotification.subscriptionID == "NewQuestion" || cloudKitNotification.subscriptionID == "QuestionVote" {
            
            NotificationCenter.default.post(name: QuestionController.shared.NewQuestionAdded, object: nil)
            NSLog("Notification posted: \(QuestionController.shared.NewQuestionAdded)")
        }
        
        if cloudKitNotification.subscriptionID == "studentReadyCheck" {

            
                NotificationCenter.default.post(name: UserController.userReadyStateChanged, object: nil)
                NSLog("Notification posted: \(UserController.userReadyStateChanged)")
            
        }
        completionHandler(.newData)
    }
}

