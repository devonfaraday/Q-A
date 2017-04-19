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
        
        if cloudKitNotification.subscriptionID == "2D1F5FC7-895C-48D7-B841-0C3C92989334" {
            
            NotificationCenter.default.post(name: TopicController.shared.topicBoolNotificationName, object: nil)
            NSLog("Notification posted: \(TopicController.shared.topicBoolNotificationName)")
            
        }
        if cloudKitNotification.subscriptionID == "CC8302F5-0905-411D-BA6F-87234FAFD63F" || cloudKitNotification.subscriptionID == "8A0DA4BD-9ACB-4D2B-B338-B6338F10E661" {
            
            NotificationCenter.default.post(name: QuestionController.shared.NewQuestionAdded, object: nil)
            NSLog("Notification posted: \(QuestionController.shared.NewQuestionAdded)")
        }
        if cloudKitNotification.subscriptionID == "D6E35C37-F12F-42DD-B945-C45C553B27C1" {

            
                NotificationCenter.default.post(name: UserController.userReadyStateChanged, object: nil)
                NSLog("Notification posted: \(UserController.userReadyStateChanged)")
            
        }
    
        
        NSLog("Notification received")
        completionHandler(.newData)
    }
}

